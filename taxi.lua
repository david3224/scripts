local sampev = require 'lib.samp.events'
local SE = require 'samp.events'
require "lib.moonloader"
local encoding = require 'encoding'
local wm = require 'lib.windows.message'
local dlstatus = require('moonloader').download_status
local vkeys = require 'vkeys'
local rkeys = require 'rkeys'
local imgui = require 'imgui'
local fa = require 'faIcons'
local inicfg = require 'inicfg'

encoding.default = 'CP1251'
u8 = encoding.UTF8

local themes = import "imgui_themes.lua"

update_state = false 

local script_vers = 3
local script_vers_text = 1.1

local font_url = "https://raw.githubusercontent.com/david3224/scripts/master/update_taxi.ini"
local font_path = getWorkingDirectory() .. "/resource/fonts/fontawesome-webfont.ttf"

local update_url = "https://raw.githubusercontent.com/david3224/scripts/master/update_taxi.ini"
local update_path = getWorkingDirectory() .. "/update_taxi.ini"

local script_url = "https://github.com/david3224/scripts/blob/master/taxi.lua?raw=true"
local script_path = thisScript().path

imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.HotKey = require('imgui_addons').HotKey
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar

local main_window_state = imgui.ImBool(false)
local takecall_settings_window_state = imgui.ImBool(false)
local reports_settings_window_state = imgui.ImBool(false)
local hello_settings_window_state = imgui.ImBool(false)
local hotkeys_window_state = imgui.ImBool(false)
local gender = imgui.ImInt(0)
local offtakecall = imgui.ImInt(3)
local soundtakecall = imgui.ImBool(true)
local select_report1 = imgui.ImBool(true)
local select_report2 = imgui.ImBool(true)
local select_report3 = imgui.ImBool(true)
local autotakecall = imgui.ImBool(false)
local autoreports = imgui.ImBool(false)
local autohello = imgui.ImBool(false)
local binds = imgui.ImBool(true)
local playername = imgui.ImBuffer(48)
local hello = imgui.ImBuffer(144)
hello.v = u8"Приветствую. Куда поедем?"
local hello_wait = imgui.ImInt(7000)
local report1 = imgui.ImBuffer(144)
report1.v = u8'Принял вызов. Направляюсь к клиенту.'
local report2 = imgui.ImBuffer(144)
report2.v = u8'Клиент доставлен. Свободен для вызовов.'
local report3 = imgui.ImBuffer(144)
report3.v = u8'Отказываюсь от вызова.'


local hotkey1_text = imgui.ImBuffer(144)

local hotkey2_text = imgui.ImBuffer(144)
local hotkey3_text = imgui.ImBuffer(144)
local hotkey4_text = imgui.ImBuffer(144)
local hotkey5_text = imgui.ImBuffer(144)
local hotkey6_text = imgui.ImBuffer(144)
local hotkey7_text = imgui.ImBuffer(144)
local hotkey8_text = imgui.ImBuffer(144)
local hotkey9_text = imgui.ImBuffer(144)
local hotkey10_text = imgui.ImBuffer(144)

local sw, sh = getScreenResolution()
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local tLastKeys = {}


local inipath = "taxiinfo.ini"
local mainIni = inicfg.load(nil, inipath)
if mainIni == nil then 
	settings = {
		playerinfo = {
			playername = ' ',
			gender = 0
		},
		func = {
			autotakecall = autotakecall.v,
			autoreports = autohello.v,
			autohello = autohello.v,
			offtakecall = offtakecall.v,
			soundtakecall = soundtakecall.v,
			report1 = report1.v,
			report2 = report2.v,
			report3 = report3.v,
			select_report1 = select_report1.v,
			select_report2 = select_report2.v,
			select_report3 = select_report3.v,
			hello = hello.v,
			hello_wait = hello_wait.v
		},
		hotkeys = {
			bindSendTakecall = "[18, 50]",
			bindSendCancel = "[18, 48]",
			bindReport1 = "[18, 51]",
			bindReport2 = "[18, 52]",
			bindReport3 = "[18, 53]",
			bindHotkey1 = "[17, 49]",
			bindHotkey2 = "[17, 50]",
			bindHotkey3 = "[17, 51]",
			bindHotkey4 = "[17, 52]",
			bindHotkey5 = "[17, 53]",
			bindHotkey6 = "[17, 54]",
			bindHotkey7 = "[17, 55]",
			bindHotkey8 = "[17, 56]",
			bindHotkey9 = "[17, 57]",
			bindHotkey10 = "[17, 48]",
			hotkey1_text = '',
			hotkey2_text = '',
			hotkey3_text = '',
			hotkey4_text = '',
			hotkey5_text = '',
			hotkey6_text = '',
			hotkey7_text = '',
			hotkey8_text = '',
			hotkey9_text = '',
			hotkey10_text = ''
		}
	}
	inicfg.save(settings, inipath) 
	mainIni = inicfg.load(nil, inipath)
