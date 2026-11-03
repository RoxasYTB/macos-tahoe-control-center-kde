#version 440

// Soft, progressive blur just outside a Liquid Glass surface. The caller
// draws this shader on a quad expanded by haloMargin around the true shape.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;
    float radius;
    float roundness;
    float haloMargin;
    float haloBlurRadius;
    float haloStrength;
    vec2 uvOffset;
    vec2 uvScale;
};

layout(binding = 1) uniform sampler2D backdrop;

float squircleSdf(vec2 p) {
    vec2 b = size * 0.5;
    float r = clamp(radius, 0.0, min(b.x, b.y));
    float n = max(roundness, 2.0);
    vec2 q = abs(p) - b + vec2(r);
    vec2 qPos = max(q, vec2(0.0));
    float arc = pow(pow(qPos.x, n) + pow(qPos.y, n), 1.0 / n);
    float d = min(max(q.x, q.y), 0.0) + arc - r;
    // Normalize the corner distance so haloMargin stays measured in screen
    // pixels around squircles, as it is along straight edges and pill ends.
    if (qPos.x > 0.0 && qPos.y > 0.0) {
        vec2 grad = pow(qPos / max(arc, 1e-4), vec2(n - 1.0));
        d /= max(length(grad), 1e-3);
    }
    return d;
}

vec3 sampleWallpaper(vec2 localPx) {
    vec2 localUv = localPx / size;
    vec2 sampleUv = clamp(uvOffset + localUv * uvScale, vec2(0.0), vec2(1.0));
    return texture(backdrop, sampleUv).rgb;
}

void main() {
    vec2 expandedSize = size + vec2(haloMargin * 2.0);
    vec2 localPx = qt_TexCoord0 * expandedSize - vec2(haloMargin);
    vec2 p = localPx - size * 0.5;
    float d = squircleSdf(p);
    if (d <= 0.0 || d >= haloMargin) {
        fragColor = vec4(0.0);
        return;
    }

    // Five-pixel gaussian-like taps produce only a hint of softness. The
    // visible contribution then fades smoothly to zero across the outer band.
    float blurPx = max(haloBlurRadius, 0.5);
    vec3 center = sampleWallpaper(localPx) * 0.40;
    vec3 blur = center;
    blur += sampleWallpaper(localPx + vec2( blurPx, 0.0)) * 0.15;
    blur += sampleWallpaper(localPx + vec2(-blurPx, 0.0)) * 0.15;
    blur += sampleWallpaper(localPx + vec2(0.0,  blurPx)) * 0.15;
    blur += sampleWallpaper(localPx + vec2(0.0, -blurPx)) * 0.15;

    // Ease in from the silhouette, then fade smoothly to zero at the outer
    // radius. This avoids the old alpha jump at d=0.5 px.
    float edgeFade = smoothstep(0.0, 1.0, d);
    float outerFade = 1.0 - smoothstep(1.0, haloMargin, d);
    float alpha = clamp(haloStrength * edgeFade * outerFade, 0.0, 1.0);
    fragColor = vec4(blur * alpha, alpha) * qt_Opacity;
}
