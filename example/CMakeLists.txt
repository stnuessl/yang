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


include(cmake/python.cmake)
include(cmake/yang.cmake)
include(cmake/util.cmake)

set(YANG_SCRIPT "${CMAKE_SOURCE_DIR}/src/yang/__main__.py")
set(YANG_TEMPLATE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/template/build.j2")

if (YANG_ENABLE_CCACHE)
    set(YANG_COMPILE_RULE_CLANG compile-object-ccache-clang)
    set(YANG_COMPILE_RULE_GCC compile-object-ccache-gcc)
else()
    set(YANG_COMPILE_RULE_CLANG compile-object-clang)
    set(YANG_COMPILE_RULE_GCC compile-object-gcc)
endif()

set(YANG_LINK_STATIC_RULE link-static-ar)
set(YANG_LINK_EXECUTABLE_RULE_CLANG link-executable-clang)
set(YANG_LINK_EXECUTABLE_RULE_GCC link-executable-gcc)

set(YANG_COMPILE_OPTIONS -O2 -pedantic -Wall -Wextra -Werror)
#
# Single executable.
#

util_add_executable(
    app1-cmake
    SOURCES src/core/core.c
            src/drivers/drivers.c
            src/init/init.c
            src/io/io.S
            src/main.c
            src/utils/utils.c
    COMPILE_DEFINITIONS APP_MESSAGE="\\\"Hello, World!\\\""
    COMPILE_OPTIONS -O2 -Wall -Wextra
    INCLUDE_DIRECTORIES include
    YANG_NAME app1
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_EXECUTABLE_RULE_CLANG}"
)

set_target_properties(
    app1-cmake
    PROPERTIES
    YANG_COMPILE_OPTIONS "${YANG_COMPILE_OPTIONS}"
)

#
# Executable depends on library.
#

util_add_executable(
    app2-cmake
    SOURCES src/main.c
    COMPILE_DEFINITIONS APP_MESSAGE="\\\"Hello, World!\\\""
    INCLUDE_DIRECTORIES include
    LINK_LIBRARIES lib2-cmake
    YANG_NAME app2
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_EXECUTABLE_RULE_CLANG}"
)

set_target_properties(
    app2-cmake
    PROPERTIES
    YANG_COMPILE_OPTIONS "${YANG_COMPILE_OPTIONS}"
)

util_add_library(
    lib2-cmake
    STATIC
    SOURCES src/core/core.c
            src/drivers/drivers.c
            src/init/init.c
            src/io/io.S
            src/utils/utils.c
    COMPILE_OPTIONS -O2 -Wall -pedantic
    INCLUDE_DIRECTORIES include
    YANG_NAME lib2
    YANG_COMPILE_RULE "compile-object-ccache-clang"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"
)

set_target_properties(
    lib2-cmake
    PROPERTIES
    YANG_COMPILE_OPTIONS "${YANG_COMPILE_OPTIONS}"
)

#
# Executable depends on multiple libraries.
#

util_add_executable(
    app3-cmake
    SOURCES src/main.c
    COMPILE_DEFINITIONS APP_MESSAGE="\\\"Hello, World!\\\""
    COMPILE_OPTIONS -Og -g2 -Wall -Werror
    INCLUDE_DIRECTORIES include
    LINK_LIBRARIES core3-cmake
                   drivers3-cmake
                   init3-cmake
                   io3-cmake
                   utils3-cmake
    YANG_NAME app3
    YANG_COMPILE_RULE "compile-object-ccache-gcc"
    YANG_LINK_RULE "${YANG_LINK_EXECUTABLE_RULE_GCC}"
)

util_add_library(
    core3-cmake
    STATIC
    SOURCES src/core/core.c
    INCLUDE_DIRECTORIES include
    YANG_NAME core3
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"
)

util_add_library(
    drivers3-cmake
    STATIC
    SOURCES src/drivers/drivers.c
    INCLUDE_DIRECTORIES include
    YANG_NAME drivers3
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"
)

util_add_library(
    init3-cmake
    STATIC
    SOURCES src/init/init.c
    INCLUDE_DIRECTORIES include
    YANG_NAME init3
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"
)

util_add_library(
    io3-cmake
    STATIC
    SOURCES src/io/io.S
    INCLUDE_DIRECTORIES include
    YANG_NAME io3
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"
)

util_add_library(
    utils3-cmake
    STATIC
    SOURCES src/utils/utils.c
    INCLUDE_DIRECTORIES include
    YANG_NAME utils3
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"
)

#
# Executable depends on library which depends on multiple libraries.
#

util_add_executable(
    app4-cmake
    SOURCES src/main.c
    INCLUDE_DIRECTORIES include
    COMPILE_DEFINITIONS APP_MESSAGE="\\\"Hello, World!\\\""
    LINK_LIBRARIES lib4-cmake
    YANG_NAME app4
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_EXECUTABLE_RULE_CLANG}"
)

util_add_library(
    lib4-cmake
    STATIC
    SOURCES src/core/core.c
    INCLUDE_DIRECTORIES include
    LINK_LIBRARIES drivers4-cmake
                   init4-cmake
                   io4-cmake
                   utils4-cmake
    YANG_NAME lib4
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"

)

set_target_properties(
    lib4-cmake
    PROPERTIES
    YANG_LINK_OPTIONS "--thin"
)

