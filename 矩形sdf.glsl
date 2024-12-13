#define TMIN 0.1
#define TMAX 20.
#define RAYMARCH_TIME 128
#define PRECISION .001
#define AA 3
#define PI 3.14159265359

// 左手坐标系
vec2 coordTransform(vec2 uv) {
    return (2. * uv - iResolution.xy) / min(iResolution.x, iResolution.y);
}

// 长方体的 SDF
float sdfCuboid(in vec3 p, in vec3 size) {
    vec3 d = abs(p) - size;  // size 是长方体的半边长（x, y, z）
    return max(max(d.x, d.y), d.z);  // 返回与各个面的距离
}

float rayMarch(in vec3 ro, in vec3 rd) {
    float t = TMIN;
    for(int i = 0; i < RAYMARCH_TIME && t < TMAX; i++) {
        vec3 p = ro + t * rd;
        float d = sdfCuboid(p, vec3(0.5, 0.5, 1.));  // 长方体大小 (0.5, 0.5, 1.0) 为例
        if(d < PRECISION)
            break;
        t += d;
    }
    return t;
}

vec3 calcNormal(in vec3 p) { // for function f(p)
    const float h = 0.0001;  // 用来计算法线的偏移量
    const vec2 k = vec2(1, -1);
    return normalize(k.xyy * sdfCuboid(p + k.xyy * h, vec3(0.5, 0.5, 1.0)) +
        k.yyx * sdfCuboid(p + k.yyx * h, vec3(0.5, 0.5, 1.0)) +
        k.yxy * sdfCuboid(p + k.yxy * h, vec3(0.5, 0.5, 1.0)) +
        k.xxx * sdfCuboid(p + k.xxx * h, vec3(0.5, 0.5, 1.0)));
}

mat3 setCamera(vec3 ta, vec3 ro, float cr) { // target, raycast origin, camera rotation
    vec3 z = normalize(ta - ro);
    vec3 cp = vec3(sin(cr), cos(cr), 0.); // 本质上确定 yz 平面
    vec3 x = normalize(-cross(z, cp));
    vec3 y = -cross(x, z);
    return mat3(x, y, z);
}

void render(vec2 uv, out vec3 color) {
    vec3 ro = vec3(2. * cos(iTime), 1., 2. * sin(iTime)); // 相机位置 (世界坐标下)
    vec3 ta = vec3(0., 0., 0.); // 观察目标
    if(iMouse.z > 0.) {
        float theta = iMouse.x / iResolution.x * 2. * PI;
        ro = vec3(2. * cos(theta), 1., 2. * sin(theta));
    }
    mat3 cam = setCamera(ta, ro, 0.); // 相机矩阵

    vec3 rd = normalize(cam * vec3(uv, 1.));
    float t = rayMarch(ro, rd);
    if(t < TMAX) {
        vec3 p = ro + t * rd;
        vec3 n = calcNormal(p);
        vec3 light = vec3(2., 1., 0.); // 光源位置
        float dif = clamp(dot(normalize(light - p), n), 0., 1.);
        float amb = .5 + .5 * dot(n, vec3(0., 1., 0.));
        color = sqrt(amb * vec3(.25, .23, .23) + dif * vec3(1.));
    }
}

void mainImage(out vec4 color, in vec2 coord) {
    vec2 uv = coordTransform(coord);
    render(uv, color.xyz);
    color = vec4(color.xyz, 1.);
}
