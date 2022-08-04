shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D texture_resource;
uniform vec4 fill_color: hint_color;
uniform vec4 empty_color: hint_color;
uniform bool enabled;

void fragment(){
	COLOR = texture(texture_resource, UV) * vec4(float(enabled)) * fill_color
			+ vec4(1.0 - float(enabled)) * texture(texture_resource, UV) * empty_color;
}