import
  ./shell_utils,
  std/macros,
  std/tables,
  std/strtabs,
  std/sugar,
  strformat,
  os

proc sudoReadFile*(filename: string): string =
  return execOutput fmt"sudo cat {filename}"

proc sudoCreateSymlink*(src, dest: string) =
  execCmdOrThrow fmt"sudo ln -s {src} {dest}"

proc sudoCopyFile*(source, dest: string) =
  execCmdOrThrow fmt"sudo cp {source} {dest}"

proc sudoCopyDir*(source, dest: string) =
  execCmdOrThrow fmt"sudo cp -r {source} {dest}"

const translation = {
  "readFile": "sudoReadFile",
  "createSymlink": "sudoCreateSymlink",
  "copyFile": "sudoCopyFile",
  "copyDir": "sudoCopyDir"
}.toTable

proc translate(a: NimNode): NimNode =
  case a.kind
  of nnkIdent:
    let x = a.strVal
    if x in translation:
      # Return translated function name
      return ident(translation[x])
    else:
      # Doesn't need to be translated, return as-is
      return a
  else:
    if len(a) == 0:
      # No children, just return as-is
      return a
    else:
      let translatedChildren = collect(newSeq):
        for c in a.children:
          translate(c)
      return newTree(a.kind, translatedChildren)

macro withSudo*(body: untyped): untyped =
  translate(body)

when isMainModule:
  expandMacros:
    withSudo:
      let x = readFile "x.txt"
