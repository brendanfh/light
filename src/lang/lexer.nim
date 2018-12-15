import strutils
import parseutils
import sequtils

import ./types/types
import ./types/tokens

iterator Generate_tokens*(source: string): LightToken =
  for line in strutils.split(source, "\n"):
    if line.strip.startsWith("//"):
      continue

    for token, is_sep in strutils.tokenize(line, {' ', ';', '\t', ',', '(', ')'}):
      if is_sep:
        if token.contains({','}):
          yield LightToken(kind: ltParamDelim)
        if token.contains({'('}):
          yield LightToken(kind: ltParamStart)
        if token.contains({')'}):
          yield LightToken(kind: ltParamEnd)
        if token.contains({';'}):
          yield LightToken(kind: ltExprDelim)
        continue

      if token.startsWith('$'):
        let varString = token[1 .. ^1].toLowerAscii
        var varName: LightVariable

        if varString == "":
          raise newException(IOError, "Expected variable name")
        else:
          if varString == "mem_1": varName = var1
          elif varString == "mem_2": varName = var2
          elif varString == "mem_3": varName = var3
          elif varString == "mem_4": varName = var4
          elif varString == "mem_5": varName = var5
          elif varString == "mem_6": varName = var6
          elif varString == "mem_7": varName = var7
          elif varString == "mem_8": varName = var8
          elif varString == "pos_x": varName = varX
          elif varString == "pos_y": varName = varY
          else:
            raise newException(IOError, "Invalid variable name.")

        yield LightToken(kind: ltVar, var_name: varName)

      elif token.startsWith('!'):
        let funcName = token[1..^1].toLowerAscii
        yield LightToken(kind: ltFunc, func_name: funcName)

      elif token.startsWith('#'):
        let funcName = token[1..^1].toLowerAscii
        yield LightToken(kind: ltFuncDef, func_name: funcName)

      elif token == "=":
        yield LightToken(kind: ltEq)

      elif token.isDigit:
        var value: int
        discard parseutils.parseInt(token, value)

        yield LightToken(kind: ltNum, value: value.LightInt)

      elif token.toLowerAscii == "if":
        yield LightToken(kind: ltIf)
      elif token.toLowerAscii == "while":
        yield LightToken(kind: ltWhile)
      elif token.toLowerAscii == "break":
        yield LightToken(kind: ltBreak)
      elif token.toLowerAscii == "then" or token.toLowerAscii == "do" or token == "{":
        yield LightToken(kind: ltBlockStart)
      elif token.toLowerAscii == "end" or token == "}":
        yield LightToken(kind: ltBlockEnd)

      elif token.toLowerAscii == "goto":
        yield LightToken(kind: ltGoto)
      elif token.startsWith(':'):
        let labelName = token[1 .. ^1]
        yield LightToken(kind: ltLabel, label_name: labelName)

      else:
        case token:
        of "+":
          yield LightToken(kind: ltOp, operation: loAdd)
        of "-":
          yield LightToken(kind: ltOp, operation: loSub)
        of "*":
          yield LightToken(kind: ltOp, operation: loMul)
        of "/":
          yield LightToken(kind: ltOp, operation: loDiv)
        of "%":
          yield LightToken(kind: ltOp, operation: loMod)
        of "<":
          yield LightToken(kind: ltOp, operation: loLt)
        of "<=":
          yield LightToken(kind: ltOp, operation: loLte)
        of ">":
          yield LightToken(kind: ltOp, operation: loGt)
        of ">=":
          yield LightToken(kind: ltOp, operation: loGte)
        of "==":
          yield LightToken(kind: ltOp, operation: loEq)
        of "~=":
          yield LightToken(kind: ltOp, operation: loNeq)
        else:
          raise newException(IOError, "Invalid token")

    yield LightToken(kind: ltExprDelim)
