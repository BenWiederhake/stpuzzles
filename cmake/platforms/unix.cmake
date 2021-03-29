find_package(PkgConfig REQUIRED)

set(PUZZLES_GTK_FOUND FALSE)
macro(try_gtk_package VER PACKAGENAME)
  if(NOT PUZZLES_GTK_FOUND AND
      (NOT DEFINED PUZZLES_GTK_VERSION OR
        PUZZLES_GTK_VERSION STREQUAL ${VER}))
    pkg_check_modules(GTK ${PACKAGENAME})
    if(GTK_FOUND)
      set(PUZZLES_GTK_FOUND TRUE)
    endif()
  endif()
endmacro()

try_gtk_package(3 gtk+-3.0)
try_gtk_package(2 gtk+-2.0)

if(NOT PUZZLES_GTK_FOUND)
  message(FATAL_ERROR "Unable to find any usable version of GTK.")
endif()

include_directories(${GTK_INCLUDE_DIRS})
link_directories(${GTK_LIBRARY_DIRS})

set(platform_common_sources gtk.c printing.c)
set(platform_gui_libs ${GTK_LIBRARIES})

set(platform_libs -lm)

set(build_icons TRUE)

function(try_append_cflag flag)
  set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${flag}")
  try_compile(compile_passed ${CMAKE_BINARY_DIR}
    SOURCES ${CMAKE_SOURCE_DIR}/cmake/testbuild.c
    OUTPUT_VARIABLE test_compile_output
    CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${GTK_INCLUDE_DIRS}")
  if(compile_passed)
    set(CMAKE_C_FLAGS ${CMAKE_C_FLAGS} PARENT_SCOPE)
  endif()
endfunction()
if (CMAKE_C_COMPILER_ID MATCHES "GNU" OR
    CMAKE_C_COMPILER_ID MATCHES "Clang")
  try_append_cflag(-Wall)
  try_append_cflag(-Werror)
  try_append_cflag(-std=c89)
  try_append_cflag(-pedantic)
  try_append_cflag(-Wwrite-strings)
endif()

function(get_platform_puzzle_extra_source_files OUTVAR NAME)
  if(build_icons AND EXISTS ${CMAKE_SOURCE_DIR}/icons/${NAME}.sav)
    build_icon(${NAME})
    set(c_icon_file ${CMAKE_BINARY_DIR}/icons/${NAME}-icon.c)
  else()
    set(c_icon_file ${CMAKE_SOURCE_DIR}/no-icon.c)
  endif()

  set(${OUTVAR} ${c_icon_file} PARENT_SCOPE)
endfunction()

function(set_platform_puzzle_target_properties NAME TARGET)
  install(TARGETS ${TARGET})
endfunction()

function(build_platform_extras)
endfunction()