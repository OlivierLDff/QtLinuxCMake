# find the Qt root directory
if(NOT Qt6Core_DIR)
  find_package(Qt6Core REQUIRED)
endif()
get_filename_component(QT_LINUX_QT_ROOT "${Qt6Core_DIR}/../../.." ABSOLUTE)
message(STATUS "Found Qt for Linux: ${QT_LINUX_QT_ROOT}")

set(QT_LINUX_QT_ROOT ${QT_LINUX_QT_ROOT})
set(QT_LINUX_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR})

if(NOT QT_LINUX_DEPLOY_APP)
  find_program(QT_LINUX_DEPLOY_APP linuxdeploy-x86_64.AppImage HINTS ${CMAKE_CURRENT_BINARY_DIR})
  if(QT_LINUX_DEPLOY_APP)
    message(STATUS "Found linuxdeploy-x86_64.AppImage : ${QT_LINUX_DEPLOY_APP}")
  else()
    set(QT_LINUX_DEPLOY_APP ${CMAKE_CURRENT_BINARY_DIR}/linuxdeploy-x86_64.AppImage)
    message(STATUS "Failed to find linuxdeploy-x86_64.AppImage, download from https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage to ${QT_LINUX_DEPLOY_APP}")
    file(DOWNLOAD "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" ${CMAKE_CURRENT_BINARY_DIR}/tmp/linuxdeploy-x86_64.AppImage)

    file(
      COPY ${CMAKE_CURRENT_BINARY_DIR}/tmp/linuxdeploy-x86_64.AppImage
      DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
      FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    )

    file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/tmp/linuxdeploy-x86_64.AppImage)
  endif()
endif()

if(NOT QT_LINUX_DEPLOY_PLUGIN)
  find_program(QT_LINUX_DEPLOY_PLUGIN linuxdeploy-plugin-qt-x86_64.AppImage HINTS ${CMAKE_CURRENT_BINARY_DIR})
  if(QT_LINUX_DEPLOY_PLUGIN)
    message(STATUS "Found linuxdeploy-plugin-qt-x86_64.AppImage : ${QT_LINUX_DEPLOY_PLUGIN}")
  else()
    set(QT_LINUX_DEPLOY_PLUGIN ${CMAKE_CURRENT_BINARY_DIR}/linuxdeploy-plugin-qt-x86_64.AppImage)
    message(STATUS "Failed to find linuxdeploy-plugin-qt-x86_64.AppImage, download from https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage to ${QT_LINUX_DEPLOY_PLUGIN}")
    file(DOWNLOAD "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage" ${CMAKE_CURRENT_BINARY_DIR}/tmp/linuxdeploy-plugin-qt-x86_64.AppImage)

    file(
            COPY ${CMAKE_CURRENT_BINARY_DIR}/tmp/linuxdeploy-plugin-qt-x86_64.AppImage
            DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
            FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    )

    file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/tmp/linuxdeploy-plugin-qt-x86_64.AppImage)
  endif()
endif()

include(CMakeParseArguments)

