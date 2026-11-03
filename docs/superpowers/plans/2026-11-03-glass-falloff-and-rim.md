# Glass Falloff and Rim Implementation Plan

**Goal:** Improve the isolated Control Center render with a progressive outer blur, a very subtle interior blur/light, and a non-uniform glass rim.

**Architecture:** Extend the existing LiquidGlass shader with three independently tunable visual layers. Expose controls through GlassCard and the private wallpaper renderer, then compare parameter grids against the saved macOS reference without using the live desktop.

**Tech Stack:** Qt Quick/QML, GLSL 440 compiled to Qt Shader Baker `.qsb`, C++ preview renderer, Python/Pillow comparison batch.

## Global Constraints

- Keep KWin's global `liquidglass` effect disabled during this work.
- Render against `/home/yohan/Images/Wallpaper/4.jpg` in a private Xvfb session only.
- Preserve chromatic separation at zero and retain the 6px accessibility blur baseline.
- Preserve existing uncommitted repository changes; checkpoint only after reviewing staged paths.
- Do not publish a pull request.

### Task 1: Parameterized material shader

**Files:** `contents/ui/components/LiquidGlass.qml`, `contents/ui/components/GlassCard.qml`, `contents/ui/components/shaders/liquidglass.frag`, matching `.qsb`.

- Add tunable exterior falloff radius/strength, interior blur mix, edge-light strength, and rim profile parameters.
- Render an expanded halo quad using the captured static backdrop; apply a soft distance falloff outside the squircle and a small Gaussian sample kernel.
- Mix the existing crisp and light-blurred samples inside the surface; add restrained directional light.
- Replace the uniform contour with separate directional bright and dark rim contributions.
- Keep RGB split disabled and preserve refraction parameters.

### Task 2: Offline tuning grid

**Files:** `work/preview.cpp`, `work/preview.qml`, `work/render_theoretical_glass.py`.

- Pass the new material parameters into QML and expose comma-separated sweep options.
- Render a compact grid over the user's wallpaper in isolated Xvfb; produce labeled comparisons and record parameters.
- Check full-size output and wallpaper pixels outside the Control Center region.

### Task 3: Review and checkpoint

- Inspect side-by-side and difference images; select the best balanced profile rather than claiming parity from a single score.
- Compile the shaders, build the preview renderer, render the batch, and inspect the resulting images.
- Stage only intended changes, review the staged diff, commit, and push a checkpoint to the existing GitHub branch when the repository remote/branch is verified.
