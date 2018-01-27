---MagnetCard v2
local component = require("component")
local buffer = require("doubleBuffering")
local image = require("image")
local event = require("event")
local ser = require("serialization")
local text = require("text")
local fs = require("filesystem")
local term = require("term")
local inet = require("internet")
local event = require("event")

local reader = component.os_magreader
local red = component.redstone

reader.setEventName("mag_card")
local configPath = "/c17mg/config.txt"
local config

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
    buffer.image(61, 16, image.load("/c17mg/check.pic"))
    buffer.draw(true)
end
local function drawFail()
    buffer.clear(0x0)
    buffer.image(61, 16, image.load("/c17mg/cross.pic"))
    buffer.semiPixelCircle(160 / 2, 50, 30, 0xEE0000)
    buffer.draw(true)
end
local function saveConfig(conf)
    file = io.open(configPath,"w")
    file:write(ser.serialize(conf))
    file:close()
end
local function read()
    local signal = {event.pull("mag_card")}
    if signal[4] == config.pass then
        drawSuccessful()
        red.setOutput(config.redstoneSide,15)
        event.pull(1.5,"mag_card")
        red.setOutput(config.redstoneSide,0)
        drawWait()
        inet.request("http://robspec.pe.hu/send.php",signal[3].." открыл дверь в месте "..config.place)
    else
        drawFail()
        inet.request("http://robspec.pe.hu/send.php",signal[3].." воткнул неправильную карту в месте "..config.place)
        event.timer(1.5,drawWait,1)
    end
end
local function createConfig()
    component.gpu.setBackground(0x000000)
    component.gpu.setBackground(0xFFFFFF)
    print("Добро пожаловать в программу настройки.\n\nВведите пароль для карты")
    pass = text.trim(term.read(_,_,_,"*"))
    print("Введите сторону в виде цифры, с которой нужно подавать редстоун-сигнал (0-5)\n0 - низ 1 - верх\n2 - зад 3 - перед\n4 - право 5 - лево")
    redstoneSide = tonumber(text.trim(io.read()))
    if not redstoneSide then print("Вы ввели НЕ число.") createConfig() end
    print("Введите место, где стоит замок")
    place = text.trim(io.read())
    config = {
        isSetupComplete = true,
        redstoneSide = redstoneSide,
        place = place,
        pass = pass
    }
    saveConfig(config)
    if component.isAvailable('os_cardwriter') then
        print("Вставьте карты в записыватель карт. Введите, сколько карт нужно записать.")
        count = tonumber(text.trim(io.read()))
        if not count then count = 1 end
        for i = 1, count  do
            component.os_cardwriter.write(config.pass,"Карта от "..config.place,false,0xFFFFFF)
        end
        return
    else
        print("Ошибка: записыватель карт не подключен. Нажмите любую клавишу чтобы игнорировать.")
        io.read()
    end
end
local function loadConfig()
    if fs.exists(configPath) then
        file = io.open(configPath,"r")
        conffile = file:read()
        if conffile then
            config = ser.unserialize(conffile)
        end
        file:close()
        if not config.isSetupComplete then createConfig() end
    else
        createConfig()
    end
end

--------------------------------------------------------------------------------------------
loadConfig()
term.clear()
drawWait()

while true do
    read(config.pass)
end


