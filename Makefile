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

BUILD_DIR := build
NINJA_BUILD_DIR := $(BUILD_DIR)/ninja
MAKE_BUILD_DIR := $(BUILD_DIR)/make
SHELL_BUILD_DIR := $(BUILD_DIR)/shell

NINJA_FILE := $(NINJA_BUILD_DIR)/build.ninja
MAKE_FILE := $(MAKE_BUILD_DIR)/Makefile

CMAKE_FILES := $(find . -name CMakeLists.txt -or -name "*.cmake")

all: ninja-setup make-setup shell-setup

ninja-setup: $(NINJA_FILE)
	@NINJA_STATUS="[%f/%t %e] " ninja -C $(NINJA_BUILD_DIR)

make-setup: $(MAKE_FILE)
	@$(MAKE) -j$(shell nproc) -C $(MAKE_BUILD_DIR)

$(NINJA_FILE): $(CMAKE_FILES)
	@cmake -Werror -GNinja -S . -B $(NINJA_BUILD_DIR)

$(MAKE_FILE): $(CMAKE_FILES)
	@cmake -Werror -S . -B $(MAKE_BUILD_DIR)

shell-setup: $(SHELL_BUILD_DIR)/app

$(SHELL_BUILD_DIR)/app: example/scripts/build.sh
	@BUILD_DIR=$(SHELL_BUILD_DIR) $(SHELL) $<

clean:
	@rm -rf $(BUILD_DIR)

.PHONY: all ninja-project make-project
