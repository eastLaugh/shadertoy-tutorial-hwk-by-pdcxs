#define TMIN 0.1
#define TMAX 20.
#define RAYMARCH_TIME 128
#define PRECISION .001

vec2 coordTransform(vec2 uv) {
    return (2. * uv - iResolution.xy) / min(iResolution.x, iResolution.y);
}

float sdfSphere(in vec3 p) {
    return length(p) - .5;
}

float rayMarch(in vec3 ro, in vec3 rd) {
    float t = TMIN;
    for(int i = 0; i < RAYMARCH_TIME && t < TMAX; i++) {
        vec3 p = ro + t * rd;
        if(sdfSphere(p) < PRECISION) {
            break;
        }
        t += sdfSphere(p);
    }
    return t;
}

void render(vec2 uv, out vec3 color) {
    vec3 ro = vec3(0., 0., 2.);
    vec3 rd = normalize(vec3(uv, .0) - ro);
    float t = rayMarch(ro, rd);
    if(t < TMAX) {
        color = vec3(1.);
    } 
}
void mainImage(out vec4 color, in vec2 coord) {
    vec2 uv = coordTransform(coord);

    color.w = 1.;
    render(uv, color.xyz);
}