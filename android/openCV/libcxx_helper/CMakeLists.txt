cmake_minimum_required(VERSION 3.6)

# Force 16 KB memory page size and RELRO segment alignment for Android 15 / Google Play
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384 -Wl,-z,separate-loadable-segments")

# dummy target to bring libc++_shared.so into packages
add_library(opencv_jni_shared STATIC dummy.cpp)
