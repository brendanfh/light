type
  #LightVariable* = enum
  #  var_m1, var_m2, var_m3, var_m4,
  #  var_m5, var_m6, var_m7, var_m8,
  #  var_p1, var_p2, var_p3, var_p4,
  #  var_x,  var_y
  LightVariable* = string
    
  LightOperation* = enum
    loAdd, loSub, loMul, loDiv, loMod,
    loBitAnd, loBitOr, loBitXor,
    loGt, loGte, loLt, loLte, loEq, loNeq

  LightInt* = int32

#func `$`*(variable: LightVariable): string =
#  case variable:
#  of var_m1: "MEM_1"
#  of var_m2: "MEM_2"
#  of var_m3: "MEM_3"
#  of var_m4: "MEM_4"
#  of var_m5: "MEM_5"
#  of var_m6: "MEM_6"
#  of var_m7: "MEM_7"
#  of var_m8: "MEM_8"
#  of var_p1: "PRM_1"
#  of var_p2: "PRM_2"
#  of var_p3: "PRM_3"
#  of var_p4: "PRM_4"
#  of var_x: "POS_X"
#  of var_y: "POS_Y"
