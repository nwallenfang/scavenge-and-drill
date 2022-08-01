// NOTE: Shader automatically converted from Godot Engine 3.5.rc8's SpatialMaterial.

shader_type spatial;
render_mode async_visible,blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform vec2 push_direction;
uniform float push_strength : hint_range(0.0, 1.0);

const float y_min = -.2;
const float y_max = 2.4;
const float wiggle_transition = .4;
const float wiggle_bias = .3;
const float wiggle_factor = .1;
const float wiggle_speed = 3.0;
const float wiggle_freq = 20.0;
const float wiggle_z = 4.9;
const float push_curve = .8;
const float push_factor = .5;
const float y_scale = .7;

float clamp_and_map(float value, float istart, float istop, float ostart, float ostop) {
    value = clamp(value, istart, istop);
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	
	// world direction_to_local_direction
	vec2 world_position = (inverse(WORLD_MATRIX) * vec4(0.0, 0.0, 0.0, 1.0)).xz;
	vec2 direction = (inverse(WORLD_MATRIX) * vec4(push_direction.x, 0.0, push_direction.y, 1.0)).xz - world_position;
	direction = direction + float(length(direction) <= 0.001) * vec2(1.0, 0.0); // very very cringe that this is necesarry
	direction = normalize(direction);
	float y = clamp_and_map(VERTEX.y, y_min, y_max, 0.0, 1.0);

	float y_for_push = y * float(y < push_strength) + push_strength * float(y >= push_strength);
	
	VERTEX.x = VERTEX.x + push_factor * direction.x * pow(y_for_push, push_curve);
	VERTEX.z = VERTEX.z + push_factor * direction.y * pow(y_for_push, push_curve);
	
	float wiggle_strength = smoothstep(push_strength -wiggle_transition - wiggle_bias, push_strength + wiggle_transition - wiggle_bias, y);
	float reduce_wiggle_on_top = pow(clamp_and_map(y, .7, 1.0, 1.0, .3), 2.0);
	float reduce_wiggle_on_bot = pow(clamp_and_map(y, 0.0, .18, 0.0, 1.), 2.0);
	VERTEX.x = VERTEX.x + wiggle_factor * wiggle_strength * reduce_wiggle_on_bot * reduce_wiggle_on_top * sin(-wiggle_speed* TIME + wiggle_freq * y + wiggle_z * VERTEX.z);
	
	float y_scaled = VERTEX.y * clamp_and_map(1.0 - pow(push_strength, 2.0), 0.0, 1.0, y_scale, 1.0);
	VERTEX.y = y_scaled;
}


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
}
