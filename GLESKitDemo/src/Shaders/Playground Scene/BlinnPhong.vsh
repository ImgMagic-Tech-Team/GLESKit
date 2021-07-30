#version 300 es

layout (location = 0) in vec4 a_position;
layout (location = 1) in vec3 a_texCoords;
layout (location = 2) in vec3 a_normal;

out vec4 v_color;

void main() {
    v_color = vec4(0.7, 0.4, 0.9, 1.0);
    gl_Position = a_position;
}
