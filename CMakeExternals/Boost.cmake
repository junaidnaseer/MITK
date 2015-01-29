#-----------------------------------------------------------------------------
# Boost
#-----------------------------------------------------------------------------

if(MITK_USE_Boost)

  # Sanity checks
  if(DEFINED BOOST_ROOT AND NOT EXISTS ${BOOST_ROOT})
    message(FATAL_ERROR "BOOST_ROOT variable is defined but corresponds to non-existing directory")
  endif()

  string(REPLACE "^^" ";" MITK_USE_Boost_LIBRARIES "${MITK_USE_Boost_LIBRARIES}")

  set(proj Boost)
  set(proj_DEPENDENCIES )
  set(Boost_DEPENDS ${proj})

  if(NOT DEFINED BOOST_ROOT AND NOT MITK_USE_SYSTEM_Boost)

    set(_boost_libs )
    set(_with_boost_libs )

    # Set the boost root to the libraries install directory
    set(BOOST_ROOT "${ep_prefix}")

    if(MITK_USE_Boost_LIBRARIES)
      string(REPLACE ";" "," _boost_libs "${MITK_USE_Boost_LIBRARIES}")
      foreach(_boost_lib ${MITK_USE_Boost_LIBRARIES})
        list(APPEND _with_boost_libs ${_with_boost_libs} --with-${_boost_lib})
      endforeach()
    endif()

    if(WIN32)
      set(_shell_extension .bat)
      if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(_boost_address_model "address-model=64")
      else()
        set(_boost_address_model "address-model=32")
      endif()
      if(MSVC)
        if(MSVC_VERSION EQUAL 1400)
          set(_boost_toolset "toolset=msvc-8.0")
        elseif(MSVC_VERSION EQUAL 1500)
          set(_boost_toolset "toolset=msvc-9.0")
        elseif(MSVC_VERSION EQUAL 1600)
          set(_boost_toolset "toolset=msvc-10.0")
        elseif(MSVC_VERSION EQUAL 1700)
          set(_boost_toolset "toolset=msvc-11.0")
        endif()
      endif()
    else()
      set(_shell_extension .sh)
    endif()

    set (APPLE_SYSROOT_FLAG)
    if(APPLE)
      set(APPLE_CMAKE_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/${proj}-cmake/ChangeBoostLibsInstallNameForMac.cmake)
      configure_file(${CMAKE_CURRENT_SOURCE_DIR}/CMakeExternals/ChangeBoostLibsInstallNameForMac.cmake.in ${APPLE_CMAKE_SCRIPT} @ONLY)
      set(_macos_change_install_name_cmd COMMAND ${CMAKE_COMMAND} -P ${APPLE_CMAKE_SCRIPT})

      # Set OSX_SYSROOT
      if (NOT ${CMAKE_OSX_SYSROOT} STREQUAL "")
        set (APPLE_SYSROOT_FLAG --sysroot=${CMAKE_OSX_SYSROOT})
      endif()
    endif()

    set(_boost_variant "$<$<CONFIG:Debug>:debug>$<$<CONFIG:Release>:release>")
    set(_boost_link shared)
    if(NOT BUILD_SHARED_LIBS)
      set(_boost_link static)
    endif()
    set(_boost_cxxflags )
    if(CMAKE_CXX_FLAGS)
      set(_boost_cxxflags "cxxflags=${CMAKE_CXX_FLAGS}")
    endif()
    set(_boost_linkflags )
    if(BUILD_SHARED_LIBS AND _install_rpath_linkflag)
      set(_boost_linkflags "linkflags=${_install_rpath_linkflag}")
    endif()

    set(_build_cmd "<SOURCE_DIR>/b2"
        ${APPLE_SYSROOT_FLAG}
        --layout=tagged
        ${_with_boost_libs}
        # Use the option below to view the shell commands (for debugging)
        #-d+4
        variant=${_boost_variant}
        link=${_boost_link}
        ${_boost_cxxflags}
        ${_boost_linkflags}
        threading=multi
        runtime-link=shared
        -q
    )

    if(MITK_USE_Boost_LIBRARIES)
      set(_boost_build_cmd BUILD_COMMAND ${_build_cmd})
      set(_install_cmd ${_build_cmd} install ${_macos_change_install_name_cmd})
    else()
      set(_boost_build_cmd BUILD_COMMAND ${CMAKE_COMMAND} -E echo "no binary libraries")
      set(_install_cmd ${CMAKE_COMMAND} -E echo "copying Boost header..."
             COMMAND ${CMAKE_COMMAND} -E copy_directory "<SOURCE_DIR>/boost" "<INSTALL_DIR>/include/boost")
    endif()

    ExternalProject_Add(${proj}
      LIST_SEPARATOR ${sep}
      URL ${MITK_THIRDPARTY_DOWNLOAD_PREFIX_URL}/boost_1_56_0.tar.bz2
      URL_MD5 a744cf167b05d72335f27c88115f211d
      # We use in-source builds for Boost
      BINARY_DIR ${ep_prefix}/src/${proj}
      CONFIGURE_COMMAND "<SOURCE_DIR>/bootstrap${_shell_extension}"
        --with-toolset=${_boost_toolset}
        --with-libraries=${_boost_libs}
        "--prefix=<INSTALL_DIR>"
      ${_boost_build_cmd}
      INSTALL_COMMAND ${_install_cmd}
      DEPENDS ${proj_DEPENDENCIES}
      )

    # Manual install commands (for a MITK super-build install)
    # until the Boost CMake system is used.

    # We just copy the include directory
    ExternalProject_Get_Property(${proj} install_dir)
    install(DIRECTORY "${install_dir}/include/boost"
            DESTINATION "include"
            COMPONENT dev
           )

    if(MITK_USE_Boost_LIBRARIES)
      # Copy the boost libraries
      file(GLOB _boost_libs
           "${install_dir}/lib/libboost*.so*"
           "${install_dir}/lib/libboost*.dylib")
      install(FILES ${_boost_libs}
              DESTINATION "lib"
              COMPONENT runtime)

      file(GLOB _boost_libs
           "${install_dir}/bin/libboost*.dll")
      install(FILES ${_boost_libs}
              DESTINATION "bin"
              COMPONENT runtime)

      file(GLOB _boost_libs
           "${install_dir}/lib/libboost*.lib"
           "${install_dir}/lib/libboost*.a")
      install(FILES ${_boost_libs}
              DESTINATION "lib"
              COMPONENT dev)
    endif()

  else()

    mitkMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")

  endif()

endif()
