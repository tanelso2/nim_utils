import
  macros,
  os

const explicitSourcePath* {.strdefine.} = getCurrentCompilerExe().parentDir.parentDir

macro mImport*(path: static[string]): untyped =
  result = newNimNode(nnkStmtList)
  result.add(quote do:
    import `path`
  )

template importCompiler*(module: string) =
  mImport(explicitSourcePath / "compiler" / module)