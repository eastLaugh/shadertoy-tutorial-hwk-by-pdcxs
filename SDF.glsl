// #define r .7+sin(iTime)
// #define r .7+fract(iTime)
#define r .7+mod(iTime,2.)
#ifdef r
float sdfCircle(vec2 uv, float _) {

    return length(uv) - r;
}

#else
float sdfCircle(vec2 uv, float r) {

    return length(uv) - r;
}

#endif

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    // vec2 uv = mix(-iResolution.xy / 2., iResolution.xy / 2., fragCoord / iResolution.xy) / min(iResolution.x, iResolution.y);
    vec2 uv = (2. * fragCoord - iResolution.xy) / min(iResolution.x, iResolution.y);

    float d = sdfCircle(uv, .7);
    vec3 color = 1. - sign(d) * vec3(.4, .5, .6);
    // color = vec3(d);
    color *= 1. - exp(-3. * abs(d));
    #define PI 3.1415926 
    color *= .8 + .2 * sin(d * 2. * PI / .04);
    color = mix(color, vec3(1.), smoothstep(.01, .001, abs(d)));

    if(iMouse.z > .0) //z是长按 w是点按
    {
        vec2 mouse = (2. * iMouse.xy - iResolution.xy) / min(iResolution.x, iResolution.y);
        float currentDistance = sdfCircle(mouse, .7);
        color = mix(color, vec3(1., 1., 0), 1. - smoothstep(0., 0.01, abs(length(uv - mouse) - abs(currentDistance))));
    // 想象一下 smoothstep(0,0.1,x)的图 → 1 - smoothstep(0,0.1,x) → 1 - smoothstep(0,0.1,|x|)   注：f(|x|)是对称的
        color = mix(color, vec3(1., 1., 0.), 1. - smoothstep(0., .1, length(uv - mouse)));
    }
    fragColor = vec4(color, 1);
}