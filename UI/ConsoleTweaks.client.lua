local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local function addUIScale(obj, scale)
	-- If a UIScale already exists, just use that
	wait()
	local uiScale = obj:FindFirstChildOfClass("UIScale")
	if not uiScale then -- Otherwise, create one
		uiScale = Instance.new("UIScale")
		uiScale.Parent = obj
	end
	uiScale.Scale = scale
end

if GuiService:IsTenFootInterface() then
	local ui = script.Parent
	local rootFrame = ui:WaitForChild("RootFrame")
	
	local zoomControls = ui:WaitForChild("ZoomControls")
	zoomControls.Visible = false
	
	local backpack = ui:WaitForChild("Backpack")
	backpack.Position = UDim2.new(0, 0, 1, 0)
	
	-- Chat is allowed on console now, so stuff relating to chat will be commented out
	--[[
	local chat = ui:WaitForChild("Chat")
	chat.Visible = false
	
	local chatPadding = ui:WaitForChild("ChatPadding", 1)
	
	if chatPadding then
		chatPadding:Destroy()
	end

	local safeChat = ui:WaitForChild("SafeChat")
	safeChat.Visible = false
	--]]
	
	local health = ui:WaitForChild("Health")
	addUIScale(health, 1.5)
end

wait()
script:Destroy()