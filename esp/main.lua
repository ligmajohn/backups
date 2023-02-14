assert(Drawing, "missing dependency: drawing")

local format, floor, wrap, newCFrame = string.format, math.floor, coroutine.wrap, CFrame.new
local Vector2, Vector3, newDrawing, fromRGB = Vector2.new, Vector3.new, Drawing.new, Color3.fromRGB

local ESP = {
    Enabled = false,
    Distance = true,
    Boxes = true,
    BoxShift = newCFrame(0, -1.5, 0),
    BoxSize = Vector3(4, 6, 0),
    Color = fromRGB(255, 255, 255),
    FaceCamera = false,
    Names = true,
    TeamColor = true,
    Thickness = 2,
    AttachShift = 1,
    TeamMates = true,
    Players = true,
    Health = false,
    Presets = {
        Green = fromRGB(0, 255, 154),
        Red = fromRGB(255, 0, 128),
        Orange = fromRGB(255, 162, 0),
        Blue = fromRGB(0, 145, 255),
        White = fromRGB(255, 255, 255)
    },
    IgnoreHumanoids = false,
    Objects = setmetatable({}, {__mode = "kv"}),
    Debug = false,
    Overrides = {}
}

local cloneref = cloneref or function(...) return ... end
local cam = workspace.CurrentCamera
local plrs = cloneref(game:GetService("Players"))
local runserv = cloneref(game:GetService("RunService"))
local plr = plrs.LocalPlayer
local WorldToViewportPoint = cam.WorldToViewportPoint

local function Draw(obj, props)
	local new = newDrawing(obj)
	props = props or {}
	for i, v in pairs(props) do
		new[i] = v
	end
	return new
end

function ESP:GetTeam(p)
	local ov = self.Overrides.GetTeam
	if ov then
		return ov(p)
	end
	return p and p.Team
end

function ESP:IsTeamMate(p)
    local ov = self.Overrides.IsTeamMate
	if ov then
		return ov(p)
    end
    return self:GetTeam(p) == self:GetTeam(plr)
end

function ESP:GetColor(obj)
	local ov = self.Overrides.GetColor
	if ov then
		return ov(obj)
    end
    local p = self:GetPlrFromChar(obj)
    return p and self.TeamColor and p.Team and p.Team.TeamColor.Color or self.Color
end

function ESP:GetPlrFromChar(char)
	local ov = self.Overrides.GetPlrFromChar
	if ov then
		return ov(char)
	end
	return plrs:GetPlayerFromCharacter(char)
end

function ESP:GetHealth(char)
	local ov = self.Overrides.GetHealth
	if ov then
		return ov(char)
	end
	local player = self:GetPlrFromChar(char)
	local humanoid = player and player.Character and (player.Character:FindFirstChildWhichIsA("Humanoid") or player.Character:FindFirstChild("Humanoid"))
	if humanoid then
		return {Health = humanoid.Health, MaxHealth = humanoid.MaxHealth}
	end
	return {Health = 0, MaxHealth = 0}
end

function ESP:Toggle(bool)
    self.Enabled = bool
    if not bool then
        for _, v in pairs(self.Objects) do
            if v.Type == "Box" then
                if v.Temporary then
                    v:Remove()
                else
                    for _, v2 in pairs(v.Components) do
                        v2.Visible = false
                    end
                end
            end
        end
    end
end

function ESP:GetBox(obj)
    return self.Objects[obj]
end

function ESP:AddObjectListener(parent, options)
    local function NewListener(c)
        if type(options.Type) == "string" and c:IsA(options.Type) or options.Type == nil then
            if type(options.Name) == "string" and c.Name == options.Name or options.Name == nil then
                if not options.Validator or options.Validator(c) then
                    local box = ESP:Add(c, {
                        PrimaryPart = type(options.PrimaryPart) == "string" and c:WaitForChild(options.PrimaryPart) or type(options.PrimaryPart) == "function" and options.PrimaryPart(c),
                        Color = type(options.Color) == "function" and options.Color(c) or options.Color,
                        ColorDynamic = options.ColorDynamic,
                        Name = type(options.CustomName) == "function" and options.CustomName(c) or options.CustomName,
                        IsEnabled = options.IsEnabled,
                        RenderInNil = options.RenderInNil
                    })
                    if options.OnAdded then
                        wrap(options.OnAdded)(box)
                    end
                end
            end
        end
    end

    if options.Recursive then
        parent.DescendantAdded:Connect(NewListener)
        for _, v in pairs(parent:GetDescendants()) do
            wrap(NewListener)(v)
        end
    else
        parent.ChildAdded:Connect(NewListener)
        for _, v in pairs(parent:GetChildren()) do
            wrap(NewListener)(v)
        end
    end
end

local boxBase = {}
boxBase.__index = boxBase

function boxBase:Remove()
    ESP.Objects[self.Object] = nil
    for i, v in pairs(self.Components) do
        v.Visible = false
        v:Remove()
        self.Components[i] = nil
    end
end

