import QtQuick
import QtQuick.Shapes

Shape {
    id: root

    property real radius: 20
    // Fitted superellipse corner profile. This is adjustable independently
    // from the radius so each control can match the reference silhouette.
    property real cornerExponent: 2.5
    property color fillColor: Qt.rgba(0.38, 0.25, 0.56, 0.34)
    property color strokeColor: Qt.rgba(1, 1, 1, 0.34)
    property real strokeWidth: 1

    preferredRendererType: Shape.CurveRenderer
    antialiasing: true

    readonly property real r: Math.max(0, Math.min(radius, width / 2, height / 2))
    readonly property var outline: {
        const pts = [];
        if (width <= 0 || height <= 0 || r <= 0) return pts;
        const power = 2 / Math.max(2, cornerExponent);
        const steps = 64;
        const add = (x, y) => pts.push(Qt.point(x, y));
        add(r, 0); add(width - r, 0);
        for (let i = 0; i <= steps; ++i) {
            const t = (Math.PI / 2) * i / steps;
            add(width - r + r * Math.pow(Math.sin(t), power), r - r * Math.pow(Math.cos(t), power));
        }
        add(width, height - r);
        for (let i = 0; i <= steps; ++i) {
            const t = (Math.PI / 2) * i / steps;
            add(width - r + r * Math.pow(Math.cos(t), power), height - r + r * Math.pow(Math.sin(t), power));
        }
        add(r, height);
        for (let i = 0; i <= steps; ++i) {
            const t = (Math.PI / 2) * i / steps;
            add(r - r * Math.pow(Math.sin(t), power), height - r + r * Math.pow(Math.cos(t), power));
        }
        add(0, r);
        for (let i = 0; i <= steps; ++i) {
            const t = (Math.PI / 2) * i / steps;
            add(r - r * Math.pow(Math.cos(t), power), r - r * Math.pow(Math.sin(t), power));
        }
        add(r, 0);
        return pts;
    }

    ShapePath {
        fillColor: root.fillColor
        strokeColor: root.strokeColor
        strokeWidth: root.strokeWidth
        joinStyle: ShapePath.RoundJoin
        startX: root.r
        startY: 0
        PathPolyline { path: root.outline }
    }
}
