local Tool = script.Parent
local Sounds = Tool.Sounds

local Rocket = Instance.new("Part")
Rocket.Locked = true
Rocket.BackSurface = 3
Rocket.BottomSurface = 3
Rocket.FrontSurface = 3
Rocket.LeftSurface = 3
Rocket.RightSurface = 3
Rocket.TopSurface = 3
Rocket.Size = Vector3.new(1,1,4)
Rocket.BrickColor = BrickColor.Red()

Tool.RocketScript:Clone().Parent = Rocket
Sounds.Explosion:Clone().Parent = Rocket
Sounds.Swoosh:Clone().Parent = Rocket


function fire(vTarget)

	local vCharacter = Tool.Parent;
	
	local vHandle = vCharacter:FindFirstChild("Head")
	if vHandle == nil then
		print("Handle not found")
		return 
	end

	local dir = vTarget - vHandle.Position

	dir = computeDirection(dir)

	local missile = Rocket:Clone()

	local pos = vHandle.Position + (dir * 6)
	
	--missile.Position = pos
	missile.CFrame = CFrame.new(pos,  pos + dir)

	local creator_tag = Instance.new("ObjectValue")

	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	if vPlayer == nil then
		print("Player not found")
	else
		if (vPlayer.Neutral == false) then -- nice touch
			missile.BrickColor = vPlayer.TeamColor
		end
	end

	creator_tag.Value =vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	missile.RocketScript.Disabled = false

	missile.Parent = game.Workspace
end

function computeDirection(vec)
	local lenSquared = vec.Magnitude * vec.Magnitude
	local invSqrt = 1 / math.sqrt(lenSquared)
	return Vector3.new(vec.X * invSqrt, vec.Y * invSqrt, vec.Z * invSqrt)
end

Tool.Enabled = true
function onActivated()
	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint

	fire(targetPos)

	wait(1)

	Tool.Enabled = true
end


script.Parent.Activated:Connect(onActivated)

