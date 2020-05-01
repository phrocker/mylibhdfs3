CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

PROJECT(libhdfs3)


include(CheckCXXCompilerFlag)
include(ExternalProject)



CHECK_CXX_COMPILER_FLAG("-std=c++14" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX14)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
elseif(COMPILER_SUPPORTS_CXX0X)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
else()
 message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++14 support. Please use a different C++ compiler.")
endif()




SET(CMAKE_VERBOSE_MAKEFILE ON CACHE STRING "Verbose build." FORCE)

SET(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
SET(DOXYFILE_PATH ${CMAKE_SOURCE_DIR}/docs)


###INCLUDE options

INCLUDE(Platform)
INCLUDE(Options)



if (ENABLE_KERBEROS)
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DUSE_KRB5")
endif(ENABLE_KERBEROS)

## Updated to add LibreSSL

INCLUDE(Functions)

INCLUDE(LibreSSL)
include(Compression)
include(LibXML2)

######################  ZLIB
use_bundled_zlib(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
######################  ZLIB


######################  libreSSL
use_libre_ssl(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
######################  libreSSL

######################  LibXML2
download_lib_xml(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
######################  LibXML2



FIND_PACKAGE(LibXml2 REQUIRED)

if (ENABLE_KERBEROS)
	FIND_PACKAGE(KERBEROS REQUIRED)
endif()
FIND_PACKAGE(Protobuf REQUIRED)
if (ENABLE_KERBEROS)
	FIND_PACKAGE(GSasl REQUIRED)
endif (ENABLE_KERBEROS)
FIND_PACKAGE(OpenSSL REQUIRED)
FIND_PACKAGE(Curl REQUIRED)
if (ENABLE_TEST)
FIND_PACKAGE(GoogleTest REQUIRED)
	INCLUDE_DIRECTORIES(${GoogleTest_INCLUDE_DIR})
	LINK_LIBRARIES(${GoogleTest_LIBRARIES})
endif(ENABLE_TEST)

IF(OS_LINUX)
	include_directories("thirdparty/uuid/include/posix")
	add_subdirectory("thirdparty/uuid")
	include_directories(thirdparty/ut)
	set(UUID_FOUND "YES" CACHE STRING "" FORCE)
	set(UUID_LIBRARIES "uuid" CACHE STRING "" FORCE)
ENDIF(OS_LINUX)

if (ENABLE_TEST)
	ADD_SUBDIRECTORY(mock)
endif(ENABLE_TEST)
ADD_SUBDIRECTORY(src)
if (ENABLE_TEST)
	ADD_SUBDIRECTORY(test)
endif(ENABLE_TEST)

CONFIGURE_FILE(src/libhdfs3.pc.in ${CMAKE_SOURCE_DIR}/src/libhdfs3.pc @ONLY)
CONFIGURE_FILE(debian/changelog.in ${CMAKE_SOURCE_DIR}/debian/changelog @ONLY)



ADD_CUSTOM_TARGET(style
	COMMAND astyle --style=attach --indent=spaces=4 --indent-preprocessor --break-blocks --pad-oper --pad-header --unpad-paren --delete-empty-lines --suffix=none --align-pointer=middle --lineend=linux --indent-col1-comments ${libhdfs3_SOURCES}
	COMMAND astyle --style=attach --indent=spaces=4 --indent-preprocessor --break-blocks --pad-oper --pad-header --unpad-paren --delete-empty-lines --suffix=none --align-pointer=middle --lineend=linux --indent-col1-comments ${unit_SOURCES}
	COMMAND astyle --style=attach --indent=spaces=4 --indent-preprocessor --break-blocks --pad-oper --pad-header --unpad-paren --delete-empty-lines --suffix=none --align-pointer=middle --lineend=linux --indent-col1-comments ${function_SOURCES}
	COMMAND astyle --style=attach --indent=spaces=4 --indent-preprocessor --break-blocks --pad-oper --pad-header --unpad-paren --delete-empty-lines --suffix=none --align-pointer=middle --lineend=linux --indent-col1-comments ${secure_SOURCES}
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	COMMENT "format code style..."
)
