shader_type canvas_item;

uniform float progress_red: hint_range(0.0, 1.0) = 0.0;
uniform float progress_green: hint_range(0.0, 1.0) = 0.0;
uniform float progress_blue: hint_range(0.0, 1.0) = 0.0;
uniform float progress_yellow: hint_range(0.0, 1.0) = 0.0;
uniform float progress_orange: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0, 0.0, 0.0), progress_red);
	COLOR.rgb = mix(COLOR.rgb, vec3(0.3, 1.0, 0.0), progress_green);
	COLOR.rgb = mix(COLOR.rgb, vec3(0.3, 0.3, 1.0), progress_blue);
	COLOR.rgb = mix(COLOR.rgb, vec3(0.851, 0.333, 0.094), progress_orange);
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0, 0.976, 0.29), progress_yellow);
	
}