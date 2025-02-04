# FindTegraJPEG.cmake
# - TegraJPEG_FOUND
# - TegraJPEG_INCLUDE_DIRS
# - TegraJPEG_LIBRARIES

# Detect Linux4Tegra distribution
SET(L4T_RELEASE_FILE /etc/nv_tegra_release)
IF(EXISTS ${L4T_RELEASE_FILE})
  SET(TegraJPEG_IS_L4T TRUE)
  EXECUTE_PROCESS(
    COMMAND sha1sum --quiet -c /etc/nv_tegra_release
    RESULT_VARIABLE TegraJPEG_DRIVER_ERROR
    OUTPUT_VARIABLE TegraJPEG_DRIVER_OUTPUT
    ERROR_QUIET
  )
  IF(TegraJPEG_DRIVER_ERROR)
    MESSAGE(WARNING "Tegra drivers have wrong checksum:\n${TegraJPEG_DRIVER_OUTPUT}")
  ELSE()
    SET(TegraJPEG_DRIVER_OK TRUE)
  ENDIF()
ELSE()
  #DJB is the even a l4t release file?
  MESSAGE(STATUS "DJB: l4t release file not found")
  SET(TegraJPEG_DRIVER_OK TRUE)
  SET(TegraJPEG_IS_L4T TRUE)
ENDIF()

# Detect L4T version
IF(TegraJPEG_IS_L4T)
#  FILE(READ ${L4T_RELEASE_FILE} L4T_RELEASE_CONTENT LIMIT 64 OFFSET 2)
#  STRING(REGEX REPLACE "^R([0-9]*)[^,]*, REVISION: ([0-9.]*).*" "\\1" L4T_VER_MAJOR "${L4T_RELEASE_CONTENT}")
#  STRING(REGEX REPLACE "^R([0-9]*)[^,]*, REVISION: ([0-9.]*).*" "\\2" L4T_VER_MINOR "${L4T_RELEASE_CONTENT}")
#  SET(L4T_VER "${L4T_VER_MAJOR}.${L4T_VER_MINOR}")
    SET(L4T_VER "32.2")
  MESSAGE(STATUS "Found Linux4Tegra ${L4T_VER}")
  IF(L4T_VER VERSION_LESS 21.3.0)
    MESSAGE(WARNING "Linux4Tegra version (${L4T_VER}) less than minimum requirement (21.3)")
  ELSE()
    SET(TegraJPEG_L4T_OK TRUE)
  ENDIF()

  #DJB overrides since version file isn't there anymore
  SET(TegraJPEG_IS_L4T TRUE)
  SET(TegraJPEG_L4T_OK TRUE)
#  SET(L4T_VER "${L4T_VER_MAJOR}.${L4T_VER_MINOR}")

  IF(L4T_VER MATCHES ^21.3)
    SET(L4T_SRC_PART r21_Release_v3.0/sources/gstjpeg_src.tbz2)
  ELSEIF(L4T_VER MATCHES ^21.4)
    SET(L4T_SRC_PART r21_Release_v4.0/source/gstjpeg_src.tbz2)
  ELSEIF(L4T_VER MATCHES ^21.5)
    SET(L4T_SRC_PART r21_Release_v5.0/source/gstjpeg_src.tbz2)
  ELSEIF(L4T_VER MATCHES ^23.1)
    SET(L4T_SRC_PART r23_Release_v1.0/source/gstjpeg_src.tbz2)
  ELSEIF(L4T_VER MATCHES ^23.2)
    SET(L4T_SRC_PART r23_Release_v2.0/source/gstjpeg_src.tbz2)
  ELSEIF(L4T_VER MATCHES ^24.1)
    SET(L4T_SRC_PART r24_Release_v1.0/24.1_64bit/source/gstjpeg_src.tbz2)
  ELSEIF(L4T_VER MATCHES ^24.2)
    SET(L4T_SRC_PART r24_Release_v2.0/BSP/sources.tbz2)
  ELSEIF(L4T_VER MATCHES ^27.1)
    SET(L4T_SRC_PART r27_Release_v1.0/BSP/r27.1.0_sources.tbz2)
  ELSEIF(L4T_VER MATCHES ^28.1)
    SET(L4T_SRC_PART r28_Release_v1.0/BSP/source_release.tbz2)
  ELSEIF(L4T_VER MATCHES ^28.2)
    SET(L4T_SRC_PART r28_Release_v2.0/BSP/source_release.tbz2)
    #DJB add
  ELSEIF(L4T_VER MATCHES ^32.2)
    # SET(L4T_SRC_PART r28_Release_v3.0/BSP/source_release.tbz2)
    SET(L4T_SRC_PART Tegra_Multimedia_Nano)
  ELSE()
    MESSAGE(WARNING "Linux4Tegra version (${L4T_VER}) is not recognized. Add the new source URL part to FindTegraJPEG.cmake.")
    SET(TegraJPEG_L4T_OK FALSE)
  ENDIF()
ENDIF()

# Download gstjpeg source
IF(TegraJPEG_L4T_OK)
  MESSAGE(STATUS "DEPENDS_DIR is: ${DEPENDS_DIR}")
  SET(L4T_SRC_PATH ${DEPENDS_DIR}/source/${L4T_SRC_PART})
  GET_FILENAME_COMPONENT(L4T_SRC_DIR ${L4T_SRC_PATH} DIRECTORY)
  MESSAGE(STATUS "Set L4T_SOURCE_DIR to: ${L4T_SRC_DIR}")
  IF(NOT EXISTS ${L4T_SRC_PATH})
    MESSAGE(STATUS "Downloading ${L4T_SRC_PART}...")
    # DJB hardcode
