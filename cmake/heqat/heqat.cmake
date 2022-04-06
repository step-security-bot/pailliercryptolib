# Copyright (C) 2021 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

include(ExternalProject)
MESSAGE(STATUS "Configuring HE QAT")
set(HEQAT_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ext_he_qat)
set(HEQAT_GIT_REPO_URL git@github.com:intel-sandbox/libraries.security.cryptography.homomorphic-encryption.glade.project-destiny.git)
set(HEQAT_GIT_LABEL development)
set(HEQAT_SRC_DIR ${HEQAT_PREFIX}/src/ext_he_qat/)

set(HEQAT_CXX_FLAGS "${IPCL_FORWARD_CMAKE_ARGS}")

ExternalProject_Add(
  ext_he_qat
  GIT_REPOSITORY ${HEQAT_GIT_REPO_URL}
  GIT_TAG ${HEQAT_GIT_LABEL}
  PREFIX ${HEQAT_PREFIX}
  INSTALL_DIR ${HEQAT_PREFIX}
  CMAKE_ARGS ${HEQAT_CXX_FLAGS}
             -DCMAKE_INSTALL_PREFIX=${HEQAT_PREFIX}
	     -DHE_QAT_MISC=OFF
	     -DIPPCP_PREFIX_PATH=${IPPCRYPTO_PREFIX}/lib/cmake
	     #-DARCH=${HEQAT_ARCH}
	     #-DCMAKE_ASM_NASM_COMPILER=nasm
	     #-DCMAKE_BUILD_TYPE=Release
  UPDATE_COMMAND ""
)

add_dependencies(ext_he_qat libippcrypto)

set(HEQAT_INC_DIR ${HEQAT_PREFIX}/include) #${HEQAT_SRC_DIR}/install/include)

# Bring up CPA variables
include(${CMAKE_CURRENT_LIST_DIR}/icp/CMakeLists.txt)
list(APPEND HEQAT_INC_DIR ${ICP_INC_DIR})

add_library(libhe_qat INTERFACE)
add_dependencies(libhe_qat ext_he_qat)

ExternalProject_Get_Property(ext_he_qat SOURCE_DIR BINARY_DIR)

target_link_libraries(libhe_qat INTERFACE ${HEQAT_PREFIX}/lib/libcpa_sample_utils.a) # ${HEQAT_PREFIX}/lib/libhe_qat_misc.a)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  target_link_libraries(libhe_qat INTERFACE ${HEQAT_PREFIX}/lib/libhe_qat_debug.so)
else()
  target_link_libraries(libhe_qat INTERFACE ${HEQAT_PREFIX}/lib/libhe_qat.so)
endif()
target_include_directories(libhe_qat SYSTEM INTERFACE ${HEQAT_INC_DIR})
