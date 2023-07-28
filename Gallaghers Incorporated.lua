script_name('CR Monopoly')
script_version("0.1 Beta")
script_authors('march')

local requests = require'requests'
local sampev = require("samp.events")
local effil = require("effil")
local encoding = require("encoding")
local imgui = require 'mimgui'
local inicfg = require 'inicfg'
local vkeys	= require 'vkeys'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local json_file = getWorkingDirectory()..'\\config\\Perem.json'
local gith_prices = requests.get('https://raw.githubusercontent.com/kumarchik/sales/main/Pricelist.json')
local base = decodeJson(gith_prices.text)
local base12 = {}
local did = nil
local dtext = nil
local adm = false
local proc = 0
local lastitem = nil
local summ = 0
local summ2 = 0
local trint = 0
local trint2 = 0
local stats_window = imgui.new.bool(false)
local dialog_window = imgui.new.bool(false)
local w,h = getScreenResolution()
local gith_sellers_list = requests.get('https://raw.githubusercontent.com/kumarchik/sales/main/Sellers.json')
local sellers_list = decodeJson(gith_sellers_list.text)
local test = {
    latest = "25.06.2022",
    updateurl = "https://raw.githubusercontent.com/qrlk/moonloader-script-updater/master/minified-example.lua"
  }


function jsonSave(jsonFilePath, t)
    file = io.open(jsonFilePath, "w")
    file:write(encodeJson(t))
    file:flush()
    file:close()
end


function jsonRead(jsonFilePath)
    local file = io.open(jsonFilePath, "r+")
    local jsonInString = file:read("*a")
    file:close()
    local jsonTable = decodeJson(jsonInString)
    return jsonTable
end

function EmulateKey(key, isDown)
    if not isDown then
        ffi.C.keybd_event(key, 0, 2, 0)
    else
        ffi.C.keybd_event(key, 0, 0, 0)
    end
end

chat_id = '826594265' 
token = '5415416008:AAF31TqXJiOueCnKulSeTx84XbfucRgFbNg' 
--local updateid

b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding

function enc(data)
    return ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do
            r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
        end
        return r;
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then
            return ''
        end
        local c = 0
        for i = 1, 6 do
            c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
        end
        return b:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

-- decoding
function dec(data)
    data = string.gsub(data, '[^' .. b .. '=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then
            return ''
        end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do
            r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0')
        end
        return r;
    end)        :gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then
            return ''
        end
        local c = 0
        for i = 1, 8 do
            c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0)
        end
        return string.char(c)
    end))
end


local text_chatpref = dec('ezAwMDBGRn1bR2FsbGFnaGVycyBJbmMuXSB7RkZGRkZGfQ==')
local text_lavka = dec('R2FsbGFnaGVycyBJbmMu')
local text_chatpref = dec('ezAwMDBGRn1bR2FsbGFnaGVycyBJbmMuXSB7RkZGRkZGfQ==')
local text_start = dec('0erw6O/yIOfg4/Dz5uXtLCD25e3y8ODr/O376SDw++3u6iDh8+Tl8iDv7vDg4e75uO0u')
local text_adm = dec('TWFydHlfR2FsbGFnaGVy')



