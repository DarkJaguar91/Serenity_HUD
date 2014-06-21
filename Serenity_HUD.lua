-----------------------------------------------------------------------------------------------
-- Client Lua Script for Serenity_HUD
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Serenity_HUD Module Definition
-----------------------------------------------------------------------------------------------
local Serenity_HUD = {} 
local SHudBar = {}
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local version = "V1.3"
local textures = {
	["Comity Vertical"] = "SHUD:ComityV",
	["Comity Horizontal"] = "SHUD:ComityH",
	["Arc Hud Left"] = "SHUD:ArcHudLeft",
	["Arc Hud Right"] = "SHUD:ArcHudRight",
	["Arc Hud Top"] = "SHUD:ArcHudTop",
	["Arc Hud Bot"] = "SHUD:ArcHudBot",
	["Courtesy Horizontal"] = "SHUD:CourtesyH",
	["Courtesy Vertical"] = "SHUD:CourtesyV",
	["Ferous Scratch Vertical"] = "SHUD:FerousScratchV",
	["Ferous Scratch Horizontal"] = "SHUD:FerousScratchH",
	["Barbed Wire Horizontal"] = "SHUD:BarbedWireH",
	["Barbed Wire Vertical"] = "SHUD:BarbedWireV",
	["Left Dragon Vertical"] = "SHUD:LDragonV",
	["Left Dragon Horizontal"] = "SHUD:LDragonH",
	["Right Dragon Vertical"] = "SHUD:RDragonV",
	["Right Dragon Horizontal"] = "SHUD:RDragonH",
}

local BGTextures = {
	["Gloss"] = "SHUD:GlossBG",
	["Arc Hud Left"] = "SHUD:ArcHudLeft",
	["Arc Hud Right"] = "SHUD:ArcHudRight",
	["Arc Hud Top"] = "SHUD:ArcHudTop",
	["Arc Hud Bot"] = "SHUD:ArcHudBot",
}

local orientation = {
	vertical = "vertical",
	horizontal = "horizontal",
}

local barType = {
	["Player Health"] = {
		max = function()
			return GameLib.GetPlayerUnit():GetMaxHealth() 
		end,
		current = function() 
			return GameLib.GetPlayerUnit():GetHealth()
	 	end,
	},
	["Player Shield"] = {
		max = function()
			return GameLib.GetPlayerUnit():GetShieldCapacityMax() 
		end,
		current = function() 
			return GameLib.GetPlayerUnit():GetShieldCapacity()
	 	end,
	},
	["Player Absorb"] = {
		max = function()
			return GameLib.GetPlayerUnit():GetAbsorptionMax() 
		end,
		current = function() 
			return GameLib.GetPlayerUnit():GetAbsorptionValue()
	 	end,
	},
	["Player Shield & Absorb"] = {
		max = function()
			return (GameLib.GetPlayerUnit():GetShieldCapacityMax() + GameLib.GetPlayerUnit():GetAbsorptionMax())
		end,
		current = function() 
			return (GameLib.GetPlayerUnit():GetShieldCapacity() + GameLib.GetPlayerUnit():GetAbsorptionValue())
	 	end,
	},
	["Player 'Mana'"] = {
		max = function()
			return (GameLib.GetPlayerUnit():GetMaxMana())
		end,
		current = function() 
			return (GameLib.GetPlayerUnit():GetMana())
	 	end,
	},
	["Player Resource"] = {
		max = function()
			if GameLib.GetPlayerUnit():GetClassId() == GameLib.CodeEnumClass.Stalker then
				return GameLib.GetPlayerUnit():GetMaxResource(4)
			else
				return (GameLib.GetPlayerUnit():GetMaxResource(1))
			end
		end,
		current = function()
			if GameLib.GetPlayerUnit():GetClassId() == GameLib.CodeEnumClass.Stalker then
				return GameLib.GetPlayerUnit():GetResource(4)
			else 
				return (GameLib.GetPlayerUnit():GetResource(1))
			end
	 	end,
	},
	["Player Sprint"] = {
		max = function()
			return (GameLib.GetPlayerUnit():GetMaxResource(0))
		end,
		current = function() 
			return (GameLib.GetPlayerUnit():GetResource(0))
	 	end,
	},	
	["Target Health"] = {
		max = function()
			if GameLib.GetTargetUnit() then
				if GameLib.GetTargetUnit():GetMaxHealth() then
					return (GameLib.GetTargetUnit():GetMaxHealth())
				else
					return 0
				end
			else
				return 0
			end
		end,
		current = function() 
			if GameLib.GetTargetUnit() then
				if GameLib.GetTargetUnit():GetHealth() then
					return (GameLib.GetTargetUnit():GetHealth())
				else
					return 0
				end
			else
				return 0
			end
	 	end,
	},
	["Target Shield"] = {
		max = function()
			if GameLib.GetTargetUnit() then
				if GameLib.GetTargetUnit():GetShieldCapacityMax() then
					return (GameLib.GetTargetUnit():GetShieldCapacityMax())
				else
					return 0
				end

			else
				return 0
			end
		end,
		current = function() 
			if GameLib.GetTargetUnit() then
				if GameLib.GetTargetUnit():GetShieldCapacity() then
					return (GameLib.GetTargetUnit():GetShieldCapacity())
				else
					return 0
				end
			else
				return 0
			end
	 	end,
	},
	["Target Shield & Absorb"] = {
		max = function()
			if GameLib.GetTargetUnit() then
				if GameLib.GetTargetUnit():GetAbsorptionMax() then
					return (GameLib.GetTargetUnit():GetAbsorptionMax())
				else
					return 0
				end

			else
				return 0
			end
		end,
		current = function() 
			if GameLib.GetTargetUnit() then
				if GameLib.GetTargetUnit():GetAbsorptionValue() then
					return (GameLib.GetTargetUnit():GetAbsorptionValue())
				else
					return 0
				end
			else
				return 0
			end
	 	end,
	},
	["Target Shield & Absorb"] = {
		max = function()
			if GameLib.GetTargetUnit() then
				if GameLib.GetTargetUnit():GetAbsorptionValue() then
					return (GameLib.GetTargetUnit():GetShieldCapacityMax() + GameLib.GetTargetUnit():GetAbsorptionMax())
				else
					return 0
				end
			else
				return 0
			end
		end,
		current = function() 
			if GameLib.GetTargetUnit() then
				if GameLib.GetTargetUnit():GetAbsorptionValue() then
					return (GameLib.GetTargetUnit():GetShieldCapacity() + GameLib.GetTargetUnit():GetAbsorptionValue())
				else
					return 0
				end
			else
				return 0
			end
	 	end,
	},	
}

