import
  std/options,
  std/sugar,
  std/macros

proc wrapException*[T](f: () -> T): Option[T] =
  try:
    return some(f())
  except:
    return none(T)

proc noneBranch(nn: NimNode): NimNode =
  nn.expectKind nnkStmtList
  for i in 0..<len(nn):
    case.nn[i].kind:
      of nnkCall:
        let cmdName = nn[i][0].`$`
        if cmdName == "none":
          let body = nn[i][1]
          body.expectKind nnkStmtList
          return body



macro match*[T](this: Option[T], body: untyped) =
  echo body.treeRepr()
  let nb = body.noneBranch()
  let sb = body.someBranch()
  quote do:
    if `this`.isSome():
      let `someVarName` = `this`.get()
      `sb`
    else:
      `nb`

when isMainModule:
  let x = none(int)
  x.match:
    some x:
     echo x+1
    none:
     echo "nothing"
