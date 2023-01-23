import
  ./context,
  ../io_utils,
  std/macros

macro expectTest*(body: untyped) =
  # block:
  #   var currContext: ExpectContext = newContext()
  #   try:
  #     `body`
  #   finally:
  #     currContext.restoreStdout()
  #     currContext.reportResults()
  nnkBlockStmt.newTree(
    newEmptyNode(),
    newStmtList(
      nnkVarSection.newTree(
        nnkIdentDefs.newTree(
          ident("currContext"),
          ident("ExpectContext"),
          newCall(
            ident("newContext"),
            ident("currentSourcePath")),)),
      nnkTryStmt.newTree(
        body,
        nnkFinally.newTree(
          newStmtList(
            newCall(
              nnkDotExpr.newTree(
                ident("currContext"),
                ident("restoreStdout"))),
            newCall(
              nnkDotExpr.newTree(
                ident("currContext"),
                ident("reportResults")
              )
            ))))))

proc checkExpectation*(ctx: var ExpectContext, loc: InstantiationInfo, actual, expected: string) =
  let trimmedActual = boxTrim actual
  let trimmedExpected = boxTrim expected
  if trimmedActual == trimmedExpected:
    ctx.recordSuccess(loc)
  else:
    ctx.recordFailure(loc, trimmedExpected, trimmedActual)
  
macro expect*(expectedOutput: string) =
  nnkBlockStmt.newTree(
    newEmptyNode(),
    newStmtList(
      nnkLetSection.newTree(
        nnkIdentDefs.newTree(
          ident("actualOutput"),
          newEmptyNode(),
          newCall(
            newDotExpr(
              ident("currContext"),
              ident("readOutput")
            )
          )
        )
      ),
      newCall(
        newDotExpr(ident("currContext"), ident("checkExpectation")),
        newCall("instantiationInfo"),
        nnkExprEqExpr.newTree(
          ident("expected"), 
          expectedOutput) ,
        nnkExprEqExpr.newTree(
          ident("actual"), 
          ident("actualOutput"))
      )
    ))