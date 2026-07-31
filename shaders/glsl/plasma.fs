#version 330

uniform float iTime;
uniform vec2 iResolution;

out vec4 finalColor;

void main() {
    vec2 xy = gl_FragCoord.xy;
    float t = iTime;

    float v1 = sin(xy.x * 0.02 + t);
    float v2 = sin(xy.y * 0.02 + t * 0.7);
    float v3 = sin((xy.x + xy.y) * 0.015 + t * 1.3);
    float v4 = sin(length(xy) * 0.02 - t);

    float v = (v1 + v2 + v3 + v4) / 4.0;

    float r = (sin(v * 3.14159) + 1.0) * 0.5;
    float g = (sin(v * 3.14159 + 2.0) + 1.0) * 0.5;
    float b = (sin(v * 3.14159 + 4.0) + 1.0) * 0.5;

    finalColor = vec4(r, g, b, 1.0);
}