import opengl
import ../gfx/glutils

type
  LightBoard* = ref object
    width: int
    height: int
    data: ref array[1024 * 1024, GLuint]
    colors: ref array[1024 * 1024 * 4, GLfloat]

    vertexArrayObject: GLuint
    vertexBufferObject: GLuint
    indexBufferObject: GLuint
    colorBufferObject: GLuint

proc CreateBoard*(width, height: int): LightBoard =
  var data = new(array[1024 * 1024, GLuint])
  var colors = new(array[1024 * 1024 * 4, GLfloat])
  for i in 0 ..< (width * height):
    data[i] = 0x0.GLuint
    colors[i * 4 + 0] = 0.GLfloat
    colors[i * 4 + 1] = 0.GLfloat
    colors[i * 4 + 2] = 0.GLfloat
    colors[i * 4 + 3] = 1.GLfloat
  LightBoard(
    width: width,
    height: height,
    data: data,
    colors: colors
  )

func GetCol*(board: LightBoard, x, y: int): GLuint =
  if x < 0 or y < 0 or x >= board.width or y >= board.height:
    0.GLuint
  else:
    board.data[][x + y * board.width]

proc SetCol*(board: LightBoard, x, y: int, val: GLuint) =
  if x < 0 or y < 0 or x >= board.width or y >= board.height:
    return

  board.data[][x + y * board.width] = val
  let
    r = ((val shr 16) and 0xff).GLfloat / 255.GLfloat
    g = ((val shr 8) and 0xff).GLfloat / 255.GLfloat
    b = ((val shr 0) and 0xff).GLfloat / 255.GLfloat
  board.colors[][x * 4 + y * board.width * 4 + 0] = r
  board.colors[][x * 4 + y * board.width * 4 + 1] = g
  board.colors[][x * 4 + y * board.width * 4 + 2] = b

func GetA*(board: LightBoard, x, y: int): GLuint =
  if x < 0 or y < 0 or x >= board.width or y >= board.height:
    0.GLuint
  else:
    (board.data[][x + y * board.width] shr 24) and 0xff

func GetR*(board: LightBoard, x, y: int): GLuint =
  if x < 0 or y < 0 or x >= board.width or y >= board.height:
    0.GLuint
  else:
    (board.data[][x + y * board.width] shr 16) and 0xff

func GetG*(board: LightBoard, x, y: int): GLuint =
  if x < 0 or y < 0 or x >= board.width or y >= board.height:
    0.GLuint
  else:
    (board.data[][x + y * board.width] shr 8) and 0xff

func GetB*(board: LightBoard, x, y: int): GLuint =
  if x < 0 or y < 0 or x >= board.width or y >= board.height:
    0.GLuint
  else:
    (board.data[][x + y * board.width] shr 0) and 0xff

proc SetA*(board: LightBoard, x, y: int, val: GLuint) =
  if x < 0 or y < 0 or x >= board.width or y >= board.height:
    return

  let mval = val mod 256
  board.data[][x + y * board.width] = board.data[][x + y * board.width] and 0x00ffffff.GLuint
  board.data[][x + y * board.width] = board.data[][x + y * board.width] or (mval shl 24)

proc SetR*(board: LightBoard, x, y: int, val: GLuint) =
  if x < 0 or y < 0 or x >= board.width or y >= board.height:
    return

  let mval = val mod 256
  board.data[][x + y * board.width] = board.data[][x + y * board.width] and 0xff00ffff.GLuint
  board.data[][x + y * board.width] = board.data[][x + y * board.width] or (mval shl 16)
  board.colors[][x * 4 + y * board.width * 4 + 0] = mval.GLfloat / 256.GLfloat

proc SetG*(board: LightBoard, x, y: int, val: GLuint) =
  if x < 0 or y < 0 or x >= board.width or y >= board.height:
    return

  let mval = val mod 256
  board.data[][x + y * board.width] = board.data[][x + y * board.width] and 0xffff00ff.GLuint
  board.data[][x + y * board.width] = board.data[][x + y * board.width] or (mval shl 8)
  board.colors[][x * 4 + y * board.width * 4 + 1] = mval.GLfloat / 256.GLfloat