else
	playername.v = u8:encode(mainIni.playerinfo.playername)
	gender.v = mainIni.playerinfo.gender
	autotakecall.v = mainIni.func.autotakecall
	autoreports.v = mainIni.func.autoreports
	autohello.v = mainIni.func.autohello
	offtakecall.v = mainIni.func.offtakecall
	soundtakecall.v = mainIni.func.soundtakecall
	report1.v = u8:encode(mainIni.func.report1)
	report2.v = u8:encode(mainIni.func.report2)
	report3.v = u8:encode(mainIni.func.report3)
	select_report1.v = mainIni.func.select_report1
	select_report2.v = mainIni.func.select_report2
	select_report3.v = mainIni.func.select_report3
	hello.v = u8:encode(mainIni.func.hello)
	hello_wait.v = mainIni.func.hello_wait
	hotkey1_text.v = u8:encode(mainIni.hotkeys.hotkey1_text)
	hotkey2_text.v = u8:encode(mainIni.hotkeys.hotkey2_text)
	hotkey3_text.v = u8:encode(mainIni.hotkeys.hotkey3_text)
	hotkey4_text.v = u8:encode(mainIni.hotkeys.hotkey4_text)
	hotkey5_text.v = u8:encode(mainIni.hotkeys.hotkey5_text)
	hotkey6_text.v = u8:encode(mainIni.hotkeys.hotkey6_text)
	hotkey7_text.v = u8:encode(mainIni.hotkeys.hotkey7_text)
	hotkey8_text.v = u8:encode(mainIni.hotkeys.hotkey8_text)
	hotkey9_text.v = u8:encode(mainIni.hotkeys.hotkey9_text)
	hotkey10_text.v = u8:encode(mainIni.hotkeys.hotkey10_text)
end

