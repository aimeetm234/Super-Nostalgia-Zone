-- Handles various stuff related to chat, such as the sending of SuperSafeChat messages, allowing players who cannot access regular chat to still be able to communicate with others
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Remote = Instance.new("RemoteEvent")
Remote.Name = "SuperSafeChatRemote"
Remote.Parent = ReplicatedStorage

local Remote2 = Instance.new("RemoteFunction")
Remote2.Name = "CanUsersChatAsync"
Remote2.Parent = ReplicatedStorage

local function CanUsersChatAsync(from, to, falseIfBothUsersAreTheSame)
	if from == to then
		return not falseIfBothUsersAreTheSame
	else
		local success, result = pcall(function()
			return TextChatService:CanUsersChatAsync(from, to)
		end)
		if not success then
			return false
		else
			return result
		end
	end
end

local function CreatePseudoTextSource(player)
	return {
		CanSend = true,
		UserId = player.UserId
	}
end

local function CreatePseudoTextChatMessage(player, message, textChannel, timestamp)
	return {
		MessageId = tostring(player.UserId) .. "-" .. string.upper(HttpService:GenerateGUID(true)),
		Metadata = "",
		PrefixText = player.DisplayName,
		Status = Enum.TextChatMessageStatus.Success,
		Text = message,
		TextChannel = textChannel,
		TextSource = CreatePseudoTextSource(player),
		Timestamp = timestamp or DateTime.now(),
		Translation = ""
	}
end

local function SendSuperSafeChatMessage(sender, message, channel)
	local Timestamp = DateTime.now()
	for _, v in pairs(Players:GetPlayers()) do
		if not CanUsersChatAsync(sender.UserId, v.UserId, true) then
			Remote:FireClient(v, CreatePseudoTextChatMessage(sender, message, channel, Timestamp), true)
		end
	end
end

Remote.OnServerEvent:Connect(SendSuperSafeChatMessage)
Remote2.OnServerInvoke = function(sender, to, falseIfBothUsersAreTheSame)
	return CanUsersChatAsync(sender.UserId, to, falseIfBothUsersAreTheSame)
end