--ТЕЛЕГА
--[[
function threadHandle(runner, url, args, resolve, reject)
    local t = runner(url, args)
    local r = t:get(0)
    while not r do
        r = t:get(0)
        wait(0)
    end
    local status = t:status()
    if status == 'completed' then
        local ok, result = r[1], r[2]
        if ok then resolve(result) else reject(result) end
    elseif err then
        reject(err)
    elseif status == 'canceled' then
        reject(status)
    end
    t:cancel(0)
end

function requestRunner()
    return effil.thread(function(u, a)
        local https = require 'ssl.https'
        local ok, result = pcall(https.request, u, a)
        if ok then
            return {true, result}
        else
            return {false, result}
        end
    end)
end

function async_http_request(url, args, resolve, reject)
    local runner = requestRunner()
    if not reject then reject = function() end end
    lua_thread.create(function()
        threadHandle(runner, url, args, resolve, reject)
    end)
end


function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end

function sendTelegramNotification(msg) 
    msg = msg:gsub('{......}', '') 
    msg = encodeUrl(msg) 
    async_http_request('https://api.telegram.org/bot' .. token .. '/sendMessage?chat_id=' .. chat_id .. '&text='..msg,'', function(result) end) 
end




function sendTelegram(message)
    if message and message:len() > 0 then
        local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if _ then
            message = sampGetPlayerNickname(id)..':\n'..message
            sendTelegramNotification(message)
        else
            message = '[Err]Unknown_Name(nil):\n'..message
            sendTelegramNotification(message)
        end
    else
        sendTelegramNotification('Проебали сообщение.')
    end
end

function getLastUpdate() 
    async_http_request('https://api.telegram.org/bot'..token..'/getUpdates?chat_id='..chat_id..'&offset=-1','',function(result)
        if result then
            local proc_table = decodeJson(result)
            if proc_table.ok then
                if #proc_table.result > 0 then
                    local res_table = proc_table.result[1]
                    if res_table then
                        updateid = res_table.update_id
                    end
                else
                    updateid = 1 
                end
            end
        end
    end)
end
]]--


function check()
    --local data = decodeJson(res.text)
    --chat(data[1].name)
    --sampSendDialogResponse(3040, 1, 6)
    --proc = 1.3
    jsonSave(json_file,test)
end




function chat(msg)
    sampAddChatMessage(text_chatpref..msg,-1)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    dtext = text
    did = dialogId
    dtext = text
    if dialogId == 3020 then
        lua_thread.create(function()
            wait(200)
            sampSendDialogResponse(3020, 1, 0, text_lavka)
        end)
        return false
    elseif dialogId == 3030 then
        lua_thread.create(function()
            wait(200)
            sampSendDialogResponse(3030, 1, 13, nil)
            wait(200)
            setVirtualKeyDown(18, true)
            wait(100)
            setVirtualKeyDown(18, false)
        end)
        return false
    elseif dialogId == 3040 and (proc == 0 or proc == 1.3 or proc == 2.1) then
        dialog_window[0] = not dialog_window[0]
    elseif dialogId == 3010 then
        sampSendDialogResponse(3010, 1)
        return false
    end
    if dialogId == 3040 then
        return false
    end
    if dialogId == 25672 then
        return false
    end
    if dialogId == 25673 then
        return false
    end
    if dialogId == 3060 then
        return false
    end
end





function sampev.onServerMessage(color, message)
    if message:match('%pИнформация%p {FFFFFF}Товар .+ успешно выставлен на продажу!') then
        lastitem = message:match(message,'%pИнформация%p {FFFFFF}Товар (.+) успешно выставлен на продажу!')
    end
    if message:match('%pИнформация%p {FFFFFF}Вы начали скупку товара') then
        lastitem = message:match('%pИнформация%p {FFFFFF}Вы начали скупку товара (.+) в количестве')
    end
    if message:match('%pОшибка%p {ffffff}Вы не можете добавить на скупку товар на общую сумму, которой у вас нет в наличии.') then
        proc = 0
        chat("Произошла ошибка при выставлении, снимите товар со скупа и повторите попытку.")
    end
    if message:match('%pПодсказка%p %pFFFFFF%pУ вас есть 3 минуты, чтобы настроить товар, иначе аренда ларька будет отменена.') then
        lastitem = message:match('%pПодсказка%p %pFFFFFF%pУ вас есть 3 минуты, чтобы настроить товар, иначе аренда ларька будет отменена.')
    end
end


function main()
    while not isSampAvailable() do wait(500) end
    chat(text_start)
    sampRegisterChatCommand('mono', function() check() end)
    --getLastUpdate() 
    if not doesFileExist(json_file) then jsonSave(json_file, {}) end
    --base = jsonRead(json_file)
    lua_thread.create(trading)
    if sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed))):match(text_adm) then
        adm = true
    end
    while true do
        wait(0)
        if dialog_window[0] == false and did == 3040 and (proc == 0 or proc == 1.3 or proc == 2.1) then
            sampSendDialogResponse(3040, 0)
            did = nil
            --chat("Закрываю")
        end
    end
end


