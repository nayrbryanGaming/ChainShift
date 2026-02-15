shader_type canvas_item;

// ==============================================================================
// CHAINSHIFT - NUCLEAR BUILD :: GOLD MASTER
// ==============================================================================
// Pure procedural world rendered via Raymarching.
// No external assets. 4K compliant. Resolution independent.
// ==============================================================================

// MANDATORY GLOBAL STATE UNIFORMS
uniform float u_entropy;      // Chaos factor
uniform float u_phase;        // Evolution time/angle
uniform float u_distortion;   // Spatial warping
uniform vec3  u_color_seed;   // Base color palette
uniform float u_time;         // Engine time
uniform float u_impulse;      // Interaction feedback (0.0 to 1.0)

// CONSTANTS
const int MAX_STEPS = 128;
const float MAX_DIST = 100.0;
const float SURF_DIST = 0.001;

// ==============================================================================
// MATH & SDF PRIMITIVES
// ==============================================================================

mat2 rot(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(vec2(c, -s), vec2(s, c));
}

// Deterministic Noise
float noise(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 45.164))) * 43758.5453);
}

// Signed Distance Function: Abstract Fractal Structure
float map(vec3 p) {
    vec3 q = p;
    
    // 1. Domain Repetition (Infinite World)
    vec3 id = floor((p + 2.0) / 4.0);
    p = mod(p + 2.0, 4.0) - 2.0;
    
    // 2. Phase Rotation
    p.xz *= rot(u_phase * 0.5 + id.x * 0.1);
    p.xy *= rot(u_time * 0.1);
    
    // 3. Distortion (Entropy-driven)
    float d1 = length(p) - 1.0; // Base Sphere
    
    // Impulse Warp (Phase 2 Add)
    p += sin(p.y * 10.0 + u_time * 5.0) * 0.1 * u_impulse;

    // Fractal-like folding
    float amp = 0.5;
    for(int i = 0; i < 3; i++) {
        p = abs(p) - 0.5 * u_entropy;
        p.xz *= rot(u_distortion + float(i));
        d1 = min(d1, length(p) - 0.2 * amp);
        amp *= 0.5;
    }
    
    // Smooth blending
    float d2 = length(q + vec3(sin(u_time), cos(u_time), 0.0)) - 0.5;
    float k = 0.5;
    float d = mix(d2, d1, clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0)) - k * 0.5;
    
    return d;
}

// ==============================================================================
// RAYMARCHING ENGINE
// ==============================================================================

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

// ==============================================================================
// FRAGMENT SHADER
// ==============================================================================

void fragment() {
    // Resolution Independence via UV Correction
    vec2 uv = (UV * 2.0 - 1.0);
    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
    uv.x *= resolution.x / resolution.y;
    
    // Impulse: Chromatic Aberration Offset
    float aber = u_impulse * 0.05;
    
    // Camera Setup (Phase 6 Super Polish: Breathing Camera)
    vec3 ro = vec3(
        sin(u_time * 0.1) * 0.5, 
        cos(u_time * 0.13) * 0.5, 
        -3.0 + u_distortion + sin(u_time * 0.05) * 0.2
    );
    
    vec3 target = vec3(0.0, 0.0, 0.0);
    vec3 fwd = normalize(target - ro);
    vec3 right = normalize(cross(vec3(0, 1, 0), fwd));
    vec3 up = cross(fwd, right);
    
    // Ray Directions for RGB channels (Simple chromatic aberration)
    vec3 rdG = normalize(fwd + uv.x * right + uv.y * up);
    vec3 rdR = normalize(fwd + (uv.x + aber) * right + uv.y * up);
    vec3 rdB = normalize(fwd + (uv.x - aber) * right + uv.y * up);
    
    // Raymarch Main (Green/Center)
    float d = raymarch(ro, rdG);
    
    vec3 col = vec3(0.0);
    
    if(d < MAX_DIST) {
        vec3 p = ro + rdG * d;
        vec3 n = getNormal(p);
        
        // Simple Lighting
        vec3 lightPos = vec3(2.0, 2.0, -2.0);
        vec3 l = normalize(lightPos - p);
        float dif = clamp(dot(n, l), 0.0, 1.0);
        
        // Rim Lighting (Phase 5 Polish)
        float rim = 1.0 - max(dot(n, -rdG), 0.0);
        rim = smoothstep(0.6, 1.0, rim);
        
        vec3 baseColor = u_color_seed + 0.2 * cos(vec3(0,2,4) + u_phase);
        col = baseColor * dif;
        col += vec3(0.1); 
        col += baseColor * rim * 0.5; // Add Rim Term
        
        // Cheap Aberration coloring overlay if impulse is high
        if (u_impulse > 0.01) {
            col.r += 0.5 * u_impulse; 
            col.b += 0.5 * u_impulse;
        }
    }
    
    // Post-Processing (Phase 5 Polish)
    // 1. Vignette
    float len = length(uv);
    col *= smoothstep(1.5, 0.5, len);
    
    // 2. Film Grain
    float grain = noise(vec3(uv * 10.0, u_time * 10.0));
    col += (grain - 0.5) * 0.05;
    
    COLOR = vec4(col, 1.0);
}