local HotKey_Takecall = {
	v = decodeJson(mainIni.hotkeys.bindSendTakecall)
}
local HotKey_Cancel = {
	v = decodeJson(mainIni.hotkeys.bindSendCancel)
}
local HotKey_Report_takecall = {
	v = decodeJson(mainIni.hotkeys.bindReport1)
}
local HotKey_Report_done = {
	v = decodeJson(mainIni.hotkeys.bindReport2)
}
local HotKey_Report_cancel = {
	v = decodeJson(mainIni.hotkeys.bindReport3)
}
local HotKey_1 = {
	v = decodeJson(mainIni.hotkeys.bindHotkey1)
}
local HotKey_2 = {
	v = decodeJson(mainIni.hotkeys.bindHotkey2)
}
local HotKey_3 = {
	v = decodeJson(mainIni.hotkeys.bindHotkey3)
}
local HotKey_4 = {
	v = decodeJson(mainIni.hotkeys.bindHotkey4)
}
local HotKey_5 = {
	v = decodeJson(mainIni.hotkeys.bindHotkey5)
}
local HotKey_6 = {
	v = decodeJson(mainIni.hotkeys.bindHotkey6)
}
local HotKey_7 = {
	v = decodeJson(mainIni.hotkeys.bindHotkey7)
}
local HotKey_8 = {
	v = decodeJson(mainIni.hotkeys.bindHotkey8)
}
local HotKey_9 = {
	v = decodeJson(mainIni.hotkeys.bindHotkey9)
}
local HotKey_10 = {
	v = decodeJson(mainIni.hotkeys.bindHotkey10)
}

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	imgui.SwitchContext()
	themes.SwitchColorTheme()
	bindSendTakecall = rkeys.registerHotKey(HotKey_Takecall.v, true, f_takecall)
	bindSendCancel = rkeys.registerHotKey(HotKey_Cancel.v, true, f_canceltaxi)
	bindReport1 = rkeys.registerHotKey(HotKey_Report_takecall.v, true, f_report1)
	bindReport2 = rkeys.registerHotKey(HotKey_Report_done.v, true, f_report2)
	bindReport3 = rkeys.registerHotKey(HotKey_Report_cancel.v, true, f_report3)
	bindHotkey1 = rkeys.registerHotKey(HotKey_1.v, true, f_binder1)
	bindHotkey2 = rkeys.registerHotKey(HotKey_2.v, true, f_binder2)
	bindHotkey3 = rkeys.registerHotKey(HotKey_3.v, true, f_binder3)
	bindHotkey4 = rkeys.registerHotKey(HotKey_4.v, true, f_binder4)
	bindHotkey5 = rkeys.registerHotKey(HotKey_5.v, true, f_binder5)
	bindHotkey6 = rkeys.registerHotKey(HotKey_6.v, true, f_binder6)
	bindHotkey7 = rkeys.registerHotKey(HotKey_7.v, true, f_binder7)
	bindHotkey8 = rkeys.registerHotKey(HotKey_8.v, true, f_binder8)
	bindHotkey9 = rkeys.registerHotKey(HotKey_9.v, true, f_binder9)
	bindHotkey10 = rkeys.registerHotKey(HotKey_10.v, true, f_binder10)
	downloadUrlToFile(font_url, font_path, function(id, status)
	end)
	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updateIni = inicfg.load(nil, update_path)
			if tonumber(updateIni.info.vers) > script_vers then
				sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Имеется обновление. Оно будет загружено автоматически.", 0xffd500)
				update_state = true
			end
		end
	end)
	imgui.Process = false
	sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Скрипт загружен. Автор скрипта: {ffff7a}Castiel_Chrysler{ffffff}.", 0xffd500)
	sampRegisterChatCommand('taxi', cmd_imgui)
	while true do
		wait(0)
		if update_state then
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Скрипт успешно обновлён.", 0xffd500)
					update_state = false
					os.remove(update_path)
				end
			end)
			break
		end
	end
end

 function sampev.onServerMessage(color, text)
	if text:find("нуждается в такси, его вызов отправлен в общую очередь.") and autotakecall.v then
		lua_thread.create(function()
			wait(0)
			sampSendChat('/takecall')
		end)
	end
	if text:find("Диспетчер: Вы приняли вызов от игрока") then
		lua_thread.create(function()
			wait(0)
			if soundtakecall.v then addOneOffSound(0.0, 0.0, 0.0, 1057) end
			if offtakecall.v == 3 then autotakecall.v = false end
			if autoreports.v then f_report1() end
		end)
	end
	if text:find("Пассажир %g+ доставлен, вы заработали") and autoreports.v then
		lua_thread.create(function()
			wait(0)
			f_report2()
		end)
	end
	if text:find("Вы отказались обслуживать %g+. Плата по счетчику составила") and autoreports.v then
		lua_thread.create(function()
			wait(0)
			f_report2()
		end)
	end
	
	if text:find("К вам в такси сел новый пассажир") and autohello.v then
		lua_thread.create(function()
			wait(0)
			sampSendChat(u8:decode(hello.v))
			autohello.v = not autohello.v
			wait(hello_wait)
			autohello.v = not autohello.v
		end)
	end
end

function cmd_imgui()
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
end

