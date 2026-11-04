#pragma once

#include <QObject>
#include <QProcess>
#include <QStringList>
#include <QVariantList>

class SystemControlController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool wifiEnabled READ wifiEnabled NOTIFY stateChanged)
    Q_PROPERTY(bool wifiAvailable READ wifiAvailable NOTIFY stateChanged)
    Q_PROPERTY(QString wifiNetworkName READ wifiNetworkName NOTIFY stateChanged)
    Q_PROPERTY(bool wifiNetworkSecured READ wifiNetworkSecured NOTIFY stateChanged)
    Q_PROPERTY(QStringList wifiOtherNetworks READ wifiOtherNetworks NOTIFY stateChanged)
    Q_PROPERTY(bool bluetoothEnabled READ bluetoothEnabled NOTIFY stateChanged)
    Q_PROPERTY(bool bluetoothAvailable READ bluetoothAvailable NOTIFY stateChanged)
    Q_PROPERTY(QVariantList bluetoothDevices READ bluetoothDevices NOTIFY stateChanged)
    Q_PROPERTY(bool batteryAvailable READ batteryAvailable NOTIFY stateChanged)
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY stateChanged)
    Q_PROPERTY(int volume READ volume NOTIFY stateChanged)
    Q_PROPERTY(bool brightnessAvailable READ brightnessAvailable CONSTANT)
    Q_PROPERTY(bool mediaAvailable READ mediaAvailable NOTIFY stateChanged)

public:
    explicit SystemControlController(QObject *parent = nullptr);
    bool wifiEnabled() const { return m_wifiEnabled; }
    bool wifiAvailable() const { return m_wifiAvailable; }
    QString wifiNetworkName() const { return m_wifiNetworkName; }
    bool wifiNetworkSecured() const { return m_wifiNetworkSecured; }
    QStringList wifiOtherNetworks() const { return m_wifiOtherNetworks; }
    bool bluetoothEnabled() const { return m_bluetoothEnabled; }
    bool bluetoothAvailable() const { return m_bluetoothAvailable; }
    QVariantList bluetoothDevices() const { return m_bluetoothDevices; }
    bool batteryAvailable() const { return m_batteryAvailable; }
    int batteryPercent() const { return m_batteryPercent; }
    int volume() const { return m_volume; }
    bool brightnessAvailable() const { return m_brightnessAvailable; }
    bool mediaAvailable() const { return m_mediaService.isEmpty() == false; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void refreshWifiNetworks();
    Q_INVOKABLE void refreshBluetoothDevices();
    Q_INVOKABLE void toggleWifi();
    Q_INVOKABLE void connectWifiNetwork(const QString &ssid);
    Q_INVOKABLE void toggleBluetooth();
    Q_INVOKABLE void setVolume(int percent);
    Q_INVOKABLE void launchScreenshot();
    Q_INVOKABLE void openWifiSettings();
    Q_INVOKABLE void openBluetoothSettings();
    Q_INVOKABLE void toggleBluetoothDevice(const QString &address, bool connected);
    Q_INVOKABLE void toggleAppearance();
    Q_INVOKABLE void mediaPrevious();
    Q_INVOKABLE void mediaTogglePlayback();
    Q_INVOKABLE void mediaNext();

Q_SIGNALS:
    void stateChanged();

private:
    void run(const QString &program, const QStringList &arguments);
    bool m_wifiEnabled = false;
    bool m_wifiAvailable = false;
    QString m_wifiNetworkName;
    bool m_wifiNetworkSecured = false;
    QStringList m_wifiOtherNetworks;
    bool m_bluetoothEnabled = false;
    bool m_bluetoothAvailable = false;
    QVariantList m_bluetoothDevices;
    bool m_batteryAvailable = false;
    int m_batteryPercent = 0;
    int m_volume = 0;
    bool m_brightnessAvailable = false;
    bool m_darkAppearance = true;
    QString m_mediaService;
    void callMedia(const QString &method);
};
