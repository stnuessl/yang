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

include(${CMAKE_CURRENT_LIST_DIR}/util.cmake)

function(yang_add_spec)
    set(FLAG_ARGS "")
    set(
        ONE_VALUE_ARGS
        FROM_TARGET
        BINARY_DIR
        BUILD_OUTPUT
        BUILD_SPEC
    )
    set(
        MULTI_VALUE_ARGS
    )

    cmake_parse_arguments(
        ARG
        "${FLAG_ARGS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN}
    )

    util_assert_arg(ARG BINARY_DIR)
    util_assert_arg(ARG BUILD_OUTPUT)
    util_assert_arg(ARG BUILD_SPEC)
    util_assert_arg(ARG FROM_TARGET)

    file(MAKE_DIRECTORY ${ARG_BINARY_DIR})

    if ("${CMAKE_GENERATOR}" STREQUAL "Ninja")
        set(PREREQUISITE ${CMAKE_BINARY_DIR}/build.ninja)
    else()
        set(PREREQUISITE ${CMAKE_BINARY_DIR}/Makefile)
    endif()

    set(PRIMARY "${ARG_FROM_TARGET}")
    set(TARGET_QUEUE ${PRIMARY})

    while (TARGET_QUEUE)
        list(POP_FRONT TARGET_QUEUE ITEM)

        if (TARGET ${ITEM})
            util_get_target_property(NAME ${ITEM} YANG_NAME)
            util_get_target_property(COMPILE_RULE ${ITEM} YANG_COMPILE_RULE)
            util_get_target_property(LINK_RULE ${ITEM} YANG_LINK_RULE)
            util_get_target_property(SOURCES ${ITEM} SOURCES)
            util_get_target_property(INCLUDES ${ITEM} INCLUDE_DIRECTORIES)
            util_get_target_property(OPTIONS ${ITEM} YANG_COMPILE_OPTIONS)
            util_get_target_property(TYPE ${ITEM} TYPE)
            util_get_target_property(LIBRARIES ${ITEM} LINK_LIBRARIES)
            util_get_target_property(LINK_OPTIONS ${ITEM} YANG_LINK_OPTIONS)

            list(APPEND TARGET_QUEUE ${LIBRARIES})

            if ("${TYPE}" STREQUAL "EXECUTABLE")
                set(LINK_TYPE executable)
                set(LINK_OUTPUT ${NAME}${CMAKE_EXECUTABLE_SUFFIX})
            elseif ("${TYPE}" STREQUAL "STATIC_LIBRARY")
                set(LINK_TYPE static-library)
                set(LINK_OUTPUT ${NAME}${CMAKE_STATIC_LIBRARY_SUFFIX})
            elseif ("${TYPE}" STREQUAL "OBJECT_LIBRARY")
                set(LINK_TYPE object-library)
                set(LINK_OUTPUT ${NAME})
            else()
                message(FATAL_ERROR "target type \"${TYPE}\" not supported")
            endif()

            list(
                TRANSFORM OPTIONS
                PREPEND "--compile-options="
                OUTPUT_VARIABLE COMPILE_OPTIONS_ARGS
            )

            list(
                TRANSFORM LINK_OPTIONS
                PREPEND "--link-options="
                OUTPUT_VARIABLE LINK_OPTIONS_ARGS
            )

            if ("${ITEM}" STREQUAL "${PRIMARY}")
                set(LINK_OUTPUT "${ARG_BUILD_OUTPUT}")
            endif()

            set(OUTPUT_FILE ${ARG_BINARY_DIR}/${NAME}.tag)

            unset(LINK_LIBRARIES)

            # Link the libraries created with yang instead of the libraries
            # created with cmake.
            foreach(LIBRARY IN LISTS LIBRARIES)
                util_get_target_property(LIB_NAME ${LIBRARY} YANG_NAME)
                if (LIB_NAME)
                    list(APPEND LINK_LIBRARIES "${LIB_NAME}")
                else()
                    list(APPEND LINK_LIBRARIES "${LIB}")
                endif()
            endforeach()

            add_custom_command(
                OUTPUT "${OUTPUT_FILE}"
                COMMAND ${UV} run -m yang add
                        --link-type "${LINK_TYPE}"
                        --compile-rule "${COMPILE_RULE}"
                        --link-rule "${LINK_RULE}"
                        --build-directory "${ARG_BINARY_DIR}"
                        --sources ${SOURCES}
                        --compile-definitions APP_MESSAGE="\\\"Hello, ${NAME}!\\\""
                        --include-directories ${INCLUDES}
                        --link-libraries ${LINK_LIBRARIES}
                        --link-output "${LINK_OUTPUT}"
                        ${COMPILE_OPTIONS_ARGS}
                        ${LINK_OPTIONS_ARGS}
                COMMAND "${CMAKE_COMMAND}" -E touch "${OUTPUT_FILE}"
                WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                DEPENDS ${PREREQUISITE}
                COMMAND_EXPAND_LISTS
                VERBATIM
            )

            list(APPEND TAG_FILES "${OUTPUT_FILE}")
        endif()
    endwhile()

    add_custom_command(
        OUTPUT ${ARG_BUILD_SPEC}
        COMMAND ${UV} run -m yang aggregate
                --build-directory "${ARG_BINARY_DIR}"
                --target "${ARG_BUILD_OUTPUT}"
                --output "${ARG_BUILD_SPEC}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        DEPENDS "${YANG_SCRIPT}" ${TAG_FILES}
        COMMAND_EXPAND_LISTS
        VERBATIM
    )

