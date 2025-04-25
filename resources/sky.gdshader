shader_type canvas_item;

uniform vec4 color_start : source_color;
uniform vec4 color_end : source_color;
uniform int nb_steps = 3;

void fragment() {
	float one_step = 1.0 / float(nb_steps);
 	float gradient = floor(UV.y / one_step) * one_step;

    COLOR = mix(color_start, color_end, gradient);
}
