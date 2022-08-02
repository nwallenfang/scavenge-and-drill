shader_type spatial;
//render_mode unshaded;

uniform sampler2D bubble_noise : hint_albedo;
uniform float bubble_noise_scale;
uniform float bubble_time_scale;
uniform float bubble_strength;
uniform vec4 albedo : hint_color;

void vertex() {
	float height = bubble_strength * texture(bubble_noise, bubble_noise_scale * VERTEX.xy + bubble_time_scale * vec2(0.0,TIME)).r;
	VERTEX += NORMAL * height;
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	ALBEDO = albedo.rgb;
	ROUGHNESS = .05;
	ALPHA = min(1.0, .05 + fresnel(2.0, NORMAL, VIEW)) * albedo.a;
}
