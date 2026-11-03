#pragma once

#include <QObject>
#include <QPointer>
#include <QQuickWindow>
#include <QSystemTrayIcon>

class TrayController final : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(bool popupVisible READ popupVisible NOTIFY popupVisibleChanged)

    explicit TrayController(QSystemTrayIcon *trayIcon, QObject *parent = nullptr);
    void setWindow(QQuickWindow *window);
    bool popupVisible() const;

Q_SIGNALS:
    void popupVisibleChanged();

public Q_SLOTS:
    void toggleWindow();
    void setPopupVisible(bool visible);

private:
    void positionWindow();

    QSystemTrayIcon *m_trayIcon = nullptr;
    QPointer<QQuickWindow> m_window;
    bool m_popupVisible = false;
};
