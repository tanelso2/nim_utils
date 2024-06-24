import
  std/tables

proc `&`*[A,B](t1: Table[A,B], t2: Table[A,B]): Table[A,B] =
  result = initTable[A,B](len(t1) + len(t2))
  for k,v in t1.pairs():
    result[k] = v
  for k,v in t2.pairs():
    result[k] = v

proc `&`*[A,B](t1: TableRef[A,B], t2: TableRef[A,B]): TableRef[A,B] =
  result = newTable[A,B](len(t1) + len(t2))
  for k,v in t1.pairs():
    result[k] = v
  for k,v in t2.pairs():
    result[k] = v
