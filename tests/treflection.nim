import
  macros,
  unittest,
  nim_utils/reflection


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

macro dumpImpl(x: typed) =
  echo newLit(x.getImpl.treeRepr)

dumpImpl Base
dumpImpl RBase
dumpImpl Deriv
dumpImpl Variant

macro dumpFields(x: typed) =
  echo newLit($collectObjFieldsForType(x.getImpl()))

dumpFields Base
dumpFields RBase
dumpFields Deriv
dumpFields Variant