function imgui.OnDrawFrame()
	if not main_window_state.v and not takecall_settings_window_state.v and not reports_settings_window_state.v and not hello_settings_window_state.v and not hotkeys_window_state.v then
		imgui.Process = false
	end
	
	if main_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(700, 515), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_TAXI .. " Taxi Helper", main_window_state, imgui.WindowFlags.NoResize)
		imgui.SetWindowFontScale(1.1)
		local text = '{2bcaff}[Информация об игроке]:'
		imgui.TextColoredRGB(text)
		imgui.SetWindowFontScale(1.0)
		imgui.Spacing()
		imgui.Spacing()
		imgui.Spacing()
		imgui.PushItemWidth(250)
		imgui.InputText(u8"Имя и фамилия игрока (на русском)", playername, 48)
		imgui.Text(u8"Выберите пол вашего игрока:")
		if imgui.RadioButton(u8"Мужской", gender, 2) then
			report1.v = u8'Принял вызов. Направляюсь к клиенту.'
			report2.v = u8'Клиент доставлен. Свободен для вызовов.'
			mainIni.func.report1 = u8:decode(report1.v)
			mainIni.func.report2 = u8:decode(report2.v)
			inicfg.save(mainIni, inipath)
		end
		if imgui.RadioButton(u8"Женский", gender, 1) then
			report1.v = u8'Приняла вызов. Направляюсь к клиенту.'
			report2.v = u8'Клиент доставлен. Свободна для вызовов.'
			mainIni.func.report1 = u8:decode(report1.v)
			mainIni.func.report2 = u8:decode(report2.v)
			inicfg.save(mainIni, inipath)
		end
		imgui.Spacing()
		imgui.Spacing()
		imgui.Spacing()
		imgui.Separator()
		imgui.SetWindowFontScale(1.1)
		local text = '{2bcaff}[Функционал]:'
		imgui.TextColoredRGB(text)
		imgui.SetWindowFontScale(1.0)
		imgui.Spacing()
		imgui.Spacing()
		imgui.Spacing()
		
		
		imgui.ToggleButton("##1", autotakecall)
		imgui.SameLine()
		imgui.Text(u8("Автоматическое принятие вызова"))
		imgui.SameLine(283)
		if imgui.Button(fa.ICON_WRENCH .. u8" Расширенные настройки", imgui.ImVec2(180, 20)) then
			takecall_settings_window_state.v = not takecall_settings_window_state.v
			main_window_state.v = not main_window_state.v
		end
		imgui.Spacing()
		
		if imgui.ToggleButton("##2", autoreports) then
			if playername.v == "" then 
				sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Впишите имя игрока и сохраните настройки.", 0xffd500)
				autoreports.v = false
			end
			if gender.v == 0 then 
				sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Выберите пол для игрока и сохраните настройки.", 0xffd500)
				autoreports.v = false
			end
		end
		imgui.SameLine()
		imgui.Text(u8("Автоматические доклады в рацию"))
		imgui.SameLine(283)
		if imgui.Button(fa.ICON_WRENCH .. u8" Раcширенные настройки", imgui.ImVec2(180, 20)) then
			main_window_state.v = not main_window_state.v
			reports_settings_window_state.v = not reports_settings_window_state.v
		end
		
		imgui.Spacing()
		
		imgui.ToggleButton("##3", autohello)
		imgui.SameLine()
		imgui.Text(u8("Автоматическое приветствие клиентов"))
		imgui.SameLine()
		if imgui.Button(fa.ICON_WRENCH .. u8" Рaсширенные настройки", imgui.ImVec2(180, 20)) then
			main_window_state.v = not main_window_state.v
			hello_settings_window_state.v = not hello_settings_window_state.v
		end
		
		imgui.Spacing()
		imgui.Spacing()
		imgui.Spacing()
		imgui.Separator() 
		imgui.SetWindowFontScale(1.1)
		local text = '{2bcaff}[Горячие клавиши]:'
		imgui.TextColoredRGB(text)
		imgui.SetWindowFontScale(1.0)
		
		imgui.Spacing()
		imgui.Spacing()
		imgui.Spacing()
		
		if imgui.HotKey("##4", HotKey_Takecall, tLastKeys, 100) then
			rkeys.changeHotKey(bindSendTakecall, HotKey_Takecall.v)
			mainIni.hotkeys.bindSendTakecall = encodeJson(HotKey_Takecall.v)
		end
		imgui.SameLine()
		text = '{ffff00}/takecall {ffffff}(принять вызов)'
		imgui.TextColoredRGB(text)
		imgui.Spacing()
		
		
		if imgui.HotKey("##5", HotKey_Cancel, tLastKeys, 100) then
			rkeys.changeHotKey(bindSendCancel, HotKey_Cancel.v)
			mainIni.hotkeys.bindSendCancel = encodeJson(HotKey_Cancel.v)
		end
		imgui.SameLine()
		text = '{ffff00}/cancel taxi {ffffff}(отказаться от вызова)'
		imgui.TextColoredRGB(text)
		imgui.Spacing()
		
		
		if imgui.HotKey("##6", HotKey_Report_takecall, tLastKeys, 100) then
			rkeys.changeHotKey(bindReport1, HotKey_Report_takecall.v)
			mainIni.hotkeys.bindReport1 = encodeJson(HotKey_Report_takecall.v)
		end
		imgui.SameLine()
		text = '{ffffff}Совершить доклад о принятии вызова'
		imgui.TextColoredRGB(text)
		imgui.Spacing()
		
		
		if imgui.HotKey("##7", HotKey_Report_done, tLastKeys, 100) then
			rkeys.changeHotKey(bindReport2, HotKey_Report_done.v)
			mainIni.hotkeys.bindReport2 = encodeJson(HotKey_Report_done.v)
		end
		imgui.SameLine()
		text = '{ffffff}Совершить доклад о завершении вызова'
		imgui.TextColoredRGB(text)
		imgui.Spacing()
		
		
		if imgui.HotKey("##8", HotKey_Report_cancel, tLastKeys, 100) then
			rkeys.changeHotKey(bindReport3, HotKey_Report_cancel.v)
			mainIni.hotkeys.bindReport3 = encodeJson(HotKey_Report_cancel.v)
		end
		imgui.SameLine()
		text = '{ffffff}Совершить доклад об отказе от вызова'
		imgui.TextColoredRGB(text)
		imgui.Spacing()
		imgui.Spacing()
		imgui.Spacing()
		
		if imgui.Button(fa.ICON_PENCIL .. u8" Добавить дополнительные хоткеи", imgui.ImVec2(250, 25)) then
			hotkeys_window_state.v = not hotkeys_window_state.v
			main_window_state.v = not main_window_state.v
		end
		
		imgui.SetCursorPos(imgui.ImVec2(530, 460))
		if imgui.Button(fa.ICON_FLOPPY_O .. u8" Сохранить настройки", imgui.ImVec2(150, 40)) then
			save_all()
		end
		imgui.End()
	end
	
	if takecall_settings_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(380, 195), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_WRENCH .. u8" Настройки автоматического принятия вызовов", takecall_settings_window_state, imgui.WindowFlags.NoResize)
		imgui.Text(u8"Отключение функции:")
		imgui.Spacing()
		imgui.RadioButton(u8"Сразу после принятия вызова (рекомендуется)", offtakecall, 3)
		imgui.RadioButton(u8"Не отключать", offtakecall, 4)
		imgui.Spacing()
		imgui.Spacing()
		imgui.Separator() 
		imgui.Spacing()
		imgui.Spacing()
		imgui.Checkbox(u8"Звуковое уведомление о принятии вызова", soundtakecall)
		imgui.Spacing()
		imgui.Spacing()
		imgui.Separator() 
		imgui.Spacing()
		imgui.Spacing()
		if imgui.Button(u8"Сохранить и вернуться назад", imgui.ImVec2(200, 25)) then
			takecall_settings_window_state.v = not takecall_settings_window_state.v
			main_window_state.v = not main_window_state.v
			save_all()
		end
		imgui.End()
	end
	
	if reports_settings_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(440, 385), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_WRENCH .. u8" Настройки автоматических докладов в рацию", reports_settings_window_state, imgui.WindowFlags.NoResize)
		imgui.Text(u8"Схема отчёта о принятии вызова:")
		imgui.Spacing()
		local text = '{ffee54}[Имя Фамилия]'
		imgui.TextColoredRGB(text)
		imgui.SameLine()
		imgui.InputText("", report1)
		
		imgui.Spacing()
		imgui.Spacing()
		imgui.Separator() 
		imgui.Spacing()
		imgui.Spacing()
		
		imgui.Text(u8"Схема отчёта о завершении вызова:")
		imgui.Spacing()
		local text = '{ffee54}[Имя Фамилия]'
		imgui.TextColoredRGB(text)
		imgui.SameLine()
		imgui.InputText(" ", report2)
		
		imgui.Spacing()
		imgui.Spacing()
		imgui.Separator() 
		imgui.Spacing()
		imgui.Spacing()
		
		imgui.Text(u8"Схема отчёта об отказе от вызова:")
		imgui.Spacing()
		local text = '{ffee54}[Имя Фамилия]'
		imgui.TextColoredRGB(text)
		imgui.SameLine()
		imgui.InputText("  ", report3)
		
		imgui.Spacing()
		imgui.Spacing()
		imgui.Separator() 
		imgui.Spacing()
		imgui.Spacing()
		
		imgui.Text(u8"Действующие отчёты:")
		imgui.Spacing()
		imgui.Checkbox(u8"О принятии вызова", select_report1)
		imgui.Spacing()
		imgui.Checkbox(u8"О завершении вызова", select_report2)
		imgui.Spacing()
		imgui.Checkbox(u8"Об отказе от вызова", select_report3)
		
		imgui.Spacing()
		imgui.Spacing()
		imgui.Separator() 
		imgui.Spacing()
		imgui.Spacing()
		
		if imgui.Button(u8"Сохранить и вернуться назад", imgui.ImVec2(200, 25)) then
			reports_settings_window_state.v = not reports_settings_window_state.v
			main_window_state.v = not main_window_state.v
			save_all()
		end
		imgui.End()
	end
	
	if hello_settings_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(400, 225), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_WRENCH .. u8" Настройки автоматического приветствия пассажиров", hello_settings_window_state, imgui.WindowFlags.NoResize)
		imgui.Text(u8"Схема приветствия:")
		imgui.Spacing()
		imgui.PushItemWidth(351)
		imgui.InputText("", hello)
		imgui.Spacing()
		imgui.Spacing()
		imgui.Separator() 
		imgui.Spacing()
		imgui.Spacing()
			
		imgui.Text(u8"Задержка после отправки (миллисекунд):")
		imgui.SameLine()
		imgui.PushItemWidth(96)
		imgui.InputInt(" ", hello_wait)
		imgui.Spacing()
		imgui.Text(u8"Не рекомендуется устанавливать нулевую задержку.\nЕсли в такси сядет несколько пассажиров - то \nпри нулевой задержке приветствие отправится несколько раз.")
		imgui.Spacing()
		imgui.Spacing()
		imgui.Separator() 
		imgui.Spacing()
		imgui.Spacing()
		
		if imgui.Button(u8"Сохранить и вернуться назад", imgui.ImVec2(200, 25)) then
			if type((hello_wait.v)) ~= 'number' then sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Некорректное время задержки приветствия.", 0xffd500) return end
			hello_settings_window_state.v = not hello_settings_window_state.v
			main_window_state.v = not main_window_state.v
			save_all()
		end
		imgui.End()
	end
	if hotkeys_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(600, 435), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_PENCIL .. u8" Дополнительные хоткеи", hotkeys_window_state, imgui.WindowFlags.NoResize)
		
		if imgui.HotKey("##8", HotKey_1, tLastKeys, 100) then
			rkeys.changeHotKey(bindHotkey1, HotKey_1.v)
			mainIni.hotkeys.bindHotkey1 = encodeJson(HotKey_1.v)
		end
		imgui.SameLine()
		if imgui.InputText("##1", hotkey1_text) then
		end
		
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		
		if imgui.HotKey("##9", HotKey_2, tLastKeys, 100) then
			rkeys.changeHotKey(bindHotkey2, HotKey_2.v)
			mainIni.hotkeys.bindHotkey2 = encodeJson(HotKey_2.v)
		end
		imgui.SameLine()
		imgui.InputText("##2", hotkey2_text)
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		
		if imgui.HotKey("##10", HotKey_3, tLastKeys, 100) then
			rkeys.changeHotKey(bindHotkey3, HotKey_3.v)
			mainIni.hotkeys.bindHotkey3 = encodeJson(HotKey_3.v)
		end
		imgui.SameLine()
		imgui.InputText("##3", hotkey3_text)
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		
		if imgui.HotKey("##11", HotKey_4, tLastKeys, 100) then
			rkeys.changeHotKey(bindHotkey4, HotKey_4.v)
			mainIni.hotkeys.bindHotkey4 = encodeJson(HotKey_4.v)
		end
		imgui.SameLine()
		imgui.InputText("##4", hotkey4_text)
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		
		if imgui.HotKey("##12", HotKey_5, tLastKeys, 100) then
			rkeys.changeHotKey(bindHotkey5, HotKey_5.v)
			mainIni.hotkeys.bindHotkey5 = encodeJson(HotKey_5.v)
		end
		imgui.SameLine()
		imgui.InputText("##5", hotkey5_text)
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		
		if imgui.HotKey("##13", HotKey_6, tLastKeys, 100) then
			rkeys.changeHotKey(bindHotkey6, HotKey_6.v)
			mainIni.hotkeys.bindHotkey6 = encodeJson(HotKey_6.v)
		end
		imgui.SameLine()
		imgui.InputText("##6", hotkey6_text)
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		
		if imgui.HotKey("##14", HotKey_7, tLastKeys, 100) then
			rkeys.changeHotKey(bindHotkey7, HotKey_7.v)
			mainIni.hotkeys.bindHotkey7 = encodeJson(HotKey_7.v)
		end
		imgui.SameLine()
		imgui.InputText("##7", hotkey7_text)
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		
		if imgui.HotKey("##15", HotKey_8, tLastKeys, 100) then
			rkeys.changeHotKey(bindHotkey8, HotKey_8.v)
			mainIni.hotkeys.bindHotkey8 = encodeJson(HotKey_8.v)
		end
		imgui.SameLine()
		imgui.InputText("##8", hotkey8_text)
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		
		if imgui.HotKey("##16", HotKey_9, tLastKeys, 100) then
			rkeys.changeHotKey(bindHotkey9, HotKey_9.v)
			mainIni.hotkeys.bindHotkey9 = encodeJson(HotKey_9.v)
		end
		imgui.SameLine()
		imgui.InputText("##9", hotkey9_text)
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		
		if imgui.HotKey("##17", HotKey_10, tLastKeys, 100) then
			rkeys.changeHotKey(bindHotkey10, HotKey_10.v)
			mainIni.hotkeys.bindHotkey10 = encodeJson(HotKey_10.v)
		end
		imgui.SameLine()
		imgui.InputText("##10", hotkey10_text)
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		
		if imgui.Button(u8"Сохранить и вернуться назад", imgui.ImVec2(200, 25)) then
			hotkeys_window_state.v = not hotkeys_window_state.v
			main_window_state.v = not main_window_state.v
			save_all()
		end
		
		imgui.End()
	end
