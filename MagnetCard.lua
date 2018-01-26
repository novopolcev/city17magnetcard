---MagnetCard v1
local component = require("component")
local buffer = require("doubleBuffering")
local GUI = require("GUI")
local image = require("image")
local event = require("event")
local sides = require("sides")

local reader = component.os_magreader
local red = component.redstone

local pass = "PSh8gKCgg0Xn"

reader.setEventName("mag_card")

--------------------------------------------------------------------------------------------
local function drawWait()
    buffer.clear(0x0)
    buffer.semiPixelCircle(160 / 2, 50, 30, 0xFFDB40)
    buffer.semiPixelSquare(76,46,9,9,0xFFDB40)
    buffer.semiPixelSquare(61,46,9,9,0xFFDB40)
    buffer.semiPixelSquare(91,46,9,9,0xFFDB40)
    buffer.draw(true)
end
local function drawSuccessful()
    buffer.clear(0x0)
    buffer.semiPixelCircle(160 / 2, 50, 30, 0x61CE61)
    buffer.image(61, 16, image.load("/home/pikcha2.pic"))
    buffer.draw(true)
end
local function drawFail()
    buffer.clear(0x0)
    buffer.image(61, 16, image.load("/home/cross.pic"))
    buffer.semiPixelCircle(160 / 2, 50, 30, 0xEE0000)
    buffer.draw(true)
end
local function read(data)
    while true do
      local signal = {event.pull("mag_card")}
      if signal[4] == data then
        red.setOutput(sides.left,15)
        drawSuccessful()
        event.pull(1.5,"mag_card")
        red.setOutput(sides.left,0)
        drawWait()
      else
        drawFail()
        event.timer(1.5,drawWait,1)
      end
    end
  end
--------------------------------------------------------------------------------------------
require("term").clear()
drawWait()

while true do
    read(pass)
end


