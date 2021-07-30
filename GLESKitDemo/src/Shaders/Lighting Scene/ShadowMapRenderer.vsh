#version 300 es

layout (location = 0) in vec4 a_position;
layout (location = 1) in vec2 a_occludersTexCoord;

out vec2 v_occludersTexCoord;

void main()
{
    v_occludersTexCoord = a_occludersTexCoord;
    gl_Position = a_position;
}