end

function imgui.BeforeDrawFrame()
  if fa_font == nil then
    local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
    font_config.MergeMode = true

    fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
  end
end

function f_takecall()
	sampSendChat("/takecall")
end

function f_canceltaxi()
	sampSendChat("/cancel taxi")
end

function f_report1()
	if playername.v == "" then sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Впишите имя игрока и сохраните настройки.", 0xffd500) end
	if gender.v == 0 then sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Выберите пол для игрока и сохраните настройки.", 0xffd500) return end
	if gender.v == 1 then sampSendChat("/r " .. u8:decode(playername.v) .. ". " .. u8:decode(report1.v))
	elseif gender.v == 2 then sampSendChat("/r " .. u8:decode(playername.v) .. ". " .. u8:decode(report1.v))
	end
end

function f_report2()
	if playername.v == "" then sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Впишите имя игрока и сохраните настройки.", 0xffd500) end
	if gender.v == 0 then sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Выберите пол для игрока и сохраните настройки.", 0xffd500) return end
	if gender.v == 1 then sampSendChat("/r " .. u8:decode(playername.v) .. ". " .. u8:decode(report2.v))
	elseif gender.v == 2 then sampSendChat("/r " .. u8:decode(playername.v) .. ". " .. u8:decode(report2.v))
	end
