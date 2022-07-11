import
  osproc,
  sequtils,
  strformat,
  strutils,
  streams

proc execOutput*(x: openArray[string]): string =
  let process = x[0]
  let args = x[1..^1]
  let p = startProcess(process, args=args, options={poUsePath})
  defer: p.close()
  let exitCode = p.waitForExit()
  if exitCode != 0:
    echo "Heya, that failed"
    echo p.errorStream().readAll()
    raise newException(IOError, fmt"process {process} had non-zero exit code: {exitCode}")
  return p.outputStream().readAll()

proc execOutput*(command: string): string =
  command
    .split(" ")
    .filterIt(it != "")
    .execOutput
