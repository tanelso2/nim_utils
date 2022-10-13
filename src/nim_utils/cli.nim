import
  os,
  logging,
  strformat,
  strutils

proc prompt*(msg: string): string =
  stdout.write(fmt"{msg}: ")
  return stdin.readline().strip()


proc promptWithDefault*(msg, default: string): string =
  let msgWithDefault = fmt"{msg} (default: {default})"
  let res = prompt msgWithDefault
  if res == "":
    default
  else:
    res

proc yesNoPrompt*(
  msg: string,
  autoyes: bool = false,
  autono: bool = false
): bool =
  let yesNoMsg = fmt"{msg} [y/N]"
  var default = ""
  if autoyes and autono:
    raise newException(IOError, "autoyes and autono are both true... don't know what to do")
  elif autoyes:
    default = "y"
  elif autono:
    default = "n"

  var res: string
  if default == "":
    res = prompt yesNoMsg
  else:
    res = promptWithDefault(yesNoMsg, default)
  case res:
    of "y", "Y":
      true
    of "n", "N":
      false
    else:
      echo "I couldnt understand that, trying again"
      yesNoPrompt(msg)
