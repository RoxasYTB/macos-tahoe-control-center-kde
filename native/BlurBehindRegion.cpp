#include "BlurBehindRegion.h"

#include <KWindowEffects>

#include <QImage>
#include <QRegion>
#include <QTimer>

BlurBehindRegion::BlurBehindRegion(QObject *parent)
    : QObject(parent)
{
}

BlurBehindRegion::~BlurBehindRegion()
{
    if (m_window) {
        KWindowEffects::enableBlurBehind(m_window, false);
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
        return;
    }

    const QString path = m_maskSource.isLocalFile()
        ? m_maskSource.toLocalFile()
        : QString();
    QImage mask(path);
    if (mask.isNull()) {
        KWindowEffects::enableBlurBehind(m_window, false);
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
        return;
    }

    KWindowEffects::enableBlurBehind(m_window, true, region);
}
