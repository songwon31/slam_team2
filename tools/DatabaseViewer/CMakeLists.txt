
IF(MINGW)
  ADD_EXECUTABLE(databaseViewer WIN32 main.cpp)
ELSE()
  ADD_EXECUTABLE(databaseViewer main.cpp)
ENDIF()

TARGET_LINK_LIBRARIES(databaseViewer rtabmap_gui)

SET_TARGET_PROPERTIES( databaseViewer 
  PROPERTIES OUTPUT_NAME ${PROJECT_PREFIX}-databaseViewer)

INSTALL(TARGETS databaseViewer
		RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT runtime
		BUNDLE DESTINATION "${CMAKE_BUNDLE_LOCATION}" COMPONENT runtime)
