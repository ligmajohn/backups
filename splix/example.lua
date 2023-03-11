local library, utility = loadstring(game:HttpGet("https://raw.githubusercontent.com/ligmajohn/backups/main/splix/library.lua"))()
--
local title_string = "Splix - Private | %A, %B"
local day = os.date(" %d", os.time())
local second_string = ", %Y."
title_string = os.date(title_string, os.time())..day..utility:GetSubPrefix(day)..os.date(second_string, os.time())
--
local lib = library:New({name = title_string})
--
local aimbot = lib:Page({name = "Aimbot"})
local visuals = lib:Page({name = "Visuals"})
local exploits = lib:Page({name = "Exploits"})
local misc = lib:Page({name = "Miscellaneous"})
--
local aimbot_main = aimbot:Section({name = "Main"})
local aimbot_br = aimbot:Section({name = "Bullet Redirection",side = "right"})
local aimbot_m, aimbot_mi, aimbot_s = aimbot:MultiSection({sections = {"Main", "Misc", "Settings"}, side = "left"})
--
local visuals_team, visuals_enemies, visuals_allies = visuals:MultiSection({sections = {"Team", "Enemies", "Allies"}, side = "left"})
local visuals_player = visuals:Section({name = "Players"})
local visuals_miscellaneous = visuals:Section({name = "Miscellaneous",side = "right"})
--
local exploits_main = exploits:Section({name = "Main"})
local exploits_skin = exploits:Section({name = "Skin Changer",side = "right"})
local exploits_freeze = exploits:Section({name = "Freeze Players"})
--
local misc_main = misc:Section({name = "Main"})
local misc_adj = misc:Section({name = "Adjustments",side = "right"})
--
local asd = aimbot_m:Toggle({name = "Aimbot Toggle", def = true, pointer = "aimbot_toggle"})
asd:Colorpicker({info = "Aimbot FOV Color", def = Color3.fromRGB(0,255,150), transparency = 0.5})
asd:Colorpicker({info = "Aimbot Outline FOV Color", def = Color3.fromRGB(45,45,45), transparency = 0.25})
aimbot_s:Label({name = "Some of the features\nhere, May be unsafe.\nUse with caution."})
aimbot_mi:Colorpicker({info = "Aimbot FOV Color", def = Color3.fromRGB(0,255,150), transparency = 0.5})
aimbot_mi:Multibox({name = "Aimbot Hitpart", min = 1, options = {"Head", "Torso", "Arms", "Legs"}, def = {"Head", "Torso"}})
aimbot_s:Dropdown({name = "Aimbot Hitpart", options = {"Head", "Torso", "Arms", "Legs"}, def = "Head"})
--
aimbot_main:Label({name = "Some of the features\nhere, May be unsafe.\nUse with caution."})
local aimbot_toggle = aimbot_main:Toggle({name = "Aimbot Toggle", def = true, pointer = "aimbot_toggle"})
aimbot_toggle:Colorpicker({info = "Aimbot FOV Color", def = Color3.fromRGB(0,255,150), transparency = 0.5})
aimbot_toggle:Colorpicker({info = "Aimbot Outline FOV Color", def = Color3.fromRGB(45,45,45), transparency = 0.25})
aimbot_main:Colorpicker({name = "Locking Color", info = "Aimbot Locked Player Color", def = Color3.fromRGB(205,50,50)}):Colorpicker({info = "Aimbot Outline FOV Color", def = Color3.fromRGB(45,45,45), transparency = 0.25})
aimbot_main:Toggle({name = "Aimbot Visible", def = true})
aimbot_main:Slider({name = "Watermark X Offset", min = 0, max = utility:GetScreenSize().X, def = 100, decimals = 1, callback = function(value)
    if lib.watermark and lib.watermark.outline then
        lib.watermark:Update("Offset", Vector2.new(value, lib.watermark.outline.Position.Y))
    end
end})
aimbot_main:Slider({name = "Watermark Y Offset", min = 0, max = utility:GetScreenSize().Y, def = 38/2-10, decimals = 1, callback = function(value)
    if lib.watermark and lib.watermark.outline then
        lib.watermark:Update("Offset", Vector2.new(lib.watermark.outline.Position.X, value))
    end
end})
aimbot_main:Slider({name = "Aimbot Field Of View", min = 0, max = 1000, def = 125, suffix = "°"})
aimbot_main:Toggle({name = "Aimbot Toggle", def = true, pointer = "aimbot_toggle"}):Keybind({callback = function(input, active) print(active) end})
aimbot_main:Keybind({name = "Aimbot Keybind", mode = "Toggle", callback = function(input, active) print(active) end})
aimbot_main:Keybind({name = "Aimbot Keybind", mode = "Hold", callback = function(input, active) print(active) end})
aimbot_main:Multibox({name = "Aimbot Hitpart", min = 1, options = {"Head", "Torso", "Arms", "Legs"}, def = {"Head", "Torso"}})
aimbot_main:Dropdown({name = "Aimbot Hitpart", options = {"Head", "Torso", "Arms", "Legs"}, def = "Head"})
--
aimbot_br:Toggle({name = "Bullet Redirection Toggle", def = true})
aimbot_br:Slider({name = "B.R. Hitchance", min = 0, max = 100, def = 65, suffix = "%"})
aimbot_br:Slider({name = "B.R. Accuracy", min = 0, max = 100, def = 90, suffix = "%"})
--
visuals_team:Toggle({name = "Draw Boxes", def = true})
visuals_team:Toggle({name = "Draw Names", def = true})
visuals_team:Toggle({name = "Draw Health", def = true})
--
visuals_enemies:Toggle({name = "Draw Boxes", def = true})
visuals_enemies:Toggle({name = "Draw Names", def = true})
visuals_enemies:Toggle({name = "Draw Health", def = true})
--
visuals_allies:Toggle({name = "Draw Boxes", def = true})
visuals_allies:Toggle({name = "Draw Names", def = true})
visuals_allies:Toggle({name = "Draw Health", def = true})
--
visuals_miscellaneous:Toggle({name = "Draw Field Of View"})
visuals_miscellaneous:Toggle({name = "Draw Server Position"})
--
exploits_main:Toggle({name = "God Mode"})
exploits_main:Toggle({name = "Bypass Suppresion"})
exploits_main:Toggle({name = "Bypass Fall"})
exploits_main:Button({name = "Stress Server"})
exploits_main:Button({name = "Crash Server"})
--
exploits_freeze:Toggle({name = "Freeze Toggle"})
exploits_freeze:Toggle({name = "Freeze On Shoot"})
exploits_freeze:Slider({name = "Freeze Interval", min = 1, max = 3000, def = 1000, suffix = "ms"})
--
exploits_skin:Toggle({name = "Custom Skin"})
exploits_skin:Slider({name = "Skin Offset Vertical", min = 0, max = 4, def = 1, decimals = 0.01})
exploits_skin:Slider({name = "Skin Offset Horizontal", min = 0, max = 4, def = 1, decimals = 0.01})
exploits_skin:Slider({name = "Skin Studs Vertical", min = 0, max = 4, def = 1, decimals = 0.01})
exploits_skin:Slider({name = "Skin Studs Horizontal", min = 0, max = 4, def = 1, decimals = 0.01})
--
misc_main:Toggle({name = "Fly"})
misc_main:Toggle({name = "Auto Spot", def = true})
misc_main:Toggle({name = "Hit Logs", def = true})
misc_main:Toggle({name = "Chat Spam"})
misc_main:Toggle({name = "Auto Vote"})
misc_main:Dropdown({name = "Auto Vote Options", options = {"Yes", "No"}, def = "Yes"})
--
misc_adj:Toggle({name = "Walk Speed"})
misc_adj:Toggle({name = "Jump Height"})
misc_adj:Slider({name = "Walk Speed", min = 16, max = 200, def = 16})
misc_adj:Slider({name = "Jump Height", min = 50, max = 400, def = 50})
--
lib:Initialize()
