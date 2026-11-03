#include "BlurBehindRegion.h"

#include <KWindowEffects>

#include <QGuiApplication>
#include <QImage>
#include <QRegion>
#include <QTimer>
#include <QVector>
#include <QtGui/qguiapplication_platform.h>

#include <cstdlib>
#include <xcb/xcb.h>

namespace {

void setX11BlurBehindRegion(QWindow *window, const QRegion &region)
{
#if QT_CONFIG(xcb)
    if (!window || QGuiApplication::platformName() != QStringLiteral("xcb")) {
        return;
    }

    auto *x11 = qGuiApp->nativeInterface<QNativeInterface::QX11Application>();
    if (!x11 || !x11->connection()) {
        return;
    }

    const xcb_window_t windowId = window->winId();
    xcb_connection_t *connection = x11->connection();
    constexpr char blurAtomName[] = "_KDE_NET_WM_BLUR_BEHIND_REGION";
    constexpr char cardinalAtomName[] = "CARDINAL";

    const auto internAtom = [connection](const char *name, uint16_t length) {
        const auto cookie = xcb_intern_atom(connection, false, length, name);
        return xcb_intern_atom_reply(connection, cookie, nullptr);
    };
    auto *blurAtom = internAtom(blurAtomName, sizeof(blurAtomName) - 1);
    auto *cardinalAtom = internAtom(cardinalAtomName, sizeof(cardinalAtomName) - 1);
    if (!blurAtom || !cardinalAtom) {
        std::free(blurAtom);
        std::free(cardinalAtom);
        return;
    }

    if (region.isEmpty()) {
        xcb_delete_property(connection, windowId, blurAtom->atom);
    } else {
        const qreal scale = window->devicePixelRatio();
        QVector<uint32_t> values;
        values.reserve(region.rectCount() * 4);
        for (const QRect &rect : region) {
            values << uint32_t(qRound(rect.x() * scale))
                   << uint32_t(qRound(rect.y() * scale))
                   << uint32_t(qRound(rect.width() * scale))
                   << uint32_t(qRound(rect.height() * scale));
        }
        xcb_change_property(connection, XCB_PROP_MODE_REPLACE, windowId,
                            blurAtom->atom, cardinalAtom->atom, 32,
                            uint32_t(values.size()), values.constData());
    }
    xcb_flush(connection);
    std::free(blurAtom);
    std::free(cardinalAtom);
#else
    Q_UNUSED(window)
    Q_UNUSED(region)
#endif
}

}

BlurBehindRegion::BlurBehindRegion(QObject *parent)
    : QObject(parent)
{
}

BlurBehindRegion::~BlurBehindRegion()
{
    if (m_window) {
        KWindowEffects::enableBlurBehind(m_window, false);
        setX11BlurBehindRegion(m_window, {});
    }
}

QQuickWindow *BlurBehindRegion::window() const
{
    return m_window;
}

void BlurBehindRegion::setWindow(QQuickWindow *window)
{
    if (m_window == window) {
        return;
    }

    if (m_window) {
        KWindowEffects::enableBlurBehind(m_window, false);
        setX11BlurBehindRegion(m_window, {});
    }

    m_window = window;
    if (m_window) {
        connect(m_window, &QWindow::visibleChanged, this, &BlurBehindRegion::apply);
        connect(m_window, &QWindow::widthChanged, this, &BlurBehindRegion::apply);
        connect(m_window, &QWindow::heightChanged, this, &BlurBehindRegion::apply);
        connect(m_window, &QObject::destroyed, this, [this] {
            m_window = nullptr;
        });
    }

    Q_EMIT windowChanged();
    QTimer::singleShot(0, this, &BlurBehindRegion::apply);
}

QUrl BlurBehindRegion::maskSource() const
{
    return m_maskSource;
}

void BlurBehindRegion::setMaskSource(const QUrl &source)
{
    if (m_maskSource == source) {
        return;
    }
    m_maskSource = source;
    Q_EMIT maskSourceChanged();
    QTimer::singleShot(0, this, &BlurBehindRegion::apply);
}

bool BlurBehindRegion::enabled() const
{
    return m_enabled;
}

void BlurBehindRegion::setEnabled(bool enabled)
{
    if (m_enabled == enabled) {
        return;
    }
    m_enabled = enabled;
    Q_EMIT enabledChanged();
    QTimer::singleShot(0, this, &BlurBehindRegion::apply);
}

int BlurBehindRegion::alphaThreshold() const
{
    return m_alphaThreshold;
}

void BlurBehindRegion::setAlphaThreshold(int threshold)
{
    threshold = qBound(0, threshold, 255);
    if (m_alphaThreshold == threshold) {
        return;
    }
    m_alphaThreshold = threshold;
    Q_EMIT alphaThresholdChanged();
    QTimer::singleShot(0, this, &BlurBehindRegion::apply);
}

void BlurBehindRegion::refresh()
{
    apply();
}

void BlurBehindRegion::apply()
{
    if (!m_window) {
        return;
    }

    if (!m_enabled || !m_window->isVisible()) {
        KWindowEffects::enableBlurBehind(m_window, false);
        setX11BlurBehindRegion(m_window, {});
        return;
    }

    QString path;
    if (m_maskSource.isLocalFile()) {
        path = m_maskSource.toLocalFile();
    } else if (m_maskSource.scheme() == QStringLiteral("qrc")) {
        path = QStringLiteral(":") + m_maskSource.path();
    }
    QImage mask(path);
    if (mask.isNull()) {
        KWindowEffects::enableBlurBehind(m_window, false);
        setX11BlurBehindRegion(m_window, {});
        return;
    }

    mask = mask.convertToFormat(QImage::Format_RGBA8888);
    if (mask.size() != m_window->size()) {
        mask = mask.scaled(m_window->size(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
    }

    QRegion region;
    for (int y = 0; y < mask.height(); ++y) {
        const uchar *pixels = mask.constScanLine(y);
        int runStart = -1;
        for (int x = 0; x < mask.width(); ++x) {
            const int alpha = pixels[x * 4 + 3];
            if (alpha > m_alphaThreshold) {
                if (runStart < 0) {
                    runStart = x;
                }
            } else if (runStart >= 0) {
                region += QRect(runStart, y, x - runStart, 1);
                runStart = -1;
            }
        }
        if (runStart >= 0) {
            region += QRect(runStart, y, mask.width() - runStart, 1);
        }
    }

    if (region.isEmpty()) {
        KWindowEffects::enableBlurBehind(m_window, false);
        setX11BlurBehindRegion(m_window, {});
        return;
    }

    KWindowEffects::enableBlurBehind(m_window, true, region);
    setX11BlurBehindRegion(m_window, region);
}
