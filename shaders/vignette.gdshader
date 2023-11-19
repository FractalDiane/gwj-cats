//Vignette Shader

//see more info about shaders here --> https://github.com/TechnoLukas/My-favourite-shaders-links
//ported with https://github.com/jayaarrgh/shadertoy2godot (with some hand fixing)
//on shadertoy https://www.shadertoy.com/view/WsGSD3

shader_type spatial;
uniform vec2 size;

void fragment() {
	
	vec2 uv=UV;
	vec2 suv = abs(uv * 2.0 - 1.0);
	vec2 u = smoothstep(vec2(0), size, 1.0 - suv);
    
	ALBEDO = vec3(0.0, 0.0, 0.0);
	ALPHA = 1.0 - u.x * u.y;
}