end

function f_report3()
	if playername.v == "" then sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Впишите имя игрока и сохраните настройки.", 0xffd500) end
	if gender.v == 0 then sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Выберите пол для игрока и сохраните настройки.", 0xffd500) return end
	sampSendChat("/r " .. u8:decode(playername.v) .. ". " .. u8:decode(report3.v))
end

function f_binder1()
	if hotkey1_text.v == "" then return end
	sampSendChat(u8:decode(hotkey1_text.v))
end

function f_binder2()
	if hotkey2_text.v == "" then return end
	sampSendChat(u8:decode(hotkey2_text.v))
end

function f_binder3()
	if hotkey3_text.v == "" then return end
	sampSendChat(u8:decode(hotkey3_text.v))
end

function f_binder4()
	if hotkey4_text.v == "" then return end
	sampSendChat(u8:decode(hotkey4_text.v))
end

function f_binder5()
	if hotkey5_text.v == "" then return end
	sampSendChat(u8:decode(hotkey5_text.v))
end

function f_binder6()
	if hotkey6_text.v == "" then return end
	sampSendChat(u8:decode(hotkey6_text.v))
end

function f_binder7()
	if hotkey7_text.v == "" then return end
	sampSendChat(u8:decode(hotkey7_text.v))
end

function f_binder8()
	if hotkey8_text.v == "" then return end
	sampSendChat(u8:decode(hotkey8_text.v))