imgui.OnInitialize(function()
    imgui.SwitchContext()
	local style 							= imgui.GetStyle()
	local colors 							= style.Colors
	local clr 								= imgui.Col
	local ImVec4 							= imgui.ImVec4
	local ImVec2 							= imgui.ImVec2

	style.WindowTitleAlign 					= ImVec2(0.5, 0.5)
	style.WindowRounding 					= 6.0
	style.FrameRounding 					= 5.0
	style.ScrollbarRounding 				= 9.0
	style.GrabRounding 						= 3.0
	style.ChildRounding						= 7.0
    colors[clr.Text]				   	= ImVec4(0.95, 0.96, 0.98, 1.00)
	colors[clr.TextDisabled] 			= ImVec4(0.65, 0.65, 0.65, 0.65)
	colors[clr.WindowBg]			   	= ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ChildBg]		  			= ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.PopupBg]					= ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.Border]				 	= ImVec4(1.00, 0.28, 0.28, 0.50)
	colors[clr.Separator]			 	= ImVec4(1.00, 0.28, 0.28, 0.50)
	colors[clr.BorderShadow]		   	= ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.FrameBg]					= ImVec4(0.22, 0.22, 0.22, 1.00)
	colors[clr.FrameBgHovered]		 	= ImVec4(0.18, 0.18, 0.18, 1.00)
	colors[clr.FrameBgActive]		  	= ImVec4(0.09, 0.12, 0.14, 1.00)
	colors[clr.TitleBg]					= ImVec4(1.00, 0.30, 0.30, 1.00)
	colors[clr.TitleBgActive]		  	= ImVec4(1.00, 0.30, 0.30, 1.00)
	colors[clr.TitleBgCollapsed]	   	= ImVec4(1.00, 0.30, 0.30, 1.00)
	colors[clr.MenuBarBg]			  	= ImVec4(0.20, 0.20, 0.20, 1.00)
	colors[clr.ScrollbarBg]				= ImVec4(0.02, 0.02, 0.02, 0.39)
	colors[clr.ScrollbarGrab]		  	= ImVec4(0.36, 0.36, 0.36, 1.00)
	colors[clr.ScrollbarGrabHovered]   	= ImVec4(0.18, 0.22, 0.25, 1.00)
	colors[clr.ScrollbarGrabActive]		= ImVec4(0.24, 0.24, 0.24, 1.00)
	colors[clr.CheckMark]			  	= ImVec4(1.00, 0.28, 0.28, 1.00)
	colors[clr.SliderGrab]			 	= ImVec4(1.00, 0.28, 0.28, 1.00)
	colors[clr.SliderGrabActive]	   	= ImVec4(1.00, 0.28, 0.28, 1.00)
	colors[clr.Button]				 	= ImVec4(1.00, 0.30, 0.30, 1.00)
	colors[clr.ButtonHovered]		  	= ImVec4(1.00, 0.25, 0.25, 1.00)
	colors[clr.ButtonActive]		   	= ImVec4(1.00, 0.20, 0.20, 1.00)
	colors[clr.Header]				 	= ImVec4(1.00, 0.28, 0.28, 1.00)
	colors[clr.HeaderHovered]		  	= ImVec4(1.00, 0.39, 0.39, 1.00)
	colors[clr.HeaderActive]		   	= ImVec4(1.00, 0.21, 0.21, 1.00)
	colors[clr.ResizeGrip]			 	= ImVec4(1.00, 0.28, 0.28, 1.00)
	colors[clr.ResizeGripHovered]	  	= ImVec4(1.00, 0.39, 0.39, 1.00)
	colors[clr.ResizeGripActive]	   	= ImVec4(1.00, 0.19, 0.19, 1.00)
	colors[clr.PlotLines]			  	= ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]	   	= ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]		  	= ImVec4(1.00, 0.21, 0.21, 1.00)
	colors[clr.PlotHistogramHovered]   	= ImVec4(1.00, 0.18, 0.18, 1.00)
	colors[clr.TextSelectedBg]		 	= ImVec4(1.00, 0.25, 0.25, 1.00)
	colors[clr.ModalWindowDimBg]   		= ImVec4(0.00, 0.00, 0.00, 0.30)
end)

