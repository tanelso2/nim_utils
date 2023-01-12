import
  macros,
  sequtils,
  ./reflection

proc getValueForField(fieldName: string, obj, t: NimNode): NimNode =
    newCall("ofYaml",
        newCall(newDotExpr(obj, ident("get")), 
                newStrLitNode(fieldName)),
        nnkCommand.newTree(
            ident("typeof"),
            newDotExpr(t, ident(fieldName))
        )
    )

proc mkObjTypeConsFieldParam(name: string, obj, t: NimNode): NimNode =
    newColonExpr(
        ident(name),
        getValueForField(name, obj, t)
    )

proc mkOfYamlForObjType(t: NimNode): NimNode =
    let retType = t
    let nodeParam = newIdentDefs(ident("n"), ident("YNode"))
    let typeParam = newIdentDefs(ident("t"), 
                                 nnkBracketExpr.newTree(
                                    ident "typedesc",
                                    retType
                                 ))
    let n = ident("n")
    let fields = collectFieldsForType(t.getImpl())
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

proc mkObjTypeTableField(name: string, obj: NimNode): NimNode =
    nnkExprColonExpr.newTree(
        newStrLitNode(name),
        newCall(
            ident("toYaml"),
            newDotExpr(
                obj,
                ident(name)
            )
        )
    )

proc mkToYamlForObjType(t: NimNode): NimNode =
    let retType = ident("YNode")
    let obj = ident("x")
    let fields = collectFieldsForType(t.getImpl())
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


macro deriveYaml*(v: typed) =
    if v.kind == nnkSym and v.symKind == nskType:
        let ofYamlDef = mkOfYamlForObjType v
        let toYamlDef = mkToYamlForObjType v
        result = newStmtList(
            ofYamlDef,
            toYamlDef
        )
    else:
        error("deriveYaml only works on types", v)