
#
# force build macro
#
macro(force_build proj)
  ExternalProject_Add_Step(${proj} forcebuild
    COMMAND ${CMAKE_COMMAND} -E remove ${base}/Stamp/${proj}/${proj}-build
    DEPENDEES configure
    DEPENDERS build
    ALWAYS 1
  )
endmacro()

macro(get_toolchain_file tag)
  string(REPLACE "-" "_" tag_with_underscore ${tag})
  set(toolchain_file ${toolchain_${tag_with_underscore}})
endmacro()

macro(get_try_run_results_file tag)
  string(REPLACE "-" "_" tag_with_underscore ${tag})
  set(try_run_results_file ${try_run_results_${tag_with_underscore}})
endmacro()

#
# GLEW fetch and install
#
macro(install_glew)
    set(glew_url https://downloads.sourceforge.net/project/glew/glew/2.1.0/glew-2.1.0.tgz)
    set(glew_sha256 04de91e7e6763039bc11940095cd9c7f880baba82196a7765f727ac05a993c95)
    ExternalProject_Add(
        glew
        SOURCE_DIR ${source_prefix}/glew
        URL ${glew_url}
        URL_MD5 ""
        CONFIGURE_COMMAND ""
        BUILD_COMMAND ""
        INSTALL_COMMAND ${CMAKE_COMMAND}
    )
endmacro()

#
# Eigen fetch and install
#
macro(install_eigen)
    set(eigen_url https://bitbucket.org/eigen/eigen/get/3.3.4.tar.gz)
  # set(eigen_url http://www.vtk.org/files/support/eigen-3.1.0-alpha1.tar.gz)
  # set(eigen_md5 c04dedf4ae97b055b6dd2aaa01daf5e9)
  ExternalProject_Add(
    eigen
    SOURCE_DIR ${source_prefix}/eigen
    URL ${eigen_url}
    URL_MD5 ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND}  -E copy_directory "${source_prefix}/eigen/Eigen" "${install_prefix}/eigen/Eigen" && ${CMAKE_COMMAND} -E copy_directory "${source_prefix}/eigen/unsupported" "${install_prefix}/eigen/unsupported"
    CMAKE_ARGS
      -DEIGEN_MPL2_ONLY
  )
endmacro()

#
# VTK fetch
#
macro(fetch_vtk)
  ExternalProject_Add(
    vtk-fetch
    SOURCE_DIR ${source_prefix}/vtk
    GIT_REPOSITORY git://github.com/patmarion/VTK.git
    GIT_TAG ce4a267
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# VTK compile
#
macro(compile_vtk)
  set(proj vtk-host)
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/vtk
    DOWNLOAD_COMMAND ""
    INSTALL_COMMAND ""
    DEPENDS vtk-fetch
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_TESTING:BOOL=OFF
      ${vtk_module_defaults}
  )
endmacro()

#
# VTK crosscompile
#
macro(crosscompile_vtk tag)
  set(proj vtk-${tag})
  get_toolchain_file(${tag})
  get_try_run_results_file(${proj})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/vtk
    DOWNLOAD_COMMAND ""
    DEPENDS vtk-host
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DBUILD_TESTING:BOOL=OFF
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
      -DVTKCompileTools_DIR:PATH=${build_prefix}/vtk-host
      ${vtk_module_defaults}
      -C ${try_run_results_file}
  )
endmacro()

#
# FLANN fetch
#
macro(fetch_flann)
  ExternalProject_Add(
    flann-fetch
    SOURCE_DIR ${source_prefix}/flann
    GIT_REPOSITORY git://github.com/mariusmuja/flann
    GIT_TAG 1.9.1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# FLANN crosscompile
#
macro(crosscompile_flann tag)
  set(proj flann-${tag})
  get_toolchain_file(${tag})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/flann
    DOWNLOAD_COMMAND ""
    DEPENDS flann-fetch
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
     # -DBUILD_SHARED_LIBS:BOOL=OFF
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_PYTHON_BINDINGS:BOOL=OFF
      -DBUILD_MATLAB_BINDINGS:BOOL=OFF
  )

  force_build(${proj})
