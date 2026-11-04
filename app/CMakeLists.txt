cmake_minimum_required(VERSION 3.21)
project(tahoe_control_center LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick Widgets DBus)
find_package(KF6WindowSystem REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(XCB REQUIRED IMPORTED_TARGET xcb)

add_executable(tahoe-control-center
    main.cpp
    TrayController.cpp
    TrayController.h
    SystemControlController.cpp
    SystemControlController.h
    ../native/BlurBehindRegion.cpp
    ../native/BlurBehindRegion.h
    controlcenter.qrc
)

target_link_libraries(tahoe-control-center PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Widgets
    Qt6::DBus
    KF6::WindowSystem
    PkgConfig::XCB
)

install(TARGETS tahoe-control-center RUNTIME DESTINATION bin)
install(FILES control-center.desktop DESTINATION share/applications)
install(FILES ../contents/ui/components/icons/control-centre-iconscout-white.png
        DESTINATION share/icons/hicolor/512x512/apps)
