#include "SystemControlController.h"

#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusReply>
#include <QProcess>
#include <QRegularExpression>
#include <QTimer>
#include <QVariant>

SystemControlController::SystemControlController(QObject *parent)
    : QObject(parent)
{
    QProcess schemeQuery;
    schemeQuery.start(QStringLiteral("kreadconfig6"), {QStringLiteral("--file"), QStringLiteral("kdeglobals"), QStringLiteral("--group"), QStringLiteral("General"), QStringLiteral("--key"), QStringLiteral("ColorScheme")});
    if (schemeQuery.waitForFinished(500)) {
        m_darkAppearance = QString::fromUtf8(schemeQuery.readAllStandardOutput()).trimmed().contains(QStringLiteral("Dark"), Qt::CaseInsensitive);
    }
    QTimer::singleShot(0, this, &SystemControlController::refresh);
}

void SystemControlController::run(const QString &program, const QStringList &arguments)
{
    auto *process = new QProcess(this);
    connect(process, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this,
            [this, process](int, QProcess::ExitStatus) {
        process->deleteLater();
        QTimer::singleShot(150, this, &SystemControlController::refresh);
    });
    process->start(program, arguments);
}

void SystemControlController::refresh()
{
    const QString oldMediaService = m_mediaService;
    m_mediaService.clear();
    const QDBusReply<QStringList> services = QDBusConnection::sessionBus().interface()->registeredServiceNames();
    if (services.isValid()) {
        for (const QString &service : services.value()) {
            if (service.startsWith(QStringLiteral("org.mpris.MediaPlayer2."))) {
                m_mediaService = service;
                break;
            }
        }
    }
    QProcess wifiQuery;
    wifiQuery.start(QStringLiteral("nmcli"), {QStringLiteral("-t"), QStringLiteral("-f"), QStringLiteral("WIFI"), QStringLiteral("general")});
    wifiQuery.waitForFinished(500);
    const bool newWifi = wifiQuery.readAllStandardOutput().trimmed() == "enabled";

    QProcess btQuery;
    btQuery.start(QStringLiteral("bluetoothctl"), {QStringLiteral("show")});
    btQuery.waitForFinished(500);
    const bool newBluetooth = QString::fromUtf8(btQuery.readAllStandardOutput()).contains(QRegularExpression(QStringLiteral("Powered:\\s+yes")));

    QProcess volumeQuery;
    volumeQuery.start(QStringLiteral("pactl"), {QStringLiteral("get-sink-volume"), QStringLiteral("@DEFAULT_SINK@")});
    volumeQuery.waitForFinished(500);
    const auto match = QRegularExpression(QStringLiteral("(\\d+)%")).match(QString::fromUtf8(volumeQuery.readAllStandardOutput()));
    const int newVolume = match.hasMatch() ? qBound(0, match.captured(1).toInt(), 100) : m_volume;

    if (m_wifiEnabled != newWifi || m_bluetoothEnabled != newBluetooth || m_volume != newVolume || oldMediaService != m_mediaService) {
        m_wifiEnabled = newWifi;
        m_bluetoothEnabled = newBluetooth;
        m_volume = newVolume;
        Q_EMIT stateChanged();
    }
}

void SystemControlController::callMedia(const QString &method)
{
    if (m_mediaService.isEmpty()) return;
    QDBusMessage message = QDBusMessage::createMethodCall(m_mediaService,
        QStringLiteral("/org/mpris/MediaPlayer2"), QStringLiteral("org.mpris.MediaPlayer2.Player"), method);
    QDBusConnection::sessionBus().asyncCall(message);
}

void SystemControlController::mediaPrevious() { callMedia(QStringLiteral("Previous")); }
void SystemControlController::mediaTogglePlayback() { callMedia(QStringLiteral("PlayPause")); }
void SystemControlController::mediaNext() { callMedia(QStringLiteral("Next")); }

void SystemControlController::toggleWifi()
{
    run(QStringLiteral("nmcli"), {QStringLiteral("radio"), QStringLiteral("wifi"), m_wifiEnabled ? QStringLiteral("off") : QStringLiteral("on")});
}

void SystemControlController::toggleBluetooth()
{
    run(QStringLiteral("bluetoothctl"), {QStringLiteral("power"), m_bluetoothEnabled ? QStringLiteral("off") : QStringLiteral("on")});
}

void SystemControlController::setVolume(int percent)
{
    run(QStringLiteral("pactl"), {QStringLiteral("set-sink-volume"), QStringLiteral("@DEFAULT_SINK@"), QString::number(qBound(0, percent, 100)) + QLatin1Char('%')});
}

void SystemControlController::launchScreenshot()
{
    QProcess::startDetached(QStringLiteral("spectacle"), {});
}

void SystemControlController::toggleAppearance()
{
    const QString scheme = m_darkAppearance ? QStringLiteral("MacTahoeLiquidKdeLight") : QStringLiteral("MacTahoeLiquidKdeDark");
    run(QStringLiteral("plasma-apply-colorscheme"), {scheme});
    m_darkAppearance = !m_darkAppearance;
}
