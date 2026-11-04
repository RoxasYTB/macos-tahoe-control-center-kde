#include "TrayController.h"

#include <QCursor>
#include <QDebug>
#include <QGuiApplication>
#include <QRect>
#include <QScreen>
#include <QIcon>
#include <QStringList>
#include <QTimer>
#include <utility>

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

void TrayController::setMenuBarItems(const QString &newlineSeparatedItems)
{
    QStringList requested;
    for (const QString &item : newlineSeparatedItems.split(QLatin1Char('\n'), Qt::SkipEmptyParts)) {
        const QString name = item.trimmed();
        if (!name.isEmpty() && !requested.contains(name))
            requested.push_back(name);
    }
    if (requested == m_menuBarItems)
        return;

    for (QSystemTrayIcon *icon : std::as_const(m_menuBarIcons)) {
        icon->hide();
        delete icon;
    }
    m_menuBarIcons.clear();
    m_menuBarItems = requested;

    for (const QString &name : std::as_const(m_menuBarItems)) {
        auto *icon = new QSystemTrayIcon(this);
        QIcon themedIcon = QIcon::fromTheme(iconNameForControl(name));
        if (themedIcon.isNull() && m_trayIcon)
            themedIcon = m_trayIcon->icon();
        icon->setIcon(themedIcon);
        icon->setToolTip(name + QStringLiteral(" — Tahoe Control Center"));
        connect(icon, &QSystemTrayIcon::activated, this,
                [this, name](QSystemTrayIcon::ActivationReason reason) {
            if (reason == QSystemTrayIcon::Trigger || reason == QSystemTrayIcon::MiddleClick)
                activateMenuBarControl(name);
        });
        icon->show();
        m_menuBarIcons.push_back(icon);
    }
}

QString TrayController::iconNameForControl(const QString &name)
{
    if (name == QStringLiteral("Wi-Fi")) return QStringLiteral("network-wireless-signal-excellent");
    if (name == QStringLiteral("Bluetooth")) return QStringLiteral("bluetooth-active");
    if (name == QStringLiteral("Sound")) return QStringLiteral("audio-volume-high");
    if (name == QStringLiteral("Display") || name == QStringLiteral("Keyboard Brightness")) return QStringLiteral("display-brightness-high");
    if (name == QStringLiteral("Battery")) return QStringLiteral("battery-full");
    if (name == QStringLiteral("Focus")) return QStringLiteral("notifications-disabled");
    if (name == QStringLiteral("Appearance") || name == QStringLiteral("Dark Mode")) return QStringLiteral("weather-clear-night");
    if (name == QStringLiteral("Screenshot")) return QStringLiteral("camera-photo");
    if (name == QStringLiteral("Now Playing") || name == QStringLiteral("Recognize Music")) return QStringLiteral("audio-x-generic");
    if (name == QStringLiteral("AirDrop")) return QStringLiteral("network-transmit-receive");
    return QStringLiteral("preferences-desktop");
}

void TrayController::activateMenuBarControl(const QString &name)
{
    if (!m_popupVisible) {
        toggleWindow();
        QTimer::singleShot(120, this, [this, name] { Q_EMIT menuBarControlActivated(name); });
        return;
    }
    Q_EMIT menuBarControlActivated(name);
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
    // The transparent window includes a 12 px right gutter after the
    // 292 px panel. The reference panel itself sits about 13 px from the
    // display edge, so account for that gutter when positioning the window.
    constexpr int panelRightGutter = 12;
    constexpr int referencePanelRightInset = 13;
    const int panelWidth = m_window->width() - panelRightGutter;
    const int x = rightEdge - panelWidth - referencePanelRightInset + 1;
    const int y = trayGeometry.isValid() && !trayGeometry.isEmpty()
        ? trayGeometry.y() + trayGeometry.height() + 5
        : screen->geometry().y() + 41;
    m_window->setPosition(x, y);
}
