cmake_minimum_required(VERSION 3.8)

# ---------------------------------------------------------------------------- #
# PROJECT
# name version language
# ---------------------------------------------------------------------------- #
project(PMESH VERSION 1.0 LANGUAGES CXX)

# ---------------------------------------------------------------------------- #
# VARIABLE
# alias and configurations
# ---------------------------------------------------------------------------- #
set(PMESH_TARGET ${PROJECT_NAME})

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

# ---------------------------------------------------------------------------- #
# External dependencies
# ---------------------------------------------------------------------------- #
##
## ilang
##
find_package(ilang REQUIRED)

##
## Python (required if CMake version < 3.12)
##
if(${CMAKE_VERSION} VERSION_LESS 3.12)

  if(NOT TARGET Python::Python)
    add_library(Python::Python IMPORTED INTERFACE)

    set_property(TARGET Python::Python 
      PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${PYTHON_INCLUDE_DIRECTORIES}
    )

    set_property(TARGET Python::Python
      PROPERTY INTERFACE_LINK_LIBRARIES ${PYTHON_LIBRARIES}
    )
    
  endif()

endif()


# ---------------------------------------------------------------------------- #
# TARGET
# library
# ---------------------------------------------------------------------------- #
add_library(${PMESH_TARGET}
  src/pmesh_l2_ila.cc
  src/pmesh_l1_ila.cc
  src/pmesh_util.cc
)

target_include_directories(${PMESH_TARGET} PRIVATE include)

target_link_libraries(${PMESH_TARGET} PUBLIC ilang::ilang)


# ---------------------------------------------------------------------------- #
# TARGET
# executable
# ---------------------------------------------------------------------------- #
add_executable(${PMESH_TARGET}Exe
  app/main.cc
)

target_include_directories(${PMESH_TARGET}Exe PRIVATE include)

target_link_libraries(${PMESH_TARGET}Exe ${PMESH_TARGET})
