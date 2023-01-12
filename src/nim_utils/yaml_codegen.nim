import
  macros,
  sequtils,
  ./reflection

proc getValueForField(f: Field, obj, t: NimNode): NimNode =
    newCall("ofYaml",
        newCall(newDotExpr(obj, ident("get")), 
                newStrLitNode(f.getName())),
        nnkBracketExpr.newTree(
          ident("typedesc"),
          f.getT()
        )
    )

proc mkObjTypeConsFieldParam(f: Field, obj, t: NimNode): NimNode =
  newColonExpr(
    ident(f.name),
    getValueForField(f, obj, t)
  )

proc mkOfYamlForObjType(t: NimNode, fields: seq[Field]): NimNode =
    let retType = t
    let nodeParam = newIdentDefs(ident("n"), ident("YNode"))
    let typeParam = newIdentDefs(ident("t"), 
                                 nnkBracketExpr.newTree(
                                    ident "typedesc",
                                    retType
                                 ))
    let n = ident("n")
    newProc(
        name=ident("ofYaml"),
        params=[retType, nodeParam, typeParam],
        body=nnkStmtList.newTree(
            nnkCommand.newTree(
                ident("expectYMap"),
                n,
                newStmtList(
                    nnkAsgn.newTree(
                        ident("result"),
                        nnkObjConstr.newTree(
                            concat(
                              @[retType],
                              fields.mapIt(mkObjTypeConsFieldParam(it, n, retType))
                            )
                        )
                    )

                )
            )
        )
    )

proc mkObjTypeTableField(f: Field, obj: NimNode): NimNode =
    nnkExprColonExpr.newTree(
        newStrLitNode(f.name),
        newCall(
            ident("toYaml"),
            newDotExpr(
                obj,
                ident(f.name)
            )
        )
    )

proc mkToYamlForObjType(t: NimNode, fields: seq[Field]): NimNode =
    let retType = ident("YNode")
    let obj = ident("x")
    newProc(
        name=ident("toYaml"),
        params=[retType, newIdentDefs(obj, t)],
        body=nnkStmtList.newTree(
            newCall(
                ident("newYMap"),
                nnkTableConstr.newTree(
                    fields.mapIt(mkObjTypeTableField(it, obj))
                )
            )
        )
    )

proc mkToYamlForEnumType(t: NimNode, vals: seq[string]): NimNode =
  let retType = ident("YNode")
  let obj = ident("x")
  newProc(
      name=ident("toYaml"),
      params=[retType, newIdentDefs(obj, t)],
      body=nnkStmtList.newTree(
        newCall(
          ident("newYString"),
          nnkPrefix.newTree(
            ident("$"),
            obj
          )
        )
      )
  )

proc mkEnumOfBranch(val: string): NimNode =
  nnkOfBranch.newTree(
    nnkPrefix.newTree(
      ident("$"),
      ident(val)
    ),
    newStmtList(
      ident(val)
    )
  )

proc mkOfYamlForEnumType(t: NimNode, vals: seq[string]): NimNode =
  let retType = t
  let n = ident("n")
  let nodeParam = newIdentDefs(n, ident("YNode"))
  let typeParam = newIdentDefs(ident("t"), 
                                nnkBracketExpr.newTree(
                                  ident "typedesc",
                                  retType
                                ))
  let elseBranch = 
    nnkElse.newTree(
      newStmtList(
        nnkRaiseStmt.newTree(
          newCall(
            ident("newException"),
            ident("ValueError"),
            nnkInfix.newTree(
              ident("&"),
              #TODO: Add type name here
              newStrLitNode("unknown kind: "),
              nnkDotExpr.newTree(
                n, ident("strVal")
              )
            )
          )
        )
      )
    )
  newProc(
      name=ident("ofYaml"),
      params=[retType, nodeParam, typeParam],
      body=nnkStmtList.newTree(
        nnkCommand.newTree(
          ident("expectYString"),
          n,
          newStmtList(
            nnkCaseStmt.newTree(
              concat(@[
                  nnkDotExpr.newTree(
                    n, ident("strVal")
                  )
                ],
                vals.mapIt(mkEnumOfBranch(it)),
                @[elseBranch]
              )
            )
          )
        )
      ))

proc mkToYamlForType(t: NimNode): NimNode =
  let fields = collectObjFieldsForType(t.getImpl())
  case fields.kind
  of otObj:
    return mkToYamlForObjType(t, fields.fields)
  of otVariant:
    error("NOIMPL for variants", t)
  of otEnum:
    return mkToYamlForEnumType(t, fields.vals)
  of otEmpty:
    error("NOIMPL for empty types", t)

proc mkOfYamlForType(t: NimNode): NimNode =
  let fields = collectObjFieldsForType(t.getImpl())
  case fields.kind
  of otObj:
    return mkOfYamlForObjType(t, fields.fields)
  of otVariant:
    error("NOIMPL for variants", t)
  of otEnum:
    return mkOfYamlForEnumType(t, fields.vals)
  of otEmpty:
    error("NOIMPL for empty types", t)

macro deriveYaml*(v: typed) =
    if v.kind == nnkSym and v.symKind == nskType:
        let ofYamlDef = mkOfYamlForType v
        let toYamlDef = mkToYamlForType v
        result = newStmtList(
            ofYamlDef,
            toYamlDef
        )
    else:
        error("deriveYaml only works on types", v)

macro deriveYamls*(body: untyped) =
  expectKind(body, nnkStmtList)
  result = newStmtList()
  for x in body.children:
    result.add(nnkCommand.newTree(
      ident("deriveYaml"),
      x
    ))
