type
  Iter*[T] = ref object
    curr: int
    list: seq[T]
    length: int
    empty: T

proc CreateIter*[T](items: seq[T], empty: T): Iter[T] =
  Iter[T](curr: 0, list: items, length: items.len, empty: empty)

proc Step*[T](iter: Iter[T]) =
  iter.curr += 1

func ReachedEnd*[T](iter: Iter[T]): bool =
  iter.curr >= iter.length

proc Current*[T](iter: Iter[T]): T =
  if iter.curr < 0 or iter.curr >= iter.length:
    return iter.empty

  return iter.list[iter.curr]

proc Previous*[T](iter: Iter[T]): T =
  if iter.curr - 1 < 0 or iter.curr - 1 >= iter.length:
    return iter.empty

  return iter.list[iter.curr - 1]

proc Next*[T](iter: Iter[T]): T =
  if iter.curr + 1 < 0 or iter.curr + 1 >= iter.length:
    return iter.empty

  return iter.list[iter.curr + 1]

