#include "TrayController.h"

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
    if (name == QStringLiteral("Display")) return QStringLiteral("brightness-high");
    if (name == QStringLiteral("Keyboard Brightness")) return QStringLiteral("input-keyboard");
    if (name == QStringLiteral("Battery")) return QStringLiteral("battery-full");
    if (name == QStringLiteral("Focus")) return QStringLiteral("notifications-disabled");
    if (name == QStringLiteral("Appearance") || name == QStringLiteral("Dark Mode")) return QStringLiteral("weather-clear-night");
    if (name == QStringLiteral("Screenshot")) return QStringLiteral("camera-photo");
    if (name == QStringLiteral("Now Playing") || name == QStringLiteral("Recognize Music")) return QStringLiteral("audio-x-generic");
    if (name == QStringLiteral("AirDrop")) return QStringLiteral("network-transmit-receive");
    if (name == QStringLiteral("Stage Manager") || name == QStringLiteral("Application Windows")) return QStringLiteral("view-grid");
    if (name == QStringLiteral("Screen Mirroring")) return QStringLiteral("video-display");
    if (name == QStringLiteral("Mission Control")) return QStringLiteral("view-fullscreen");
    if (name == QStringLiteral("Show Desktop")) return QStringLiteral("user-desktop");
    if (name.startsWith(QStringLiteral("Tile Windows"))) return QStringLiteral("view-split-left-right");
    if (name == QStringLiteral("Dock Auto-hide")) return QStringLiteral("preferences-system-windows");
    if (name == QStringLiteral("Fast User Switching")) return QStringLiteral("system-switch-user");
    if (name == QStringLiteral("Home")) return QStringLiteral("go-home");
    if (name == QStringLiteral("Notes") || name == QStringLiteral("Quick Note")) return QStringLiteral("accessories-text-editor");
    if (name == QStringLiteral("Lock Screen")) return QStringLiteral("system-lock-screen");
    if (name == QStringLiteral("Utilities")) return QStringLiteral("applications-utilities");
    if (name == QStringLiteral("Alarm") || name == QStringLiteral("Stopwatch") || name == QStringLiteral("Timer")) return QStringLiteral("appointment-new");
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
    // The Control Center belongs on the primary (center HDMI) display. Tray
    // geometry can resolve to another screen, and the pointer may be there
    // while the user works, so neither should choose the popup's destination.
    QScreen *screen = QGuiApplication::primaryScreen();
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
    const int y = available.y() + 5;
    m_window->setPosition(x, y);
}
