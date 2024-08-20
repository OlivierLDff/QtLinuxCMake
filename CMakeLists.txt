cmake_minimum_required(VERSION 3.0)

include(cmake/AddQtLinuxAppImage.cmake)

set(QT_LINUX_QT_ROOT ${QT_LINUX_QT_ROOT} CACHE STRING "qt sdk root folder")
set(QT_LINUX_SOURCE_DIR ${QT_LINUX_SOURCE_DIR} CACHE STRING "add_qt_linux_appimage CMakeLists.txt folder")

set(QT_LINUX_CMAKE_FOUND ON CACHE BOOL "QLinuxCMake have been found" FORCE)
set(QT_LINUX_CMAKE_VERSION "1.2.2" CACHE STRING "QLinuxCMake version" FORCE)

set(QT_LINUX_DEPLOY_APP ${QT_LINUX_DEPLOY_APP} CACHE STRING "linuxdeployqt program" FORCE)
