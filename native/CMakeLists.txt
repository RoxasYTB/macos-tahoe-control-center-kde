cmake_minimum_required(VERSION 3.21)
project(controlcenterblurplugin LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)
find_package(KF6WindowSystem REQUIRED)

add_library(controlcenterblurplugin MODULE
    BlurBehindRegion.cpp
    BlurBehindRegion.h
    QmlPlugin.cpp
)

target_link_libraries(controlcenterblurplugin PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    KF6::WindowSystem
)

set_target_properties(controlcenterblurplugin PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)
