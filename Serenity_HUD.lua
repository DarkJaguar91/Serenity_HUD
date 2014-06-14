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
local textures = {
	["Plain"] = "SHUD:plain",
	["Cracked Glass"] = "SHUD:CrackedGlass",
	["Tempered Glass"] = "SHUD:TemperedGlass",
	["Marble"] = "SHUD:Marble",
	["Scratched Glass"] = "SHUD:ScratchedGlass",
	["Glass Waves"] = "SHUD:GlassWaives",
	["Flames"] = "SHUD:Flames",
	["Ice"] = "SHUD:Ice",
	["Water Verticle"] = "SHUD:Water",
	["Water Horizontal"] = "SHUD:HorizontalWater",
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
	["player Shield&Absorb"] = {
		max = function()
			return (GameLib.GetPlayerUnit():GetShieldCapacityMax() + GameLib.GetPlayerUnit():GetShieldCapacityMax())
		end,
		current = function() 
			return (GameLib.GetPlayerUnit():GetShieldCapacity() + GameLib.GetPlayerUnit():GetShieldCapacity())
	 	end,
	},


}

local savedBars = {}

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
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
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
		types:DeleteAll()
		for i, v in pairs(barType) do
			types:AddItem(i)
		end
		local texts = self.wndMain:FindChild("Textures")
		texts:DeleteAll()
		for i, v in pairs(textures) do
			texts:AddItem(i)
		end

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("shud", "OnSerenity_HUDOn", self)
		Apollo.RegisterSlashCommand("SHUD", "OnSerenity_HUDOn", self)

		-- Do additional Addon initialization here
		self.refreshTimer = ApolloTimer.Create(0.100, true, "OnPreviewRefresh", self)
		self.refreshTimer:Start()
		
		self.BarRefrehser = ApolloTimer.Create(0.027, true, "OnRefreshBars", self)
		self.BarRefrehser:Start()
	end
end

-----------------------------------------------------------------------------------------------
-- Serenity_HUD Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

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
	for i, v in pairs(self.barList) do
		v:Refresh()
	end
end

-----------------------------------------------------------------------------------------------
-- Serenity_HUDForm Functions
-----------------------------------------------------------------------------------------------

