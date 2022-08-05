shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D texture_resource;
uniform vec4 fill_color: hint_color;
uniform vec4 empty_color: hint_color;
uniform bool enabled;

void fragment(){
	vec4 tex = texture(texture_resource, UV);
	COLOR = tex * fill_color;
}