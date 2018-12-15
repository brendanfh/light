# Package

version       = "0.1.0"
author        = "Brendan Hansen"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["christmas_proj"]


# Dependencies

requires "nim >= 0.19.0"
requires "opengl >= 1.2.0"
requires "glfw"

task run, "Run project":
  exec("nimble build -d:release")
  exec("./christmas_proj")