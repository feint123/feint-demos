shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.5, 0.5);
uniform float alpha = 0.5;

void fragment() {
	COLOR = texture(TEXTURE, UV + scroll_speed * TIME);
	COLOR.a = alpha;
}
