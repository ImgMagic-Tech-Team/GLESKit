#version 300 es

//precision highp float;

in highp vec4 v_color;
out highp vec4 o_fragColor;

void main() {
    o_fragColor = v_color;
}
