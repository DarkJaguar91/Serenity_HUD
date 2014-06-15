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
	["Player Shield & Absorb"] = {
		max = function()
			return (GameLib.GetPlayerUnit():GetShieldCapacityMax() + GameLib.GetPlayerUnit():GetShieldCapacityMax())
		end,
		current = function() 
			return (GameLib.GetPlayerUnit():GetShieldCapacity() + GameLib.GetPlayerUnit():GetShieldCapacity())
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
	
	return tSavedData
end

function Serenity_HUD:OnRestore(eType, tSavedData)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
		return
	end
	
	Print("Serenity_bags")
	
	if tSavedData ~= nil then
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
		bar.name,
		self:GetBarTypeNameFromObject(bar.dataObject),
		self:GetTextureNameFromTextureValue(bar.texture),
		bar.fullColour,
		bar.emptyColour,
		bar.width,
		bar.height,
		bar.x,
		bar.y,
		bar.showText,
		bar.textX,
		bar.textY,
		bar.textCol,
		bar.emptyHide,
		bar.fullHide,
		bar.textAsPercentage,
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
		types:DeleteAll()
		for i, v in pairs(barType) do
			types:AddItem(i)
		end
		local texts = self.wndMain:FindChild("Textures")
		texts:DeleteAll()
		for i, v in pairs(textures) do
			texts:AddItem(i)
		end
		
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
	Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndMain, strName = "Serenity_HUD"})
end


function Serenity_HUD:InitialiseBars()
	if (savedBarData) then
		self.barList = {}
		for i, v in pairs(savedBarData) do
			self:CreateNewBar(v)
		end
		savedBarData = nil
	end
	
	if (#self.barList == 0) then
		-- player bars
	 	self:CreateNewBar({"Player Health","Player Health","Water Horizontal","9a00ff00","80ffffff",20,170,-100,40,true,8,91,"ff25f200",false,false,false})
		self:CreateNewBar({"Player Shield","Player Shield & Absorb","Water Verticle","9a00ffd9","80ffffff",20,150,-80,30,true,8,81,"ff00ffd9",false,false,false})
		self:CreateNewBar({"Player 'Mana'","Player 'Mana'","Glass Waves","9aff00bc","80ffffff",20,170,-120,40,true,4,-92,"ffff00bc",false,true,false})
		self:CreateNewBar({"Player Resource","Player Resource","Marble","9aff4d00","80ffffff",20,170,-140,40,true,-1,-92,"ffff4d00",false,true,false})
		self:CreateNewBar({"Player Sprint","Player Sprint","Water Verticle","9affffff","667a6d6d",10,84,-65,-3,true,2,-48,"ffafafaf",false,true,true})
		-- target bars
		self:CreateNewBar({"Target Shield","Target Shield & Absorb","Water Horizontal","9a00ffd9","80ffffff",20,150,80,30,true,-8,81,"ff00ffd9",true,false,false})
		self:CreateNewBar({"Target Health","Target Health","Water Horizontal","9a00ff00","80ffffff",20,170,100,40,true,1,91,"ff25f200",true,false,false})		
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
			bar:SetBGColor(ApolloColor.new("ff5555ff"))
		end
	end
	
	self.listItem:ArrangeChildrenVert()
end

function Serenity_HUD:resetDisplay()
	local currentBar = self.listItem:GetData()
	if currentBar == nil then self.display:Show(false) return end
	self.display:Show(true)
	self.display:FindChild("EditName"):SetText(currentBar.name)
	self.display:FindChild("Resources"):SelectItemByText(self:GetBarTypeNameFromObject(currentBar.dataObject))
	self.display:FindChild("Textures"):SelectItemByText(self:GetTextureNameFromTextureValue(currentBar.texture))
	
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
			SHUDOBJ.display:FindChild("ExampleBar"):SetBGColor(ColorToString(colorPickerColor))
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
	
	if params then
		self.name = params[1]
		self.dataObject = barType[params[2]]
		self.texture = textures[params[3]]
		self.fullColour = params[4]
		self.emptyColour = params[5]
		self.width = params[6]
		self.height = params[7]
		self.x = params[8]
		self.y = params[9]
		self.showText = params[10]
		self.textX = params[11]
		self.textY = params[12]
		self.textCol = params[13]
		self.emptyHide = params[14]
		self.fullHide = params[15]
		self.textAsPercentage = params[16]
	else
		self.name = "Bar" .. (#parent.barList + 1)
		self.dataObject = barType["Player Health"]
		self.texture = textures["Plain"]
		self.fullColour = "ff00ff00"
		self.emptyColour = "55ffffff"
		self.width = 30
		self.height = 100
		self.x = 0
		self.y = 0
		self.showText = false
		self.textX = 0
		self.textY = 0
		self.textCol = "ffffffff"
		self.emptyHide = false
		self.fullHide = false
		self.textAsPercentage = false
	end	
end

function SHudBar:Refresh()
	self.bar:SetEmptySprite(self.texture)
	self.bar:SetFullSprite(self.texture)
	self.bar:SetBGColor(ApolloColor.new(self.emptyColour))
	self.bar:SetBarColor(ApolloColor.new(self.fullColour))
	self.bar:SetMax(self.dataObject.max())
	self.bar:SetProgress(self.dataObject.current())
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

-----------------------------------------------------------------------------------------------
-- Serenity_HUD Instance
-----------------------------------------------------------------------------------------------
local Serenity_HUDInst = Serenity_HUD:new()
Serenity_HUDInst:Init()
SHUDOBJ = Serenity_HUDInst