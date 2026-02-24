shader_type canvas_item;

uniform vec4 window_rects[8];
uniform int window_count = 0;

void fragment() {
	vec2 pos = FRAGCOORD.xy;
	for (int i = 0; i < window_count; i++) {
		vec4 r = window_rects[i];
		if (pos.x >= r.x && pos.x <= r.x + r.z &&
			pos.y >= r.y && pos.y <= r.y + r.w) {
			discard;
		}
	}
	COLOR = texture(TEXTURE, UV);
}
