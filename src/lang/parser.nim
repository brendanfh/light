
import ./types/types
import ./types/tokens
import ./types/ast

import ../utils/iter

type
  LightParser = object
    tokens: Iter[LightToken]
  
func CreateParser(tokens: Iter[LightToken]): LightParser =
  LightParser(tokens: tokens)
func CreateParser(tokens: seq[LightToken]): LightParser =
  CreateParser(CreateIter[LightToken](tokens, LightToken(kind: ltNull)))

func NextExpr(parser: LightParser, prev: LightExpr, stop_at: set[LightTokenType]): LightExpr

func Parse_block(tokens: Iter[LightToken], sep, endd: LightTokenType): seq[LightExpr] =
  result = @[]

  var last = tokens.Current
  if last.kind == endd:
    tokens.Step()
    return

  var parser = CreateParser(tokens)
  while last.kind != endd:
    let p = parser.NextExpr(LightExpr(kind: leNull), {sep, endd})
    if p.kind != leNull:
      result.add(p)
    last = parser.tokens.Current
    parser.tokens.Step()
  
func NextExpr(parser: LightParser, prev: LightExpr, stop_at: set[LightTokenType]): LightExpr =
  let curr = parser.tokens.Current

  if curr.kind in stop_at:
    return prev

  parser.tokens.Step()

  if curr.kind in {ltNum, ltVar} and prev.kind == leNull:
    let prevExpr =
      case curr.kind:
      of ltNum: LightExpr(kind: leNumLit, value: curr.value)
      of ltVar: LightExpr(kind: leVar, var_name: curr.var_name)
      else: LightExpr(kind: leNull)

    return parser.NextExpr(prevExpr, stop_at)

  elif curr.kind == ltOp:
    let next = parser.NextExpr(LightExpr(kind: leNull), stop_at)
    return LightExpr(
      kind: leOp,
      left: prev,
      right: next,
      operation: curr.operation
    )
  
  elif curr.kind == ltEq:
    if prev.kind != leVar:
      raise newException(ValueError, "Expected variable on the left of assignment operator")

    else:
      let next = parser.NextExpr(LightExpr(kind: leNull), stop_at)

      return LightExpr(
        kind: leAssign,
        variable: prev.var_name,
        expression: next
      )

  elif curr.kind == ltLabel:
    return LightExpr(
      kind: leLabel,
      label: curr.label_name
    )
  
  elif curr.kind == ltGoto:
    let next = parser.tokens.Current
    if next.kind != ltLabel:
      raise newException(ValueError, "Expected label after goto")

    else:
      return LightExpr(
        kind: leGoto,
        label: next.label_name
      )

  elif curr.kind == ltIf:
    let condition = parser.NextExpr(LightExpr(kind: leNull), {ltBlockStart})
    parser.tokens.Step()
    let body = Parse_block(parser.tokens, ltExprDelim, ltBlockEnd)

    return LightExpr(
      kind: leIf,
      condition: condition,
      body: body
    )

  elif curr.kind == ltWhile:
    let condition = parser.NextExpr(LightExpr(kind: leNull), {ltBlockStart})
    parser.tokens.Step()
    let body = Parse_block(parser.tokens, ltExprDelim, ltBlockEnd)

    return LightExpr(
      kind: leWhile,
      condition: condition,
      body: body
    )
  
  elif curr.kind == ltBreak:
    return LightExpr(
      kind: leBreak
    )

  elif curr.kind == ltFunc:
    if parser.tokens.Current.kind != ltParamStart:
      raise newException(ValueError, "Expected parameter list after function call")

    parser.tokens.Step()
    let params = Parse_block(parser.tokens, ltParamDelim, ltParamEnd)

    return LightExpr(
      kind: leFuncCall,
      func_name: curr.func_name,
      params: params
    )
  
  elif curr.kind == ltFuncDef:
    if parser.tokens.Current.kind != ltBlockStart:
      raise newException(ValueError, "Expected block start after function definition")
    
    parser.tokens.Step()
    let body = Parse_block(parser.tokens, ltExprDelim, ltBlockEnd)
    
    return LightExpr(
      kind: leFuncDef,
      def_func_name: curr.func_name,
      func_body: body
    )

  else:
    return LightExpr(
      kind: leNull
    )
  
iterator Parse_tokens*(tokens: seq[LightToken]): LightExpr =
  var parser = CreateParser(tokens)
  while not parser.tokens.ReachedEnd:
    let next = parser.NextExpr(LightExpr(kind: leNull), {ltExprDelim})
    if next.kind != leNull:
      yield next
    parser.tokens.Step()
