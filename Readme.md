# 💻 Qt Linux CMake

CMake macro to deploy and create installer for Qt application on windows.

![](https://user-images.githubusercontent.com/2480569/34471167-d44bd55e-ef41-11e7-941e-e091a83cae38.png)

## What it is

The project provide a cmake function that wrap [linuxdeployqt](https://github.com/probonopd/linuxdeployqt). You will need **linuxdeployqt** installed for the function to work.

This Linux Deployment Tool, `linuxdeployqt`, takes an application as input and makes it self-contained by copying in the resources that the application uses (like libraries, graphics, and plugins) into a bundle. The resulting bundle can be distributed as an AppDir or as an [AppImage](https://appimage.org/) to users, or can be put into cross-distribution packages. It can be used as part of the build process to deploy applications written in C, C++, and other compiled languages with systems like `CMake`, `qmake`, and `make`. When used on Qt-based applications, it can bundle a specific minimal subset of Qt required to run the application.

## Usage

```cmake
add_qt_linux_appimage(MyApp
  ALL
  APP_DIR ${CMAKE_CURRENT_SOURCE_DIR}/AppDir
  QML_DIR ${PROJECT_SOURCE_DIR}/qml
  NO_COPYRIGHT_FILES
  # NO_TRANSLATIONS
  # NO_PLUGINS
  # NO_STRIP
  # NO_APPIMAGE
  VERBOSE_LEVEL 3
)
```

This function will generate a target `MyAppAppImage`.

**APP_DIR**

Should point to the folder containing an AppDir structure.

```
└── usr
    ├── bin
    │   └── your_app
    ├── lib
    └── share
        ├── applications
        │   └── your_app.desktop
        └── icons
            └── <theme>
                └── <resolution> 
                    └── apps 
                        └── your_app.png
```

**QML_DIR**

Scan for QML imports in the given path.

**NO_TRANSLATIONS**

Skip deployment of translations.

**NO_PLUGINS**

Skip plugin deployment.

**NO_STRIP**

Don't run 'strip' on the binaries.

**NO_APPIMAGE**

Only create AppDir

**NO_COPYRIGHT_FILES**

Skip deployment of copyright files.

## Examples

The project [QaterialGallery](https://github.com/OlivierLDff/QaterialGallery) show usage.

## 🐳 Run in Docker

It can be very annoying to set the perfect environment to deploy an app, even in CI. I created a docker image ready to be used with this macro.

* https://hub.docker.com/repository/docker/reivilo1234/qt-linux-cmake