endfunction()


function(yang_add_build NAME)
    set(FLAG_ARGS "")
    set(
        ONE_VALUE_ARGS
        BINARY_DIR
        OUTPUT_DIRECTORY
        TEMPLATE_FILE
    )
    set(
        MULTI_VALUE_ARGS
        FROM_TARGET
        DEPENDS
    )

    cmake_parse_arguments(
        ARG
        "${FLAG_ARGS}"
        "${ONE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        ${ARGN}
    )

    util_assert_arg(ARG BINARY_DIR)
    util_assert_arg(ARG OUTPUT_DIRECTORY)
    util_assert_arg(ARG TEMPLATE_FILE)
    util_assert_arg(ARG FROM_TARGET)

    file(MAKE_DIRECTORY "${ARG_OUTPUT_DIRECTORY}")

    set(YANG_BUILD_DIR "${ARG_BINARY_DIR}")
    set(YANG_BUILD_FILE "${YANG_BUILD_DIR}/build.ninja")

    foreach(PRIMARY IN LISTS ARG_FROM_TARGET)
        get_target_property(TARGET ${PRIMARY} YANG_NAME)

        set(TARGET_BINARY_DIR "${ARG_BINARY_DIR}/${TARGET}")
        set(TARGET_BUILD_SPEC "${TARGET_BINARY_DIR}/spec-${TARGET}.json")
        set(TARGET_OUTPUT "${ARG_OUTPUT_DIRECTORY}/${TARGET}")

        list(APPEND ALL_BUILD_SPECS "${TARGET_BUILD_SPEC}")

        file(MAKE_DIRECTORY "${TARGET_BINARY_DIR}")

        yang_add_spec(
            BINARY_DIR "${TARGET_BINARY_DIR}"
            BUILD_OUTPUT "${TARGET_OUTPUT}"
            BUILD_SPEC "${TARGET_BUILD_SPEC}"
            FROM_TARGET ${PRIMARY}
        )

        add_custom_target(
            ${TARGET}
            COMMAND ninja $ENV{YANG_NINJA_ARGS}
                -C ${YANG_BUILD_DIR}
                ${TARGET_OUTPUT}
            DEPENDS ${YANG_BUILD_FILE}
                    ${ARG_DEPENDS}
            JOB_POOL yang-pool
            VERBATIM
        )

        set_target_properties(
            ${TARGET}
            PROPERTIES
            YANG_PRIMARY "${PRIMARY}"
        )
    endforeach()

    # Combine all targets into one build
    add_custom_command(
        OUTPUT ${YANG_BUILD_FILE}
        COMMAND ${UV} run -m yang generate
            --build-template ${ARG_TEMPLATE_FILE}
            --build-spec ${ALL_BUILD_SPECS}
            --output ${YANG_BUILD_FILE}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS ${ARG_TEMPLATE_FILE}
                ${ALL_BUILD_SPECS}
        COMMAND_EXPAND_LISTS
        VERBATIM
    )

    add_custom_target(
        ${NAME}
        ALL
        COMMAND ninja $ENV{YANG_NINJA_ARGS} -C ${YANG_BUILD_DIR}
        DEPENDS ${YANG_BUILD_FILE}
                ${ARG_DEPENDS}
        JOB_POOL yang-pool
        VERBATIM
    )

endfunction()
