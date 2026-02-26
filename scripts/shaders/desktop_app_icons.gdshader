shader_type canvas_item;

uniform vec4 lens_rect = vec4(0.0, 0.0, 0.0, 0.0); // x, y, w, h em pixels de tela
uniform bool use_lens_clip = false;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	if (use_lens_clip) {
		vec2 screen_pos = FRAGCOORD.xy;
		float left   = lens_rect.x;
		float top    = lens_rect.y;
		float right  = lens_rect.x + lens_rect.z;
		float bottom = lens_rect.y + lens_rect.w;

		if (screen_pos.x < left || screen_pos.x > right ||
			screen_pos.y < top  || screen_pos.y > bottom) {
			discard;
		}
	}

	COLOR = tex;
}
