shader_type canvas_item;

uniform float close_progress : hint_range(0.0, 1.0) = 0.0;
uniform float open_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 fill_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    float diagonal = (UV.x + UV.y) * 0.5;
    if (diagonal > close_progress) {
        discard; 
    } else {
        COLOR = fill_color; 
    }
	if (diagonal < open_progress) {
        discard; 
    } else {
        COLOR = fill_color; 
    }
	
}