local archudtheme = {{textY=77,BGTexture="Arc Hud Left",textAsPercentage=false,emptyColour="ff606060",texture="Arc Hud Left",textX=-6,height=150,showText=true,textCol="ff02ff00",borderWidth=0,width=75,y=35,x=-65,name="Health",fullColour="ff3cff23",orientation="vertical",barType="Player Health",fullHide=false,emptyHide=false},
					 {textY=60,BGTexture="Arc Hud Left",textAsPercentage=false,emptyColour="ff606060",texture="Arc Hud Left",textX=26,height=150,showText=true,textCol="ff23fff8",borderWidth=0,width=75,y=35,x=-55,name="Shield",fullColour="ff23ffee",orientation="vertical",barType="Player Shield & Absorb",fullHide=false,emptyHide=true},
					 {textY=-83,BGTexture="Arc Hud Left",textAsPercentage=false,emptyColour="ff606060",texture="Arc Hud Left",textX=18,height=150,showText=true,textCol="ffff23f2",borderWidth=0,width=75,y=35,x=-75,name="Mana",fullColour="ffff23f2",orientation="vertical",barType="Player 'Mana'",fullHide=true,emptyHide=false},
					 {textY=0,BGTexture="Arc Hud Left",textAsPercentage=false,emptyColour="ff606060",texture="Arc Hud Left",textX=-45,height=150,showText=true,textCol="ffff8223",borderWidth=0,width=75,y=35,x=-85,name="Resource",fullColour="ffff8223",orientation="vertical",barType="Player Resource",fullHide=true,emptyHide=true},
					 {textY=-28,BGTexture="Arc Hud Top",textAsPercentage=true,emptyColour="ff606060",texture="Arc Hud Top",textX=0,height=40,showText=true,textCol="ffffffff",borderWidth=0,width=132,y=-20,x=0,name="Sprint",fullColour="ffffffff",orientation="horizontal",barType="Player Sprint",fullHide=true,emptyHide=false},
 					 {textY=77,BGTexture="Arc Hud Right",textAsPercentage=false,emptyColour="ff606060",texture="Arc Hud Right",textX=0,height=150,showText=true,textCol="ff02ff00",borderWidth=0,width=75,y=35,x=65,name="Target Health",fullColour="ff3cff23",orientation="vertical",barType="Target Health",fullHide=false,emptyHide=true},
					 {textY=60,BGTexture="Arc Hud Right",textAsPercentage=false,emptyColour="ff606060",texture="Arc Hud Right",textX=-24,height=150,showText=true,textCol="ff23fff8",borderWidth=0,width=75,y=35,x=55,name="Target Shield",fullColour="ff23ffee",orientation="vertical",barType="Target Shield & Absorb",fullHide=false,emptyHide=true},}

