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

echo string
echo typeof string

dumpTree:
    typeof typedesc[string]
    typeof string

let s = newYString("hello").ofYaml(string)
echo s

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

expandMacros:
    deriveYaml Example

let example = """
i: 3
s: hey
f: 0.2
"""
let e = example.ofYamlStr(Example)
check e.i == 3
check e.s == "hey"
check e.f == 0.2

type
    Example2 = object of Example
        i2: int

deriveYaml Example2

# echo (typeof Example2.i2)
# echo (typeof Example2.i)

# expandMacros:
#     deriveYaml Example2

let example2 = """
i: 3
i2: 4
s: hey
f: 0.2
"""
let e2: Example2 = example2.loadNode().ofYaml(Example2)
check e2.i == 3
check e2.s == "hey"
check e2.f == 0.2
check e2.i2 == 4


type
    Base = object of RootObj
        a: string
    RBase = ref object of Base
    Deriv = object of Base
        b: int
    Complex = object of RootObj
        c: string
        d: Base
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
dumpImpl Complex

let cs = """
c: def
d:
  a: abc
"""

deriveYamls:
    Base
    Complex

let c: Complex = cs.loadNode().ofYaml(Complex) 

check c.c == "def"
check c.d.a == "abc"
checkRoundTrip c

type 
    MyEnum = enum
        my1, my2, my3

dumpTree:
    proc toYaml(x: MyEnum): YNode =
        newYString($x)

dumpTree:
    proc ofYaml(n: YNode, t: typedesc[MyEnum]): MyEnum =
        expectYString n:
            case n.strVal
            of $my1:
                my1
            of $my2:
                my2
            of $my3:
                my3
            else:
                let s = "unknown kind for MyEnum: " & n.strVal
                raise newException(ValueError, s)

dumpTree:
                let s = "unknown kind for MyEnum: " & n.strVal
                raise newException(ValueError, s)

# dumpImpl VKind
expandMacros:
    deriveYaml VKind