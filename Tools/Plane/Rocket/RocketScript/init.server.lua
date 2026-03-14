r = game:GetService("RunService")

shaft = script.Parent
position = shaft.Position

function fly()
	direction = shaft.CFrame.LookVector 
	position = position + 35*direction
	error = position - shaft.Position
	shaft.AssemblyLinearVelocity = 5*error
end

function blow()
	swoosh:Stop()
	explosion = Instance.new("Explosion")
	explosion.Position = shaft.Position
	explosion.BlastRadius = 10

	-- find instigator tag
	local creator = script.Parent:FindFirstChild("creator")
	if creator ~= nil then
		explosion.Hit:Connect(function(part, distance)  onPlayerBlownUp(part, distance, creator) end)
	end

	explosion.Parent = game.Workspace
	connection:Disconnect()
	wait(.1)
	shaft:Remove()
end

function onTouch(hit)
	if hit.Name == "Building" or
	hit.Name == "Safe" then
		swoosh:Stop()
		shaft:Remove()
	return end

	local parent = hit.Parent.Parent
	local owner = shaft.Owner
	if owner ~= nil then
		if parent ~= nil and owner.Value ~= nil then
			if parent ~= owner.Value then
				local stunt = parent:FindFirstChild("Stunt")
				if stunt ~= nil then
					if stunt.Value ~= 1 then
						blow()
					end
				else
					blow()
				end
			end
		end
	end
end

function onPlayerBlownUp(part, distance, creator)
	if part.Name == "Head" then
		local humanoid = part.Parent:FindFirstChild("Humanoid")
		tagHumanoid(humanoid, creator)
	end
end

function tagHumanoid(humanoid, creator)
	if creator ~= nil then
		local new_tag = creator:Clone()
		new_tag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end

t, s = r.Stepped:Wait()

swoosh = script.Parent.Swoosh
swoosh:Play()

d = t + 4.0 - s
connection = shaft.Touched:Connect(onTouch)

while t < d do
	fly()
	t = r.Stepped:Wait()
end

-- at max range
script.Parent.Explosion.PlayOnRemove = false
swoosh:Stop()
shaft:Remove()
