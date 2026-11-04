#include "TrayController.h"
#include "SystemControlController.h"
#include "../native/BlurBehindRegion.h"

#include <QCommandLineParser>
#include <QApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSystemTrayIcon>
#include <QTimer>
#include <QUrl>
#include <QDebug>
#include <qqml.h>

int main(int argc, char *argv[])
{
    Q_INIT_RESOURCE(controlcenter);
    QQuickWindow::setDefaultAlphaBuffer(true);
    qmlRegisterType<BlurBehindRegion>("Tahoe.ControlCenter.Native", 1, 0,
                                      "BlurBehindRegion");
    QApplication app(argc, argv);
    QCoreApplication::setApplicationName(QStringLiteral("Tahoe Control Center"));
    QCoreApplication::setOrganizationName(QStringLiteral("RoxasYTB"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("roxasytb.github.io"));
    QCoreApplication::setApplicationVersion(QStringLiteral("0.1.0"));
    QGuiApplication::setQuitOnLastWindowClosed(false);

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("A macOS Tahoe-style Control Center for KDE"));
    parser.addHelpOption();
    parser.addVersionOption();
    const QCommandLineOption showOption(QStringList{QStringLiteral("show")},
                                        QStringLiteral("Open the Control Center immediately."));
    parser.addOption(showOption);
    const QCommandLineOption stayOpenOption(QStringList{QStringLiteral("stay-open")},
                                            QStringLiteral("Keep the popup open when it loses activation for visual debugging."));
    parser.addOption(stayOpenOption);
    const QCommandLineOption editorPreviewOption(QStringList{QStringLiteral("editor-preview")},
                                                  QStringLiteral("Open the Controls editor for an isolated visual check."));
    parser.addOption(editorPreviewOption);
    parser.process(app);

    QSystemTrayIcon trayIcon(QIcon(QStringLiteral(":/contents/ui/components/icons/control-centre-iconscout-white.png")));
    trayIcon.setToolTip(QStringLiteral("Control Center"));

    TrayController controller(&trayIcon, &app);
    SystemControlController systemControls(&app);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("trayController"), &controller);
    engine.rootContext()->setContextProperty(QStringLiteral("systemControls"), &systemControls);
    const QUrl qmlUrl(QStringLiteral("qrc:/app/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.load(qmlUrl);

    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().value(0));
    if (!window) {
        qCritical() << "The Control Center window could not be created.";
        return 1;
    }

    window->setProperty("stayOpen", parser.isSet(stayOpenOption));

    if (parser.isSet(editorPreviewOption)) {
        QObject *editor = window->findChild<QObject *>(QStringLiteral("controlEditorWindow"));
        if (editor)
            QMetaObject::invokeMethod(editor, "showEditor");
    }

    controller.setWindow(window);
    trayIcon.setVisible(true);
    QTimer::singleShot(500, &app, [&trayIcon, &controller] {
        QObject::connect(&trayIcon, &QSystemTrayIcon::activated, &controller,
                         [&controller](QSystemTrayIcon::ActivationReason reason) {
            if (reason == QSystemTrayIcon::Trigger) {
                controller.toggleWindow();
            }
        });
    });

    if (parser.isSet(showOption)) {
        controller.toggleWindow();
    }

    return app.exec();
}
