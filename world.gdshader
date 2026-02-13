shader_type canvas_item;

// --- Uniforms (Global State) ---
uniform float u_entropy : hint_range(0.0, 1.0) = 0.5;
uniform float u_phase : hint_range(0.0, 10.0) = 1.0;
uniform float u_distortion : hint_range(0.0, 1.0) = 0.2;
uniform float u_shift_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec3 u_color_seed = vec3(0.2, 0.5, 0.8);
uniform float u_time;

// --- Constants ---
const int MAX_STEPS = 128;
const float MAX_DIST = 100.0;
const float SURF_DIST = 0.001;

// --- Helper Functions ---
mat2 rot2D(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(vec2(c, -s), vec2(s, c));
}

float sdSphere(vec3 p, float s) {
    return length(p) - s;
}

float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

// Smooth union from Inigo Quilez
float opSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

// --- World Map (SDF with Recursive Folds) ---
float map(vec3 p) {
    // Dynamic coordinate warping
    p.xz *= rot2D(u_time * 0.1 * u_phase);
    p.xy *= rot2D(u_time * 0.05 + u_entropy);
    
    // Fractal Folding (Bounded Recursive Detail)
    for (int i = 0; i < 3; i++) {
        p = abs(p) - 0.5 - 0.2 * u_distortion;
        p.xz *= rot2D(u_entropy * 2.0);
        p.yz *= rot2D(u_phase * 0.5);
    }
    
    // Base shape (Central Core)
    float core = sdSphere(p, 1.0 + 0.1 * sin(u_time + u_entropy * 5.0));
    
    // Distortion warping
    float noise = sin(p.x * 10.0 + u_time) * sin(p.y * 10.0 + u_time) * sin(p.z * 10.0 + u_time);
    core += noise * u_distortion * 0.2;
    
    // Repetitive fractal structure
    vec3 p3 = p;
    float spacing = 5.0 + u_entropy * 2.0;
    vec3 id = floor((p3 + spacing * 0.5) / spacing);
    
    float d = core;
    if (length(id) < 2.0) {
        p3 = mod(p3 + spacing * 0.5, spacing) - spacing * 0.5;
        float fractal = sdBox(p3, vec3(0.2 + 0.1 * sin(u_time * u_phase)));
        d = opSmoothUnion(d, fractal, 0.5);
    }
    
    return d;
}

// --- Raymarching (Robust) ---
float rayMarch(vec3 ro, vec3 rd) {
    float dO = 0.0;
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * dO;
        float dS = map(p);
        dO += dS * 0.85; 
        if (dO > MAX_DIST) return MAX_DIST;
        // Adaptive epsilon (scaling with distance for 4K stability)
        if (abs(dS) < 0.0004 + dO * 0.0001) break;
    }
    return dO;
}

// --- Normal Calculation (Precision) ---
vec3 getNormal(vec3 p) {
    float e = 0.0005;
    vec3 n = vec3(
        map(p + vec3(e, 0, 0)) - map(p - vec3(e, 0, 0)),
        map(p + vec3(0, e, 0)) - map(p - vec3(0, e, 0)),
        map(p + vec3(0, 0, e)) - map(p - vec3(0, 0, e))
    );
    float l = length(n);
    return l > 1e-6 ? n / l : vec3(0, 1, 0); 
}

void fragment() {
    vec2 uv = (UV - 0.5) * 2.0;
    float aspect = (1.0 / SCREEN_PIXEL_SIZE.x) / (1.0 / SCREEN_PIXEL_SIZE.y);
    uv.x *= aspect;
    
    // Camera jitter based on shift intensity
    vec3 ro = vec3(0, 0, -6.0 + 0.1 * u_shift_intensity * sin(u_time * 60.0));
    vec3 col = vec3(0.0);
    
    float d_g = rayMarch(ro, normalize(vec3(uv, 1.2)));
    
    if (u_shift_intensity > 0.01) {
        float offset = u_shift_intensity * 0.04;
        float d_r = rayMarch(ro, normalize(vec3(uv + vec2(offset, 0), 1.2)));
        float d_b = rayMarch(ro, normalize(vec3(uv - vec2(offset, 0), 1.2)));
        
        if (d_r < MAX_DIST) col.r = clamp(dot(getNormal(ro + normalize(vec3(uv + vec2(offset, 0), 1.2)) * d_r), normalize(vec3(2, 5, -3))), 0.1, 1.0) * u_color_seed.r;
        if (d_g < MAX_DIST) col.g = clamp(dot(getNormal(ro + normalize(vec3(uv, 1.2)) * d_g), normalize(vec3(2, 5, -3))), 0.1, 1.0) * u_color_seed.g;
        if (d_b < MAX_DIST) col.b = clamp(dot(getNormal(ro + normalize(vec3(uv - vec2(offset, 0), 1.2)) * d_b), normalize(vec3(2, 5, -3))), 0.1, 1.0) * u_color_seed.b;
    } else {
        if (d_g < MAX_DIST) {
            vec3 p = ro + normalize(vec3(uv, 1.2)) * d_g;
            vec3 n = getNormal(p);
            vec3 l = normalize(vec3(2, 5, -4));
            float diff = clamp(dot(n, l), 0.1, 1.0);
            float spec = pow(clamp(dot(reflect(-l, n), -normalize(vec3(uv, 1.2))), 0.0, 1.0), 40.0);
            float fres = pow(1.0 - clamp(dot(n, -normalize(vec3(uv, 1.2))), 0.0, 1.0), 4.0);
            col = u_color_seed * diff + vec3(spec * 0.6) + u_color_seed * fres * 0.4;
        }
    }
    
    // Environment & Fog
    if (max(col.r, max(col.g, col.b)) < 0.001) {
        col = vec3(0.01, 0.02, 0.04) * (1.0 - length(uv) * 0.6);
    } else {
        float fog = 1.0 / (1.0 + d_g * d_g * 0.015);
        col = mix(vec3(0.01, 0.02, 0.05), col, fog);
    }
    
    // Grid & Shimmer Detail
    float grid = pow(abs(sin(uv.x * 25.0) * sin(uv.y * 25.0)), 0.1);
    col = mix(col, col * 1.1, (1.0 - grid) * 0.1);
    col += u_shift_intensity * 0.15 * sin(uv.y * 150.0 + u_time * 25.0);
    
    COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
}
