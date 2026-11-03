#include "TrayController.h"

#include <QCommandLineParser>
#include <QApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSystemTrayIcon>
#include <QUrl>
#include <QDebug>

int main(int argc, char *argv[])
{
    Q_INIT_RESOURCE(controlcenter);
    QQuickWindow::setDefaultAlphaBuffer(true);
    QApplication app(argc, argv);
    QCoreApplication::setApplicationName(QStringLiteral("Tahoe Control Center"));
    QCoreApplication::setApplicationVersion(QStringLiteral("0.1.0"));
    QGuiApplication::setQuitOnLastWindowClosed(false);

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("A macOS Tahoe-style Control Center for KDE"));
    parser.addHelpOption();
    parser.addVersionOption();
    const QCommandLineOption showOption(QStringList{QStringLiteral("show")},
                                        QStringLiteral("Open the Control Center immediately."));
    parser.addOption(showOption);
    parser.process(app);

    QSystemTrayIcon trayIcon(QIcon(QStringLiteral(":/contents/ui/components/icons/control-centre-iconscout-white.png")));
    trayIcon.setToolTip(QStringLiteral("Control Center"));

    TrayController controller(&trayIcon, &app);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("trayController"), &controller);
    const QUrl qmlUrl(QStringLiteral("qrc:/app/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.load(qmlUrl);

    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().value(0));
    if (!window) {
        qCritical() << "The Control Center window could not be created.";
        return 1;
    }

    controller.setWindow(window);
    QObject::connect(&trayIcon, &QSystemTrayIcon::activated, &controller,
                     [&controller](QSystemTrayIcon::ActivationReason reason) {
        if (reason == QSystemTrayIcon::Trigger) {
            controller.toggleWindow();
        }
    });

    trayIcon.setVisible(true);
    if (!QSystemTrayIcon::isSystemTrayAvailable()) {
        qWarning() << "No system tray is available; opening the Control Center window.";
        controller.toggleWindow();
    } else if (parser.isSet(showOption)) {
        controller.toggleWindow();
    }

    return app.exec();
}
