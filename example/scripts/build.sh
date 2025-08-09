#!/usr/bin/env sh
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

set -e

#
# Define build related variables
#
TARGET="app"
BUILD_DIR="${BUILD_DIR:=build}"

SOURCES=(
    "example/src/core/core.c"
    "example/src/drivers/drivers.c"
    "example/src/init/init.c"
    "example/src/io/io.S"
    "example/src/main.c"
    "example/src/utils/utils.c"
)

INCLUDES=(
    "example/include"
)

COMPILE_RULE="compile-object-clang"
LINK_RULE="link-executable-clang"
BUILD_TEMPLATE="example/template/build.j2"

#
# Files are defined relative to the project's root directory.
#
WORKING_DIRECTORY="$(git rev-parse --show-toplevel)"
cd "${WORKING_DIRECTORY}"


#
# Optional: Set up a clean build directory.
#
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

#
# 1. Define a target.
#
uv run src/yang/__main__.py add \
    --build-directory "${BUILD_DIR}" \
    --sources "${SOURCES[@]}" \
    --compile-definitions '"APP_MESSAGE=\"Hello, yang!\""' \
    --include-directories "${INCLUDES[@]}" \
    --compile-rule "${COMPILE_RULE}" \
    --link-type executable \
    --link-rule "${LINK_RULE}" \
    --link-output "${TARGET}"

#
# 2. Aggregate the information for the target within the build directory to
#    construct a build specification.
#
uv run src/yang/__main__.py aggregate \
    --build-directory "${BUILD_DIR}" \
    --target "${TARGET}" \
    --output "${BUILD_DIR}/spec-app.json"

#
# 3. Combine the build specification(s) with the build template to generate
#    the build.ninja file.
#
uv run src/yang/__main__.py generate \
    --build-template "${BUILD_TEMPLATE}" \
    --build-spec "${BUILD_DIR}/spec-app.json" \
    --output "${BUILD_DIR}/build.ninja"

#
# Optional: build and run the defined target.
#
ninja -C "${BUILD_DIR}"

"./${BUILD_DIR}/bin/${TARGET}"

exit 0
