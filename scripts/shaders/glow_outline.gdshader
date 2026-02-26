shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.3, 1.0);
uniform float glow_size : hint_range(0.0, 20.0) = 4.0;
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.2;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;

void fragment() {
	vec4 original = texture(TEXTURE, UV);

	float outline = 0.0;
	vec2 texel = TEXTURE_PIXEL_SIZE;

	for (float x = -glow_size; x <= glow_size; x++) {
		for (float y = -glow_size; y <= glow_size; y++) {
			float dist = length(vec2(x, y));
			if (dist <= glow_size) {
				float neighbor = texture(TEXTURE, UV + vec2(x, y) * texel).a;
				outline = max(outline, neighbor * (1.0 - dist / glow_size));
			}
		}
	}

	float pulse = (sin(TIME * pulse_speed) * 0.4 + 0.6);
	outline *= (1.0 - original.a);

	vec4 glow = glow_color * outline * glow_intensity * pulse;
	COLOR = original + glow;
}