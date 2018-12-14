import os
import opengl

type
  ShaderType* = enum
    stVertex, stFragment

proc Compile_shader*(shaderType: ShaderType, source: cstringArray): GLuint =
  let s_type =
    case shaderType
    of stVertex:
      GL_VERTEX_SHADER
    of stFragment:
      GL_FRAGMENT_SHADER

  let shader = glCreateShader s_type
  glShaderSource shader, 1, source, nil
  glCompileShader shader

  var status: GLint
  glGetShaderiv shader, GL_COMPILE_STATUS, status.addr
  if status == 0:
    var logSize: GLint
    glGetShaderiv shader, GL_INFO_LOG_LENGTH, logSize.addr

    var
      errorMsg = cast[ptr GLchar](alloc logSize)
      logLen: GLsizei

    glGetShaderInfoLog shader, logSize.GLsizei, logLen.addr, errorMsg

    echo "Error compiling shader: " & $errorMsg

    dealloc errorMsg
    return 0

  return shader

proc Create_shader*(shaderType: ShaderType, fileLocation: string): GLuint =
  let source = readFile fileLocation
  let c_string = allocCStringArray([source])

  # Dealloc the string when the procedure returns
  defer: deallocCStringArray(c_string)

  return Compile_shader(shaderType, c_string)

proc Link_program*(vertex_shader, fragment_shader: GLuint): GLuint =
  let program = glCreateProgram()
  glAttachShader program, vertex_shader
  glAttachShader program, fragment_shader
  glLinkProgram program
  
  var status: GLint
  glGetProgramiv program, GL_LINK_STATUS, status.addr
  if status == 0:
    var logSize: GLint
    glGetProgramiv program, GL_INFO_LOG_LENGTH, logSize.addr

    var
      errorMsg = cast[ptr GLchar](alloc logSize)
      logLen: GLsizei

    glGetProgramInfoLog program, logSize.GLsizei, logLen.addr, errorMsg

    echo "Error linking program: " & $errorMsg

    dealloc errorMsg
    return 0

  return program
