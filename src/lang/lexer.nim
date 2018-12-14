import strutils
import parseutils
import sequtils

import ./types
import ./tokens

iterator Generate_tokens*(source: string): LightToken =
  for token, is_sep in strutils.tokenize(source, {' ', '\n', ';', '\t', '='}):
    if is_sep:
      if token.contains({'\n', ';'}):
        yield LightToken(kind: ltExprDelim)
      if token.contains({'='}):
        yield LightToken(kind: ltEq)
      continue

    if token.startsWith('$'):
      let varString = token[1 .. ^1]
      var varName: LightVariable

      if varString == "":
        raise newException(IOError, "Expected variable name")
      else:
        if varString == "MEM_1": varName = var1
        elif varString == "MEM_2": varName = var2
        elif varString == "MEM_3": varName = var3
        elif varString == "MEM_4": varName = var4
        elif varString == "MEM_5": varName = var5
        elif varString == "MEM_6": varName = var6
        elif varString == "MEM_7": varName = var7
        elif varString == "MEM_8": varName = var8
        else:
          raise newException(IOError, "Invalid variable name.")

      yield LightToken(kind: ltVar, var_name: varName)

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
