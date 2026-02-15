shader_type canvas_item;

// ==============================================================================
// CHAINSHIFT - NUCLEAR BUILD :: PHASE 1 FOUNDATION
// ==============================================================================
// Pure procedural world rendered via Raymarching.
// No external assets. 4K compliant. 60 FPS target.
// ==============================================================================

uniform float u_entropy;      // Chaos factor
uniform float u_phase;        // Evolution angle
uniform float u_distortion;   // Spatial warping
uniform vec3  u_color_seed;   // Base color palette
uniform float u_time;         // Engine time

// CONSTANTS
const int MAX_STEPS = 128;
const float MAX_DIST = 100.0;
const float SURF_DIST = 0.001;

mat2 rot(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(vec2(c, -s), vec2(s, c));
}

// Deterministic Noise for Film Grain/Detail
float noise(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

// Phase 1 SDF: Mathematical Core
float map(vec3 p) {
    vec3 q = p;
    
    // Domain Repetition
    p = mod(p + 4.0, 8.0) - 4.0;
    
    // Rotations
    p.xz *= rot(u_phase + u_time * 0.1);
    p.xy *= rot(u_phase * 0.5);
    
    // Fractal Folding (Symmetry and Complexity)
    float d = length(p) - 1.2;
    float scale = 1.0;
    
    for(int i = 0; i < 4; i++) {
        p = abs(p) - 0.5 * u_entropy;
        p.xz *= rot(u_distortion + float(i) * 0.5);
        float d_i = (length(p) - 0.3 * scale) / scale;
        d = min(d, d_i);
        scale *= 0.8;
    }
    
    // Global warping
    d += sin(q.x * u_distortion + u_time) * 0.05;
    
    return d;
}

float raymarch(vec3 ro, vec3 rd) {
    float dO = 0.0;
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        float dS = map(p);
        dO += dS;
        if(dO > MAX_DIST || abs(dS) < SURF_DIST) break;
    }
    return dO;
}

vec3 getNormal(vec3 p) {
    float d = map(p);
    vec2 e = vec2(0.01, 0.0);
    vec3 n = d - vec3(
        map(p - e.xyy),
        map(p - e.yxy),
        map(p - e.yyx)
    );
    return normalize(n);
}

void fragment() {
    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 uv = (FRAGCOORD.xy * 2.0 - resolution) / min(resolution.x, resolution.y);
    
    // Camera
    vec3 ro = vec3(0, 0, -5);
    vec3 rd = normalize(vec3(uv, 1.5));
    
    // Adaptive Step Early Exit
    float d = raymarch(ro, rd);
    
    vec3 col = vec3(0.0);
    
    if(d < MAX_DIST) {
        vec3 p = ro + rd * d;
        vec3 n = getNormal(p);
        vec3 light = normalize(vec3(1, 2, -3));
        
        float diff = clamp(dot(n, light), 0.0, 1.0);
        float amb = 0.1;
        float spec = pow(clamp(dot(reflect(-light, n), -rd), 0.0, 1.0), 32.0);
        
        vec3 base = u_color_seed + 0.3 * cos(u_phase + vec3(0, 2, 4));
        col = base * diff + amb + spec * 0.5;
        
        // Fog
        col = mix(col, vec3(0), 1.0 - exp(-0.02 * d * d));
    }
    
    // Final Polish
    col *= 1.2; // Exposure
    col = pow(col, vec3(0.4545)); // Gamma correction
    
    // Film Grain
    float grain = noise(vec3(uv * 10.0, u_time));
    col += (grain - 0.5) * 0.04;
    
    COLOR = vec4(col, 1.0);
}

