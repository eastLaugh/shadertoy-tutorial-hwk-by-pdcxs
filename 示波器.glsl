#define PI 3.1415926

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

float gaussian(float x, float mu, float sigma) {
    float coeff = 1.0 / (sigma * sqrt(2.0 * 3.1415926));
    float exponent = -((x - mu) * (x - mu)) / (2.0 * sigma * sigma);
    return coeff * exp(exponent);
}

//在此处定义波形 有y和g两个通道（点按显示导函数）
void def(float x, out float y, out float g) {

    y = sin(x);
    if(x > 0.) {
        g = sqrt(x);
    }
}

bool state = false;
void funcPlot(in vec2 uv, out vec3 color) {
    float y, g;
    def(uv.x, y, g);

    color.yz += 1. - smoothstep(0., 4. * fwidth(uv.y), abs(uv.y - y));
    color.rg += (1. - smoothstep(0., 4. * fwidth(uv.y), abs(uv.y - g)));

    if(iMouse.z > 0.) {
        float square = clamp(sign(sin(6. * 2. * PI * uv.x - 10. * iTime)), .0, 1.); //虚线方波

        float df = dFdx(y) / fwidth(uv.x);
        color.yz += (1. - smoothstep(0., 4. * fwidth(uv.y), abs(uv.y - df))) * square;

        float dg = dFdx(g) / fwidth(uv.x);
        color.rg += (1. - smoothstep(0., 4. * fwidth(uv.y), abs(uv.y - dg))) * square;
    }

}

vec2 fixUV(in vec2 c) {
    return 3. * (2. * c - iResolution.xy) / min(iResolution.x, iResolution.y);

}
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fixUV(fragCoord);
    fragColor = vec4(Grid(uv, 1.), 1);
    funcPlot(uv, fragColor.xyz);
}