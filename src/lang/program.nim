import sequtils
import tables
import ./types/ast
import ./types/tokens
import ./lexer
import ./parser

type
  LightProgram* = ref object
    code*: seq[LightExpr]

proc LoadProgram*(file_name: string): LightProgram =
  let source_code = readFile(file_name)
  let tokens = toSeq(lexer.GenerateTokens(source_code))
  let code = toSeq(parser.ParseTokens(tokens))

  LightProgram(code: code)
