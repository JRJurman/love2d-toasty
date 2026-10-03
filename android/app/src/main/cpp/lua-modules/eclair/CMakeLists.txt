cmake_minimum_required(VERSION 3.21)

project(eclair LANGUAGES C)

# eclair's sources live where they would if eclair were part of LÖVE; this
# module only builds them as their own libeclair.so, which src/tts.lua reaches
# through LuaJIT's ffi. Eclair.java loads it with System.loadLibrary, which runs
# its JNI_OnLoad.
set(ECLAIR_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../love/src/libraries/eclair)

add_library(eclair SHARED
	${ECLAIR_DIR}/eclair.c
	${ECLAIR_DIR}/eclair_android.c
)

target_compile_definitions(eclair PRIVATE ECLAIR_BUILD_SHARED)
set_target_properties(eclair PROPERTIES C_VISIBILITY_PRESET hidden)
