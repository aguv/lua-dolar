local json = require("json")

local data = "..."
local timer = 299

local isDragging = false
local dragStartX = 0
local dragStartY = 0

function formatDate(isoDate)
    local year, month, day, hour, min = isoDate:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+)")
    return string.format("%s/%s/%s - %s:%s", day, month, year, hour, min)
end

function fetchDollarPrice()
    local handle = io.popen('curl -s "https://behn3vzj46qupmsk7g3mfnoryu0ikotg.lambda-url.us-east-2.on.aws/"')
    if handle then
        local response_body = handle:read("*a")
        handle:close()

        if response_body and response_body ~= "" then
            local success, parsed = pcall(json.decode, response_body)
            if success == true then
                local result = ""

                for i, item in ipairs(parsed) do
                    if (i == 1) then
                        local formattedDate = formatDate(item.fechaActualizacion)
                        result = string.format("ULTIMA ACTUALIZACIÓN: %s\n", formattedDate)
                    end
                    result = result ..
                                 string.format("Dólar %s: VENTA: $%.2f  -  COMPRA: $%.2f\n", item.nombre, item.venta,
                            item.compra)
                end

                data = result
            end

        end
    else
        data = "ERROR WHILE FETCHING."
    end
end

function love.update(dt)
    timer = timer + dt
    if timer >= 300 then
        timer = 0
        fetchDollarPrice()
    end
end

function love.draw()
    -- Default color for most text
    love.graphics.setColor(1, 1, 1, 1) -- White

    -- Split the data into lines
    local y = 10
    for line in data:gmatch("[^\r\n]+") do
        -- Find the position of VENTA and COMPRA in the line
        local ventaPos = line:find("VENTA:")
        local compraPos = line:find("COMPRA:")

        if ventaPos and compraPos then
            -- Print the first part of the line (before VENTA)
            love.graphics.print(line:sub(1, ventaPos - 1), 10, y)

            -- Print VENTA in red
            love.graphics.setColor(1, 0, 0, 1) -- Red
            love.graphics.print("VENTA:", 10 + love.graphics.getFont():getWidth(line:sub(1, ventaPos - 1)), y)

            -- Print the middle part in white
            love.graphics.setColor(1, 1, 1, 1) -- White
            local middleText = line:sub(ventaPos + 6, compraPos - 1)
            local middleX = 10 + love.graphics.getFont():getWidth(line:sub(1, ventaPos + 5))
            love.graphics.print(middleText, middleX, y)

            -- Print COMPRA in green
            love.graphics.setColor(0, 1, 0, 1) -- Green
            local compraX = middleX + love.graphics.getFont():getWidth(middleText)
            love.graphics.print("COMPRA:", compraX, y)

            -- Print the rest in white
            love.graphics.setColor(1, 1, 1, 1) -- White
            local finalX = compraX + love.graphics.getFont():getWidth("COMPRA:")
            love.graphics.print(line:sub(compraPos + 7), finalX, y)
        else
            -- Print regular lines in white
            love.graphics.print(line, 10, y)
        end

        y = y + 20
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left click
        isDragging = true
        dragStartX = x
        dragStartY = y
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        isDragging = false
    end
end

function love.mousemoved(x, y)
    if isDragging then
        local wx, wy = love.window.getPosition()
        love.window.setPosition(wx + (x - dragStartX), wy + (y - dragStartY))
    end
end
