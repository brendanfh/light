import os
import sequtils
import opengl
import random
import glfw3 as glfw
import gfx/window as gfx_window
import gfx/glutils as glutils

import lang/ast
import lang/lexer as lexer
import lang/parser as parser
import lang/tokens

import board/board

proc key_down(window: glfw.Window, key, scancode, action, modifier: cint) {.cdecl.} =
  if key == glfw.KEY_ESCAPE and action == glfw.PRESS:
    glfw.SetWindowShouldClose(window, glfw.TRUE)

proc main2() =
  let window = gfxWindow.NewWindow(800, 600, "ASDF")
  window.SetKeyCallback(key_down)

  let vertex_shader = glutils.CreateShader(glutils.stVertex, "./data/shaders/basic.vert")
  let fragment_shader = glutils.CreateShader(glutils.stFragment, "./data/shaders/basic.frag")
  let program = glutils.LinkProgram(vertex_shader, fragment_shader)
  glUseProgram(program)

  var vao: GLuint
  var temp_vao: GLuint
  glGenVertexArrays(1.GLsizei, vao.addr)
  glGenVertexArrays(1.GLsizei, temp_vao.addr)

  var vbo: GLuint
  var cbo: GLuint
  var ibo: GLuint
  glGenBuffers(1.GLsizei, vbo.addr)
  glGenBuffers(1.GLsizei, cbo.addr)
  glGenBuffers(1.GLsizei, ibo.addr)

  glBindVertexArray(vao)
  glEnableVertexAttribArray(0)
  glEnableVertexAttribArray(1)

  var vertex_data: array[6, GLfloat] = [
    0'f32, 0'f32,
    0'f32, 1'f32,
    1'f32, 0'f32,
  ]
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, vertex_data.sizeof, vertex_data.addr, GL_STATIC_DRAW)
  glVertexAttribPointer(0, 2, cGL_FLOAT, GL_FALSE, 8.GLsizei, nil)

  var color_data: array[8, GLfloat] = [
    1'f32, 0'f32, 1'f32, 1'f32,
    0'f32, 1'f32, 0'f32, 1'f32,
  ]
  glBindBuffer(GL_ARRAY_BUFFER, cbo)
  glBufferData(GL_ARRAY_BUFFER, color_data.sizeof, color_data.addr, GL_STATIC_DRAW)
  glVertexAttribDivisor(1, 1)
  glVertexAttribPointer(1, 4, cGL_FLOAT, GL_FALSE, 16.GLsizei, nil)

  var index_data: array[3, GLuint] = [
    0.GLuint, 1.Gluint, 2.Gluint,
  ] 
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, index_data.sizeof, index_data.addr, GL_STATIC_DRAW)

  glBindVertexArray(0)


proc main() =
  let window = gfxWindow.NewWindow(1200, 700, "ASDF")
  window.SetKeyCallback(key_down)

  let source_code = readFile("data/progs/test.lgt")
  let tokens = toSeq(lexer.GenerateTokens(source_code))
  for exp in parser.ParseTokens(tokens):
    echo exp

  let board = CreateBoard(256, 256)
  board.InitRendering()

  while not window.ShouldClose():
    glClearColor(0, 0, 0, 1)
    glClear(GL_COLOR_BUFFER_BIT)

    board.SetCol(random.rand(256), random.rand(256), random.rand(0xffffff).GLuint)
    
    board.RebufferColors()
    board.Render()

    os.sleep(1)
    window.Refresh()

  window.CloseWindow()

when isMainModule:
  main()
