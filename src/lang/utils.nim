import ./types/types

proc EvalOperation*(operation: LightOperation, left, right: LightInt): LightInt =
    case operation:
    of loAdd: left + right
    of loSub: left - right
    of loMul: left * right
    of loDiv: left div right
    of loMod: left mod right
    of loBitAnd: left and right
    of loBitOr: left or right
    of loBitXor: left xor right
    of loGt:
      if left > right: 1
      else: 0
    of loGte:
      if left >= right: 1
      else: 0
    of loLt:
      if left < right: 1
      else: 0
    of loLte:
      if left <= right: 1
      else: 0
    of loEq:
      if left == right: 1
      else: 0
    of loNeq:
      if left != right: 1
      else: 0