local function ColorToString(c)
	return string.format("%02x%02x%02x%02x", math.floor(c.a * 255 + 0.5), math.floor(c.r * 255 + 0.5), math.floor(c.g * 255 + 0.5), math.floor(c.b * 255 + 0.5))
end

local function StringToColor(s)
	local a = tonumber(string.sub(s,1,2), 16)
	local r = tonumber(string.sub(s,3,4), 16)
	local g = tonumber(string.sub(s,5,6), 16)
	local b = tonumber(string.sub(s,7,8), 16)
	return CColor.new(r / 255, g / 255, b / 255, a / 255)
end

local function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end

local savedBarData = nil

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Serenity_HUD:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
	self.barList = {}
	self.col = nil

    return o
end

function Serenity_HUD:Init()
	local bHasConfigureFunction = true
	local strConfigureButtonText = "Serenity_HUD"
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

function Serenity_HUD:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end
	
	local tSavedData = {}

	tSavedData.savedBars = self:GetSavedBarList()
	tSavedData.version = version
	
	return tSavedData
end

function Serenity_HUD:OnRestore(eType, tSavedData)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end
	
	if tSavedData ~= nil then
		if tSavedData.version ~= version then return end
		
		savedBarData = tSavedData.savedBars
	end
end

function Serenity_HUD:GetSavedBarList()
	local bars = {}
	for i, v in pairs(self.barList) do
		local bData = self:GenerateDetailsArray(v)
		table.insert(bars, bData)
	end
	if (#bars > 0) then
		return bars
	else
		return nil
	end
end


function Serenity_HUD:GenerateDetailsArray(bar)
	return {
		name = bar.name, -- 1
		barType = self:GetBarTypeNameFromObject(bar.dataObject), -- 2
		texture = self:GetTextureNameFromTextureValue(bar.texture), -- 3
		BGTexture = self:GetTextureNameFromBGTextureValue(bar.BGTexture),
		fullColour = bar.fullColour, -- 4
		emptyColour = bar.emptyColour, -- 5
		orientation = bar.orientation,
		emptyHide = bar.emptyHide, -- 6
		fullHide = bar.fullHide, -- 7
		width = bar.width, -- 8
		height = bar.height, -- 9
		x = bar.x, -- 10
		y = bar.y, -- 11
		borderWidth = bar.borderWidth,
		showText = bar.showText, -- 12
		textX = bar.textX, -- 13
		textY = bar.textY, -- 14
		textCol = bar.textCol, -- 15
		textAsPercentage = bar.textAsPercentage, -- 16
	}
end

-----------------------------------------------------------------------------------------------
-- Serenity_HUD OnLoad
-----------------------------------------------------------------------------------------------
function Serenity_HUD:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Serenity_HUD.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Serenity_HUD OnDocLoaded
-----------------------------------------------------------------------------------------------
function Serenity_HUD:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
		Apollo.LoadSprites("SHUD.xml", "SHUD")
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "Serenity_HUDForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)
		self.listItem = self.wndMain:FindChild("BarListDisp")
		self.display = self.wndMain:FindChild("DataDisplay")
		
		-- example bar setup
		local exampleBar = self.wndMain:FindChild("ExampleBar")
		exampleBar:SetMax(50)
		exampleBar:SetProgress(0)
		exampleBar:SetData(0)
	
		-- combo boxes
		local types = self.wndMain:FindChild("Resources")
		types:DestroyChildren()
		for i, v in pairsByKeys(barType) do
			local item = Apollo.LoadForm(self.xmlDoc, "DetailListItem", types, self)
			item:FindChild("DetailName"):SetText(i)
		end
		types:ArrangeChildrenVert()
		local texts = self.wndMain:FindChild("Textures")
		texts:DestroyChildren()
		for i, v in pairsByKeys(textures) do
			local item = Apollo.LoadForm(self.xmlDoc, "DetailListItem", texts, self)
			item:FindChild("DetailName"):SetText(i)
		end
		texts:ArrangeChildrenVert()
		local bgTexts = self.wndMain:FindChild("BGTextures")
		bgTexts:DestroyChildren()
		for i, v in pairsByKeys(BGTextures) do
			local item = Apollo.LoadForm(self.xmlDoc, "DetailListItem", bgTexts, self)
			item:FindChild("DetailName"):SetText(i)
		end
		bgTexts:ArrangeChildrenVert()


		
		self:InitialiseBars()

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("shud", "OnSerenity_HUDOn", self)
		Apollo.RegisterSlashCommand("SHUD", "OnSerenity_HUDOn", self)
		Apollo.RegisterEventHandler("Serenity_HUD_Config", "OnSerenity_HUDOn", self)
		Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
		Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)

		-- Do additional Addon initialization here
		self.refreshTimer = ApolloTimer.Create(0.200, true, "OnPreviewRefresh", self)
		self.refreshTimer:Start()
		
		self.BarRefrehser = ApolloTimer.Create(0.100, true, "OnRefreshBars", self)
		self.BarRefrehser:Start()
	end