function boxBase:Update()
    if not self.PrimaryPart then
        return self:Remove()
    end

    local color
    if ESP.Highlighted == self.Object then
       color = ESP.HighlightColor
    else
        color = self.Color or self.ColorDynamic and self:ColorDynamic() or ESP:GetColor(self.Object) or ESP.Color
    end

    local allow = true
    if ESP.Overrides.UpdateAllow and not ESP.Overrides.UpdateAllow(self) then
        allow = false
    end
    if self.Player and not ESP.TeamMates and ESP:IsTeamMate(self.Player) then
        allow = false
    end
    if self.Player and not ESP.Players then
        allow = false
    end
    if self.IsEnabled and (type(self.IsEnabled) == "string" and not ESP[self.IsEnabled] or type(self.IsEnabled) == "function" and not self:IsEnabled()) then
        allow = false
    end
    if not workspace:IsAncestorOf(self.PrimaryPart) and not self.RenderInNil then
        allow = false
    end

    if not allow then
        for _, v in pairs(self.Components) do
            v.Visible = false
        end
        return
    end

    if ESP.Highlighted == self.Object then
        color = ESP.HighlightColor
    end

    local cf = self.PrimaryPart.CFrame
    if ESP.FaceCamera then
        cf = newCFrame(cf.p, cam.CFrame.p)
    end
    local size = self.Size
    local locs = {
        TopLeft = cf * ESP.BoxShift * newCFrame(size.X/2,size.Y/2,0),
        TopRight = cf * ESP.BoxShift * newCFrame(-size.X/2,size.Y/2,0),
        BottomLeft = cf * ESP.BoxShift * newCFrame(size.X/2,-size.Y/2,0),
        BottomRight = cf * ESP.BoxShift * newCFrame(-size.X/2,-size.Y/2,0),
        TagPos = cf * ESP.BoxShift * newCFrame(0,size.Y/2,0),
        Torso = cf * ESP.BoxShift
    }

    if ESP.Boxes then
        local TopLeft, Vis1 = WorldToViewportPoint(cam, locs.TopLeft.p)
        local TopRight, Vis2 = WorldToViewportPoint(cam, locs.TopRight.p)
        local BottomLeft, Vis3 = WorldToViewportPoint(cam, locs.BottomLeft.p)
        local BottomRight, Vis4 = WorldToViewportPoint(cam, locs.BottomRight.p)

        if self.Components.Quad then
            if Vis1 or Vis2 or Vis3 or Vis4 then
                self.Components.Quad.Visible = true
                self.Components.Quad.PointA = Vector2(TopRight.X, TopRight.Y)
                self.Components.Quad.PointB = Vector2(TopLeft.X, TopLeft.Y)
                self.Components.Quad.PointC = Vector2(BottomLeft.X, BottomLeft.Y)
                self.Components.Quad.PointD = Vector2(BottomRight.X, BottomRight.Y)
                self.Components.Quad.Color = color
            else
                self.Components.Quad.Visible = false
            end
        end
    else
        self.Components.Quad.Visible = false
    end

    if ESP.Names then
        local TagPos, Vis5 = WorldToViewportPoint(cam, locs.TagPos.p)

        if Vis5 then
            self.Components.Name.Visible = true
            self.Components.Name.Position = Vector2(TagPos.X, TagPos.Y)
            if ESP.Health and self.Player and self.Player.Character then
                local Humanoid = ESP:GetHealth(self.Player.Character)
                self.Components.Name.Text = self.Name .. format(" [%s/%s]", floor(Humanoid.Health), floor(Humanoid.MaxHealth))
            else
                self.Components.Name.Text = self.Name
            end
            self.Components.Name.Color = color

            if ESP.Distance then
                self.Components.Distance.Visible = true
                self.Components.Distance.Position = Vector2(TagPos.X, TagPos.Y + 14)
                self.Components.Distance.Text = floor((cam.CFrame.p - cf.p).magnitude) .. "m away"
                self.Components.Distance.Color = color
            else
                self.Components.Distance.Visible = false
            end
        else
            self.Components.Name.Visible = false
            self.Components.Distance.Visible = false
        end
    else
        self.Components.Name.Visible = false
        self.Components.Distance.Visible = false
    end

    if ESP.Tracers then
        local TorsoPos, Vis6 = WorldToViewportPoint(cam, locs.Torso.p)

        if Vis6 then
            self.Components.Tracer.Visible = true
            self.Components.Tracer.From = Vector2(TorsoPos.X, TorsoPos.Y)
            self.Components.Tracer.To = Vector2(cam.ViewportSize.X/2,cam.ViewportSize.Y/ESP.AttachShift)
            self.Components.Tracer.Color = color
        else
            self.Components.Tracer.Visible = false
        end
    else
        self.Components.Tracer.Visible = false
    end
end

