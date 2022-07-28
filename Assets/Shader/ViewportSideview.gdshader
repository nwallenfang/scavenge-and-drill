shader_type canvas_item;

uniform sampler2D ViewportTexture1;
uniform sampler2D ViewportTexture2;
uniform vec2 screen_size;
uniform vec2 sideview_direction;
uniform float sideview_active : hint_range(0.0, 1.0);
uniform float sideview_visible : hint_range(0.0, 1.0);
uniform float sideview_size : hint_range(0.0, 2000.0);
uniform float sideview_near : hint_range(0.0, 10.0);
uniform float sideview_far : hint_range(0.0, 10.0);
uniform vec4 border_color : hint_color;
uniform float border_width: hint_range(0.0, 40.0);

float invert(float x) {
	return 1.0 - x;
}

void fragment() {
	float sideview_nearfar = mix(sideview_near, sideview_far, pow(sideview_active,2.0));
	vec2 sideview_position = (normalize(sideview_direction) * sideview_nearfar + 1.0) * .5;
	vec2 pixel = vec2(UV.x * screen_size.x, UV.y * screen_size.y);
	vec2 pixel_center = screen_size / 2.0;
	vec2 sideview_pixel = vec2(sideview_position.x * screen_size.x, sideview_position.y * screen_size.y);
	float sideview_dist = distance(pixel, sideview_pixel);
	vec3 view1 = texture(ViewportTexture1, vec2(UV.x, 1.0-UV.y)).xyz;
	vec2 uv_sideview = vec2(.5,.5) + vec2(UV.x, UV.y) - mix(sideview_position, vec2(.5), sideview_active);
	vec3 view2 = texture(ViewportTexture2, vec2(uv_sideview.x, 1.0 - uv_sideview.y)).xyz;
	//vec3 col = mix(border_color.rgb, view1, sideview_active);
	float sideview_size_mixed = mix(sideview_size, distance(sideview_pixel, pixel_center), sideview_active);
	
	vec3 col = view1 * pow((smoothstep(sideview_size_mixed, sideview_size_mixed + border_width,sideview_dist)), .5) + view2 * smoothstep(sideview_size_mixed, sideview_size_mixed - .25 * border_width,sideview_dist);
	col = mix(col, view1, sideview_visible);
	//col = view1 * pow((smoothstep(sideview_size, sideview_size + border_width,sideview_dist)), .5) + view2 * smoothstep(sideview_size, sideview_size - .25 * border_width,sideview_dist);
	
	// CENTER POINTS for DEBUGGING
	//col = view1;
	//col = col * float(distance(UV, vec2(.5,.5)) > .03) + border_color.rgb * float(distance(UV, vec2(.5,.5)) <= .02);
	//col = col * float(distance(UV, vec2(.5,.5)) > .01);
	COLOR.xyz = col;
	//COLOR.xyz = border_color.rgb;
}