#include "TrayController.h"

#include <QCursor>
#include <QDebug>
#include <QGuiApplication>
#include <QRect>
#include <QScreen>

TrayController::TrayController(QSystemTrayIcon *trayIcon, QObject *parent)
    : QObject(parent)
    , m_trayIcon(trayIcon)
{
}

void TrayController::setWindow(QQuickWindow *window)
{
    m_window = window;
    if (!m_window) {
        return;
    }
    connect(m_window, &QWindow::visibleChanged, this, [this] {
        if (m_window && m_popupVisible != m_window->isVisible()) {
            setPopupVisible(m_window->isVisible());
        }
    });
}

bool TrayController::popupVisible() const
{
    return m_popupVisible;
}

void TrayController::toggleWindow()
{
    if (!m_window) {
        return;
    }

    if (m_popupVisible) {
        setPopupVisible(false);
        return;
    }

    positionWindow();
    setPopupVisible(true);
    m_window->raise();
    m_window->requestActivate();
}

void TrayController::setPopupVisible(bool visible)
{
    if (m_popupVisible == visible) {
        return;
    }
    m_popupVisible = visible;
    Q_EMIT popupVisibleChanged();
}

void TrayController::positionWindow()
{
    const QRect trayGeometry = m_trayIcon ? m_trayIcon->geometry() : QRect();
    QScreen *screen = trayGeometry.isValid() && !trayGeometry.isEmpty()
        ? QGuiApplication::screenAt(trayGeometry.center())
        : QGuiApplication::screenAt(QCursor::pos());
    if (!screen) {
        screen = QGuiApplication::primaryScreen();
    }
    if (!screen) {
        return;
    }

    m_window->setScreen(screen);
    const QRect available = screen->availableGeometry();
    const int rightEdge = available.x() + available.width() - 1;
    // The popup is panel-sized, so this keeps the panel's right edge 12 px
    // from the display edge, matching the design reference.
    const int x = rightEdge - m_window->width();
    const int y = trayGeometry.isValid() && !trayGeometry.isEmpty()
        ? trayGeometry.y() + trayGeometry.height() + 5
        : screen->geometry().y() + 41;
    m_window->setPosition(x, y);
}