proc SetB*(board: LightBoard, x, y: int, val: GLuint) =
  if x < 0 or y < 0 or x >= board.width or y >= board.height:
    return

  let mval = val mod 256
  board.data[][x + y * board.width] = board.data[][x + y * board.width] and 0xffffff00.GLuint
  board.data[][x + y * board.width] = board.data[][x + y * board.width] or (mval shl 0)
  board.colors[][x * 4 + y * board.width * 4 + 2] = mval.GLfloat / 256.GLfloat

proc InitRendering*(board: LightBoard) =
  glGenVertexArrays(1, board.vertexArrayObject.addr)
  glBindVertexArray(board.vertexArrayObject)

  var vertex_data: array[8, GLfloat] = [
    0'f32, 0'f32,
    0'f32, 1'f32,
    1'f32, 1'f32,
    1'f32, 0'f32,
  ]
  glGenBuffers(1, board.vertexBufferObject.addr)
  glBindBuffer(GL_ARRAY_BUFFER, board.vertexBufferObject)
  glBufferData(GL_ARRAY_BUFFER, vertex_data.sizeof, vertex_data.addr, GL_STATIC_DRAW)
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 2, cGL_FLOAT, GL_FALSE, 8.GLsizei, nil)

  glGenBuffers(1, board.colorBufferObject.addr)
  glBindBuffer(GL_ARRAY_BUFFER, board.colorBufferObject)
  glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 4 * board.width * board.height, board.colors.addr, GL_DYNAMIC_DRAW)
  glEnableVertexAttribArray(1)
  glVertexAttribDivisor(1, 1)
  glVertexAttribPointer(1, 4, cGL_FLOAT, GL_FALSE, 16.GLsizei, nil)

  var index_data: array[6, GLubyte] = [
    0.GLubyte, 1.GLubyte, 2.GLubyte, 0.GLubyte, 2.GLubyte, 3.GLubyte
  ]
  glGenBuffers(1, board.indexBufferObject.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, board.indexBufferObject)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLubyte) * 6, index_data.addr, GL_STATIC_DRAW)

  glBindVertexArray(0)

  let vertex_shader = glutils.CreateShader(glutils.stVertex, "./data/shaders/board.vert")
  let fragment_shader = glutils.CreateShader(glutils.stFragment, "./data/shaders/board.frag")
  let program = glutils.LinkProgram(vertex_shader, fragment_shader)
  glUseProgram(program)

  let u_board_width = glGetUniformLocation(program, "board_width")
  let u_board_height = glGetUniformLocation(program, "board_height")
  let u_proj = glGetUniformLocation(program, "u_proj")
  glUniform1i(u_board_width, board.width.GLint)
  glUniform1i(u_board_height, board.height.GLint)

  var proj_mat: array[9, GLfloat] = [
    (2.GLfloat / board.width.GLfloat).GLfloat, 0.GLfloat, 0.GLfloat,
    0.GLfloat, (-2.GLfloat / board.height.GLfloat).GLfloat, 0.GLfloat,
    -1.GLfloat, 1.GLfloat, 1.GLfloat
  ]
  glUniformMatrix3fv(u_proj, 1.GLsizei, GL_FALSE, proj_mat[0].addr)

proc RebufferColors*(board: LightBoard) =
  glBindBuffer(GL_ARRAY_BUFFER, board.colorBufferObject)
  glBufferSubData(GL_ARRAY_BUFFER, 0.GLintptr, sizeof(GLfloat) * 4 * board.width * board.height, board.colors[].addr)
  glBindBuffer(GL_ARRAY_BUFFER, 0)

proc Render*(board: LightBoard) =
  glBindVertexArray(board.vertexArrayObject)
  glDrawElementsInstanced(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, nil, (board.width * board.height).GLsizei)
  glBindVertexArray(0)