local newFrame = imgui.OnFrame(
    function() return dialog_window[0] end,
    function(player)
        imgui.SetNextWindowSize(imgui.ImVec2(200,254))
        imgui.SetNextWindowPos(imgui.ImVec2(w/2-200/2, h/2-210/2),imgui.Cond.FirstUseEver)
        imgui.Begin('Gallaghers Incorporated',dialog_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
        if imgui.Button(u8("Скупка"),imgui.ImVec2(184,40)) then
            proc = 1
            dialog_window[0] = not dialog_window[0]
        end
        if imgui.Button(u8("Продажа"),imgui.ImVec2(184,40)) then
            --proc = 2
            --dialog_window[0] = not dialog_window[0]
            chat("Данная функция пока находится в разработке.")
        end
        if imgui.Button(u8("Перевыставить товар"),imgui.ImVec2(184,40)) then
            if proc == 1.3 then
                proc = 3.1
            elseif proc == 2.1 then
                proc = 3.2
            elseif proc ~= 1.3 and proc ~= 2.1 and proc ~= 0 then
                chat('Я хз как ты вызвал эту ошибку, но ты казел если это видишь.')
            elseif proc == 0 then
                chat("Нечего перевыставлять, товар не был выставлен.")
            end
            dialog_window[0] = not dialog_window[0]
        end
        if imgui.Button(u8("Снять товар с продажи/скупа"),imgui.ImVec2(184,40)) then
            if proc == 1.3 then
                proc = 4.1
            elseif proc == 2.1 then
                proc = 4.2
            elseif proc ~= 1.3 and proc ~= 2.1 and proc ~= 0 then
                chat('Я хз как ты вызвал эту ошибку, но ты казел если это видишь.')
            elseif proc == 0 then
                chat("Нечего перевыставлять, товар не был выставлен.")
            end
            dialog_window[0] = not dialog_window[0]
        end
        if imgui.Button(u8("Отказаться от аренды лавки"),imgui.ImVec2(184,40)) then
            proc = 0.1
            sampSendDialogResponse(3040, 1, 5)
            dialog_window[0] = not dialog_window[0]
            proc = 0
        end
        imgui.End()
end)



function trading()
    while true do
        wait(0)
        if proc == 1 then
            summ = 0
            for i = 1, #base do
                if base[i].required then
                    summ = summ + (base[i].buyprice * base[i].number)
                end
            end
            if getPlayerMoney() < summ then
                chat('К сожалению у вас недостаточно денег для скупа.')
                proc = 0
            else
                trint2 = 0
                summ2 = 0
                for i = 1, #base do
                    if not base[i].required then
                        summ2 = summ2 + base[i].buyprice
                        trint2 = trint2 + 1
                    end
                end
                if getPlayerMoney() - (summ + summ2) > 0 then
                    proc = 1.2 --режим полного плейлиста
                else
                    proc = 1.1 --только ларцы
                end
            end
        elseif proc == 1.1 then
            setVirtualKeyDown(18, true)
            wait(100)
            setVirtualKeyDown(18, false)
            for i = 1, #base do
                if proc == 0 then
                    break
                end
                if base[i].required then
                    repeat
                        trint = 0
                        while did ~= 3040 and trint < 300 do
                            wait(10)
                            trint = trint + 10
                        end
                        wait(200)
                        sampSendDialogResponse(3040, 1, 3)
                        trint = 0
                        while did ~= 25672 and trint < 300 do
                            wait(10)
                            trint = trint + 10
                        end
                        wait(200)
                        sampSendDialogResponse(25672, 1, 0,base[i].name)
                        trint = 0
                        while did ~= 25673 and trint < 300 do
                            wait(10)
                            trint = trint + 10
                        end
                        wait(200)
                        trint = 0
                        for line in string.gmatch(dtext, '[^\r\n]+') do
                            if line:match(base[i].name) then
                                sampSendDialogResponse(25673, 1, trint)
                            end
                            trint = trint + 1
                        end
                        trint = 0
                        while did ~= 3060 and trint < 300 do
                            wait(10)
                            trint = trint + 10
                        end
                        wait(200)
                        sampSendDialogResponse(3060, 1, 0,(base[i].number..','..base[i].buyprice))
                        trint = 0
                        while lastitem ~= base[i].name and trint < 300 do
                            wait(10)
                            trint = trint + 10
                        end
                        if trint >= 300 and proc ~= 0 then
                            chat('Не удалось выставить товар '..base[i].name..", повторяем.")
                            setVirtualKeyDown(18, true)
                            wait(100)
                            setVirtualKeyDown(18, false)
                        end
                        if proc == 0 then
                            break
                        end
                    until lastitem == base[i].name
                end
            end
            proc = 1.3
            wait(200)
            chat("Товары успешно выставлены на покупку.")
        elseif proc == 1.2 then
            setVirtualKeyDown(18, true)
            wait(100)
            setVirtualKeyDown(18, false)
            for i = 1, #base do
                if proc == 0 then
                    break
                end
                if base[i].required then
                    repeat
                        trint = 0
                        while did ~= 3040 and trint < 300 do
                            wait(10)
                            trint = trint + 10
                        end
                        wait(200)
                        sampSendDialogResponse(3040, 1, 3)
                        trint = 0
                        while did ~= 25672 and trint < 300 do
                            wait(10)
                            trint = trint + 10
                        end
                        wait(200)
                        sampSendDialogResponse(25672, 1, 0,base[i].name)
                        trint = 0
                        while did ~= 25673 and trint < 300 do
                            wait(10)
                            trint = trint + 10
                        end
                        wait(200)
                        trint = 0
                        for line in string.gmatch(dtext, '[^\r\n]+') do
                            if line:match(base[i].name) then
                                sampSendDialogResponse(25673, 1, trint)
                            end
                            trint = trint + 1
                        end
                        trint = 0
                        while did ~= 3060 and trint < 300 do
                            wait(10)
                            trint = trint + 10
                        end
                        wait(200)
                        sampSendDialogResponse(3060, 1, 0,(base[i].number..','..base[i].buyprice))
                        trint = 0
                        while lastitem ~= base[i].name and trint < 300 do
                            wait(10)
                            trint = trint + 10
                        end
                        if trint >= 300 and proc ~= 0 then
                            chat('Не удалось выставить товар '..base[i].name..", повторяем.")
                            setVirtualKeyDown(18, true)
                            wait(100)
                            setVirtualKeyDown(18, false)
                        end
                        if proc == 0 then
                            break
                        end
                    until lastitem == base[i].name
                end
            end
            base12 = {}
            summ2 = getPlayerMoney() - summ
            for i = 1, #base do
                if not base[i].required and base[i].disposable then
                    summ2 = summ2 - base[i].buyprice
                    trint2 = trint2 - 1
                    table.insert(base12,{name = base[i].name , config = base[i].buyprice})
                end
            end
            trint2 = summ2 / trint2
            for i = 1, #base do
                if not base[i].required and not base[i].disposable then
                    table.insert(base12,{name = base[i].name , config = (math.floor(trint2/base[i].buyprice)..","..base[i].buyprice)})
                end
            end
            for i = 1, #base12 do
                if proc == 0 then
                    break
                end
                repeat
                    trint = 0
                    while did ~= 3040 and trint < 300 do
                        wait(10)
                        trint = trint + 10
                    end
                    wait(200)
                    sampSendDialogResponse(3040, 1, 3)
                    trint = 0
                    while did ~= 25672 and trint < 300 do
                        wait(10)
                        trint = trint + 10
                    end
                    wait(200)
                    sampSendDialogResponse(25672, 1, 0,base12[i].name)
                    trint = 0
                    while did ~= 25673 and trint < 300 do
                        wait(10)
                        trint = trint + 10
                    end
                    wait(200)
                    trint = 0
                    for line in string.gmatch(dtext, '[^\r\n]+') do
                        if line:match(base12[i].name) then
                            sampSendDialogResponse(25673, 1, trint)
                        end
                        trint = trint + 1
                    end
                    trint = 0
                    while did ~= 3060 and trint < 300 do
                        wait(10)
                        trint = trint + 10
                    end
                    wait(200)
                    sampSendDialogResponse(3060, 1, 0,base12[i].config)
                    chat(base12[i].config)
                    trint = 0
                    while lastitem ~= base12[i].name and trint < 300 do
                        wait(10)
                        trint = trint + 10
                    end
                    if trint >= 300 and proc ~= 0 then
                        chat('Не удалось выставить товар '..base12[i].name..", повторяем.")
                        setVirtualKeyDown(18, true)
                        wait(100)
                        setVirtualKeyDown(18, false)
                    end
                    if proc == 0 then
                        break
                    end
                until lastitem == base12[i].name
            end
            wait(200)
            if proc ~= 0 then
                proc = 1.3
                chat("Товары успешно выставлены на покупку.")
            end
        elseif proc == 4.1 then
            setVirtualKeyDown(18, true)
            wait(100)
            setVirtualKeyDown(18, false)
            wait(300)
            sampSendDialogResponse(3040, 1, 4)
            repeat
                trint = 0
                while did ~= 3050 and trint < 300 do
                    wait(10)
                    trint = trint + 10
                end
                trint = -1
                for line in string.gmatch(dtext, '[^\r\n]+') do
                    if line:match("%pFFFFFF%p") then
                        wait(200)
                        sampSendDialogResponse(3050, 1, trint)
                    end
                    trint = trint + 1
                end
                did = 0
                wait(300)
                sampSendDialogResponse(3050, 1, 20)
            until lastitem == "[Подсказка] {FFFFFF}У вас есть 3 минуты, чтобы настроить товар, иначе аренда ларька будет отменена."
            proc = 0
            chat("Все товары сняты со скупа.")
        elseif proc == 4.2 then
            setVirtualKeyDown(18, true)
            wait(100)
            setVirtualKeyDown(18, false)
            wait(300)
            sampSendDialogResponse(3040, 1, 1)
            repeat
                trint = 0
                while did ~= 3050 and trint < 300 do
                    wait(10)
                    trint = trint + 10
                end
                trint = -1
                for line in string.gmatch(dtext, '[^\r\n]+') do
                    if line:match("%pFFFFFF%p") then
                        wait(200)
                        sampSendDialogResponse(3050, 1, trint)
                    end
                    trint = trint + 1
                end
                did = 0
                wait(300)
                sampSendDialogResponse(3050, 1, 20)
            until lastitem == "[Подсказка] {FFFFFF}У вас есть 3 минуты, чтобы настроить товар, иначе аренда ларька будет отменена."
            proc = 0
            chat("Все товары сняты с продажи.")
        elseif proc == 2 then

        end
    end
end

--[[

if imgui.Button(u8("Скупка"),imgui.ImVec2(184,40)) then
    proc = 1
    dialog_window[0] = not dialog_window[0]
end
if imgui.Button(u8("Продажа"),imgui.ImVec2(184,40)) then
    proc = 2
    dialog_window[0] = not dialog_window[0]
end
if imgui.Button(u8("Перевыставить товар"),imgui.ImVec2(184,40)) then
    if proc == 1.3 then
        proc = 3.1
    elseif proc == 2.1 then
        proc = 3.2
    elseif proc ~= 1.3 and proc ~= 2.1 and proc ~= 0 then
        chat('Я хз как ты вызвал эту ошибку, но ты казел если это видишь.')
    elseif proc == 0 then
        chat("Нечего перевыставлять, товар не был выставлен.")
    end
    dialog_window[0] = not dialog_window[0]
end
if imgui.Button(u8("Снять товар с продажи/скупа"),imgui.ImVec2(184,40)) then
    if proc == 1.3 then
        proc = 4.1
    elseif proc == 2.1 then
        proc = 4.2
    elseif proc ~= 1.3 and proc ~= 2.1 and proc ~= 0 then
        chat('Я хз как ты вызвал эту ошибку, но ты казел если это видишь.')
    elseif proc == 0 then
        chat("Нечего перевыставлять, товар не был выставлен.")
    end
    dialog_window[0] = not dialog_window[0]
end
if imgui.Button(u8("Отказаться от аренды лавки"),imgui.ImVec2(184,40)) then
    proc = 0.1
    sampSendDialogResponse(3040, 1, 5)
    dialog_window[0] = not dialog_window[0]
    proc = 0
end]]--