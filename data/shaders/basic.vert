#version 300 es

//uniform mat3 u_proj;
layout(location = 0) in vec2 a_pos;
layout(location = 1) in vec4 a_col;

out vec4 v_col;

void main() {
	float scalar = float(gl_InstanceID) * 2.f - 1.f;
	gl_Position = vec4(a_pos, 0.0, 0.0) * scalar + vec4(0, 0, 0, 1);
	v_col = a_col;
}