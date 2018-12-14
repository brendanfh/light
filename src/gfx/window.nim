import glfw3 as glfw
import opengl

type
  Window* = object
    window: glfw.Window
    width, height: cint
    title: cstring


proc New_window*(width, height: cint, title: cstring): Window =
  # Initialize GLFW
  if glfw.Init() != glfw.TRUE:
    echo "Failed to initialize GLFW"
    return

  # Setup error callback for OpenGL
  # May use logging system in the future
  discard glfw.SetErrorCallback do (errorCode: cint, description: cstring) {.cdecl.}:
    echo "GLFW Error: " & $description

  # Create the window
  let window = glfw.CreateWindow(width, height, title, nil, nil)
  
  # Check for failed window creation
  if window == nil:
    echo "Window or context creation failed"

  # Use the window for OpenGL operations
  glfw.MakeContextCurrent(window)
  glfw.SwapInterval(0)

  # Initialize OpenGL
  opengl.loadExtensions()

  # Create the wrapper around our window
  let m_window = Window(window: window, width: width, height: height, title: title)

  return m_window

func Get_size*(window: Window): (int, int) {.inline.} =
  (int(window.width), int(window.height))

proc Set_key_callback*(window: Window, callback: glfw.KeyFun) {.inline.} =
  discard glfw.SetKeyCallback(window.window, callback)

proc Should_close*(window: Window): bool {.inline.} =
  glfw.WindowShouldClose(window.window) == glfw.TRUE 

proc Refresh*(window: Window) =
  glfw.SwapBuffers(window.window)
  glfw.PollEvents()

proc Close_window*(window: Window) =
  glfw.DestroyWindow(window.window)
  glfw.Terminate()