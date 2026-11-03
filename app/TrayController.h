#pragma once

#include <QObject>
#include <QPointer>
#include <QQuickWindow>
#include <QScreen>
#include <QSystemTrayIcon>
#include <QTemporaryDir>
#include <QUrl>

class TrayController final : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QUrl backdropUrl READ backdropUrl NOTIFY backdropUpdated)

    explicit TrayController(QSystemTrayIcon *trayIcon, QObject *parent = nullptr);
    void setWindow(QQuickWindow *window);
    QUrl backdropUrl() const;

Q_SIGNALS:
    void backdropUpdated();

public Q_SLOTS:
    void toggleWindow();

private:
    void positionWindow();
    void captureBackdrop();

    QSystemTrayIcon *m_trayIcon = nullptr;
    QPointer<QQuickWindow> m_window;
    QPointer<QScreen> m_screen;
    QUrl m_backdropUrl;
    quint64 m_backdropFrame = 0;
    QTemporaryDir m_backdropDirectory;
};
