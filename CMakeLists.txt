cmake_minimum_required(VERSION 3.6)

project(su-exec)

include(GNUInstallDirs)

set(CMAKE_CC_FLAGS "${CMAKE_CC_FLAGS} -Wall -Werror")

add_executable(su-exec su-exec.c)
install(TARGETS su-exec DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES README.md DESTINATION ${CMAKE_INSTALL_DOCDIR})

set(SU_EXEC_VERSION "0.2")
set(PATCH_VERSION "1")
set(CPACK_PACKAGE_NAME su-exec)
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Switch user and group id, setgroups and exec")
set(CPACK_PACKAGE_DESCRIPTION "Original implementation by Natanael Copa, CPack-ed by Roel van de Kraats")
set(CPACK_PACKAGE_CONTACT "Roel van de Kraats <roel@2getthere.eu>")
set(CPACK_PACKAGE_VENDOR "2getthere b.v. (https://www.2getthere.eu)")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")

# Try to find distro id
execute_process(COMMAND sh -c "grep '^ID=' /etc/os-release | sed -e 's/^.*=//g' -e 's/\"//g'" ERROR_QUIET OUTPUT_VARIABLE OS_ID)
string(STRIP "${OS_ID}" OS_ID)

# For Debian-based distros we want to create DEB packages.
if("${OS_ID}" MATCHES "ubuntu|debian")
    install(FILES LICENSE RENAME copyright DESTINATION ${CMAKE_INSTALL_DOCDIR})

    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEB_COMPONENT_INSTALL "ON")
    set(CPACK_PACKAGE_VERSION "${SU_EXEC_VERSION}-${PATCH_VERSION}")
    set(CPACK_DEBIAN_PACKAGE_SECTION "misc")
    set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://github.com/2getthere/su-exec")
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
    string(TOLOWER "${CPACK_PACKAGE_NAME}" CPACK_DEBIAN_PACKAGE_NAME)
    execute_process(COMMAND sh -c "(grep DISTRIB_CODENAME /etc/lsb-release 2>/dev/null || grep VERSION_CODENAME /etc/os-release) | sed 's/^.*=//g'" OUTPUT_VARIABLE OS_CODENAME)
    string(STRIP "${OS_CODENAME}" OS_CODENAME)
    execute_process(COMMAND dpkg --print-architecture OUTPUT_VARIABLE CPACK_PACKAGE_ARCHITECTURE)
    string(STRIP "${CPACK_PACKAGE_ARCHITECTURE}" CPACK_PACKAGE_ARCHITECTURE)
    set(FULL_VERSION "${CPACK_PACKAGE_VERSION}~${OS_CODENAME}_${CPACK_PACKAGE_ARCHITECTURE}")
    string(TOLOWER "${CPACK_DEBIAN_PACKAGE_NAME}_${FULL_VERSION}.deb" CPACK_DEBIAN_FILE_NAME)

# For Red Hat-based distros we want to create RPM packages.
elseif("${OS_ID}" MATCHES "fedora|centos|rhel")
    install(FILES LICENSE RENAME COPYING DESTINATION ${CMAKE_INSTALL_DOCDIR})

    set(CPACK_GENERATOR "RPM")
    set(CPACK_RPM_COMPONENT_INSTALL "ON")
    set(CPACK_PACKAGE_VERSION "${SU_EXEC_VERSION}-${PATCH_VERSION}")
    set(CPACK_RPM_PACKAGE_VERSION "${SU_EXEC_VERSION}")
    set(CPACK_RPM_PACKAGE_RELEASE "${PATCH_VERSION}")
    set(CPACK_RPM_PACKAGE_URL "https://github.com/2getthere/su-exec")
    set(CPACK_RPM_PACKAGE_LICENSE "MIT")
    set(CPACK_RPM_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION}")
    # Find dist tag
    execute_process(COMMAND sh -c "grep ^VERSION_ID= /etc/os-release | sed -e 's/^.*=//g' -e 's/\"//g'" OUTPUT_VARIABLE OS_VERSION)
    string(STRIP "${OS_VERSION}" OS_VERSION)
    if("${OS_ID}" MATCHES "fedora")
        set(CPACK_RPM_PACKAGE_RELEASE_DIST "fc${OS_VERSION}")
    else()
        set(CPACK_RPM_PACKAGE_RELEASE_DIST "el${OS_VERSION}")
    endif()
    # Find architecture
    execute_process(COMMAND rpm --eval "%{_arch}" OUTPUT_VARIABLE CPACK_PACKAGE_ARCHITECTURE)
    string(STRIP "${CPACK_PACKAGE_ARCHITECTURE}" CPACK_PACKAGE_ARCHITECTURE)
    set(CPACK_RPM_PACKAGE_AUTOREQ ON)
    set(VERSION_WITH_DIST "${CPACK_RPM_PACKAGE_VERSION}-${CPACK_RPM_PACKAGE_RELEASE}.${CPACK_RPM_PACKAGE_RELEASE_DIST}")
    string(TOLOWER "${CPACK_PACKAGE_NAME}" CPACK_RPM_PACKAGE_NAME)
    set(FULL_VERSION "${VERSION_WITH_DIST}.${CPACK_PACKAGE_ARCHITECTURE}")
    string(TOLOWER "${CPACK_PACKAGE_NAME}-${FULL_VERSION}.rpm" CPACK_RPM_FILE_NAME)

else()
    message(WARNING "Could not determine type of package to create")
endif()

include(CPack)
