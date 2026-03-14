local Ball = script.Parent
local damage = 35

local r = game:GetService("RunService")
local debris = game:GetService("Debris")

local last_sound_time = r.Stepped:Wait()

local allowTeamDamage = false
local ServerStorage = game:GetService("ServerStorage")
if ServerStorage:FindFirstChild("TeamDamage") then
	allowTeamDamage = ServerStorage.TeamDamage.Value
end

function onTouched(hit)
	local hitChar = hit:FindFirstAncestorWhichIsA("Model")
	local humanoid = hitChar:FindFirstChild("Humanoid")	
	if humanoid ~=nil then
		local canDamage = true
		local tag = Ball:FindFirstChild("creator")
		if tag then
			local creator = tag.Value
			local player = game.Players:GetPlayerFromCharacter(hitChar)
			if creator and player then
				if creator.Team and player.Team and creator.Team == player.Team then
					canDamage = allowTeamDamage
				end
				if creator == player then
					canDamage = true
				end
			end
		end
		
		if canDamage then
			if connection then 
				connection:Disconnect() 
			end
			Ball.Boing:Play()
			tagHumanoid(humanoid)
			humanoid:TakeDamage(damage)
			if humanoid.RootPart then
				local apply = (Ball.Position - humanoid.RootPart.Position).Unit * (Ball.AssemblyLinearVelocity/4)
				humanoid.RootPart.AssemblyLinearVelocity = humanoid.RootPart.AssemblyLinearVelocity + apply
				humanoid.RootPart.AssemblyAngularVelocity = humanoid.RootPart.AssemblyAngularVelocity + apply
			end
			humanoid.PlatformStand = true
			wait(.1)
			humanoid.PlatformStand = false
		end
	else
		local now = tick()
		if (now - last_sound_time > .1) then
			Ball.Boing:Play()
			last_sound_time = now
			damage = damage / 2
			if damage < 2 then
				if connection then 
					connection:Disconnect() 
				end
			end
		end
	end
end

function tagHumanoid(humanoid)	
	local tag = Ball:FindFirstChild("creator")
	if tag ~= nil then
		local new_tag = tag:Clone()
		new_tag.Parent = humanoid
		debris:AddItem(new_tag, 4)
	end
end


connection = Ball.Touched:Connect(onTouched)

wait(5)

Ball:Destroy()