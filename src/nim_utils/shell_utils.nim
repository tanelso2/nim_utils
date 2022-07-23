import
  os,
  osproc,
  sequtils,
  strformat,
  strutils,
  streams,
  std/tempfiles

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

proc tryExec*(command: string): bool =
  try:
    discard execOutput command
    true
  except:
    false

proc runScriptFromUrl*(url: string) =
  # TODO: Use nim's builtin library that does tmps
  # since we're on nim 1.6 now
  let f = execOutput "mktemp"
  let script = execOutput fmt"curl -fsSL {url}"
  writeFile(f, script)
  discard execCmd fmt"chmod +x {f}"
  discard execCmd fmt"sh -c {f}"

proc exeExists*(name: string): bool = findExe(name) != ""

template withShDir*(newDir: string, body: untyped) =
  let currDir = getCurrentDir()
  setCurrentDir newDir
  body
  setCurrentDir currDir