#    SET(L4T_SRC_URL "https://developer.nvidia.com/embedded/dlc/public_sources_Nano")
    SET(L4T_SRC_URL "https://developer.nvidia.com/embedded/dlc/Tegra_Multimedia_Nano")
#            "http://developer.download.nvidia.com/embedded/L4T/${L4T_SRC_PART}")

    # Do we want checksum for the download?
    FILE(DOWNLOAD ${L4T_SRC_URL} ${L4T_SRC_PATH} STATUS L4T_SRC_STATUS)
    MESSAGE(STATUS "Downloaded  L4T_SRC_URL (${L4T_SRC_URL}) to L4T_SRC_PATH(${L4T_SRC_PATH}, status was ${L4T_SRC_STATUS}...")
    LIST(GET L4T_SRC_STATUS 0 L4T_SRC_ERROR)
    LIST(GET L4T_SRC_STATUS 1 L4T_SRC_MSG)
    IF(L4T_SRC_ERROR)
      MESSAGE(WARNING "Failed to download ${L4T_SRC_PART}: ${L4T_SRC_MSG}")
      FILE(REMOVE ${L4T_SRC_PATH})
    ENDIF()
  ENDIF()

  # Look for gstjpeg_src.tbz2
  #FILE(GLOB_RECURSE L4T_GSTJPEG_PATH ${L4T_SRC_DIR}/gstjpeg_src.tbz2)
  MESSAGE(STATUS "Looking for: ${L4T_SRC_DIR}/tegra_multimedia_api")
  FILE(GLOB_RECURSE L4T_GSTJPEG_PATH ${L4T_SRC_DIR}/tegra_multimedia_api)
  IF(NOT L4T_GSTJPEG_PATH)
    MESSAGE(STATUS "Didn't exist:  ${L4T_SRC_DIR}/tegra_multimedia_api")
    MESSAGE(STATUS "Extracting ${L4T_SRC_PART}...")
    EXECUTE_PROCESS(
      COMMAND ${CMAKE_COMMAND} -E tar xjf ${L4T_SRC_PATH}
      WORKING_DIRECTORY ${L4T_SRC_DIR}
    )
    MESSAGE(STATUS "Extracted, looking for ${L4T_SRC_DIR}/tegra_multimedia_api")
    FILE(GLOB_RECURSE L4T_GSTJPEG_PATH ${L4T_SRC_DIR}/tegra_multimedia_api)
  ENDIF()

  IF(L4T_GSTJPEG_PATH)
    EXECUTE_PROCESS(
      COMMAND ${CMAKE_COMMAND} -E tar xjf ${L4T_GSTJPEG_PATH}
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      RESULT_VARIABLE L4T_HEADERS_ERROR
      ERROR_VARIABLE L4T_HEADERS_MSG
    )
    IF(L4T_HEADERS_ERROR)
      MESSAGE(WARNING "Failed to unpack ${L4T_GSTJPEG_PATH}: ${L4T_HEADERS_MSG}")
    ENDIF()
  ENDIF()
ENDIF()

MESSAGE(STATUS "Going to FIND_PATH jpeglib.h in PATHS ${L4T_SRC_DIR}/tegra_multimedia_api")
FIND_PATH(TegraJPEG_INCLUDE_DIRS
  libjpeg-8b/jpeglib.h
  DOC "Found TegraJPEG include directory"
  PATHS ${L4T_SRC_DIR}/tegra_multimedia_api
  PATH_SUFFIXES include
  NO_DEFAULT_PATH
)
MESSAGE(STATUS "After FIND_PATH, TegraJPEG_INCLUDE_DIRS is : ${TegraJPEG_INCLUDE_DIRS}")

FIND_LIBRARY(TegraJPEG_LIBRARIES
  NAMES nvjpeg
  DOC "Found TegraJPEG library (libnvjpeg.so)"
  PATH_SUFFIXES tegra
)

FIND_LIBRARY(TegraJPEG_LIBRARIES
  NAMES jpeg
  DOC "Found TegraJPEG library (libjpeg.so)"
  PATHS /usr/lib/arm-linux-gnueabihf/tegra
  NO_DEFAULT_PATH
)

MESSAGE(STATUS "After FIND_LIBRARY x2, TegraJPEG_LIBRARIES = ${TegraJPEG_LIBRARIES}")

IF(TegraJPEG_INCLUDE_DIRS AND TegraJPEG_LIBRARIES)
  INCLUDE(CheckCSourceCompiles)
  set(CMAKE_REQUIRED_INCLUDES ${TegraJPEG_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${TegraJPEG_LIBRARIES})
  check_c_source_compiles("#include <stdio.h>\n#include <libjpeg-8b/jpeglib.h>\nint main() { struct jpeg_decompress_struct d; jpeg_create_decompress(&d); d.jpegTegraMgr = 0; d.input_frame_buf = 0; return 0; }" TegraJPEG_WORKS)
  set(CMAKE_REQUIRED_INCLUDES)
  set(CMAKE_REQUIRED_LIBRARIES)
ENDIF()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(TegraJPEG FOUND_VAR TegraJPEG_FOUND
  REQUIRED_VARS TegraJPEG_LIBRARIES TegraJPEG_INCLUDE_DIRS TegraJPEG_L4T_OK TegraJPEG_DRIVER_OK TegraJPEG_WORKS)

