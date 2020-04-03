# ~~~
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
# ~~~

#[=======================================================================[.rst:
FindProtobufWithTargets
-------------------

A module to use ``Protobuf`` with less complications.

Using ``find_package(Protobuf)`` should be simple, but it is not.

CMake provides a ``FindProtobuf`` module. Unfortunately it does not generate
``protobuf::*`` targets until CMake-3.9, and ``protobuf::protoc`` does not
appear until CMake-3.10.

The CMake-config files generated by ``protobuf`` always create these targets,
but on some Linux distributions (e.g. Fedora>=29, and openSUSE-Tumbleweed) there
are system packages for protobuf, but these packages are installed without the
CMake-config files. One must either use the ``FindProtobuf`` module, find the
libraries via ``pkg-config``, or find the libraries manually.

When the CMake-config files are installed they produce the same targets as
recent versions of ``FindProtobuf``. However, they do not produce the
``Protobuf_LIBRARY``, ``Protobuf_INCLUDE_DIR``, etc. that are generated by the
module. Furthermore, the ``protobuf::protoc`` library is not usable when loaded
from the CMake-config files: its ``IMPORTED_LOCATION`` variable is not defined.

This module is designed to provide a single, uniform, ``find_package()``
module that always produces the same outputs:

- It always generates the ``protobuf::*`` targets.
- It always defines ``ProtobufWithTargets_FOUND`` and
  ``ProtobufWithTargets_VERSION``.
- It *prefers* using the CMake config files if they are available.
- It fallsback on the ``FindProtobuf`` module if the config files are not found.
- It populates any missing targets and their properties.

The following ``IMPORTED`` targets are defined:

``protobuf::libprotobuf``
  The protobuf library.
``protobuf::libprotobuf-lite``
  The protobuf lite library.
``protobuf::libprotoc``
  The protoc library.
``protobuf::protoc``
  The protoc compiler.

Example:

.. code-block:: cmake

  find_package(ProtobufWithTargets REQUIRED)
  add_executable(bar bar.cc)
  target_link_libraries(bar PRIVATE protobuf::libprotobuf)

#]=======================================================================]

if (protobuf_DEBUG)
    message(STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                   "protobuf_USE_STATIC_LIBS = ${protobuf_USE_STATIC_LIBS}"
                   " ProtobufWithTargets = ${ProtobufWithTargets_FOUND}")
endif ()

# Always load thread support, even on Windows.
find_package(Threads REQUIRED)

# First try to use the ``protobufConfig.cmake`` or ``protobuf-config.cmake``
# file if it was installed. This is common on systems (or package managers)
# where protobuf was compiled and installed with `CMake`. Note that on Linux
# this *must* be all lowercase ``protobuf``, while on Windows it does not
# matter.
find_package(Protobuf CONFIG QUIET)

if (protobuf_DEBUG)
    message(STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                   "protobuf_FOUND = ${protobuf_FOUND}"
                   " protobuf_VERSION = ${protobuf_VERSION}")
endif ()

if (NOT protobuf_FOUND)
    find_package(Protobuf QUIET)
endif ()

if (Protobuf_FOUND)
    set(ProtobufWithTargets_FOUND 1)
    set(ProtobufWithTargets_VERSION ${Protobuf_VERSION})

    if (NOT TARGET protobuf::libprotobuf)
        add_library(protobuf::libprotobuf IMPORTED INTERFACE)
        set_property(
            TARGET protobuf::libprotobuf PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                                                  ${Protobuf_INCLUDE_DIR})
        set_property(
            TARGET protobuf::libprotobuf APPEND
            PROPERTY INTERFACE_LINK_LIBRARIES ${Protobuf_LIBRARY}
                     Threads::Threads)
    endif ()

    if (NOT TARGET protobuf::libprotobuf-lite)
        add_library(protobuf::libprotobuf-lite IMPORTED INTERFACE)
        set_property(
            TARGET protobuf::libprotobuf-lite
            PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${Protobuf_INCLUDE_DIR})
        set_property(
            TARGET protobuf::libprotobuf-lite APPEND
            PROPERTY INTERFACE_LINK_LIBRARIES ${Protobuf_LITE_LIBRARY}
                     Threads::Threads)
    endif ()

    if (NOT TARGET protobuf::libprotoc)
        add_library(protobuf::libprotoc IMPORTED INTERFACE)
        set_property(
            TARGET protobuf::libprotoc PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                                                ${Protobuf_INCLUDE_DIR})
        set_property(
            TARGET protobuf::libprotoc APPEND
            PROPERTY INTERFACE_LINK_LIBRARIES ${Protobuf_PROTOC_LIBRARY}
                     Threads::Threads)
    endif ()

    if (NOT TARGET protobuf::protoc)
        add_executable(protobuf::protoc IMPORTED)

        # Discover the protoc compiler location.
        find_program(
            _protobuf_PROTOC_EXECUTABLE
            NAMES protoc
            DOC "The Google Protocol Buffers Compiler")
        if (protobuf_DEBUG)
            message(
                STATUS
                    "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                    "ProtobufWithTargets_FOUND = ${ProtobufWithTargets_FOUND}"
                    " ProtobufWithTargets_VERSION = ${ProtobufWithTargets_VERSION}"
                    " EXE = ${_protobuf_PROTOC_EXECUTABLE}")
        endif ()
        set_property(TARGET protobuf::protoc
                     PROPERTY IMPORTED_LOCATION ${_protobuf_PROTOC_EXECUTABLE})
        set_property(
            TARGET protobuf::protoc PROPERTY IMPORTED_LOCATION_DEBUG
                                             ${_protobuf_PROTOC_EXECUTABLE})
        set_property(
            TARGET protobuf::protoc PROPERTY IMPORTED_LOCATION_RELEASE
                                             ${_protobuf_PROTOC_EXECUTABLE})
        unset(_protobuf_PROTOC_EXECUTABLE)

        if (protobuf_DEBUG)
            get_target_property(_protobuf_PROTOC_EXECUTABLE protobuf::protoc
                                IMPORTED_LOCATION)
            message(
                STATUS
                    "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                    "LOCATION=${_protobuf_PROTOC_EXECUTABLE}")
        endif ()
    endif ()
endif ()

if (protobuf_DEBUG)
    message(
        STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
               "ProtobufWithTargets_FOUND = ${ProtobufWithTargets_FOUND}"
               " ProtobufWithTargets_VERSION = ${ProtobufWithTargets_VERSION}")
endif ()

if (protobuf_DEBUG)
    message(
        STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
               "ProtobufWithTargets_FOUND = ${ProtobufWithTargets_FOUND}"
               " ProtobufWithTargets_VERSION = ${ProtobufWithTargets_VERSION}")
    if (ProtobufWithTargets_FOUND)
        foreach (_target protobuf::libprotobuf protobuf::libprotobuf-lite
                         protobuf::libprotoc)
            if (NOT TARGET ${_target})
                message(
                    STATUS
                        "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
                        "target=${_target} is NOT a target")
            endif ()
        endforeach ()
        unset(_target)
    endif ()
endif ()

find_package_handle_standard_args(
    ProtobufWithTargets REQUIRED_VARS ProtobufWithTargets_FOUND
    ProtobufWithTargets_VERSION)
