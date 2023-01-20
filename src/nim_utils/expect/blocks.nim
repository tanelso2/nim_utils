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
            ident("newContext")),)),
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

proc checkExpectation*(ctx: var ExpectContext, actual, expected: string) =
  if (boxTrim actual) == (boxTrim expected):
    ctx.recordSuccess()
  else:
    ctx.recordFailure(expected, actual)
  
macro expect*(expectedOutput: string) =
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
      nnkExprEqExpr.newTree(
        ident("expected"), 
        expectedOutput) ,
      nnkExprEqExpr.newTree(
        ident("actual"), 
        ident("actualOutput"))
    )
  )