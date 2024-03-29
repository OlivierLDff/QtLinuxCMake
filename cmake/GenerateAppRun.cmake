if(NOT ALLOW_ENVIRONMENT_VARIABLE)
  message(STATUS "Generate AppRun that ignore environment variable LD_LIBRARY_PATH/QT_PLUGIN_PATH/QML2_IMPORT_PATH in ${APPRUN_PATH} for target ${TARGET_FILE_NAME}")

  file(WRITE ${APPRUN_PATH}/tmp/AppRun
    "#!/bin/bash\n"
    "#File auto generated by add_qt_linux_appimage to ignore system environment variables that may affect the app start.\n"
    "HERE=\"$(dirname \"$(readlink -f \"\${0}\")\")\"\n"
    "export LD_LIBRARY_PATH=\"\"\n"
    "export QT_PLUGIN_PATH=\"\"\n"
    "export QML2_IMPORT_PATH=\"\"\n"
    "exec \"\${HERE}/usr/bin/${TARGET_FILE_NAME}\" \"$@\"\n"
  )

  file(
    COPY ${APPRUN_PATH}/tmp/AppRun
    DESTINATION ${APPRUN_PATH}
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
  )

  file(REMOVE_RECURSE ${APPRUN_PATH}/tmp)

endif()