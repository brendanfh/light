
import ./types/types
import ./types/tokens
import ./types/ast
import ./utils

import ../utils/iter

func NextExpr(tokens: Iter[LightToken], prev: LightExpr, stop_at: set[LightTokenType]): LightExpr

func ParseBlock(tokens: Iter[LightToken], sep, endd: LightTokenType): seq[LightExpr] =
  result = @[]

  var last = tokens.Current
  if last.kind == endd:
    tokens.Step()
    return

  while last.kind != endd:
    let p = tokens.NextExpr(LightExpr(kind: leNull), {sep, endd})
    if p.kind != leNull:
      result.add(p)
    last = tokens.Current
    tokens.Step()
  
func NextExpr(tokens: Iter[LightToken], prev: LightExpr, stop_at: set[LightTokenType]): LightExpr =
  let curr = tokens.Current

  if curr.kind in stop_at:
    return prev

  tokens.Step()

  if curr.kind in {ltNum, ltVar, ltFunc} and prev.kind == leNull:
    let prevExpr =
      case curr.kind:
      of ltNum: LightExpr(kind: leNumLit, value: curr.value)
      of ltVar: LightExpr(kind: leVar, var_name: curr.var_name)
      of ltFunc:
        if tokens.Current.kind != ltLeftParen:
          raise newException(ValueError, "Expected parameter list after function call")

        tokens.Step()
        let params = ParseBlock(tokens, ltParamDelim, ltRightParen)

        LightExpr(
          kind: leFuncCall,
          func_name: curr.func_name,
          params: params
        )
      else: LightExpr(kind: leNull)

    return tokens.NextExpr(prevExpr, stop_at)

  elif curr.kind == ltOp:
    let next = tokens.NextExpr(LightExpr(kind: leNull), stop_at)

    # Reduce if possible
    if prev.kind == leNumLit and next.kind == leNumLit:
      return LightExpr(
        kind: leNumLit,
        value: EvalOperation(curr.operation, prev.value, next.value)
      )
    else:
      return LightExpr(
        kind: leOp,
        left: prev,
        right: next,
        operation: curr.operation
      )

  elif curr.kind == ltLeftParen:
    let next = tokens.NextExpr(LightExpr(kind: leNull), {ltRightParen})
    tokens.Step()
    return tokens.NextExpr(next, stop_at)
  
  elif curr.kind == ltEq:
    if prev.kind != leVar:
      raise newException(ValueError, "Expected variable on the left of assignment operator")

    else:
      let next = tokens.NextExpr(LightExpr(kind: leNull), stop_at)

      return LightExpr(
        kind: leAssign,
        variable: prev.var_name,
        expression: next
      )

  elif curr.kind == ltIf:
    let condition = tokens.NextExpr(LightExpr(kind: leNull), {ltBlockStart})
    tokens.Step()
    let body = ParseBlock(tokens, ltExprDelim, ltBlockEnd)

    let else_body =
      if tokens.Current.kind == ltElse:
        tokens.Step()
        tokens.Step()
        ParseBlock(tokens, ltExprDelim, ltBlockEnd)
      else:
        @[]


    return LightExpr(
      kind: leIf,
      condition: condition,
      body: body,
      else_body: else_body
    )

  elif curr.kind == ltWhile:
    let condition = tokens.NextExpr(LightExpr(kind: leNull), {ltBlockStart})
    tokens.Step()
    let body = ParseBlock(tokens, ltExprDelim, ltBlockEnd)

    return LightExpr(
      kind: leWhile,
      condition: condition,
      body: body
    )
  
  elif curr.kind == ltBreak:
    return LightExpr(
      kind: leBreak
    )
  
  elif curr.kind == ltFuncDef:
    if tokens.Current.kind != ltLeftParen:
      raise newException(ValueError, "Expected parameter list before function definition")

    tokens.Step()
    let params = ParseBlock(tokens, ltParamDelim, ltRightParen)
    var param_list = newSeq[LightVariable]()
    for param in params:
      if param.kind != leVar:
        raise newException(ValueError, "Only parameter variables in function defintion parameter list")
      if (param.variable < var_p1) or (param.variable > var_p4):
        raise newException(ValueError, "Only parameter variables in function defintion parameter list")
      else:
        param_list.add(param.variable)

    # Allows for next line function body
    if tokens.Current.kind == ltExprDelim:
      tokens.Step()

    if tokens.Current.kind != ltBlockStart:
      raise newException(ValueError, "Expected function body")

    tokens.Step()
    let body = ParseBlock(tokens, ltExprDelim, ltBlockEnd)
    
    return LightExpr(
      kind: leFuncDef,
      def_func_name: curr.func_name,
      param_vars: param_list,
      func_body: body
    )

  else:
    return LightExpr(
      kind: leNull
    )
  
iterator Parse_tokens*(tkns: seq[LightToken]): LightExpr =
  var tokens = CreateIter[LightToken](tkns, LightToken(kind: ltNull))
  while not tokens.ReachedEnd:
    let next = tokens.NextExpr(LightExpr(kind: leNull), {ltExprDelim})
    if next.kind != leNull:
      yield next
    tokens.Step()
