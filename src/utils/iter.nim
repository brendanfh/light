type
  Iter*[T] = ref object
    curr: int
    list: seq[T]
    length: int
    empty: T

proc CreateIter*[T](items: seq[T], empty: T): Iter[T] =
  Iter[T](curr: 0, list: items, length: items.len, empty: empty)

proc Step*[T](iter: Iter[T], off: int = 1) =
  iter.curr += off

func ReachedEnd*[T](iter: Iter[T]): bool =
  iter.curr >= iter.length

proc Current*[T](iter: Iter[T]): T =
  if iter.curr < 0 or iter.curr >= iter.length:
    return iter.empty

  return iter.list[iter.curr]

proc Previous*[T](iter: Iter[T], off: int = 1): T =
  if iter.curr - off < 0 or iter.curr - off >= iter.length:
    return iter.empty

  return iter.list[iter.curr - off]

proc Next*[T](iter: Iter[T], off: int = 1): T =
  if iter.curr + off < 0 or iter.curr + off >= iter.length:
    return iter.empty

  return iter.list[iter.curr + off]

