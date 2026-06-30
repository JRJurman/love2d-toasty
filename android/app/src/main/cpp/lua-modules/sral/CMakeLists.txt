cmake_minimum_required(VERSION 3.21)

project(SralBootstrap LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)

# Prebuilt SRAL from the release bundle, dropped into app/src/main/jniLibs/.
# Gradle packages it into the APK from jniLibs; here we only import it so the
# bootstrap shim can link against the public C API.
add_library(SRAL SHARED IMPORTED GLOBAL)
set_target_properties(SRAL PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../../../jniLibs/${ANDROID_ABI}/libSRAL.so)

# Thin JNI shim that forwards the Android JNIEnv/Activity into SRAL. This used
# to be compiled into libSRAL.so itself; with the prebuilt (app-agnostic) SRAL
# it lives in its own library that depends on it.
add_library(SralBootstrap SHARED src/SralBootstrap.cpp)

target_include_directories(SralBootstrap PRIVATE Include)

target_link_libraries(SralBootstrap PRIVATE SRAL log)
