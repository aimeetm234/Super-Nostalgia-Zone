print("LinkedLeaderboard script version 5.00 loaded")

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local loadConfig = ServerStorage:FindFirstChild("LoadLeaderboard")
local hasLoadConfig = (loadConfig ~= nil)

if hasLoadConfig and not loadConfig.Value then
	return
end

if not (ServerStorage:FindFirstChild("LoadTools") or (hasLoadConfig and loadConfig.Value)) then -- Infer we aren't in a brickbattle.
	return
end

stands = {}
CTF_mode = false

local function getKillerOfHumanoidIfStillInGame(humanoid)
	-- returns the player object that killed this humanoid
	-- returns nil if the killer is no longer in the game

	-- check for kill tag on humanoid - may be more than one - todo: deal with this
	local tag = humanoid:FindFirstChild("creator")

	-- find player with name on tag
	if tag ~= nil then
		local killer = tag.Value
		if killer ~= nil and killer.Parent ~= nil then -- killer still in game
			return killer
		end
	end

	return nil
end

local function handleKillCount(killer, player)
	local stats = killer:FindFirstChild("leaderstats")
	if stats ~= nil then
		local kills = stats:FindFirstChild("KOs")
		if kills ~= nil then
			if killer ~= player then
				kills.Value = kills.Value + 1
			else
				kills.Value = kills.Value - 1
			end
		end
	end
end

local function onHumanoidDied(humanoid, player)
	local stats = player:FindFirstChild("leaderstats")
	if stats ~= nil then
		local deaths = stats:FindFirstChild("Wipeouts")
		if deaths ~= nil then
			deaths.Value = deaths.Value + 1
		end

		-- do short dance to try and find the killer
		local killer = getKillerOfHumanoidIfStillInGame(humanoid)
		if killer ~= nil then
			handleKillCount(killer, player)
		end
	end
end

local function onPlayerRespawn(property, player)
	-- need to connect to new humanoid

	if property == "Character" and player.Character ~= nil then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid ~= nil then
			humanoid.Died:Once(function()
				onHumanoidDied(humanoid, player) 
			end)
		end
	end
end


-----------------------------------------------


local function findAllFlagStands(root)
	local c = root:GetChildren()
	for i=1,#c do
		if (c[i].ClassName == "Model" or c[i]:IsA("BasePart")) then
			findAllFlagStands(c[i])
		end
		if (c[i].ClassName == "FlagStand") then
			table.insert(stands, c[i])
		end
	end
end

local function onCaptureScored(player)
	local ls = player:FindFirstChild("leaderstats")
	if ls == nil then return end
	local caps = ls:FindFirstChild("Captures")
	if caps == nil then return end
	caps.Value = caps.Value + 1
end

local function hookUpListeners()
	for i=1,#stands do
		stands[i].FlagCaptured:Connect(onCaptureScored)
	end
end

local function onPlayerEntered(newPlayer)
	local stats = Instance.new("IntValue")
	stats.Name = "leaderstats"

	if CTF_mode == true then
		local captures = Instance.new("IntValue")
		captures.Name = "Captures"
		captures.Value = 0

		captures.Parent = stats

		-- VERY UGLY HACK
		-- Will this leak threads?
		-- Is the problem even what I think it is (player arrived before character)?
		while true do
			if newPlayer.Character ~= nil then break end
			wait(5)
		end
	else
		local kills = Instance.new("IntValue")
		kills.Name = "KOs"
		kills.Value = 0

		local deaths = Instance.new("IntValue")
		deaths.Name = "Wipeouts"
		deaths.Value = 0

		kills.Parent = stats
		deaths.Parent = stats

		-- VERY UGLY HACK
		-- Will this leak threads?
		-- Is the problem even what I think it is (player arrived before character)?
		while true do
			if newPlayer.Character ~= nil then break end
			wait(0.5)
		end

		local humanoid = newPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid ~= nil then
			humanoid.Died:Once(function ()
				onHumanoidDied(humanoid, newPlayer) 
			end)
		end

		-- start to listen for new humanoid
		newPlayer.Changed:Connect(function(property) onPlayerRespawn(property, newPlayer) end )
	end

	stats.Parent = newPlayer
end


findAllFlagStands(Workspace)
hookUpListeners()
if (#stands > 0) then CTF_mode = true end

for _,v in pairs(Players:GetPlayers()) do
	onPlayerEntered(v)
end

Players.PlayerAdded:Connect(onPlayerEntered)