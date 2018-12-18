import os
import times
import tables
import random
import parseutils

import docopt
import opengl
import glfw3 as glfw
import gfx/window as gfx_window
import gfx/glutils as glutils

import lang/types/types
import lang/types/ast
import lang/program
import lang/executer

import board/board

proc key_down(window: glfw.Window, key, scancode, action, modifier: cint) {.cdecl.} =
  if key == glfw.KEY_ESCAPE and action == glfw.PRESS:
    glfw.SetWindowShouldClose(window, glfw.TRUE)

proc CreateFuncs(window: gfx_window.Window, board: LightBoard): ExecFuncs =
  newTable({
    "say": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      echo $args
    ),

    "get_width": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.width.int32
    ),

    "get_height": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.height.int32
    ),

    "in_bounds": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      if args[0] < 0 or args[1] < 0 or args[0] >= board.width or args[1] >= board.height:
        0
      else:
        1
    ),

    "set_col": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.SetCol(args[0].int, args[1].int, args[2].GLuint)
    ),

    "set_a": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.SetA(args[0].int, args[1].int, args[2].GLuint)
    ),

    "set_r": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.SetR(args[0].int, args[1].int, args[2].GLuint)
    ),

    "set_g": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.SetG(args[0].int, args[1].int, args[2].GLuint)
    ),

    "set_b": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.SetB(args[0].int, args[1].int, args[2].GLuint)
    ),

    "get_col": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.GetCol(args[0].int, args[1].int).int32
    ),

    "get_a": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.GetA(args[0].int, args[1].int).int32
    ),

    "get_r": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.GetR(args[0].int, args[1].int).int32
    ),

    "get_g": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.GetG(args[0].int, args[1].int).int32
    ),

    "get_b": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.GetB(args[0].int, args[1].int).int32
    ),

    "random": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      random.rand(args[0].int).int32
    ),

    "halt": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      ec.StopExecution()
    ),

    "render": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      glClearColor(0, 0, 0, 1)
      glClear(GL_COLOR_BUFFER_BIT)
      
      board.RebufferColors()
      board.Render()

      os.sleep(1)
      window.Refresh()
      if window.ShouldClose():
        ec.StopExecution()
    )
  })

let docs = """
Light Interpreter.

Usage:
  light run <file> [--width=<int>] [--height=<int>] [--win_width=<int>] [--win_height=<int>]
  light ast <file>
  light (-h | --help)
  light --version
  
Options:
  -h --help           Show this screen.
  --width=<int>       Width of board [default: 64].
  --height=<int>      Height of board [default: 64].
  --win_width=<int>   Width of window [default: 1200].
  --win_height=<int>  Height of window [default: 700].
"""

type
  RunOptions = object
    filename: string
    board_width: int
    board_height: int
    window_width: int
    window_height: int

proc RunProgram(options: RunOptions) =
  let window = gfx_window.NewWindow(options.window_width.cint, options.window_height.cint, "Light Visualizer")
  window.SetKeyCallback(key_down)

  var program = LoadProgram(options.filename)

  let board = CreateBoard(options.board_width, options.board_height)
  board.InitRendering()

  let ec = MakeExecutionContext(CreateFuncs(window, board))
  discard ExecuteProgram(ec, program)

  while not window.ShouldClose():
    glClearColor(0, 0, 0, 1)
    glClear(GL_COLOR_BUFFER_BIT)
    
    board.Render()

    os.sleep(1)
    window.Refresh()

  window.CloseWindow()

proc PrintAst(filename: string) =
  let program = LoadProgram(filename)

  echo "\n" & filename & "'s Abstract Syntax Tree"
  for line in program.code:
    echo line
  echo "\n"

proc main() =
  random.randomize(getTime().toUnix())
  let args = docopt(docs, version = "Light programming language v0.1.0")

  if args["run"]:
    var
      board_width: int
      board_height: int
      window_width: int
      window_height: int
    discard parseInt($args["--width"], board_width)
    discard parseInt($args["--height"], board_height)
    discard parseInt($args["--win_width"], window_width)
    discard parseInt($args["--win_height"], window_height)
    let options = RunOptions(
        filename: $args["<file>"],
        board_width: board_width,
        board_height: board_height,
        window_width: window_width,
        window_height: window_height,
    )
    RunProgram(options)

  if args["ast"]:
    PrintAst($args["<file>"])

when isMainModule:
  main()
