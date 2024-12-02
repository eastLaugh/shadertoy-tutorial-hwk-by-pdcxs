vec3 NumberPlane(vec2 uv) {
    vec3 col = vec3(0);
    vec2 cell = fract(uv);

    if(cell.x < fwidth(uv.x)) {
        col = vec3(1);
    }
    if(cell.y < fwidth(uv.y)) {
        col = vec3(1);
    }

    if(abs(uv.x) < 1. && abs(uv.y) < 1.) {
        col += vec3(0.1);
    }

    if(abs(uv.y) < fwidth(uv.y)) {
        col = vec3(1., 0, 0);
    }

    if(abs(uv.x) < fwidth(uv.x)) {
        col = vec3(0., 1, 0);

    }
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv =(2. * fragCoord - iResolution.xy) / min(iResolution.x, iResolution.y);

    fragColor = vec4(NumberPlane(uv), 1);
}