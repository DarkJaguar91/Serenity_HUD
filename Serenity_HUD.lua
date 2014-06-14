-----------------------------------------------------------------------------------------------
-- Client Lua Script for Serenity_HUD
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Serenity_HUD Module Definition
-----------------------------------------------------------------------------------------------
local Serenity_HUD = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local barList = {}
local savedBars = {}

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Serenity_HUD:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

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
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "Serenity_HUDForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("shud", "OnSerenity_HUDOn", self)
		Apollo.RegisterSlashCommand("SHUD", "OnSerenity_HUDOn", self)

		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- Serenity_HUD Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/shud"
function Serenity_HUD:OnSerenity_HUDOn()
	self.wndMain:Invoke()
end


-----------------------------------------------------------------------------------------------
-- Serenity_HUDForm Functions
-----------------------------------------------------------------------------------------------

function Serenity_HUD:AddNewBar( wndHandler, wndControl, eMouseButton )
	local bar = Apollo.LoadForm(self.xmlDoc, "Bar", nil, self)
	
	bar:Show(true)	
	
	
end

-----------------------------------------------------------------------------------------------
-- Serenity_HUD Instance
-----------------------------------------------------------------------------------------------
local Serenity_HUDInst = Serenity_HUD:new()
Serenity_HUDInst:Init()
