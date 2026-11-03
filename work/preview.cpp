#include <QGuiApplication>
#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QTimer>
#include <QUrl>

int main(int argc, char *argv[])
{
    QQuickWindow::setDefaultAlphaBuffer(true);
    QGuiApplication app(argc, argv);
    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addOption({QStringLiteral("qml"), QStringLiteral("QML scene to render"), QStringLiteral("path"), QStringLiteral(PREVIEW_QML_PATH)});
    parser.addOption({QStringLiteral("output"), QStringLiteral("PNG path to write"), QStringLiteral("path"), QStringLiteral(PREVIEW_PNG_PATH)});
    parser.addOption({QStringLiteral("wallpaper"), QStringLiteral("Static wallpaper image"), QStringLiteral("path")});
    parser.addOption({QStringLiteral("scale"), QStringLiteral("Theoretical refraction scale"), QStringLiteral("value"), QStringLiteral("75")});
    parser.addOption({QStringLiteral("ior"), QStringLiteral("Theoretical glass index of refraction"), QStringLiteral("value"), QStringLiteral("1.7")});
    parser.addOption({QStringLiteral("thickness"), QStringLiteral("Refraction edge width in pixels; -1 preserves each QML surface's value"), QStringLiteral("value"), QStringLiteral("-1")});
    parser.addOption({QStringLiteral("blur"), QStringLiteral("Backdrop blur radius in pixels"), QStringLiteral("value"), QStringLiteral("6")});
    parser.addOption({QStringLiteral("chroma"), QStringLiteral("Chromatic separation (0 disables it)"), QStringLiteral("value"), QStringLiteral("0")});
    parser.addOption({QStringLiteral("profile"), QStringLiteral("Optional JSON map of QML surface name to refraction scale"), QStringLiteral("path")});
    parser.addOption({QStringLiteral("material"), QStringLiteral("Optional JSON map of material properties to sweep"), QStringLiteral("path")});
    parser.addOption({QStringLiteral("settle-ms"), QStringLiteral("Wait for QML shaders to settle"), QStringLiteral("value"), QStringLiteral("1800")});
    parser.process(app);

    QQmlApplicationEngine engine;
    const QString wallpaperPath = parser.value(QStringLiteral("wallpaper"));
    engine.rootContext()->setContextProperty(
        QStringLiteral("renderWallpaper"), wallpaperPath.isEmpty() ? QVariant() : QVariant(QUrl::fromLocalFile(wallpaperPath)));
    engine.rootContext()->setContextProperty(QStringLiteral("renderRefractionScale"), parser.value(QStringLiteral("scale")).toDouble());
    engine.rootContext()->setContextProperty(QStringLiteral("renderRefractionIOR"), parser.value(QStringLiteral("ior")).toDouble());
    engine.rootContext()->setContextProperty(QStringLiteral("renderRefractionThickness"), parser.value(QStringLiteral("thickness")).toDouble());
    engine.rootContext()->setContextProperty(QStringLiteral("renderBlurRadius"), parser.value(QStringLiteral("blur")).toDouble());
    engine.rootContext()->setContextProperty(QStringLiteral("renderChromaStrength"), parser.value(QStringLiteral("chroma")).toDouble());
    QVariantMap refractionProfile;
    const QString profilePath = parser.value(QStringLiteral("profile"));
    if (!profilePath.isEmpty()) {
        QFile profileFile(profilePath);
        if (profileFile.open(QIODevice::ReadOnly))
            refractionProfile = QJsonDocument::fromJson(profileFile.readAll()).object().toVariantMap();
    }
    engine.rootContext()->setContextProperty(QStringLiteral("renderRefractionProfile"), refractionProfile);
    QVariantMap materialParameters;
    const QString materialPath = parser.value(QStringLiteral("material"));
    if (!materialPath.isEmpty()) {
        QFile materialFile(materialPath);
        if (materialFile.open(QIODevice::ReadOnly))
            materialParameters = QJsonDocument::fromJson(materialFile.readAll()).object().toVariantMap();
    }
    engine.rootContext()->setContextProperty(QStringLiteral("renderMaterialParameters"), materialParameters);
    const QUrl url = QUrl::fromLocalFile(parser.value(QStringLiteral("qml")));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.load(url);
    const int settleMs = parser.value(QStringLiteral("settle-ms")).toInt();
    QTimer::singleShot(settleMs, &app, [&] {
        auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().value(0));
        if (!window || !window->grabWindow().save(parser.value(QStringLiteral("output"))))
            QCoreApplication::exit(2);
        else
            app.quit();
    });
    return app.exec();
}
