import
  os,
  osproc,
  sequtils,
  strformat,
  strutils,
  streams,
  std/tempfiles,
  ./logline

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

proc execCmdOrThrow*(command: string) =
  let exitCode = execCmd(command)
  if exitCode != 0:
    raise newException(IOError, fmt"command {command} had non-zero exit code: {exitCode}")

proc execOrThrow*(command: string) = discard execOutput(command)

proc runScriptFromUrl*(url: string) =
  let
    (cfile,path) = createTempFile("","")
    f = cfile
  let script = execOutput fmt"curl -fsSL {url}"
  f.write(script)
  f.close()
  execCmdOrThrow fmt"chmod +x {path}"
  execCmdOrThrow fmt"sh -c {path}"

proc exeExists*(name: string): bool = findExe(name) != ""

template withShDir*(newDir: string, body: untyped) =
  let currDir = getCurrentDir()
  setCurrentDir newDir
  try:
    body
  finally:
    setCurrentDir currDir
