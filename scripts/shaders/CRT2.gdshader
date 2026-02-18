shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color, filter_linear;

uniform float curvature : hint_range(0.0, 0.3) = 0.06;
uniform float chroma_offset : hint_range(0.0, 0.01) = 0.0015;
uniform float mask_strength : hint_range(0.0, 1.0) = 0.5;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;

uniform float power_on : hint_range(0.0, 1.0) = 0.0;


// Curvatura CRT
vec2 warp(vec2 uv) {
    vec2 c = uv - 0.5;
    float dist = dot(c, c);
    c *= 1.0 + dist * curvature;
    return c + 0.5;
}


// Máscara RGB estilo dots
vec3 rgb_mask(vec2 fragcoord) {
    float pattern = mod(floor(fragcoord.x), 3.0);

    if (pattern < 1.0) return vec3(1.0, 0.2, 0.2);
    else if (pattern < 2.0) return vec3(0.2, 1.0, 0.2);
    else return vec3(0.2, 0.2, 1.0);
}


void fragment() {

    vec2 uv = warp(UV);

    float inside = step(0.0, uv.x) * step(uv.x, 1.0) *
                   step(0.0, uv.y) * step(uv.y, 1.0);

    float offset = chroma_offset;

    float r = texture(tex, uv + vec2(offset, 0.0)).r;
    float g = texture(tex, uv).g;
    float b = texture(tex, uv - vec2(offset, 0.0)).b;

    vec3 color = vec3(r, g, b);

    // CRT mask
    vec3 mask = rgb_mask(FRAGCOORD.xy);
    color *= mix(vec3(1.0), mask, mask_strength);

    // Vignette
    vec2 center = uv - 0.5;
    float vignette = 1.0 - dot(center, center) * vignette_strength;
    color *= vignette;

    color *= inside;

    // =============================
    // BOOT LIMPO
    // =============================

     float t = power_on;

    // Fade global real
    float fade = smoothstep(0.02, 0.6, t);

    // Flash central elegante (ativo só durante boot)
    float flash_strength = exp(-t * 10.0) * step(0.001, t);

    float radial = 1.0 - length(uv - 0.5) * 2.0;
    radial = clamp(radial, 0.0, 1.0);

    vec3 flash_color = vec3(1.0) * flash_strength * radial * 1.2;

    // Pequeno overshoot temporário
    float overshoot = 1.0 + exp(-t * 6.0) * 0.3;

    color *= fade;
    color *= overshoot;
    color += flash_color;

    // Se ainda não ligou, força preto absoluto
    float is_on = step(0.001, t);
    color *= is_on;

    ALBEDO = color;
    ALPHA = 1.0;
}
