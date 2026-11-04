#pragma once

#include <QObject>
#include <QProcess>

class SystemControlController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool wifiEnabled READ wifiEnabled NOTIFY stateChanged)
    Q_PROPERTY(bool bluetoothEnabled READ bluetoothEnabled NOTIFY stateChanged)
    Q_PROPERTY(int volume READ volume NOTIFY stateChanged)
    Q_PROPERTY(bool brightnessAvailable READ brightnessAvailable CONSTANT)
    Q_PROPERTY(bool mediaAvailable READ mediaAvailable NOTIFY stateChanged)

public:
    explicit SystemControlController(QObject *parent = nullptr);
    bool wifiEnabled() const { return m_wifiEnabled; }
    bool bluetoothEnabled() const { return m_bluetoothEnabled; }
    int volume() const { return m_volume; }
    bool brightnessAvailable() const { return m_brightnessAvailable; }
    bool mediaAvailable() const { return m_mediaService.isEmpty() == false; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void toggleWifi();
    Q_INVOKABLE void toggleBluetooth();
    Q_INVOKABLE void setVolume(int percent);
    Q_INVOKABLE void launchScreenshot();
    Q_INVOKABLE void toggleAppearance();
    Q_INVOKABLE void mediaPrevious();
    Q_INVOKABLE void mediaTogglePlayback();
    Q_INVOKABLE void mediaNext();

Q_SIGNALS:
    void stateChanged();

private:
    void run(const QString &program, const QStringList &arguments);
    bool m_wifiEnabled = false;
    bool m_bluetoothEnabled = false;
    int m_volume = 0;
    bool m_brightnessAvailable = false;
    bool m_darkAppearance = true;
    QString m_mediaService;
    void callMedia(const QString &method);
};
