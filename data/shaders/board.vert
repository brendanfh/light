#version 300 es

layout(location = 0) in vec2 a_pos;
layout(location = 1) in vec4 a_col;

uniform mat3 u_proj;
uniform int board_width;
uniform int board_height;

out vec4 v_col;

void main() {
    vec2 offset = vec2(gl_InstanceID % board_width, gl_InstanceID / board_width);
    gl_Position = vec4(u_proj * vec3(a_pos + offset, 1), 1);
    v_col = a_col;
}