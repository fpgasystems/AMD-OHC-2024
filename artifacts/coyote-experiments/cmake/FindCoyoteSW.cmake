#
# Coyote SW package
#
cmake_minimum_required(VERSION 3.0)
#project(CoyoteSW)

# Includes
include_directories(${CYT_DIR}/sw/include)

# Sources
file(GLOB SOURCES ${CYT_DIR}sw/src/*.cpp)

# AVX support (Disable on Enzian)
set(EN_AVX 1 CACHE STRING "AVX environment.")

# Set exec
set(EXEC main)

# Coyote directory
macro(validation_checks)

    # Coyote directory
    if(NOT DEFINED CYT_DIR)
        message(FATAL_ERROR "Coyote directory not set.")
    endif()

    # AVX check
    if(FDEV_NAME STREQUAL "enzian")
        if(EN_AVX)
            set(EN_AVX 0)
        endif()
    endif()

endmacro

