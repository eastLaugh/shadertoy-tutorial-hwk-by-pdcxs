#define TMIN 0.1
#define TMAX 20.
#define RAYMARCH_TIME 128
#define PRECISION .001
#define AA 3

//左手坐标系
vec2 coordTransform(vec2 uv) {
    return (2. * uv - iResolution.xy) / min(iResolution.x, iResolution.y);
}

float sdfSphere(in vec3 p) {
    return length((p - vec3(0., 0., .5))) - 1.5; //球位置和半径
}

float rayMarch(in vec3 ro, in vec3 rd) {
    float t = TMIN;
    for(int i = 0; i < RAYMARCH_TIME && t < TMAX; i++) {
        vec3 p = ro + t * rd;
        float d = sdfSphere(p);
        if(d < PRECISION)
            break;
        t += d;
    }
    return t;
}
vec3 calcNormal(in vec3 p) // for function f(p)
{
    const float h = 0.0001; // replace by an appropriate value
    const vec2 k = vec2(1, -1);
    return normalize(k.xyy * sdfSphere(p + k.xyy * h) +
        k.yyx * sdfSphere(p + k.yyx * h) +
        k.yxy * sdfSphere(p + k.yxy * h) +
        k.xxx * sdfSphere(p + k.xxx * h));
}

mat3 setCamera(vec3 ta, vec3 ro, float cr) { //target,raycast origin, camera rotation
    vec3 z = normalize(ta - ro);
    vec3 cp = vec3(sin(cr), cos(cr), 0.);
    vec3 x = normalize(cross(z, cp));
    vec3 y = cross(x, z);
    return mat3(x, y, z);

}

void render(vec2 uv, out vec3 color) {

    vec3 ro = vec3(2. * cos(iTime), 1., 2. * sin(iTime));     //相机位置  mat*ro=vec3(0.)
    vec3 ta = vec3(0., 0., 0.); //观察目标
    mat3 cam = setCamera(ta, ro, 0.); //相机矩阵

    vec3 rd = normalize(cam * vec3(uv, 1.));
    float t = rayMarch(ro, rd);
    if(t < TMAX) {
        vec3 p = ro + t * rd;
        vec3 n = calcNormal(p);
        vec3 light = vec3(2., 1., 0.); //光源位置
        float dif = clamp(dot(normalize(light - p), n), 0., 1.);
        float amb = .5 + .5 * dot(n, vec3(0., 1., 0.));
        color = sqrt(amb * vec3(.25, .23, .23) + dif * vec3(1.));
    }
}
void mainImage(out vec4 color, in vec2 coord) {
    vec2 uv = coordTransform(coord);

    color.w = 1.;
    render(uv, color.xyz);
}