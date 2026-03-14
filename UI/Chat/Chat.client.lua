--------------------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------------------

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local canUseChatBar
do
	local success, result = pcall(function()
		return TextChatService:CanUserChatAsync(localPlayer.UserId)
	end)
	canUseChatBar = success and result or false
end

local chat = script.Parent
local util = chat:WaitForChild("Utility")

local chatBar = chat:WaitForChild("ChatBar")
local chatOutput = chat:WaitForChild("ChatOutput")
local focusBackdrop = chatBar:WaitForChild("FocusBackdrop")
local mainBackdrop = chat:WaitForChild("MainBackdrop")
local messageTemplate = util:WaitForChild("MessageTemplate")

local TextChannels = TextChatService:WaitForChild("TextChannels")
local LinkedList = require(util:WaitForChild("LinkedList"))
local SafeChat = require(ReplicatedStorage.SafeChat)

local screenGui = chat.Parent
local chatPadding = screenGui:WaitForChild("ChatPadding")

local remote = ReplicatedStorage:WaitForChild("SuperSafeChatRemote")
local remote2 = ReplicatedStorage:WaitForChild("CanUsersChatAsync")

--------------------------------------------------------------------------------------------------------------------------------------
-- Template for system messages
--------------------------------------------------------------------------------------------------------------------------------------

local SYSMSG_TEMPLATE = {
	Name = "(ROBLOX)",
	TeamColor = BrickColor.new("Really black")
}

--------------------------------------------------------------------------------------------------------------------------------------
-- Player Colors
--------------------------------------------------------------------------------------------------------------------------------------

local PLAYER_COLORS = {
	[0] = Color3.fromRGB(173,  35,  35); -- red
	[1] = Color3.fromRGB( 42,  75, 215); -- blue
	[2] = Color3.fromRGB( 29, 105,  20); -- green
	[3] = Color3.fromRGB(129,  38, 192); -- purple
	[4] = Color3.fromRGB(255, 146,  51); -- orange
	[5] = Color3.fromRGB(255, 238,  51); -- yellow
	[6] = Color3.fromRGB(255, 205, 243); -- pink
	[7] = Color3.fromRGB(233, 222, 187); -- tan
}

local function computePlayerColor(player, isSystemMessage)
	if isSystemMessage then
		return SYSMSG_TEMPLATE.TeamColor.Color
	else
		if player.Team then
			return player.TeamColor.Color
		else
			local pName = player.Name
			local length = #pName

			local oddShift = (1 - (length % 2))
			local value = 0

			for i = 1, length do
				local char = pName:sub(i, i):byte()
				local rev = (length - i) + oddShift

				if (rev % 4) >= 2 then
					value = value - char
				else
					value = value + char	
				end 
			end

			return PLAYER_COLORS[value % 8]
		end
	end
end

--------------------------------------------------------------------------------------------
-- Chat Input
--------------------------------------------------------------------------------------------

local function beginChatting()
	focusBackdrop.Visible = true
	mainBackdrop.BackgroundColor3 = Color3.new(1, 1, 1)

	if not chatBar:IsFocused() then
		chatBar.TextTransparency = 1
		chatBar:CaptureFocus()

		wait()

		chatBar.Text = ""
		chatBar.TextTransparency = 0
	end
end

local function onInputBegan(input, processed)
	if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Slash then
			beginChatting()
		end
	end
end

local function onChatFocusLost(enterPressed)
	local msg: string = chatBar.Text
	mainBackdrop.BackgroundColor3 = focusBackdrop.BackgroundColor3
	focusBackdrop.Visible = false
	chatBar.Text = ""

	if enterPressed and #msg > 0 then
		if #msg > 128 then
			msg = msg:sub(1, 125) .. "..."
		end

		local isSafeChatMessage = false
		local channel = TextChannels:FindFirstChild("RBXGeneral")

		if msg:sub(1, 1) == "%" then
			local teamColor = localPlayer.TeamColor
			local teamChannel = TextChannels:FindFirstChild(`RBXTeam{teamColor.Name}`)

			if teamChannel then
				channel = teamChannel
			end

			msg = msg:sub(2)
		elseif msg:sub(1, 3) == "/sc" then
			isSafeChatMessage = true
			local indices = msg:sub(4):split(" ")
			local tree = SafeChat

			for i, index in indices do
				local num = 1 + (tonumber(index) or 0)
				tree = tree.Branches[num]
			end

			msg = tree.Label
		end

		if channel and channel:IsA("TextChannel") then
			channel:SendAsync(msg)
			if isSafeChatMessage then
				remote:FireServer(msg, channel)
			end
		end
	end
end

if canUseChatBar then
	chatBar.Focused:Connect(beginChatting)
	chatBar.FocusLost:Connect(onChatFocusLost)
	UserInputService.InputBegan:Connect(onInputBegan)
else
	chatBar.Visible = false
	mainBackdrop.Visible = false
	chatPadding:Destroy()
end

--------------------------------------------------------------------------------------------
-- Chat Output
--------------------------------------------------------------------------------------------

local messageId = 0
local chatQueue = LinkedList.new()

local function getMessageId()
	messageId += 1
	return messageId
end

-- Credits to 0xabcdef1234 for this function
-- https://devforum.roblox.com/t/typewriter-effect-new-property-maxvisiblegraphemes-live/1092043
local function removeTags(str)
	-- replace line break tags (otherwise grapheme loop will miss those linebreak characters)
	str = str:gsub("<br%s*/>", "\n")
	return (str:gsub("<[^<>]->", ""))
end

local function formatMessage(str)
	str = removeTags(str)
	return str:gsub("#[# ]+#", "[ Content Deleted ]")
end

local function onIncomingMessage(message: TextChatMessage, isSuperSafeChat: boolean?)
	local isSystemMessage = false
	local source = message.TextSource
	local player = source and Players:GetPlayerByUserId(source.UserId)

	if not player then
		isSystemMessage = true
		player = SYSMSG_TEMPLATE
	else
		local canChat = canUseChatBar and remote2:InvokeServer(player.UserId)
		if not isSuperSafeChat then
			canChat = canUseChatBar and remote2:InvokeServer(player.UserId)
		else
			canChat = not canUseChatBar
		end
		if not canChat then
			return
		end
	end

	local text = formatMessage(message.Text)
	
	-- Create the message
	local msg = messageTemplate:Clone()

	local playerLbl = msg:WaitForChild("PlayerName")
	playerLbl.TextColor3 = computePlayerColor(player, isSystemMessage)
	playerLbl.TextStrokeColor3 = playerLbl.TextColor3
	playerLbl.AutomaticSize = Enum.AutomaticSize.XY
	playerLbl.Text = player.Name .. ";  "

	local msgLbl = msg:WaitForChild("Message")
	msgLbl.AutomaticSize = Enum.AutomaticSize.XY
	msgLbl.Text = text
	if isSystemMessage then
		msgLbl.TextColor3 = player.TeamColor.Color
	end

	msg.AutomaticSize = Enum.AutomaticSize.X
	msg.LayoutOrder = getMessageId()

	msg.Name = "Message" .. msg.LayoutOrder
	msg.Parent = chatOutput

	if chatQueue.size == 6 then
		local front = chatQueue.front
		front.data:Destroy()

		chatQueue:Remove(front.id)
	end

	chatQueue:Add(msg)
	Debris:AddItem(msg, 60)
end

TextChatService.MessageReceived:Connect(onIncomingMessage)
remote.OnClientEvent:Connect(onIncomingMessage)

--------------------------------------------------------------------------------------------