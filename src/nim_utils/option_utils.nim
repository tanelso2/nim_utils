import
  std/options,
  std/sugar

proc wrapException*[T](f: () -> T): Option[T] =
  try:
    return some(f())
  except:
    return none(T)
