
#
# AppLauncherTest4
#

include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Test1 - Pass arguments to the application using the launcher
set(command ${launcher_exe} --launcher-no-splash --launch ${application} --foo myarg --list item1 item2 item3 --verbose)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test1 - [${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Argument passed:--foo myarg --list item1 item2 item3 --verbose")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Test1 - Failed to pass parameters from ${launcher_name} "
                      "to ${application_name}.")
endif()

# --------------------------------------------------------------------------
# Test2 - Check if flag --launcher-verbose works as expected
set(command ${launcher_exe} --launcher-no-splash --launcher-verbose --launch ${application})
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test2 - [${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(regex "info: Setting library path.*info: Starting.*")
string(REGEX MATCH ${regex} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "Test2 - Problem with flag --launcher-verbose")
endif()

# --------------------------------------------------------------------------
# Test3 - Check if flag --launcher-help works as expected
set(command ${launcher_exe} --launcher-help --launch ${application})
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test3 - [${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Usage
  CTKAppLauncher [options]

Options

  --launcher-help                Display help
  --launcher-verbose             Verbose mode
  --launch                       Specify the application to launch
  --launcher-detach              Launcher will NOT wait for the application to finish
  --launcher-no-splash           Hide launcher splash
  --launcher-timeout             Specify the time in second before the launcher kills the application. -1 means no timeout (default: -1)
  --launcher-generate-template   Generate an example of setting file
")

# TODO Comparison of expected string and current string doesn't seem to work ?
#if(NOT ${expected_msg} STREQUAL ${ov})
#  message(FATAL_ERROR "Test3 - Problem with flag --launcher-help."
#                      "\n expected_msg:\n ${expected_msg}"
#                      "\n current_msg:\n ${ov}")
#endif()

# --------------------------------------------------------------------------
# Delete template file if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove -f ${launcher}LauncherSettings.ini.template
  )

# --------------------------------------------------------------------------
# Test4 - Check if flag --launcher-generate-template works as expected
set(command ${launcher_exe} --launcher-generate-template)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test4 - Failed to run [${launcher_exe}] with parameter --launcher-generate-template\n${ev}")
endif()

if(NOT EXISTS ${launcher}LauncherSettings.ini.template)
   message(FATAL_ERROR "Test4 - Problem with flag --launcher-generate-template."
                       "Failed to generate template settings file: ${launcher}LauncherSettings.ini.template")
endif()

# --------------------------------------------------------------------------
# Delete timeout file if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove -f ${application}-timeout.txt
  )

# --------------------------------------------------------------------------
# Test5 - Check if flag --launcher-timeout works as expected
set(command ${launcher_exe} --launcher-no-splash --launcher-timeout 4 --launch ${application} --test-timeout)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  RESULT_VARIABLE rv
  )
print_command_as_string("${command}")

if(NOT "${rv}" STREQUAL "3")
  message(FATAL_ERROR "Test5a - Failed to run [${launcher_exe}] with parameter --launcher-timeout\n${ev}")
endif()

# Since launcher-timeout > App4Test-timeout, file ${application}-timeout.txt should exists
if(NOT EXISTS ${application}-timeout.txt)
   message(FATAL_ERROR "Test5a - Problem with flag --launcher-timeout. "
                       "File [${application}-timeout.txt] should exist.")
endif()

# Delete timeout file if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove -f ${application}-timeout.txt
  )

# Re-try with launcher-timeout < App4Test-timeout
set(command ${launcher_exe} --launcher-no-splash --launcher-timeout 1 --launch ${application} --test-timeout)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

# Since we force the application to shutdown, we expect the error code to be >0
if(NOT rv)
  message(FATAL_ERROR "Test5b - Failed to run [${launcher_exe}] with parameter --launcher-timeout\n${ev}")
endif()

# Since launcher-timeout < App4Test-timeout, file ${application}-timeout.txt should NOT exists
# Note: On windows, since out App4Test does NOT support the WM_CLOSE event, let's skip the test.
#       See https://github.com/commontk/AppLauncher/issues/15
set(_exists)
set(_exists_msg " NOT")
if(WIN32)
  set(_exists NOT)
  set(_exists_msg)
endif()
if(${_exists} EXISTS ${application}-timeout.txt)
   message(FATAL_ERROR "Test5d - Problem with flag --launcher-timeout. "
                       "File [${application}-timeout.txt] should ${_exists_msg}exist.")
endif()