end

function f_binder9()
	if hotkey9_text.v == "" then return end
	sampSendChat(u8:decode(hotkey9_text.v))
end

function f_binder10()
	if hotkey10_text.v == "" then return end
	sampSendChat(u8:decode(hotkey10_text.v))
end

function save_all()
	mainIni.playerinfo.playername = u8:decode(playername.v)
	mainIni.playerinfo.gender = gender.v
	mainIni.func.autotakecall = autotakecall.v
	mainIni.func.autoreports = autoreports.v
	mainIni.func.autohello = autohello.v
	mainIni.func.offtakecall = offtakecall.v
	mainIni.func.soundtakecall = soundtakecall.v
	mainIni.func.report1 = u8:decode(report1.v)
	mainIni.func.report2 = u8:decode(report2.v)
	mainIni.func.report3 = u8:decode(report3.v)
	mainIni.func.select_report1 = select_report1.v
	mainIni.func.select_report2 = select_report2.v
	mainIni.func.select_report3 = select_report3.v
	mainIni.func.hello = u8:decode(hello.v)
	mainIni.func.hello_wait = hello_wait.v
	mainIni.hotkeys.bindSendTakecall = encodeJson(HotKey_Takecall.v)
	mainIni.hotkeys.bindSendCancel = encodeJson(HotKey_Cancel.v)
	mainIni.hotkeys.bindReport1 = encodeJson(HotKey_Report_takecall.v)
	mainIni.hotkeys.bindReport2 = encodeJson(HotKey_Report_done.v)
	mainIni.hotkeys.bindReport3 = encodeJson(HotKey_Report_cancel.v)
	mainIni.hotkeys.bindHotkey1 = encodeJson(HotKey_1.v)
	mainIni.hotkeys.bindHotkey2 = encodeJson(HotKey_2.v)
	mainIni.hotkeys.bindHotkey3 = encodeJson(HotKey_3.v)
	mainIni.hotkeys.bindHotkey4 = encodeJson(HotKey_4.v)
	mainIni.hotkeys.bindHotkey5 = encodeJson(HotKey_5.v)
	mainIni.hotkeys.bindHotkey6 = encodeJson(HotKey_6.v)
	mainIni.hotkeys.bindHotkey7 = encodeJson(HotKey_7.v)
	mainIni.hotkeys.bindHotkey8 = encodeJson(HotKey_8.v)
	mainIni.hotkeys.bindHotkey9 = encodeJson(HotKey_9.v)
	mainIni.hotkeys.bindHotkey10 = encodeJson(HotKey_10.v)
	
	mainIni.hotkeys.hotkey1_text = u8:decode(hotkey1_text.v)
	mainIni.hotkeys.hotkey2_text = u8:decode(hotkey2_text.v)
	mainIni.hotkeys.hotkey3_text = u8:decode(hotkey3_text.v)
	mainIni.hotkeys.hotkey4_text = u8:decode(hotkey4_text.v)
	mainIni.hotkeys.hotkey5_text = u8:decode(hotkey5_text.v)
	mainIni.hotkeys.hotkey6_text = u8:decode(hotkey6_text.v)
	mainIni.hotkeys.hotkey7_text = u8:decode(hotkey7_text.v)
	mainIni.hotkeys.hotkey8_text = u8:decode(hotkey8_text.v)
	mainIni.hotkeys.hotkey9_text = u8:decode(hotkey9_text.v)
	mainIni.hotkeys.hotkey10_text = u8:decode(hotkey10_text.v)
	
	if inicfg.save(mainIni, inipath) then
		sampAddChatMessage("[LUA] Taxi Helper v1.1: {ffffff}Настройки успешно сохранены.", 0xffd500)
	end
end