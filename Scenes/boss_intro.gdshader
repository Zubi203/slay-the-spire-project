shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 adjusted_center = vec2(mix(0.5, UV.x, ratio), UV.y);
	float circle = distance(vec2(0.5), adjusted_center);
	COLOR.a = step(1.5 - progress * 1.5, circle);
}
