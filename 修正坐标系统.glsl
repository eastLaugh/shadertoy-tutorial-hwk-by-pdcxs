const vec3 yaxiscolor = vec3(0.88, 0.06, 0.06);
const vec3 xaxiscolor = vec3(0.04, 1.0, 0.0);
vec3 Grid(in vec2 uv, float ywidth) {
    vec3 color = vec3(0);
    vec2 cell = 1. - 2. * abs(fract(uv) - .5);

    // step(a,b) == a<=b
    color += vec3(step(cell.x, ywidth * fwidth(uv.x)));
    color += vec3(step(cell.y, fwidth(uv.y)));
    color += vec3(0.1) * step(max(abs(uv.x), abs(uv.y)), 1.0);

    color = mix(color, yaxiscolor, step(abs(uv.x), fwidth(uv.x)));
    color = mix(color, xaxiscolor, step(abs(uv.y), fwidth(uv.y)));

    return color;
}

float segment(in vec2 uv, in vec2 a, in vec2 b, in float w) {
    vec2 ab = b - a;
    vec2 ap = uv - a;
    float proj = clamp(dot(ap, ab) / dot(ab, ab), 0., 1.); //pa在线段ab上的投影(归一化)
    float d = length(proj * ab - ap);
    // return d;
    return step(d, length(vec2(dFdx(d), dFdy(d))) * w);
}

vec2 fixUV(in vec2 c) {
    return 3. * (2. * c - iResolution.xy) / min(iResolution.x, iResolution.y);

}
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fixUV(fragCoord);
    fragColor = vec4(Grid(uv, 1.), 1);
    fragColor += vec4(vec3(segment(uv, vec2(-1, -1), vec2(1, 1.5), 5.)), 1);

}