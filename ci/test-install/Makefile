# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# A simple Makefile to test the `install` target.
#
# This is not intended to be a demonstration of how to write good Makefiles,
# nor is it a general solution on how to build Makefiles for google-cloud-cpp.
# It is simply a minimal file to test the installed pkg-config support files.

# The CXX, CXXFLAGS and CXXLD variables are hard-coded. These values work for
# our tests, but applications would typically make them configurable parameters.
CXX=g++
CXXFLAGS=-std=c++11 -pthread
CXXLD=$(CXX)

all: common_install_test

# Configuration variables to compile and link against the Cloud C++ common
# library.
GCPP_DEPS := google_cloud_cpp_grpc_utils google_cloud_cpp_common grpc++ grpc
GCPP_CXXFLAGS   := $(shell pkg-config $(GCPP_DEPS) --cflags)
GCPP_CXXLDFLAGS := $(shell pkg-config $(GCPP_DEPS) --libs-only-L)
GCPP_LIBS       := $(shell pkg-config $(GCPP_DEPS) --libs-only-l)

# A target using the Cloud C++ common library.
common_install_test: common_install_test.cc
	$(CXXLD) $(CXXFLAGS) $(GCPP_CXXFLAGS) $(GCPP_CXXLDFLAGS) -o $@ $^ $(GCPP_LIBS)
