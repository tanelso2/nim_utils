import
    macros,
    sequtils,
    nim_utils/simple_yaml,
    test_utils/yaml_testing,
    unittest

type
    Simple = object of RootObj
        a: string
    Simple2 = object of RootObj
        a: string

dumpTree:
    proc ofYaml(n: YNode, t: typedesc[Simple]): Simple =
        expectYMap n:
            result = Simple(a: ofYaml(n.get("a"),
                                      typeof Simple.a))

proc ofYaml(n: YNode, t: typedesc[Simple]): Simple =
    expectYMap n:
        let a = n.get("a").ofYaml( typeof Simple.a )
        result = Simple(a: a)

proc toYaml(x: Simple): YNode =
    {
        "a": toYaml(x.a)
    }.newYMap()

# macro dumpDefn(v: untyped) =
#     quote do:
#         echo treeRepr(getImpl(`v`))

# template dumpDef(v: typed) = dumpDefn(v)

# dumpDef(ofYaml)
# dumpDef(toYaml)

macro dumpTypeImpl(x: typed) =
    echo newLit(x.getTypeImpl.treeRepr)

dumpTypeImpl Simple

macro dumpImpl(x: typed) =
    echo newLit(x.getImpl.treeRepr)

dumpImpl Simple

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
    let fields = @["a"]
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

macro deriveYaml*(v: typed) =
    if v.kind == nnkSym and v.symKind == nskType:
        # StmtList
        #   ProcDef 
        #     Ident "ofYaml"
        #     Empty
        #     Empty
        #     FormalParams
        #       Ident "Simple"
        #       IdentDefs
        #         Ident "n"
        #         Ident "YNode"
        #         Empty
        #       IdentDefs
        #         Ident "t"
        #         BracketExpr
        #           Ident "typedesc"
        #           Ident "Simple"
        #         Empty
        #     Empty
        #     Empty
        #     StmtList
        #       Command
        #         Ident "expectYMap"
        #         Ident "n"
        #         StmtList
        #           LetSection
        #             IdentDefs
        #               Ident "a"
        #               Empty
        #               Call
        #                 DotExpr
        #                   Ident "n"
        #                   Ident "getStr"
        #                 StrLit "a"
        #           Asgn
        #             Ident "result"
        #             ObjConstr
        #               Ident "Simple"
        #               ExprColonExpr
        #                 Ident "a"
        #                 Ident "a"
        let ofYamlDef = mkOfYamlForObjType v
        let toYamlDef = nnkProcDef.newTree()
        result = newStmtList(
            ofYamlDef #, toYamlDef
        )
    else:
        error("deriveYaml only works on types", v)

expandMacros:
    deriveYaml(Simple2)

import
    tables

proc collectObjectFieldNames(o: NimNode): seq[string] =
    discard

let simpleStr = """
a: hello
"""
checkRoundTrip simpleStr

var a = simpleStr.loadNode().ofYaml(Simple)
checkRoundTrip a
check a.a == "hello"

var a2 = simpleStr.loadNode().ofYaml(Simple2)
# checkRoundTrip a2
check a2.a == "hello"