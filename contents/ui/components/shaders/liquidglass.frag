#version 440

// Liquid-glass fragment shader — Snell-on-a-dome refraction.
//
// Ported from iyinchao/liquid-glass-studio's fragment-main.glsl with extras.
// Key ideas:
//   * Edge refraction uses Snell's law through a dome-shaped bevel:
//         sinθI = (1 - t)^2      where t = 0..1 across the edge band
//         θT    = asin(sinθI / IOR)
//         mag   = tan(θI - θT)   // lateral shift of the refracted ray
//   * SDF gradient is kept UNNORMALIZED and its magnitude is reused as a
//     corner-AA gate.
//   * Chromatic dispersion: R/B sampled at an extra offset along the
//     refraction direction, scaled by how deep we are in the edge band.
//
// qt_TexCoord0 is widget-local UV (0..1).
// uvOffset/uvScale map widget UV -> wallpaper UV.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4  qt_Matrix;
    float qt_Opacity;
    vec2  size;              // widget size in px
    float radius;            // corner radius in px
    float roundness;         // superellipse exponent; 2 = circle, 5 ≈ iOS squircle
    float refractThickness;  // edge band width in px
    float refractIOR;
    float refractScale;
    float chromaStrength;    // 0..1 chromatic aberration
    vec4  tint;
    vec4  tintBottom;
    vec2  uvOffset;
    vec2  uvScale;
    vec4  overlayDarken;     // rgb = target blend color, a = band height (0 = off)
    float innerBlurMix;      // 0 = crisp backdrop, 1 = current light blur
    vec2 crispUvOffset;
    vec2 crispUvScale;
};

layout(binding = 1) uniform sampler2D backdrop;
layout(binding = 2) uniform sampler2D crispBackdrop;

// --- Shape SDF: superellipse-cornered rounded rect (squircle) ---

// Squircle / rounded-box SDF with analytic gradient.
//
// Returns vec3(d, nx, ny) where (nx, ny) is the unit outward normal.
//
//   q     = |p| - b + r
//   arc   = (qx^n + qy^n)^(1/n)   — qx = max(q.x, 0), qy = max(q.y, 0)
//   d_rel = min(max(q.x, q.y), 0) + arc - r
//   d     = d_rel / |∇|           — normalize to unit-gradient distance
//
// Fast paths:
//   * Interior (qx == 0 && qy == 0): level-set slope is 1 from the
//     min/max term; no pow() needed.
//   * Straight edge (exactly one of qx/qy is zero): p-norm collapses to
//     |q.x| or |q.y|; gradient is axis-aligned; no pow() needed.
//   * Corner wedge (both qx > 0 && qy > 0): p-norm and analytic
//     gradient.
//
// Sign convention: normal flipped by sign(p) at return time so it
// points outward in original p-space (q uses abs(p)).
vec3 sceneSDFAndNormal(vec2 p) {
    vec2 b = size * 0.5;
    float n = max(roundness, 2.0);
    float r = clamp(radius, 0.0, min(b.x, b.y));

    vec2 q = abs(p) - b + vec2(r);
    float qx = max(q.x, 0.0);
    float qy = max(q.y, 0.0);

    float d;
    vec2 nrm;

    if (qx <= 0.0 && qy <= 0.0) {
        // Interior: nearest silhouette is the straight edge. Level-set
        // slope is 1 already; normal is the axis with the larger q.
        d = max(q.x, q.y) - r;
        nrm = q.x >= q.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    } else if (qx == 0.0) {
        // Top/bottom straight edge past the corner box.
        d = qy - r;
        nrm = vec2(0.0, 1.0);
    } else if (qy == 0.0) {
        // Left/right straight edge past the corner box.
        d = qx - r;
        nrm = vec2(1.0, 0.0);
    } else {
        // Corner wedge: both qx, qy > 0.
        float qxn = pow(qx, n);
        float qyn = pow(qy, n);
        float arc = pow(qxn + qyn, 1.0 / n);
        // ∂arc/∂x = (qx/arc)^(n-1); same for y.
        float gx = pow(qx / arc, n - 1.0);
        float gy = pow(qy / arc, n - 1.0);
        float gradLen = sqrt(gx*gx + gy*gy);
        d   = (arc - r) / max(gradLen, 1e-3);
        nrm = vec2(gx, gy) / max(gradLen, 1e-3);
    }

    // q uses abs(p); flip the normal back to original-space signs.
    nrm *= sign(p + vec2(1e-20));
    return vec3(d, nrm);
}