function ESP:Add(obj, options)
    if not obj.Parent and not options.RenderInNil then
        if ESP.Debug then warn(obj, "has no parent") end
        return
    end

    local box = setmetatable({
        Name = options.Name or obj.Name,
        Type = "Box",
        Color = options.Color,
        Size = options.Size or self.BoxSize,
        Object = obj,
        Player = options.Player or plrs:GetPlayerFromCharacter(obj),
        PrimaryPart = options.PrimaryPart or obj.ClassName == "Model" and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj:IsA("BasePart") and obj,
        Components = {},
        IsEnabled = options.IsEnabled,
        Temporary = options.Temporary,
        ColorDynamic = options.ColorDynamic,
        RenderInNil = options.RenderInNil
    }, boxBase)

    if self:GetBox(obj) then
        self:GetBox(obj):Remove()
    end

    box.Components["Quad"] = Draw("Quad", {
        Thickness = self.Thickness,
        Color = color,
        Transparency = 1,
        Filled = false,
        Visible = self.Enabled and self.Boxes
    })
    box.Components["Name"] = Draw("Text", {
		Text = box.Name,
		Color = box.Color,
		Center = true,
		Outline = true,
        Size = 19,
        Visible = self.Enabled and self.Names
	})
	box.Components["Distance"] = Draw("Text", {
		Color = box.Color,
		Center = true,
		Outline = true,
        Size = 19,
        Visible = self.Enabled and self.Names
	})

	box.Components["Tracer"] = Draw("Line", {
		Thickness = ESP.Thickness,
		Color = box.Color,
        Transparency = 1,
        Visible = self.Enabled and self.Tracers
    })
    self.Objects[obj] = box

    obj.AncestryChanged:Connect(function(_, parent)
        if parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)
    obj:GetPropertyChangedSignal("Parent"):Connect(function()
        if obj.Parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)

    local hum = obj:FindFirstChildWhichIsA("Humanoid")
	if hum and (not ESP.IgnoreHumanoids) then
        hum.Died:Connect(function()
            if ESP.AutoRemove ~= false then
                box:Remove()
            end
		end)
    end

    return box
end

local function CharAdded(char)
    local p = plrs:GetPlayerFromCharacter(char)
    if not char:FindFirstChild("HumanoidRootPart") then
        local ev
        ev = char.ChildAdded:Connect(function(c)
            if c.Name == "HumanoidRootPart" then
                ev:Disconnect()
                ESP:Add(char, {
                    Name = p.Name,
                    Player = p,
                    PrimaryPart = c
                })
            end
        end)
    else
        ESP:Add(char, {
            Name = p.Name,
            Player = p,
            PrimaryPart = char.HumanoidRootPart
        })
    end
end
local function PlayerAdded(p)
    p.CharacterAdded:Connect(CharAdded)
    if p.Character then
        wrap(CharAdded)(p.Character)
    end
end
plrs.PlayerAdded:Connect(PlayerAdded)
for _, v in pairs(plrs:GetPlayers()) do
    if v ~= plr then
        PlayerAdded(v)
    end
end

local Updating = runserv.RenderStepped:Connect(function()
    cam = workspace.CurrentCamera
    for _, v in (ESP.Enabled and pairs or ipairs)(ESP.Objects) do
        if v.Update then
            local s, e = pcall(v.Update, v)
            if not s then if ESP.Debug then warn("[esp]", e, v.Object:GetFullName()) end end
        end
    end
end)

function ESP:DefaultSetup(color)
    ESP:Toggle(true)
    ESP.Players = true
    ESP.Tracers = true
    ESP.Distance = true
    ESP.Boxes = true
    ESP.Names = true
    ESP.Health = true
    ESP.Color = ESP.Presets[tostring(color)] or color or ESP.Presets.White
end

local CoreGui = cloneref(game:GetService("CoreGui"))
local chamfolder = nil
local chamsEnabled = false
function ESP:Chams(enabled)
    chamsEnabled = enabled
    if enabled then
        if chamfolder then
            chamfolder:Destroy()
            chamfolder = nil
        end
        chamfolder = Instance.new("Folder")
        chamfolder.Parent = CoreGui
        spawn(function()
            repeat wait()
                for _, v in next, plrs:GetPlayers() do
                    if v ~= plr then
                        local char = v.Character
                        if chamfolder ~= nil and char ~= nil then
                            local hitbox = chamfolder:FindFirstChild(v.Name) or Instance.new("Highlight")
                            hitbox.Name = v.Name
                            hitbox.Parent = chamfolder
                            hitbox.Adornee = char
                            hitbox.OutlineColor = v.TeamColor.Color
                            hitbox.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hitbox.FillColor = v.TeamColor.Color
                            hitbox.FillTransparency = 0.5
                        end
                    end
                end
            until not chamsEnabled or not ESP.Enabled
        end)
    else
        if chamfolder then
            chamfolder:Destroy()
            chamfolder = nil
        end
    end
end

function ESP:Kill()
    ESP.Debug = false
    ESP:Toggle(false)
    ESP.Players = false
    ESP.Tracers = false
    ESP.Distance = false
    ESP.Boxes = false
    ESP.Names = false
    ESP.Health = false
    Updating:Disconnect()
    ESP:Chams(false)
end

return ESP
