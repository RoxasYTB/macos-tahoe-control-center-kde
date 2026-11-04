#include "SystemControlController.h"

#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusReply>
#include <QDirIterator>
#include <QFile>
#include <QProcess>
#include <QRegularExpression>
#include <QHash>
#include <QSet>
#include <QSharedPointer>
#include <QTimer>
#include <QVariant>

namespace {

QStringList splitNmcliRow(const QString &row)
{
    QStringList fields;
    QString field;
    bool escaped = false;
    for (const QChar ch : row) {
        if (escaped) {
            field += ch;
            escaped = false;
        } else if (ch == QLatin1Char('\\')) {
            escaped = true;
        } else if (ch == QLatin1Char(':')) {
            fields.push_back(field);
            field.clear();
        } else {
            field += ch;
        }
    }
    if (escaped) field += QLatin1Char('\\');
    fields.push_back(field);
    return fields;
}

struct BluetoothQuerySnapshot {
    QByteArray paired;
    QByteArray connected;
    int pending = 2;
};

bool readBatteryPercent(int *percent)
{
    QDirIterator supplies(QStringLiteral("/sys/class/power_supply"),
                          QDir::Dirs | QDir::NoDotAndDotDot);
    while (supplies.hasNext()) {
        const QString supply = supplies.next();
        QFile typeFile(supply + QStringLiteral("/type"));
        if (!typeFile.open(QIODevice::ReadOnly)
                || typeFile.readAll().trimmed() != QByteArrayLiteral("Battery")) {
            continue;
        }
        QFile capacityFile(supply + QStringLiteral("/capacity"));
        if (!capacityFile.open(QIODevice::ReadOnly)) continue;
        bool ok = false;
        const int value = QString::fromLatin1(capacityFile.readAll().trimmed()).toInt(&ok);
        if (!ok || value < 0 || value > 100) continue;
        *percent = value;
        return true;
    }
    return false;
}

} // namespace

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
    const bool wifiFinished = wifiQuery.waitForFinished(500);
    const bool wifiRadioQueryValid = wifiFinished
            && wifiQuery.exitStatus() == QProcess::NormalExit
            && wifiQuery.exitCode() == 0;
    const bool newWifi = wifiRadioQueryValid
            && wifiQuery.readAllStandardOutput().trimmed() == "enabled";

    QProcess wifiDevicesQuery;
    wifiDevicesQuery.start(QStringLiteral("nmcli"), {
        QStringLiteral("-t"), QStringLiteral("-f"), QStringLiteral("TYPE"),
        QStringLiteral("device")
    });
    const bool wifiDevicesQueryValid = wifiDevicesQuery.waitForFinished(500)
            && wifiDevicesQuery.exitStatus() == QProcess::NormalExit
            && wifiDevicesQuery.exitCode() == 0;
    bool hasWifiDevice = false;
    if (wifiDevicesQueryValid) {
        for (const QString &line : QString::fromUtf8(wifiDevicesQuery.readAllStandardOutput())
                 .split(QLatin1Char('\n'), Qt::SkipEmptyParts)) {
            if (line.trimmed() == QStringLiteral("wifi")) {
                hasWifiDevice = true;
                break;
            }
        }
    }
    const bool newWifiAvailable = wifiRadioQueryValid && wifiDevicesQueryValid && hasWifiDevice;

    QProcess btQuery;
    btQuery.start(QStringLiteral("bluetoothctl"), {QStringLiteral("show")});
    const bool bluetoothFinished = btQuery.waitForFinished(500);
    const bool newBluetoothAvailable = bluetoothFinished
            && btQuery.exitStatus() == QProcess::NormalExit
            && btQuery.exitCode() == 0;
    const bool newBluetooth = newBluetoothAvailable
            && QString::fromUtf8(btQuery.readAllStandardOutput()).contains(
                QRegularExpression(QStringLiteral("Powered:\\s+yes")));

    int newBatteryPercent = 0;
    const bool newBatteryAvailable = readBatteryPercent(&newBatteryPercent);

    QProcess volumeQuery;
    volumeQuery.start(QStringLiteral("pactl"), {QStringLiteral("get-sink-volume"), QStringLiteral("@DEFAULT_SINK@")});
    volumeQuery.waitForFinished(500);
    const auto match = QRegularExpression(QStringLiteral("(\\d+)%")).match(QString::fromUtf8(volumeQuery.readAllStandardOutput()));
    const int newVolume = match.hasMatch() ? qBound(0, match.captured(1).toInt(), 100) : m_volume;

    if (m_wifiAvailable != newWifiAvailable || m_wifiEnabled != newWifi
            || m_bluetoothAvailable != newBluetoothAvailable || m_bluetoothEnabled != newBluetooth
            || m_batteryAvailable != newBatteryAvailable || m_batteryPercent != newBatteryPercent
            || m_volume != newVolume || oldMediaService != m_mediaService) {
        m_wifiAvailable = newWifiAvailable;
        m_wifiEnabled = newWifi;
        m_bluetoothAvailable = newBluetoothAvailable;
        m_bluetoothEnabled = newBluetooth;
        m_batteryAvailable = newBatteryAvailable;
        m_batteryPercent = newBatteryPercent;
        m_volume = newVolume;
        Q_EMIT stateChanged();
    }
    refreshWifiNetworks();
    refreshBluetoothDevices();
}

