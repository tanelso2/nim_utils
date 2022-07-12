import
  os,
  logging

let logger = newConsoleLogger()
addHandler(logger)

proc yesNoPrompt*(
  msg: string,
  autoyes: bool = false,
  autono: bool = false
): bool =
  stdout.write(fmt"{msg} [y/N]: ")
  if autoyes and autones:
    raise newException(IOError, "autoyes and autono are both true... don't know what to do")
  elif autoyes:
    info "assuming yes"
    return true
  elif autono:
    info "assuming no"
    return true
    
  let res = stdin.readline()
  case res:
    of "y", "Y":
      true
    of "n", "N":
      false
    else:
      echo "I couldnt understand that, trying again"
      yesNoPrompt(msg)
