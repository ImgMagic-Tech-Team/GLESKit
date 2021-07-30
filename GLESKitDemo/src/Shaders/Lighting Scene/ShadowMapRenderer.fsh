#version 300 es

precision highp float;
precision highp sampler2DArray;

uniform sampler2DArray u_occlusionMaps;
uniform float u_occlusionMapsCount;
uniform float u_shadowMapSize;

in vec2 v_occludersTexCoord;
out vec4 o_fragColor;

const float Treshold = 0.75;
const float PI = 3.1415;

void main()
{
    float distance = 1.0;
    
    float normX = v_occludersTexCoord.s * 2.0 - 1.0;
    float theta = PI * 1.5 + normX * PI;
    
    for (float y = 0.0; y < u_shadowMapSize; y += 1.0) {
        //the current distance is how far from the top we've come
        float dst = y / u_shadowMapSize;
        
        //rectangular to polar
        float normY = dst * 2.0 - 1.0;
        
        float r = (1.0 + normY) * 0.5;
        
        //coord which we will sample from occlude map
        vec2 coord = vec2(-r * sin(theta), -r * cos(theta)) / 2.0 + 0.5;
        
        //sample the occlusion map
        float occlusionMapLayer = roundEven(v_occludersTexCoord.t * (u_occlusionMapsCount - 1.0));
        vec4 data = texture(u_occlusionMaps, vec3(coord, occlusionMapLayer));
        
        //if we've hit an opaque fragment (occluder), then get new distance
        //if the new distance is below the current, then we'll use that for our ray
        float caster = data.a;
        
        if (caster > Treshold) {
            distance = min(distance, dst);
        }
    }
    
    o_fragColor = vec4(vec3(distance), 1.0);
}
