
ADD_EXECUTABLE(recovery main.cpp)
  
TARGET_LINK_LIBRARIES(recovery rtabmap_core)

SET_TARGET_PROPERTIES( recovery 
	PROPERTIES OUTPUT_NAME ${PROJECT_PREFIX}-recovery)

INSTALL(TARGETS recovery
		RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT runtime
		BUNDLE DESTINATION "${CMAKE_BUNDLE_LOCATION}" COMPONENT runtime)



