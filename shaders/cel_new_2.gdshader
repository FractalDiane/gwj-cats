/*
-------------------------------------
Godot 3.2 Cel Shader v2.0.0
Modified by Diane Sparks
-------------------------------------
Copyright (c) 2017 David E Lipps

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"),to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,and/or sell copies of the Software, and
to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

shader_type spatial;
render_mode ambient_light_disabled;

uniform vec4 base_color : source_color = vec4(1.0);
uniform vec4 shade_color : source_color = vec4(1.0);
uniform float shade_threshold : hint_range(-1.0, 1.0) = 0.0;
uniform float shade_softness : hint_range(0.0, 1.0) = 0.01;
uniform float shadow_threshold : hint_range(0.0, 1.0) = 0.7;
uniform float shadow_softness : hint_range(0.0, 1.0) = 0.01;
uniform sampler2D base_texture;
uniform sampler2D shade_texture;

uniform sampler2D emission_map;
uniform vec4 emission_color : source_color = vec4(0.0);

uniform bool additive_color = false;
uniform float additive_intensity : hint_range(0.0, 1.0) = 0.005;

uniform vec2 uv_offset = vec2(0.0);
uniform float uv_rotation = 0.0;
uniform float uv_rotation_mid : hint_range(0.0, 1.0) = 0.5f;
uniform vec2 uv_scale = vec2(1.0);


vec3 fresnel_glow(float amount, float intensity, vec3 color, vec3 normal, vec3 view) {
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * color * intensity;
}


vec2 rotate_uv(vec2 uv, float rotation, float mid) {
    return vec2(
      cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
      cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid
    );
}

vec2 final_uv(vec2 uv) {
	return rotate_uv(uv, uv_rotation, uv_rotation_mid) * uv_scale + uv_offset;
}


void light() {
	float NdotL = dot(NORMAL, LIGHT);
	float is_lit = step(shade_threshold, NdotL);
	vec3 base = texture(base_texture, final_uv(UV)).rgb;
	vec3 shade = texture(base_texture, final_uv(UV)).rgb;
	
	base *= max(vec3(float(additive_color)), base_color.rgb);
	shade *= max(vec3(float(additive_color)), shade_color.rgb);
	
	float shade_value = smoothstep(shade_threshold - shade_softness, shade_threshold + shade_softness, NdotL);	
	vec3 shadow_value = vec3(smoothstep(shadow_threshold - shadow_softness, shadow_threshold + shadow_softness,  ATTENUATION));
	
	shade_value = min(shade_value, shadow_value.x);
	vec3 diffuse = mix(shade, base, shade_value * ATTENUATION);

	DIFFUSE_LIGHT += diffuse * LIGHT_COLOR;
	//DIFFUSE_LIGHT += diffuse * ATTENUATION;
	//DIFFUSE_LIGHT += mix(DIFFUSE_LIGHT, DIFFUSE_LIGHT * LIGHT_COLOR, ATTENUATION);
}

void fragment() {
	vec4 emission_tex = texture(emission_map, final_uv(UV));
	vec4 base_tex = texture(base_texture, final_uv(UV));
	//ALBEDO = shade_color.rgb;
	EMISSION = emission_tex.rgb * emission_color.rgb * base_tex.rgb;
	//EMISSION += fresnel_glow(10.0, 0.2, vec3(0.0, 0.8, 0.6), NORMAL, VIEW);
}