function(add_qt_linux_appimage TARGET)

  set(QT_LINUX_OPTIONS
    ALL
    NO_APPIMAGE
    NO_COPYRIGHT_FILES
  )

  set(QT_LINUX_ONE_VALUE_ARG
    APP_DIR
    QML_DIR
    VERBOSE_LEVEL
  )

  set(QT_LINUX_MULTI_VALUE_ARG
    DEPENDS
    EXTRA_PLUGINS
  )
  # parse the function arguments
  cmake_parse_arguments(ARGIMG "${QT_LINUX_OPTIONS}" "${QT_LINUX_ONE_VALUE_ARG}" "${QT_LINUX_MULTI_VALUE_ARG}" ${ARGN})

  if(NOT ARGIMG_APP_DIR)
    message(FATAL_ERROR "add_qt_linux_appimage : appdir not specified")
  endif()

  # Check AppDir exists
  if(NOT EXISTS ${ARGIMG_APP_DIR})
    message(FATAL_ERROR "${ARGIMG_APP_DIR} doesn't exists")
  endif()

  set(QT_LINUX_DESKTOP_FILE usr/share/applications/${TARGET}.desktop)

  if(NOT EXISTS ${ARGIMG_APP_DIR}/${QT_LINUX_DESKTOP_FILE})
    message(FATAL_ERROR "${ARGIMG_APP_DIR}/${QT_LINUX_DESKTOP_FILE} doesn't exists")
  endif()

  # Find correct qmake
  set(QT_LINUX_QMAKE_PATH ${QT_LINUX_QT_ROOT}/bin/qmake)
  set(QT_LINUX_QMAKE_OPT -qmake=${QT_LINUX_QMAKE_PATH})

  # --output
  if(NOT ARGIMG_NO_APPIMAGE)
    set(QT_LINUX_APPIMAGE_OPT --output appimage)
  endif()

  # EXTRA_QT_PLUGINS
  # args are semicolon separated
  if(ARGIMG_EXTRA_PLUGINS)
    set(EXTRA_PLUGINS_LIST "")
    foreach(PLUGIN ${ARGIMG_EXTRA_PLUGINS})
      message(STATUS "Add Extra plugin : ${PLUGIN}")
      if(EXTRA_PLUGINS_LIST STREQUAL "")
        set(EXTRA_PLUGINS_LIST "${PLUGIN}")
      else()
        string(APPEND EXTRA_PLUGINS_LIST ";${PLUGIN}")
      endif()
    endforeach()
    message(STATUS "Extra plugins list : ${EXTRA_PLUGINS_LIST}")
    set(QT_LINUX_EXTRA_PLUGINS_OPT export EXTRA_QT_PLUGINS=${EXTRA_PLUGINS_LIST} &&)
  endif()

  # DISABLE_COPYRIGHT_FILES_DEPLOYMENT
  if(ARGIMG_NO_COPYRIGHT_FILES)
    set(QT_LINUX_COPYRIGHT_OPT export DISABLE_COPYRIGHT_FILES_DEPLOYMENT=1 &&)
  endif()

  # QML_SOURCES_PATHS
  if(ARGIMG_QML_DIR)
    set(QT_LINUX_QML_DIR_OPT export QML_SOURCES_PATHS=${ARGIMG_QML_DIR} &&)
  endif()

  # --verbosity
  if(ARGIMG_VERBOSE_LEVEL)
    set(QT_LINUX_VERBOSE_OPT "--verbosity ${ARGIMG_VERBOSE_LEVEL}")
    set(QT_LINUX_PLUGIN_VERBOSE_OPT export DEBUG=${ARGIMG_VERBOSE_LEVEL} &&)
  endif()

  if(ARGIMG_ALL)
    set(QT_LINUX_ALL ALL)
  endif()

  set(QT_LINUX_TARGET ${TARGET}AppImage)

  if(ARGIMG_ALLOW_ENVIRONMENT_VARIABLE)
    set(ALLOW_ENVIRONMENT_VARIABLE ON)
  else()
    set(ALLOW_ENVIRONMENT_VARIABLE OFF)
  endif()

  if(ARGIMG_VERBOSE_LEVEL)
    message(STATUS "ARGIMG_APP_DIR : ${ARGIMG_APP_DIR}")
    message(STATUS "QT_LINUX_TARGET : ${QT_LINUX_TARGET}")
    message(STATUS "QT_LINUX_DEPLOY_APP : ${QT_LINUX_DEPLOY_APP}")
    message(STATUS "QT_LINUX_APPIMAGE_OPT : ${QT_LINUX_APPIMAGE_OPT}")
    message(STATUS "QT_LINUX_QML_DIR_OPT : ${QT_LINUX_QML_DIR_OPT}")
    message(STATUS "QT_LINUX_EXTRA_PLUGINS_OPT : ${QT_LINUX_EXTRA_PLUGINS_OPT}")
    message(STATUS "QT_LINUX_VERBOSE_OPT : ${QT_LINUX_VERBOSE_OPT}")
    message(STATUS "NO_COPYRIGHT_FILES : ${ARGIMGNO_COPYRIGHT_FILES}")
  endif()

  # Call linuxdeployqt
  add_custom_target(${QT_LINUX_TARGET}
    ${QT_LINUX_ALL}
    DEPENDS ${TARGET} ${ARGIMG_DEPENDS}
    COMMAND ${CMAKE_COMMAND} -DALLOW_ENVIRONMENT_VARIABLE=${ALLOW_ENVIRONMENT_VARIABLE} -DAPPRUN_PATH=${CMAKE_CURRENT_BINARY_DIR}/AppDir -DTARGET_FILE_NAME=$<TARGET_FILE_NAME:${TARGET}> -P "${QT_LINUX_SOURCE_DIR}/GenerateAppRun.cmake"
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${ARGIMG_APP_DIR} ${CMAKE_CURRENT_BINARY_DIR}/AppDir
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${TARGET}> ${CMAKE_CURRENT_BINARY_DIR}/AppDir/usr/bin/$<TARGET_FILE_NAME:${TARGET}>
    COMMAND ${QT_LINUX_QML_DIR_OPT}
            ${QT_LINUX_COPYRIGHT_OPT}
            ${QT_LINUX_PLUGIN_VERBOSE_OPT}
            ${QT_LINUX_EXTRA_PLUGINS_OPT}
            export PATH=/usr/bin/:${QT_LINUX_QT_ROOT}/bin/:${QT_LINUX_QT_ROOT}/libexec/ &&
            ${QT_LINUX_DEPLOY_APP}
            --appdir AppDir
            -d ${CMAKE_CURRENT_BINARY_DIR}/AppDir/${QT_LINUX_DESKTOP_FILE}
            -e CloudCompanionStandalone
            ${QT_LINUX_VERBOSE_OPT}
            --plugin qt
            ${QT_LINUX_APPIMAGE_OPT}

    COMMENT "Deploy AppImage with ${QT_LINUX_DEPLOY_APP}. Source are in ${QT_LINUX_SOURCE_DIR}"
  )

endfunction()