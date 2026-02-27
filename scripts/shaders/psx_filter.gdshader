shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_nearest;
uniform float pixel_size: hint_range(1.0, 8.0) = 2.0;
uniform float color_depth: hint_range(8.0, 64.0) = 32.0;
uniform float scanline_intensity: hint_range(0.0, 0.5) = 0.08;
uniform float scanline_count: hint_range(50.0, 300.0) = 80.0;
uniform float dither_strength: hint_range(0.0, 0.5) = 0.04;
uniform float aberration: hint_range(0.0, 0.01) = 0.002;
uniform vec2 screen_size = vec2(1280.0, 720.0);

vec3 reduce_colors(vec3 color, float depth) {
	return floor(color * depth) / depth;
}

float dither(vec2 uv) {
	return fract(sin(dot(uv, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;

	// pixelação correta
	vec2 snapped = floor(uv * screen_size / pixel_size) * pixel_size / screen_size;

	// aberração cromática
	float r = texture(screen_texture, snapped + vec2(aberration, 0.0)).r;
	float g = texture(screen_texture, snapped).g;
	float b = texture(screen_texture, snapped - vec2(aberration, 0.0)).b;
	vec3 color = vec3(r, g, b);

	// redução de cores
	color = reduce_colors(color, color_depth);

	// dithering
	color += (dither(uv) - 0.5) * dither_strength;

	// scanlines animadas
	float scan = sin(uv.y * scanline_count * PI + TIME * 2.0) * 0.5 + 0.5;
	color *= 1.0 - scan * scanline_intensity;

	COLOR = vec4(color, 1.0);
}