// Distance-only helper for the silhouette mask / outside test.
float sceneSDF(vec2 p) {
    return sceneSDFAndNormal(p).x;
}

vec3 sampleBackdrop(vec2 localUV) {
    vec2 wpUV = clamp(uvOffset + localUV * uvScale, vec2(0.0), vec2(1.0));
    return texture(backdrop, wpUV).rgb;
}

vec3 sampleCrispBackdrop(vec2 localUV) {
    vec2 wpUV = clamp(crispUvOffset + localUV * crispUvScale, vec2(0.0), vec2(1.0));
    return texture(crispBackdrop, wpUV).rgb;
}

vec3 sampleGlassBackdrop(vec2 localUV) {
    vec3 crisp = sampleCrispBackdrop(localUV);
    vec3 lightlyBlurred = sampleBackdrop(localUV);
    return mix(crisp, lightlyBlurred, clamp(innerBlurMix, 0.0, 1.0));
}

void main() {
    vec2 uv = qt_TexCoord0;
    vec2 p  = (uv - vec2(0.5)) * size;
    vec3 dn = sceneSDFAndNormal(p);
    float d = dn.x;
    vec2 ndir = dn.yz;

    // Outside the shape (past the feather band): fully transparent.
    if (d > 1.5) {
        fragColor = vec4(0.0);
        return;
    }

    vec3 col;
    float depthPx = -d;

    bool canRefract = refractThickness > 0.0;

    vec3 tintColor = mix(tint.rgb, tintBottom.rgb, tintBottom.a > 0.0 ? uv.y : 0.0);
    float tintAlpha = tint.a;

    if (!canRefract || depthPx >= refractThickness) {
        // Interior: flat glass (pass-through + tint), no refraction.
        col = sampleGlassBackdrop(uv);
        col = mix(col, tintColor, tintAlpha);
    } else {
        // --- Edge band: Snell on a dome ---
        // Clamp t so fragments in the outer feather band (d > 0) produce
        // valid colors; the silhouette mask alpha-blends them out.
        float t = clamp(depthPx / refractThickness, 0.0, 1.0);
        float sinThetaI = (1.0 - t) * (1.0 - t);
        float thetaI = asin(clamp(sinThetaI, 0.0, 1.0));
        float sinThetaT = sinThetaI / refractIOR;
        float thetaT = asin(clamp(sinThetaT, 0.0, 1.0));
        float edgeMag = tan(thetaI - thetaT);

        vec2 displacePx = -ndir * edgeMag * refractScale;
        vec2 displaceUV = displacePx / size;

        float edgeWeight = 1.0 - t;
        float chromaPx = chromaStrength * refractThickness * 0.35 * edgeWeight;
        vec2 chromaUV = -ndir * chromaPx / size;

        col.r = sampleGlassBackdrop(uv + displaceUV + chromaUV).r;
        col.g = sampleGlassBackdrop(uv + displaceUV).g;
        col.b = sampleGlassBackdrop(uv + displaceUV - chromaUV).b;

        col = mix(col, tintColor, tintAlpha);

    }

    // Overlay darken: bottom gradient blending toward a target color (lyrics mode)
    if (overlayDarken.a > 0.0) {
        float darkenT = smoothstep(1.0 - overlayDarken.a, 1.0, uv.y);
        col = mix(col, overlayDarken.rgb, darkenT);
    }

    // Final AA mask at the silhouette. ~1px feather centered exactly
    // on the geometric edge — narrower than the previous 2.5px so
    // corners (where the AA feather covers more screen pixels per SDF
    // unit) don't read as a bright halo against the wallpaper.
    float mask = 1.0 - smoothstep(-0.5, 0.5, d);

    // Qt Quick blends ShaderEffect output as premultiplied alpha. The
    // silhouette feather must premultiply RGB by the mask; otherwise
    // fractional-alpha edge pixels still carry full tint/solid color and
    // blend as a bright fringe, most visible around squircle corners.
    fragColor = vec4(col * mask, mask) * qt_Opacity;
}
