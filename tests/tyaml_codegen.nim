import
    macros,
    sequtils,
    nim_utils/reflection,
    nim_utils/simple_yaml,
    nim_utils/yaml_codegen,
    test_utils/yaml_testing,
    unittest

type
    Simple = object of RootObj
        a: string
    Simple2 = object of RootObj
        a: string

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

# dumpTypeImpl Simple

macro dumpImpl(x: typed) =
    echo newLit(x.getImpl.treeRepr)

dumpImpl Simple

macro dumpTypeKind(x: typed) =
    echo newLit($x.typeKind)

# dumpTypeKind Simple

macro dumpResolvedTypeKind(x: typed) =
    echo newLit($x.getType().typeKind)

# dumpResolvedTypeKind Simple

macro dumpTypeInst(x: typed) = 
    echo newLit(x.getTypeInst().treeRepr)

# dumpTypeInst Simple

expandMacros:
    deriveYaml Simple2

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
checkRoundTrip a2
check a2.a == "hello"

type
    Example = object of RootObj
        i: int
        s: string
        f: float

deriveYaml Example

let example = """
i: 3
s: hey
f: 0.2
"""
let e = example.loadNode().ofYaml(Example)
check e.i == 3
check e.s == "hey"
check e.f == 0.2

type
    Base = object of RootObj
        a: string
    RBase = ref object of Base
    Deriv = object of Base
        b: int
    VKind = enum
        vk1, vk2
    Variant = object of RootObj
        c: string
        case kind: VKind
        of vk1:
            v1: string
        of vk2:
            v2: float

dumpImpl Base
dumpImpl RBase
dumpImpl Deriv
dumpImpl Variant
    