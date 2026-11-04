#pragma once

#include <QObject>
#include <QPointer>
#include <QQuickWindow>
#include <QStringList>
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
    void menuBarControlActivated(const QString &name);

public Q_SLOTS:
    void toggleWindow();
    void setPopupVisible(bool visible);
    Q_INVOKABLE void setMenuBarItems(const QString &newlineSeparatedItems);

private:
    void positionWindow();
    void activateMenuBarControl(const QString &name);
    static QString iconNameForControl(const QString &name);

    QSystemTrayIcon *m_trayIcon = nullptr;
    QPointer<QQuickWindow> m_window;
    bool m_popupVisible = false;
    QStringList m_menuBarItems;
    QList<QSystemTrayIcon *> m_menuBarIcons;
};