void SystemControlController::refreshBluetoothDevices()
{
    auto *paired = new QProcess(this);
    auto *connected = new QProcess(this);
    const auto snapshot = QSharedPointer<BluetoothQuerySnapshot>::create();
    auto finish = [this, snapshot](QProcess *process, bool connectedQuery) {
        if (connectedQuery) snapshot->connected = process->readAllStandardOutput();
        else snapshot->paired = process->readAllStandardOutput();
        process->deleteLater();
        if (--snapshot->pending != 0) return;
        QHash<QString, QString> names;
        QStringList deviceOrder;
        QSet<QString> connectedAddresses;
        const QRegularExpression row(QStringLiteral("^Device\\s+([0-9A-Fa-f:]{17})\\s+(.+)$"));
        for (const QString &line : QString::fromUtf8(snapshot->paired).split(QLatin1Char('\n'), Qt::SkipEmptyParts)) {
            const auto match = row.match(line.trimmed());
            if (match.hasMatch()) {
                const QString address = match.captured(1);
                if (!names.contains(address)) deviceOrder.push_back(address);
                names.insert(address, match.captured(2).trimmed());
            }
        }
        for (const QString &line : QString::fromUtf8(snapshot->connected).split(QLatin1Char('\n'), Qt::SkipEmptyParts)) {
            const auto match = row.match(line.trimmed());
            if (match.hasMatch()) {
                const QString address = match.captured(1);
                if (!names.contains(address)) deviceOrder.push_back(address);
                names.insert(address, match.captured(2).trimmed());
                connectedAddresses.insert(address);
            }
        }
        QVariantList devices;
        for (const QString &address : deviceOrder) {
            devices.push_back(QVariantMap{{QStringLiteral("address"), address},
                                          {QStringLiteral("name"), names.value(address)},
                                          {QStringLiteral("connected"), connectedAddresses.contains(address)}});
        }
        if (m_bluetoothDevices != devices) {
            m_bluetoothDevices = devices;
            Q_EMIT stateChanged();
        }
    };
    connect(paired, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this,
            [finish, paired](int, QProcess::ExitStatus) { finish(paired, false); });
    connect(connected, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this,
            [finish, connected](int, QProcess::ExitStatus) { finish(connected, true); });
    paired->start(QStringLiteral("bluetoothctl"), {QStringLiteral("devices"), QStringLiteral("Paired")});
    connected->start(QStringLiteral("bluetoothctl"), {QStringLiteral("devices"), QStringLiteral("Connected")});
}

void SystemControlController::refreshWifiNetworks()
{
    auto *query = new QProcess(this);
    connect(query, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this,
            [this, query](int exitCode, QProcess::ExitStatus status) {
        QString activeNetwork;
        bool activeNetworkSecured = false;
        QStringList otherNetworks;
        if (exitCode == 0 && status == QProcess::NormalExit) {
            const QString output = QString::fromUtf8(query->readAllStandardOutput());
            for (const QString &line : output.split(QLatin1Char('\n'), Qt::SkipEmptyParts)) {
                const QStringList fields = splitNmcliRow(line);
                if (fields.size() < 2 || fields.at(1).trimmed().isEmpty()) continue;
                const QString ssid = fields.at(1).trimmed();
                if (fields.at(0) == QStringLiteral("*")) {
                    activeNetwork = ssid;
                    activeNetworkSecured = fields.size() >= 3
                            && !fields.at(2).trimmed().isEmpty()
                            && fields.at(2).trimmed() != QStringLiteral("--");
                } else if (!otherNetworks.contains(ssid)) {
                    otherNetworks.push_back(ssid);
                }
            }
        }
        query->deleteLater();
        if (m_wifiNetworkName != activeNetwork
                || m_wifiNetworkSecured != activeNetworkSecured
                || m_wifiOtherNetworks != otherNetworks) {
            m_wifiNetworkName = activeNetwork;
            m_wifiNetworkSecured = activeNetworkSecured;
            m_wifiOtherNetworks = otherNetworks;
            Q_EMIT stateChanged();
        }
    });
    query->start(QStringLiteral("nmcli"), {
        QStringLiteral("-t"), QStringLiteral("-f"), QStringLiteral("IN-USE,SSID,SECURITY"),
        QStringLiteral("device"), QStringLiteral("wifi"), QStringLiteral("list"),
        QStringLiteral("--rescan"), QStringLiteral("no")
    });
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

void SystemControlController::connectWifiNetwork(const QString &ssid)
{
    if (!m_wifiAvailable || !m_wifiEnabled || ssid.trimmed().isEmpty()) return;

    auto *process = new QProcess(this);
    connect(process, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this,
            [this, process](int exitCode, QProcess::ExitStatus status) {
        const bool connected = status == QProcess::NormalExit && exitCode == 0;
        process->deleteLater();
        if (!connected) openWifiSettings();
        QTimer::singleShot(150, this, &SystemControlController::refresh);
    });
    process->start(QStringLiteral("nmcli"), {
        QStringLiteral("device"), QStringLiteral("wifi"), QStringLiteral("connect"), ssid
    });
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

void SystemControlController::openWifiSettings()
{
    QProcess::startDetached(QStringLiteral("systemsettings"),
                            {QStringLiteral("kcm_networkmanagement")});
}

void SystemControlController::openBluetoothSettings()
{
    QProcess::startDetached(QStringLiteral("systemsettings"), {QStringLiteral("kcm_bluetooth")});
}

void SystemControlController::toggleBluetoothDevice(const QString &address, bool connected)
{
    run(QStringLiteral("bluetoothctl"), {connected ? QStringLiteral("disconnect") : QStringLiteral("connect"), address});
}

void SystemControlController::toggleAppearance()
{
    const QString scheme = m_darkAppearance ? QStringLiteral("MacTahoeLiquidKdeLight") : QStringLiteral("MacTahoeLiquidKdeDark");
    run(QStringLiteral("plasma-apply-colorscheme"), {scheme});
    m_darkAppearance = !m_darkAppearance;
}