endmacro()


#
# Boost fetch
#
macro(fetch_boost)
  ExternalProject_Add(
    boost-fetch
    SOURCE_DIR ${source_prefix}/boost
    GIT_REPOSITORY git://github.com/linuxfreakus/boost-cmake
    GIT_TAG origin/master
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

#
# Boost crosscompile
#
macro(crosscompile_boost tag)


  set(proj boost-${tag})
  get_toolchain_file(${tag})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/boost
    DOWNLOAD_COMMAND ""
    DEPENDS boost-fetch
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
      -DBUILD_SHARED_LIBS:BOOL=OFF
  )

  force_build(${proj})
endmacro()


#
# PCL fetch
#
macro(fetch_pcl)
  ExternalProject_Add(
    pcl-fetch
    SOURCE_DIR ${source_prefix}/pcl
    GIT_REPOSITORY git://github.com/PointCloudLibrary/pcl.git
    GIT_TAG pcl-1.8.1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    PATCH_COMMAND 
      ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_SOURCE_DIR}/patches/FindGlew.cmake ${source_prefix}/pcl/cmake/Modules/FindGLEW.cmake
  )
endmacro()

#
# PCL crosscompile
#
macro(crosscompile_pcl tag)
  set(proj pcl-${tag})
  get_toolchain_file(${tag})
  get_try_run_results_file(${proj})

  # copy the toolchain file and append the boost install dir to CMAKE_FIND_ROOT_PATH
  set(original_toolchain_file ${toolchain_file})
  get_filename_component(toolchain_file ${original_toolchain_file} NAME)
  set(toolchain_file ${build_prefix}/${proj}/${toolchain_file})
  configure_file(${original_toolchain_file} ${toolchain_file} COPYONLY)
  file(APPEND ${toolchain_file}
    "\nlist(APPEND CMAKE_FIND_ROOT_PATH ${install_prefix}/boost-${tag})\n")

  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${source_prefix}/pcl
    DOWNLOAD_COMMAND ""
    DEPENDS pcl-fetch boost-${tag} flann-${tag} eigen glew
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}/${proj}
      -DCMAKE_BUILD_TYPE:STRING=${build_type}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${toolchain_file}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DPCL_SHARED_LIBS:BOOL=OFF
      -DBUILD_visualization:BOOL=OFF
      -DBUILD_examples:BOOL=OFF
      -DBUILD_tools:BOOL=OFF
      -DBUILD_apps:BOOL=OFF
      -DEIGEN_INCLUDE_DIR=${install_prefix}/eigen
      -DFLANN_INCLUDE_DIR=${install_prefix}/flann-${tag}/include
      -DFLANN_LIBRARY=${install_prefix}/flann-${tag}/lib/libflann_cpp_s.a
      -DBOOST_ROOT=${install_prefix}/boost-${tag}
      -DGLEW_INCLUDE_DIR=${install_prefix}/glew
      -C ${try_run_results_file}
  )

  force_build(${proj})
endmacro()


macro(create_pcl_framework)
    add_custom_target(pclFramework ALL
      COMMAND ${CMAKE_SOURCE_DIR}/makeFramework.sh pcl
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      DEPENDS pcl-ios-device
      COMMENT "Creating pcl.framework")
endmacro()


# macro to find programs on the host OS
macro( find_host_program )
 set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
 set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
 set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
 if( CMAKE_HOST_WIN32 )
  SET( WIN32 1 )
  SET( UNIX )
 elseif( CMAKE_HOST_APPLE )
  SET( APPLE 1 )
  SET( UNIX )
 endif()
 find_program( ${ARGN} )
 SET( WIN32 )
 SET( APPLE )
 SET( UNIX 1 )
 set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
 set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
 set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
endmacro()
