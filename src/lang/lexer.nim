import strutils
import parseutils
import sequtils

import ./types/types
import ./types/tokens

iterator Generate_tokens*(source: string): LightToken =
  for line in strutils.split(source, "\n"):
    if line.strip.startsWith("//"):
      continue

    for token, is_sep in strutils.tokenize(line, {' ', ';', '\t', ',', '(', ')', '{', '}'}):
      if is_sep:
        for ch in token.items:
          if ch == ',':
            yield LightToken(kind: ltParamDelim)
          if ch == '{':
            yield LightToken(kind: ltBlockStart)
          if ch == '}':
            yield LightToken(kind: ltBlockEnd)
          if ch == '(':
            yield LightToken(kind: ltLeftParen)
          if ch == ')':
            yield LightToken(kind: ltRightParen)
          if ch == ';':
            yield LightToken(kind: ltExprDelim)
        continue

      if token.startsWith('$'):
        let varName = token[1 .. ^1].toLowerAscii

        if varName == "":
          raise newException(IOError, "Expected variable name")
        
        yield LightToken(kind: ltVar, var_name: varName)
      
      elif token.startsWith('!'):
        let funcName = token[1..^1].toLowerAscii
        yield LightToken(kind: ltFunc, func_name: funcName)

      elif token.startsWith('@'):
        let funcName = token[1..^1].toLowerAscii
        yield LightToken(kind: ltFuncDef, func_name: funcName)

      elif token == "=":
        yield LightToken(kind: ltEq)

      elif (token.startsWith("-") and token != "-") or token.isDigit:
        var value: int
        discard parseutils.parseInt(token, value)

        yield LightToken(kind: ltNum, value: value.LightInt)

      elif token == "var":
        yield LightToken(kind: ltVarDef)
      elif token.toLowerAscii == "if":
        yield LightToken(kind: ltIf)
      elif token.toLowerAscii == "else":
        yield LightToken(kind: ltElse)
      elif token.toLowerAscii == "while":
        yield LightToken(kind: ltWhile)
      elif token.toLowerAscii == "break":
        yield LightToken(kind: ltBreak)
      elif token.toLowerAscii == "then" or token.toLowerAscii == "do":
        yield LightToken(kind: ltBlockStart)
      elif token.toLowerAscii == "end":
        yield LightToken(kind: ltBlockEnd)

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
        of "&":
          yield LightToken(kind: ltOp, operation: loBitAnd)
        of "|":
          yield LightToken(kind: ltOp, operation: loBitOr)
        of "^":
          yield LightToken(kind: ltOp, operation: loBitXor)
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
