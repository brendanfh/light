import os
import tables
import opengl
import glfw3 as glfw
import gfx/window as gfx_window
import gfx/glutils as glutils

import lang/types/types
import lang/program
import lang/executer

import board/board

proc key_down(window: glfw.Window, key, scancode, action, modifier: cint) {.cdecl.} =
  if key == glfw.KEY_ESCAPE and action == glfw.PRESS:
    glfw.SetWindowShouldClose(window, glfw.TRUE)

proc main() =
  let window = gfxWindow.NewWindow(1200, 700, "ASDF")
  window.SetKeyCallback(key_down)

  let program = LoadProgram("./data/progs/fibcol.lgt")

  const board_width: int = 128
  const board_height: int = 128
  let board = CreateBoard(board_width, board_height)
  board.InitRendering()

  var funcs = newTable({
    "say": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      echo $args
    ),
    "set_col": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      board.SetCol(ec.worker.pos_x.int, ec.worker.pos_y.int, args[0].GLuint)
    ),
    "step_linear": (proc(ec: ExecutionContext, args: openarray[int32]): int32 {.closure.} =
      ec.worker.pos_x += args[0]
      while ec.worker.pos_x >= board_width:
        ec.worker.pos_x -= board_width.LightInt
        ec.worker.pos_y += 1
      while ec.worker.pos_x < 0:
        ec.worker.pos_x += board_width.LightInt
        ec.worker.pos_y -= 1
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

  let ec = MakeExecutionContext(funcs)
  discard ExecuteProgram(ec, program)

  while not window.ShouldClose():
    glClearColor(0, 0, 0, 1)
    glClear(GL_COLOR_BUFFER_BIT)
    
    board.RebufferColors()
    board.Render()

    os.sleep(1)
    window.Refresh()

  window.CloseWindow()

when isMainModule:
  main()
