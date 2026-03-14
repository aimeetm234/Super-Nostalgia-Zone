r = game:GetService("RunService")

shaft = script.Parent
position = Vector3.new(0,0,0)
debris = game:GetService("Debris")

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = shaft:FindFirstChild("creator")
	if tag ~= nil then
		-- kill all other tags
		while(humanoid:FindFirstChild("creator") ~= nil) do
			humanoid:FindFirstChild("creator").Parent = nil
		end

		local new_tag = tag:Clone()
		new_tag.Parent = humanoid
		debris:AddItem(new_tag, 1)
	end
end

local function onExplosionHit(hit)
	local char = hit:FindFirstAncestorWhichIsA("Model")
	if char then
		local humanoid = char:FindFirstChild("Humanoid")
		if humanoid then
			tagHumanoid(humanoid)
		end
	end
end

function fly()
	local direction = shaft.CFrame.LookVector
	position = position + direction
	shaft.AssemblyLinearVelocity = position - shaft.Position
end

function blow(hit)
	local canExplode = true
	local char = hit:FindFirstAncestorWhichIsA("Model")
	
	if char then
		local humanoid = char:FindFirstChild("Humanoid")
		if humanoid then
			local tag = shaft:FindFirstChild("creator")
			local player = game.Players:GetPlayerFromCharacter(char)
			if tag and player and tag.Value == player then
				canExplode = false
			end
		end
	end
	
	if canExplode then
		local tag = shaft:FindFirstChild("creator")
		swoosh:Stop()
		
		if tag then
			local explosion = Instance.new("Explosion")
			explosion.Position = shaft.Position
			tag:Clone().Parent = explosion
			explosion.Parent = workspace
			explosion.Hit:Connect(onExplosionHit)
			connection:Disconnect()
			shaft.Explosion:Play()
			shaft.Anchored = true
			shaft.CanCollide = false
			shaft.Transparency = 1
			
			shaft.Explosion:Play()
			shaft.Explosion.Ended:Wait()
			shaft:Destroy()
		end
	end
end

t, s = r.Stepped:Wait()

swoosh = script.Parent.Swoosh
swoosh:Play()

position = shaft.Position
d = t + 10.0 - s
connection = shaft.Touched:Connect(blow)

while t < d do
	fly()
	t = r.Stepped:Wait()
end

swoosh:Stop()
shaft:Remove()