util_add_library(
    drivers4-cmake
    STATIC
    SOURCES src/drivers/drivers.c
    INCLUDE_DIRECTORIES include
    YANG_NAME drivers4
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"

)

util_add_library(
    init4-cmake
    STATIC
    SOURCES src/init/init.c
    INCLUDE_DIRECTORIES include
    YANG_NAME init4
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"

)

util_add_library(
    io4-cmake
    STATIC
    SOURCES src/io/io.S
    INCLUDE_DIRECTORIES include
    YANG_NAME io4
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"

)

util_add_library(
    utils4-cmake
    STATIC
    SOURCES src/utils/utils.c
    INCLUDE_DIRECTORIES include
    YANG_NAME utils4
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"

)


#
# Executable depends on an object library.
#

util_add_executable(
    app5-cmake
    SOURCES src/main.c
    INCLUDE_DIRECTORIES include
    COMPILE_DEFINITIONS APP_MESSAGE="\\\"Hello, World!\\\""
    LINK_LIBRARIES lib5-cmake
    YANG_NAME app5
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_EXECUTABLE_RULE_CLANG}"
)

util_add_library(
    lib5-cmake
    OBJECT
    SOURCES src/core/core.c
            src/drivers/drivers.c
            src/init/init.c
            src/io/io.S
            src/utils/utils.c
    INCLUDE_DIRECTORIES include
    YANG_NAME lib5
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE ""
)


#
# Executable depends on multiple object libraries.
#

util_add_executable(
    app6-cmake
    SOURCES src/main.c
    INCLUDE_DIRECTORIES include
    COMPILE_DEFINITIONS APP_MESSAGE="\\\"Hello, World!\\\""
    LINK_LIBRARIES core6-cmake
                   drivers6-cmake
                   init6-cmake
                   io6-cmake
                   utils6-cmake
    YANG_NAME app6
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_EXECUTABLE_RULE_CLANG}"
)

util_add_library(
    core6-cmake
    OBJECT
    SOURCES src/core/core.c
    INCLUDE_DIRECTORIES include
    YANG_NAME core6
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
)

util_add_library(
    drivers6-cmake
    OBJECT
    SOURCES src/drivers/drivers.c
    INCLUDE_DIRECTORIES include
    YANG_NAME drivers6
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
)

util_add_library(
    init6-cmake
    OBJECT
    SOURCES src/init/init.c
    INCLUDE_DIRECTORIES include
    YANG_NAME init6
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
)

util_add_library(
    io6-cmake
    OBJECT
    SOURCES src/io/io.S
    INCLUDE_DIRECTORIES include
    YANG_NAME io6
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
)

util_add_library(
    utils6-cmake
    OBJECT
    SOURCES src/utils/utils.c
    INCLUDE_DIRECTORIES include
    YANG_NAME utils6
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
)

#
# Executable depends on library which depends on object libraries.
#

util_add_executable(
    app7-cmake
    SOURCES src/main.c
    INCLUDE_DIRECTORIES include
    COMPILE_DEFINITIONS APP_MESSAGE="\\\"Hello, World!\\\""
    LINK_LIBRARIES lib7-cmake
    YANG_NAME app7
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_EXECUTABLE_RULE_CLANG}"
)

util_add_library(
    lib7-cmake
    STATIC
    SOURCES src/core/core.c
    INCLUDE_DIRECTORIES include
    LINK_LIBRARIES drivers7-cmake
                   init7-cmake
                   io7-cmake
                   utils7-cmake
    YANG_NAME lib7
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
    YANG_LINK_RULE "${YANG_LINK_STATIC_RULE}"
)

util_add_library(
    drivers7-cmake
    OBJECT
    SOURCES src/drivers/drivers.c
    INCLUDE_DIRECTORIES include
    YANG_NAME drivers7
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
)

util_add_library(
    init7-cmake
    OBJECT
    SOURCES src/init/init.c
    INCLUDE_DIRECTORIES include
    YANG_NAME init7
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
)

util_add_library(
    io7-cmake
    OBJECT
    SOURCES src/io/io.S
    INCLUDE_DIRECTORIES include
    YANG_NAME io7
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
)

util_add_library(
    utils7-cmake
    OBJECT
    SOURCES src/utils/utils.c
    INCLUDE_DIRECTORIES include
    YANG_NAME utils7
    YANG_COMPILE_RULE "${YANG_COMPILE_RULE_CLANG}"
)


get_directory_property(TARGETS BUILDSYSTEM_TARGETS)


cmake_path(
    APPEND
    CMAKE_CURRENT_BINARY_DIR
    "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
    OUTPUT_VARIABLE
    OUTPUT_DIR
)

yang_add_build(
    app
    BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/yang"
    OUTPUT_DIRECTORY "${OUTPUT_DIR}"
    TEMPLATE_FILE "${YANG_TEMPLATE_FILE}"
    FROM_TARGET app1-cmake
                app2-cmake
                app3-cmake
                app4-cmake
                app5-cmake
                app6-cmake
                app7-cmake
)

add_custom_target(
    run-apps
    ALL
    COMMAND ${OUTPUT_DIR}/app1
    COMMAND ${OUTPUT_DIR}/app2
    COMMAND ${OUTPUT_DIR}/app3
    COMMAND ${OUTPUT_DIR}/app4
    COMMAND ${OUTPUT_DIR}/app5
    COMMAND ${OUTPUT_DIR}/app6
    COMMAND ${OUTPUT_DIR}/app7
    DEPENDS app
)


