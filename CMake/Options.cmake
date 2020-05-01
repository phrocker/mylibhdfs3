OPTION(ENABLE_COVERAGE "enable code coverage" OFF)
OPTION(ENABLE_DEBUG "enable debug build" OFF)
OPTION(ENABLE_SSE "enable SSE4.2 buildin function" ON)
OPTION(ENABLE_FRAME_POINTER "enable frame pointer on 64bit system with flag -fno-omit-frame-pointer, on 32bit system, it is always enabled" ON)
OPTION(ENABLE_LIBCPP "using libc++ instead of libstdc++, only valid for clang compiler" OFF)
OPTION(ENABLE_BOOST "using boost instead of native compiler c++0x support" OFF)
option(ENABLE_KERBEROS "Enable Kerberos Fx" OFF)
option(ENABLE_TEST "Enables Testing. Off by default" OFF)

INCLUDE (CheckFunctionExists)
CHECK_FUNCTION_EXISTS(dladdr HAVE_DLADDR)
CHECK_FUNCTION_EXISTS(nanosleep HAVE_NANOSLEEP)


CHECK_CXX_COMPILER_FLAG("-std=c++14" COMPILER_SUPPORTS_CXX14)
if(COMPILER_SUPPORTS_CXX14)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
else()
 message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++14 support. Please use a different C++ compiler.")
endif()

IF(ENABLE_DEBUG STREQUAL ON)
    SET(CMAKE_BUILD_TYPE Debug CACHE 
        STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
    SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0" CACHE STRING "compiler flags for debug" FORCE)
    SET(CMAKE_C_FLAGS_DEBUG "-g -O0" CACHE STRING "compiler flags for debug" FORCE)
ELSE(ENABLE_DEBUG STREQUAL ON)
    SET(CMAKE_BUILD_TYPE RelWithDebInfo CACHE 
        STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
ENDIF(ENABLE_DEBUG STREQUAL ON)

SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-strict-aliasing")
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-strict-aliasing")

IF(ENABLE_COVERAGE STREQUAL ON)
    INCLUDE(CodeCoverage)
ENDIF(ENABLE_COVERAGE STREQUAL ON)

IF(ENABLE_FRAME_POINTER STREQUAL ON)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer")
ENDIF(ENABLE_FRAME_POINTER STREQUAL ON) 

IF(ENABLE_SSE STREQUAL ON)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msse4.2")
ENDIF(ENABLE_SSE STREQUAL ON) 

IF(NOT TEST_HDFS_PREFIX)
SET(TEST_HDFS_PREFIX "./" CACHE STRING "default directory prefix used for test." FORCE)
ENDIF(NOT TEST_HDFS_PREFIX)

ADD_DEFINITIONS(-DTEST_HDFS_PREFIX="${TEST_HDFS_PREFIX}")
ADD_DEFINITIONS(-D__STDC_FORMAT_MACROS)
ADD_DEFINITIONS(-D_GNU_SOURCE)

IF(OS_MACOSX AND CMAKE_COMPILER_IS_GNUCXX)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wl,-bind_at_load")
ENDIF(OS_MACOSX AND CMAKE_COMPILER_IS_GNUCXX)

IF(OS_LINUX)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wl,--export-dynamic")
ENDIF(OS_LINUX)

SET(BOOST_ROOT ${CMAKE_PREFIX_PATH})
IF(ENABLE_BOOST STREQUAL ON)
    MESSAGE(STATUS "using boost instead of native compiler c++0x support.")
    FIND_PACKAGE(Boost 1.50 REQUIRED)
    SET(NEED_BOOST true CACHE INTERNAL "boost is required")
ELSE(ENABLE_BOOST STREQUAL ON)
    SET(NEED_BOOST false CACHE INTERNAL "boost is required")
ENDIF(ENABLE_BOOST STREQUAL ON)


TRY_COMPILE(STRERROR_R_RETURN_INT
	${CMAKE_BINARY_DIR}
	${CMAKE_SOURCE_DIR}/CMake/CMakeTestCompileStrerror.cpp
    CMAKE_FLAGS "-DCMAKE_CXX_LINK_EXECUTABLE='echo not linking now...'"
	OUTPUT_VARIABLE OUTPUT)

MESSAGE(STATUS "Checking whether strerror_r returns an int")

IF(STRERROR_R_RETURN_INT)
	MESSAGE(STATUS "Checking whether strerror_r returns an int -- yes")
ELSE(STRERROR_R_RETURN_INT)
	MESSAGE(STATUS "Checking whether strerror_r returns an int -- no")
ENDIF(STRERROR_R_RETURN_INT)

TRY_COMPILE(HAVE_STEADY_CLOCK
	${CMAKE_BINARY_DIR}
	${CMAKE_SOURCE_DIR}/CMake/CMakeTestCompileSteadyClock.cpp
    CMAKE_FLAGS "-DCMAKE_CXX_LINK_EXECUTABLE='echo not linking now...'"
	OUTPUT_VARIABLE OUTPUT)

TRY_COMPILE(HAVE_NESTED_EXCEPTION
	${CMAKE_BINARY_DIR}
	${CMAKE_SOURCE_DIR}/CMake/CMakeTestCompileNestedException.cpp
    CMAKE_FLAGS "-DCMAKE_CXX_LINK_EXECUTABLE='echo not linking now...'"
	OUTPUT_VARIABLE OUTPUT)

FILE(WRITE ${CMAKE_BINARY_DIR}/test.cpp "#include <boost/chrono.hpp>")
TRY_COMPILE(HAVE_BOOST_CHRONO
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/test.cpp 
    CMAKE_FLAGS "-DCMAKE_CXX_LINK_EXECUTABLE='echo not linking now...'"
    -DINCLUDE_DIRECTORIES=${Boost_INCLUDE_DIR}
    OUTPUT_VARIABLE OUTPUT)

FILE(WRITE ${CMAKE_BINARY_DIR}/test.cpp "#include <chrono>")
TRY_COMPILE(HAVE_STD_CHRONO
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/test.cpp 
    CMAKE_FLAGS "-DCMAKE_CXX_LINK_EXECUTABLE='echo not linking now...'"
    OUTPUT_VARIABLE OUTPUT)

FILE(WRITE ${CMAKE_BINARY_DIR}/test.cpp "#include <boost/atomic.hpp>")
TRY_COMPILE(HAVE_BOOST_ATOMIC
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/test.cpp 
    CMAKE_FLAGS "-DCMAKE_CXX_LINK_EXECUTABLE='echo not linking now...'"
    -DINCLUDE_DIRECTORIES=${Boost_INCLUDE_DIR}
    OUTPUT_VARIABLE OUTPUT)
    
FILE(WRITE ${CMAKE_BINARY_DIR}/test.cpp "#include <atomic>")
TRY_COMPILE(HAVE_STD_ATOMIC
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/test.cpp 
    CMAKE_FLAGS "-DCMAKE_CXX_LINK_EXECUTABLE='echo not linking now...'"
    OUTPUT_VARIABLE OUTPUT)
