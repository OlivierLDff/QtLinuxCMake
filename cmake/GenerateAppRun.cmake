if(NOT ALLOW_ENVIRONMENT_VARIABLE)
  message(STATUS "Generate AppRun that ignore environment variable LD_LIBRARY_PATH/QT_PLUGIN_PATH/QML2_IMPORT_PATH in ${APPRUN_PATH} for target ${TARGET_FILE_NAME}")

  file(WRITE ${APPRUN_PATH}
    "#!/bin/bash\n"
    "export LD_LIBRARY_PATH=\"\"\n"
    "export QT_PLUGIN_PATH=\"\"\n"
    "export QML2_IMPORT_PATH=\"\"\n"
    "usr/bin/${TARGET_FILE_NAME}\n"
  )
endif()