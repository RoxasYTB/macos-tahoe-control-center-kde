#pragma once

#include <QObject>
#include <QPointer>
#include <QQuickWindow>
#include <QUrl>

class BlurBehindRegion : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickWindow *window READ window WRITE setWindow NOTIFY windowChanged)
    Q_PROPERTY(QUrl maskSource READ maskSource WRITE setMaskSource NOTIFY maskSourceChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(int alphaThreshold READ alphaThreshold WRITE setAlphaThreshold NOTIFY alphaThresholdChanged)

public:
    explicit BlurBehindRegion(QObject *parent = nullptr);
    ~BlurBehindRegion() override;

    QQuickWindow *window() const;
    void setWindow(QQuickWindow *window);

    QUrl maskSource() const;
    void setMaskSource(const QUrl &source);

    bool enabled() const;
    void setEnabled(bool enabled);

    int alphaThreshold() const;
    void setAlphaThreshold(int threshold);

    Q_INVOKABLE void refresh();

Q_SIGNALS:
    void windowChanged();
    void maskSourceChanged();
    void enabledChanged();
    void alphaThresholdChanged();

private:
    void apply();

    QPointer<QQuickWindow> m_window;
    QUrl m_maskSource;
    bool m_enabled = false;
    int m_alphaThreshold = 14;
};
