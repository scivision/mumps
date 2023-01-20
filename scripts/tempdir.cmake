# https://gist.github.com/scivision/2581385d2a5187426020dc17f111d9a2

function(get_temp_dir ovar)

find_program(mktemp NAMES mktemp)
if(mktemp)
  execute_process(COMMAND mktemp -d OUTPUT_VARIABLE out OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE ret)
  if(ret EQUAL 0)
    set(${ovar} ${out} PARENT_SCOPE)
    return()
  endif()
endif()


find_program(pwsh NAMES pwsh)
if(pwsh)
  execute_process(COMMAND pwsh -c "[System.IO.Path]::GetTempPath()" OUTPUT_VARIABLE out OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE ret)
  if(ret EQUAL 0)
    string(RANDOM LENGTH 12 _s)
    set(out ${out}${_s})
    file(MAKE_DIRECTORY ${out})
    set(${ovar} ${out} PARENT_SCOPE)
    return()
  endif()
endif()

message(FATAL_ERROR "Could not find mktemp or pwsh to make temporary directory")

endfunction(get_temp_dir)
