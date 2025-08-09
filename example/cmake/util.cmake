#
# The MIT License (MIT)
#
# Copyright (c) 2025 Steffen Nuessle
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

include_guard(GLOBAL)

macro(util_assert_arg PREFIX NAME)
    if (NOT DEFINED ${PREFIX}_${NAME})
        message(
            FATAL_ERROR
            "${CMAKE_CURRENT_FUNCTION}(): missing argument \"${NAME}\""
        )
    endif()
endmacro()

function(util_get_target_property OUTPUT_VARIABLE TARGET PROPERTY)
    set(DEFAULT_VALUE "${ARGN}")

    get_target_property(VALUE ${TARGET} ${PROPERTY})

    if ("${VALUE}" STREQUAL "VALUE-NOTFOUND")
        set(VALUE "${DEFAULT_VALUE}")
    endif()

    set(${OUTPUT_VARIABLE} "${VALUE}" PARENT_SCOPE)
endfunction()


function(util_configure_target TARGET)
    set(FLAG_ARGS "")
    set(
        ONE_VALUE_ARGS
        YANG_NAME
        YANG_COMPILE_RULE
        YANG_LINK_RULE
    )
    set(
        MULTI_VALUE_ARGS
        COMPILE_DEFINITIONS
        COMPILE_OPTIONS
        INCLUDE_DIRECTORIES
        LINK_LIBRARIES
        LINK_OPTIONS
        SOURCES
    )

    cmake_parse_arguments(
        ARG
        "${FLAG_ARGS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN}
    )


    util_assert_arg(ARG YANG_NAME)
    util_assert_arg(ARG YANG_COMPILE_RULE)

    util_get_target_property(TYPE ${TARGET} TYPE)

    if ("${TYPE}" STREQUAL "OBJECT_LIBRARY")
        set(ARG_YANG_LINK_RULE "")
    endif()


    target_sources(${TARGET} PRIVATE ${ARG_SOURCES})

    set_target_properties(
        ${TARGET}
        PROPERTIES
        YANG_NAME "${ARG_YANG_NAME}"
        YANG_COMPILE_RULE "${ARG_YANG_COMPILE_RULE}"
        YANG_LINK_RULE "${ARG_YANG_LINK_RULE}"
    )

    if (DEFINED ARG_COMPILE_DEFINITIONS)
        target_compile_definitions(${TARGET} PRIVATE ${ARG_COMPILE_DEFINITIONS})
    endif()

    if (DEFINED ARG_COMPILE_OPTIONS)
        target_compile_options(${TARGET} PRIVATE ${ARG_COMPILE_OPTIONS})
    endif()

    if (DEFINED ARG_INCLUDE_DIRECTORIES)
        target_include_directories(${TARGET} PRIVATE ${ARG_INCLUDE_DIRECTORIES})
    endif()

    if (DEFINED ARG_LINK_LIBRARIES)
        target_link_libraries(${TARGET} PRIVATE ${ARG_LINK_LIBRARIES})
    endif()

    if (DEFINED ARG_LINK_OPTIONS)
        target_link_options(${TARGET} PRIVATE ${ARG_LINK_OPTIONS})
    endif()
endfunction()

function(util_add_executable TARGET)
    add_executable(${TARGET} EXCLUDE_FROM_ALL)
    util_configure_target(${TARGET} ${ARGN})
endfunction()

function(util_add_library TARGET TYPE)
    add_library(${TARGET} ${TYPE} EXCLUDE_FROM_ALL)
    util_configure_target(${TARGET} ${ARGN})
endfunction()