end

-----------------------------------------------------------------------------------------------
-- Serenity_HUD Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function Serenity_HUD:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "Serenity_HUD", {"Serenity_HUD_Config", "", ""})
end

function Serenity_HUD:OnWindowManagementReady()
	--Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndMain, strName = "Serenity_HUD"})
end

function Serenity_HUD:CreateBarsFromList(list)
	self.barList = {}
	for i, v in pairs(list) do
		self:CreateNewBar(v)
	end
end

function Serenity_HUD:InitialiseBars()
	if (savedBarData) then
		self:CreateBarsFromList(savedBarData)
		savedBarData = nil
	end
	
	if (#self.barList == 0) then
		self:CreateBarsFromList(archudtheme)
	end
end

function Serenity_HUD:OnConfigure()
	self:OnSerenity_HUDOn()
end

function Serenity_HUD:OnSerenity_HUDOn()
	self.wndMain:Invoke()
end

function Serenity_HUD:OnPreviewRefresh()
	local exampleBar = self.wndMain:FindChild("ExampleBar")
	exampleBar:SetData(exampleBar:GetData() + 1)
	if (exampleBar:GetData() > 50) then
		exampleBar:SetData(0)
	end
	
	exampleBar:SetProgress(exampleBar:GetData())
end

function Serenity_HUD:OnRefreshBars()
	if GameLib.GetPlayerUnit() then
		for i, v in pairs(self.barList) do
			v:Refresh()
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Serenity_HUDForm Functions
-----------------------------------------------------------------------------------------------

function Serenity_HUD:AddNewBar( wndHandler, wndControl, eMouseButton)	
	self:CreateNewBar()
	
	self:ResetListItems()
	self:resetDisplay()
end

function Serenity_HUD:CreateNewBar(params)
	local newBar = SHudBar:new()
	newBar:Init(self, params)
	
	table.insert(self.barList, newBar)
	
	self.listItem:SetData(self.barList[#self.barList])
end

function Serenity_HUD:OnOptionsShow( wndHandler, wndControl )	
	if (#self.barList > 0) then
		self:ResetListItems()		
		self:resetDisplay()
	end
end

function Serenity_HUD:OnOptionsClosed( wndHandler, wndControl )

end

function Serenity_HUD:ResetListItems()
	if not self.wndMain:IsVisible() then return end
	self.listItem:DestroyChildren()
			
	if (self.listItem:GetData() == nil) then
		self.listItem:SetData(self.barList[1])
	end
	for i, v in pairs(self.barList) do
		local bar = Apollo.LoadForm(self.xmlDoc, "BarListItem", self.listItem, self)
		bar:SetData(v)
		bar:FindChild("BarName"):SetText(v.name)
		if v == self.listItem:GetData() then
			bar:SetBGColor(ApolloColor.new("ff00ff00"))
		end
	end
	
	self.listItem:ArrangeChildrenVert()
end

function Serenity_HUD:resetDisplay()
	local currentBar = self.listItem:GetData()
	if currentBar == nil then self.display:Show(false) return end
	self.display:Show(true)
	self.display:FindChild("EditName"):SetText(currentBar.name)
		
	self.display:FindChild("FullColour"):SetBGColor(ApolloColor.new(currentBar.fullColour))
	self.display:FindChild("EmptyColour"):SetBGColor(ApolloColor.new(currentBar.emptyColour))
	
	self.display:FindChild("HeightVal"):SetText(currentBar.height)
	self.display:FindChild("WidthVal"):SetText(currentBar.width)
	self.display:FindChild("XVal"):SetText(currentBar.x)
	self.display:FindChild("YVal"):SetText(currentBar.y)
	
	self.display:FindChild("ShowBTN"):SetCheck(currentBar.showText)
	self.display:FindChild("TextColour"):SetBGColor(currentBar.textCol)
	self.display:FindChild("TXVal"):SetText(currentBar.textX)
	self.display:FindChild("TYVal"):SetText(currentBar.textY)
	
	self.display:FindChild("EmptyHide"):SetCheck(currentBar.emptyHide)
	self.display:FindChild("FullHide"):SetCheck(currentBar.fullHide)
	self.display:FindChild("TextPercentage"):SetCheck(currentBar.textAsPercentage)
	self.display:FindChild("BorderWidthVal"):SetText(currentBar.borderWidth)	
	
	self.display:FindChild("ExampleBar"):SetEmptySprite("")
	self.display:FindChild("TexSprite"):SetSprite(currentBar.BGTexture)
	self.display:FindChild("ExampleBar"):SetFullSprite(currentBar.texture)
	self.display:FindChild("ExampleBar"):SetFullSprite(currentBar.texture)
	if currentBar.orientation == orientation.horizontal then
		self.display:FindChild("ExampleBar"):SetStyleEx("VerticallyAligned", false)
		self.display:FindChild("ExampleBar"):SetStyleEx("BRtoLT", false)
	else
		self.display:FindChild("ExampleBar"):SetStyleEx("VerticallyAligned", true)
		self.display:FindChild("ExampleBar"):SetStyleEx("BRtoLT", true)
	end
	self.display:FindChild("ExampleBar"):SetBarColor(currentBar.fullColour)
	self.display:FindChild("TexSprite"):SetBGColor(currentBar.emptyColour)
	self.display:FindChild("ExampleBar"):SetAnchorOffsets(currentBar.borderWidth, currentBar.borderWidth, -currentBar.borderWidth, -currentBar.borderWidth)

	self.display:FindChild("ResourceLbl"):SetText("Resource: " .. self:GetBarTypeNameFromObject(currentBar.dataObject))
	for i, v in pairs(self.display:FindChild("Resources"):GetChildren()) do
		if v:FindChild("DetailName"):GetText() == self:GetBarTypeNameFromObject(currentBar.dataObject) then
			v:SetBGColor("ff00ff00")
		else
			v:SetBGColor("ffffffff")
		end
	end
	
	self.display:FindChild("TextureLbl"):SetText("Texture: " .. self:GetTextureNameFromTextureValue(currentBar.texture))
	for i, v in pairs(self.display:FindChild("Textures"):GetChildren()) do
		if v:FindChild("DetailName"):GetText() == self:GetTextureNameFromTextureValue(currentBar.texture) then
			v:SetBGColor("ff00ff00")
		else
			v:SetBGColor("ffffffff")
		end
	end
	
	self.display:FindChild("BGTextureLbl"):SetText("Border: " .. self:GetTextureNameFromBGTextureValue(currentBar.BGTexture))
	for i, v in pairs(self.display:FindChild("BGTextures"):GetChildren()) do
		if v:FindChild("DetailName"):GetText() == self:GetTextureNameFromBGTextureValue(currentBar.BGTexture) then
			v:SetBGColor("ff00ff00")
		else
			v:SetBGColor("ffffffff")
		end
	end
end

function Serenity_HUD:GetBarTypeNameFromObject(object)
	for i, v in pairs(barType) do
		if v == object then
			return i
		end
	end
	return nil
end

function Serenity_HUD:GetTextureNameFromBGTextureValue(value)
	for i, v in pairs(BGTextures) do
		if v == value then
			return i
		end
	end
	return nil
end

function Serenity_HUD:GetTextureNameFromTextureValue(value)
	for i, v in pairs(textures) do
		if v == value then
			return i
		end
	end
	return nil
end


function Serenity_HUD:UserChangedBarName( wndHandler, wndControl, strText )
	self.listItem:GetData():SetName(wndHandler:GetText())
	self:ResetListItems()
end

function Serenity_HUD:LaunchColorPicker(element)
	colorPickerColor = nil
	
	if element == "FullColour" then
		colorPickerColor = StringToColor(self.listItem:GetData().fullColour)
	elseif element == "EmptyColour" then
		colorPickerColor = StringToColor(self.listItem:GetData().emptyColour)
	elseif element == "TextColour" then
		colorPickerColor = StringToColor(self.listItem:GetData().textCol)
	end
	
	colorPickerSetting = element
	if ColorPicker then ColorPicker.AdjustCColor(colorPickerColor, true, self.OnColorUpdate) end
end

function Serenity_HUD:OnColourClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
	self:LaunchColorPicker(wndControl:GetName())
end

function Serenity_HUD:OnColorUpdate()
	if colorPickerSetting ~= nil and colorPickerColor ~= nil then
		if (colorPickerSetting == "FullColour") then
			SHUDOBJ.listItem:GetData().fullColour = ColorToString(colorPickerColor)
			SHUDOBJ.display:FindChild("ExampleBar"):SetBarColor(ColorToString(colorPickerColor))
		elseif (colorPickerSetting == "EmptyColour") then
			SHUDOBJ.listItem:GetData().emptyColour = ColorToString(colorPickerColor)
			SHUDOBJ.display:FindChild("TexSprite"):SetBGColor(ColorToString(colorPickerColor))
		elseif (colorPickerSetting == "TextColour") then
			SHUDOBJ.listItem:GetData().textCol = ColorToString(colorPickerColor)
		end
		SHUDOBJ.display:FindChild(colorPickerSetting):SetBGColor(ColorToString(colorPickerColor))
	end
end

function Serenity_HUD:OnValChangeButtonDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	local bar = self.listItem:GetData()
	if (wndHandler:GetName() == "WDec") then
		bar.width = bar.width - 2
		self.display:FindChild("WidthVal"):SetText(bar.width)
	elseif (wndHandler:GetName() == "WInc") then
		bar.width = bar.width + 2
		self.display:FindChild("WidthVal"):SetText(bar.width)
	elseif (wndHandler:GetName() == "HInc") then
		bar.height = bar.height + 2
		self.display:FindChild("HeightVal"):SetText(bar.height)
	elseif (wndHandler:GetName() == "HDec") then
		bar.height = bar.height - 2
		self.display:FindChild("HeightVal"):SetText(bar.height)
	elseif (wndHandler:GetName() == "XInc") then
		bar.x = bar.x - 1
		self.display:FindChild("XVal"):SetText(bar.x)
	elseif (wndHandler:GetName() == "XDec") then
		bar.x = bar.x + 1
		self.display:FindChild("XVal"):SetText(bar.x)
	elseif (wndHandler:GetName() == "YDec") then
		bar.y = bar.y + 1
		self.display:FindChild("YVal"):SetText(bar.y)
	elseif (wndHandler:GetName() == "YInc") then
		bar.y = bar.y - 1
		self.display:FindChild("YVal"):SetText(bar.y)
	elseif (wndHandler:GetName() == "TYInc") then
		bar.textY = bar.textY - 1
		self.display:FindChild("TYVal"):SetText(bar.textY)
	elseif (wndHandler:GetName() == "TYDec") then
		bar.textY = bar.textY + 1
		self.display:FindChild("TYVal"):SetText(bar.textY)
	elseif (wndHandler:GetName() == "TXInc") then
		bar.textX = bar.textX - 1
		self.display:FindChild("TXVal"):SetText(bar.textX)
	elseif (wndHandler:GetName() == "TXDec") then
		bar.textX = bar.textX + 1
		self.display:FindChild("TXVal"):SetText(bar.textX)
	elseif (wndHandler:GetName() == "BWInc") then
		bar.borderWidth = bar.borderWidth - 1
		self.display:FindChild("BorderWidthVal"):SetText(bar.borderWidth)
		self:resetDisplay()
	elseif (wndHandler:GetName() == "BWDec") then
		bar.borderWidth = bar.borderWidth + 1
		self.display:FindChild("BorderWidthVal"):SetText(bar.borderWidth)
		self:resetDisplay()
	end
end

function Serenity_HUD:OnMouseWheelMove( wndHandler, wndControl, nLastRelativeMouseX, nLastRelativeMouseY, fScrollAmount, bConsumeMouseWheel )
	local bar = self.listItem:GetData()
	if (wndHandler:GetName() == "WidthVal") then
		bar.width = bar.width + 2 * math.floor(fScrollAmount)
		self.display:FindChild("WidthVal"):SetText(bar.width)
	elseif (wndHandler:GetName() == "HeightVal") then
		bar.height = bar.height + 2 * math.floor(fScrollAmount)
		self.display:FindChild("HeightVal"):SetText(bar.height)
	elseif (wndHandler:GetName() == "XVal") then
		bar.x = bar.x + 1 * -math.floor(fScrollAmount)
		self.display:FindChild("XVal"):SetText(bar.x)
	elseif (wndHandler:GetName() == "YVal") then
		bar.y = bar.y + 1 * -math.floor(fScrollAmount)
		self.display:FindChild("YVal"):SetText(bar.y)
	elseif (wndHandler:GetName() == "TXVal") then
		bar.textX = bar.textX + 1 * -math.floor(fScrollAmount)
		self.display:FindChild("TXVal"):SetText(bar.textX)
	elseif (wndHandler:GetName() == "TYVal") then
		bar.textY = bar.textY + 1 * -math.floor(fScrollAmount)
		self.display:FindChild("TYVal"):SetText(bar.textY)
	elseif (wndHandler:GetName() == "BorderWidthVal") then
		bar.borderWidth = bar.borderWidth + 1 * -math.floor(fScrollAmount)
		self.display:FindChild("BorderWidthVal"):SetText(bar.borderWidth)
		self:resetDisplay()
	end
	return true
end

function Serenity_HUD:GetIndexOfBarItem(bar)
	for i, v in pairs(self.barList) do
		if v == bar then
			return i
		end
	end
	return 0
end

function Serenity_HUD:OnDeletePressed( wndHandler, wndControl, eMouseButton )
	if self.listItem:GetData() then
		table.remove(self.barList, self:GetIndexOfBarItem(self.listItem:GetData()))
		self.listItem:GetData():Destroy()
		self.listItem:SetData(nil)
	end
	self:ResetListItems()
	self:resetDisplay()
end

function Serenity_HUD:OnCopyBarclicked( wndHandler, wndControl, eMouseButton )
	if self.listItem:GetData() then
		self:CreateNewBar(self:GenerateDetailsArray(self.listItem:GetData()))
	end
	
	self:ResetListItems()
	self:resetDisplay()
end

function Serenity_HUD:OnTextShowChecked( wndHandler, wndControl, eMouseButton )
	if (wndHandler:GetName() == "ShowBTN") then
		self.listItem:GetData().showText = true
	elseif (wndHandler:GetName() == "EmptyHide") then
		self.listItem:GetData().emptyHide = true
	elseif (wndHandler:GetName() == "FullHide") then
		self.listItem:GetData().fullHide = true
	elseif (wndHandler:GetName() == "TextPercentage") then
		self.listItem:GetData().textAsPercentage = true
	elseif (wndHandler:GetName() == "HorizontalBar") then
		self.listItem:GetData().orientation = orientation.horizontal
		self:resetDisplay()
	end
end

function Serenity_HUD:OnTextShowUnChecked( wndHandler, wndControl, eMouseButton )
	if (wndHandler:GetName() == "ShowBTN") then
		self.listItem:GetData().showText = false
	elseif (wndHandler:GetName() == "EmptyHide") then
		self.listItem:GetData().emptyHide = false
	elseif (wndHandler:GetName() == "FullHide") then
		self.listItem:GetData().fullHide = false
	elseif (wndHandler:GetName() == "TextPercentage") then
		self.listItem:GetData().textAsPercentage = false
	elseif (wndHandler:GetName() == "HorizontalBar") then
		self.listItem:GetData().orientation = orientation.vertical
		self:resetDisplay()
	end
end

function Serenity_HUD:OnNumberBoxChange( wndHandler, wndControl, strText )
	local bar = self.listItem:GetData()
	local num = nil
	if strText == "" then
		num = 0
	else
		num = tonumber(strText)
	end
	if num == nil then return end
	if wndHandler:GetName() == "WidthVal" then
		bar.width = num
	elseif wndHandler:GetName() == "HeightVal" then
		bar.height = num
	elseif wndHandler:GetName() == "XVal" then
		bar.x = num
	elseif wndHandler:GetName() == "YVal" then
		bar.y = num
	elseif wndHandler:GetName() == "TXVal" then
		bar.textX = num
	elseif wndHandler:GetName() == "TYVal" then
		bar.textY = num
	elseif wndHandler:GetName() == "BorderWidthVal" then
		bar.borderWidth = num
	end
end

---------------------------------------------------------------------------------------------------
-- BarListItem Functions
---------------------------------------------------------------------------------------------------

function Serenity_HUD:OnBarListItemClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
	self.listItem:SetData(wndHandler:GetData())
	self:ResetListItems()
	self:resetDisplay()
end

function Serenity_HUD:DetailListItemClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
	local bar = self.listItem:GetData()
	if (wndHandler:GetParent():GetName() == "Resources") then
		bar:SetResource(wndHandler:FindChild("DetailName"):GetText())
	elseif (wndHandler:GetParent():GetName() == "Textures") then
		bar:SetTexture(wndHandler:FindChild("DetailName"):GetText())
	elseif (wndHandler:GetParent():GetName() == "BGTextures") then
		bar:SetBGTexture(wndHandler:FindChild("DetailName"):GetText())
	end
	self:ResetListItems()
	self:resetDisplay()
end

-----------------------------------------------------------------------------------------------
-- SHUD bar
-----------------------------------------------------------------------------------------------

function SHudBar:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function SHudBar:Init(parent, params)
	self.par = parent;
	self.frame = Apollo.LoadForm(self.par.xmlDoc, "Bar", nil, self)
	self.bar = self.frame:FindChild("BarTex")
	self.text = self.frame:FindChild("Text")
	self.bg = self.frame:FindChild("Border")
	
	if params then
		self.name = params.name
		self.dataObject = barType[params.barType]
		self.texture = textures[params.texture]
		self.BGTexture = BGTextures[params.BGTexture]
		self.fullColour = params.fullColour
		self.emptyColour = params.emptyColour
		self.orientation = params.orientation
		self.emptyHide = params.emptyHide
		self.fullHide = params.fullHide
		self.width = params.width
		self.height = params.height
		self.x = params.x
		self.y = params.y
		self.borderWidth = params.borderWidth
		self.showText = params.showText
		self.textX = params.textX
		self.textY = params.textY
		self.textCol = params.textCol
		self.textAsPercentage = params.textAsPercentage
	else
		self.name = "Bar" .. (#parent.barList + 1)
		self.dataObject = barType["Player Health"]
		self.texture = textures["Comity Vertical"]
		self.BGTexture = BGTextures["Gloss"]
		self.fullColour = "ff00ff00"
		self.emptyColour = "55ffffff"
		self.orientation = orientation.vertical
		self.emptyHide = false
		self.fullHide = false
		self.width = 30
		self.height = 100
		self.x = 0
		self.y = 0
		self.borderWidth = 1
		self.showText = false
		self.textX = 0
		self.textY = 0
		self.textCol = "ffffffff"
		self.textAsPercentage = false
	end	
end

function SHudBar:Refresh()
	self.bar:SetEmptySprite("")
	self.bar:SetFullSprite(self.texture)	
	if self.orientation == orientation.horizontal then
		self.bar:SetStyleEx("VerticallyAligned", false)
		self.bar:SetStyleEx("BRtoLT", false)
	else
		self.bar:SetStyleEx("VerticallyAligned", true)
		self.bar:SetStyleEx("BRtoLT", true)
	end
			
	self.bg:SetSprite(self.BGTexture)
	self.bg:SetBGColor(ApolloColor.new(self.emptyColour))
	self.bar:SetBarColor(ApolloColor.new(self.fullColour))
	self.bar:SetMax(self.dataObject.max())
	self.bar:SetProgress(self.dataObject.current())
	
	self.bar:SetAnchorOffsets(self.borderWidth, self.borderWidth, -self.borderWidth, -self.borderWidth)
	
	self.text:Show(self.showText)
	self.text:SetTextColor(self.textCol)
	
	if self.textAsPercentage then
		local perc = self.dataObject.current() / self.dataObject.max() * 100
		self.text:SetText(string.format("%.0f%%", perc))
	elseif self.dataObject.current() >= 1000 then
		self.text:SetText(string.format("%.1fK", self.dataObject.current()/1000))
	else
		self.text:SetText(string.format("%.0f", self.dataObject.current()))
	end

	if (not self.par.wndMain:IsVisible()) and ((self.emptyHide and self.dataObject.current() <= 0) or (self.fullHide and self.dataObject.current() == self.dataObject.max())) then
		self.frame:Show(false)
	else
		self.frame:Show(true)
	end
	
	self.frame:SetAnchorOffsets(self.x - self.width/2, self.y - self.height/2, self.x + self.width/2, self.y + self.height/2)
	self.text:SetAnchorOffsets(self.textX - 50, self.textY - 10, self.textX + 50, self.textY + 10)
end

function SHudBar:Destroy()
	self.frame:Destroy()
end

function SHudBar:SetResource(type)
	self.dataObject = barType[type]
end

function SHudBar:SetName(name)
	self.name = name
end

function SHudBar:SetTexture(textureName)
	self.texture = textures[textureName]
end

function SHudBar:SetBGTexture(textureName)
	self.BGTexture = BGTextures[textureName]
end

-----------------------------------------------------------------------------------------------
-- Serenity_HUD Instance
-----------------------------------------------------------------------------------------------
local Serenity_HUDInst = Serenity_HUD:new()
Serenity_HUDInst:Init()
SHUDOBJ = Serenity_HUDInst