function Serenity_HUD:AddNewBar( wndHandler, wndControl, eMouseButton )	
	local newBar = SHudBar:new()
	newBar:Init(self)
	
	table.insert(self.barList, newBar)
	
	self.listItem:SetData(self.barList[#self.barList])
	self:ResetListItems()
	self:resetDisplay()
end

function Serenity_HUD:OnOptionsShow( wndHandler, wndControl )	
	if (#self.barList > 0) then
		self:ResetListItems()
		
		if (self.listItem:GetData() == nil) then
			self.listItem:SetData(self.barList[1])
		end
		
		self:resetDisplay()
	end
end

function Serenity_HUD:OnOptionsClosed( wndHandler, wndControl )

end

function Serenity_HUD:ResetListItems()
	self.listItem:DestroyChildren()

	for i, v in pairs(self.barList) do
		local bar = Apollo.LoadForm(self.xmlDoc, "BarListItem", self.listItem, self)
		bar:SetData(v)
		bar:FindChild("BarName"):SetText(v.name)
		if v == self.listItem:GetData() then
			bar:SetBGColor(ApolloColor.new("ff5555ff"))
		end
	end
	
	self.listItem:ArrangeChildrenVert()
end

function Serenity_HUD:resetDisplay()
	self.display:Show(true)
	
	local currentBar = self.listItem:GetData()
	self.display:FindChild("EditName"):SetText(currentBar.name)
	self.display:FindChild("Resources"):SelectItemByText(self:GetBarTypeNameFromObject(currentBar.dataObject))
	self.display:FindChild("Textures"):SelectItemByText(self:GetTextureNameFromTextureValue(currentBar.texture))
	self.display:FindChild("FullColour"):SetBGColor(ApolloColor.new(currentBar.fullColour))
	self.display:FindChild("EmptyColour"):SetBGColor(ApolloColor.new(currentBar.emptyColour))
	self.display:FindChild("HeightVal"):SetText(currentBar.height)
	self.display:FindChild("WidthVal"):SetText(currentBar.width)

	self.display:FindChild("ExampleBar"):SetEmptySprite(currentBar.texture)
	self.display:FindChild("ExampleBar"):SetFullSprite(currentBar.texture)
	self.display:FindChild("ExampleBar"):SetBarColor(currentBar.fullColour)
	self.display:FindChild("ExampleBar"):SetBGColor(currentBar.emptyColour)	
end

function Serenity_HUD:ResourceChanged( wndHandler, wndControl )
	self.listItem:GetData():SetResource(wndHandler:GetSelectedText())
end

function Serenity_HUD:GetBarTypeNameFromObject(object)
	for i, v in pairs(barType) do
		if v == object then
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

function Serenity_HUD:OnTextureChosen( wndHandler, wndControl )
	self.listItem:GetData():SetTexture(wndHandler:GetSelectedText())
	self:resetDisplay()
end

function Serenity_HUD:LaunchColorPicker(element)
	colorPickerColor = nil
	
	if element == "FullColour" then
		colorPickerColor = StringToColor(self.listItem:GetData().fullColour)
	elseif element == "EmptyColour" then
		colorPickerColor = StringToColor(self.listItem:GetData().emptyColour)
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
			SHUDOBJ.display:FindChild("ExampleBar"):SetBGColor(ColorToString(colorPickerColor))
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
		bar.x = bar.x + 1
		self.display:FindChild("XVal"):SetText(bar.height)
	elseif (wndHandler:GetName() == "HDec") then
		bar.x = bar.x - 1
		self.display:FindChild("XVal"):SetText(bar.height)
	elseif (wndHandler:GetName() == "YDec") then
		bar.y = bar.y - 1
		self.display:FindChild("YVal"):SetText(bar.height)
	elseif (wndHandler:GetName() == "YInc") then
		bar.y = bar.y + 1
		self.display:FindChild("YVal"):SetText(bar.height)
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
	end
	return true
end

---------------------------------------------------------------------------------------------------
-- BarListItem Functions
---------------------------------------------------------------------------------------------------

function Serenity_HUD:OnBarListItemClick( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
	self.listItem:SetData(wndHandler:GetData())
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
	self.name = "Bar" .. (#parent.barList + 1)
	self.frame = Apollo.LoadForm(self.par.xmlDoc, "Bar", nil, self)
	self.bar = self.frame:FindChild("BarTex")
	self.text = self.frame:FindChild("Text")
	self.dataObject = barType["Player Health"]
	self.texture = textures["Plain"]
	self.fullColour = "ff00ff00"
	self.emptyColour = "55ffffff"
	self.width = 30
	self.height = 100
	self.x = 0
	self.y = 0
		
	self.text:Show(false)
	
	if params then
		
	end	
end

function SHudBar:Refresh()
	self.bar:SetEmptySprite(self.texture)
	self.bar:SetFullSprite(self.texture)
	self.bar:SetBGColor(ApolloColor.new(self.emptyColour))
	self.bar:SetBarColor(ApolloColor.new(self.fullColour))
	self.bar:SetMax(self.dataObject.max())
	self.bar:SetProgress(self.dataObject.current())
	
	self.frame:SetAnchorOffsets(self.x - self.width/2, self.y - self.height/2, self.x + self.width/2, self.y + self.height/2)
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

-----------------------------------------------------------------------------------------------
-- Serenity_HUD Instance
-----------------------------------------------------------------------------------------------
local Serenity_HUDInst = Serenity_HUD:new()
Serenity_HUDInst:Init()
SHUDOBJ = Serenity_HUDInst