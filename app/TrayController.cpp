#include "TrayController.h"

#include <QCursor>
#include <QDebug>
#include <QDir>
#include <QEventLoop>
#include <QFile>
#include <QGuiApplication>
#include <QPixmap>
#include <QRect>
#include <QScreen>

TrayController::TrayController(QSystemTrayIcon *trayIcon, QObject *parent)
    : QObject(parent)
    , m_trayIcon(trayIcon)
    , m_backdropDirectory(QDir::tempPath() + QStringLiteral("/tahoe-control-center-XXXXXX"))
{
}

void TrayController::setWindow(QQuickWindow *window)
{
    m_window = window;
}

QUrl TrayController::backdropUrl() const
{
    return m_backdropUrl;
}

void TrayController::toggleWindow()
{
    if (!m_window) {
        return;
    }

    if (m_window->isVisible()) {
        m_window->hide();
        return;
    }

    positionWindow();
    captureBackdrop();
    QGuiApplication::processEvents(QEventLoop::ExcludeUserInputEvents);
    m_window->show();
    m_window->raise();
    m_window->requestActivate();
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

    m_screen = screen;
    m_window->setScreen(screen);
    const QRect available = screen->availableGeometry();
    const int rightEdge = available.x() + available.width() - 1;
    // The 60 px left inset places the panel's right edge 13 px from the
    // display edge, matching the design reference at 1920 x 1080.
    const int x = rightEdge - m_window->width();
    const int y = trayGeometry.isValid() && !trayGeometry.isEmpty()
        ? trayGeometry.y() + trayGeometry.height() + 5
        : screen->geometry().y() + 41;
    m_window->setPosition(x, y);
}

void TrayController::captureBackdrop()
{
    if (!m_window || !m_screen || !m_backdropDirectory.isValid()) {
        return;
    }

    const QRect screenGeometry = m_screen->geometry();
    const QRect captureRect(m_window->x() - screenGeometry.x(),
                            m_window->y() - screenGeometry.y(),
                            m_window->width(),
                            m_window->height());
    const QPixmap capture = m_screen->grabWindow(0,
                                                  captureRect.x(), captureRect.y(),
                                                  captureRect.width(), captureRect.height());
    if (capture.isNull()) {
        qWarning() << "Could not capture the desktop backdrop for the Control Center.";
        return;
    }

    const QString imagePath = m_backdropDirectory.filePath(
        QStringLiteral("backdrop-%1.png").arg(++m_backdropFrame));
    if (!capture.save(imagePath, "PNG")) {
        qWarning() << "Could not save the desktop backdrop for the Control Center.";
        return;
    }

    m_backdropUrl = QUrl::fromLocalFile(imagePath);
    Q_EMIT backdropUpdated();
}
