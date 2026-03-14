-- PopperCam Version 16
-- OnlyTwentyCharacters

local PopperCam = {} -- Guarantees your players won't see outside the bounds of your map!

-----------------
--| Constants |--
-----------------

local POP_RESTORE_RATE = 0.3
local MIN_CAMERA_ZOOM = 0.5

local VALID_SUBJECTS = 
{
	'Humanoid',
	'VehicleSeat',
	'SkateboardPlatform',
}

-----------------
--| Variables |--
-----------------

local Players = game:GetService('Players')

local Camera = nil
local CameraSubjectChangeConn = nil

local SubjectPart = nil

local PlayerCharacters = {} -- For ignoring in raycasts
local VehicleParts = {} -- Also just for ignoring

local LastPopAmount = 0
local LastZoomLevel = 0
local PopperEnabled = true

local CFrame_new = CFrame.new

-----------------------
--| Local Functions |--
-----------------------

local math_abs = math.abs

local function OnCharacterAdded(player, character)
	PlayerCharacters[player] = character
end

local function OnPlayersChildAdded(child)
	if child:IsA('Player') then
		child.CharacterAdded:Connect(function(character)
			OnCharacterAdded(child, character)
		end)
		if child.Character then
			OnCharacterAdded(child, child.Character)
		end
	end
end

local function OnPlayersChildRemoved(child)
	if child:IsA('Player') then
		PlayerCharacters[child] = nil
	end
end

---------------------------------------------------------------------------------
-- Credits to crusherfire for these two functions
-- https://devforum.roblox.com/t/cameragetlargestcutoffdistance-source/2071917/5 
---------------------------------------------------------------------------------
local function GetLargestCutoffDistance(currentFocus: CFrame, goalCFrame: CFrame, collisionRadius: number, ignoreList: { any }?): number
	local origin = currentFocus.Position

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = ignoreList or {}
	params.FilterType = Enum.RaycastFilterType.Exclude

	-- Camera bounds
	local cameraOffsets = {
		Vector3.new(0, 0, 0), -- camera center
		Vector3.new(collisionRadius, 0, 0), -- right of the camera
		Vector3.new(-collisionRadius, 0, 0), -- left of the camera
	}

	local largestCutoffDistance = 0

	for _, offset in ipairs(cameraOffsets) do
		local correctedGoalCFrame = goalCFrame * CFrame.new(offset)
		local direction = ((correctedGoalCFrame.Position) - currentFocus.Position)
		local result: RaycastResult = workspace:Raycast(origin, direction, params)

		if not result then
			continue
		end
		local distance = (result.Position - correctedGoalCFrame.Position).Magnitude
		if distance > largestCutoffDistance then
			largestCutoffDistance = distance
		end
	end

	return largestCutoffDistance
end

local function GetCollisionRadius(): number
	local camera = workspace.CurrentCamera
	local viewportSize = camera.ViewportSize
	local aspectRatio = viewportSize.X / viewportSize.Y
	local fovRads = math.rad(camera.FieldOfView)
	local imageHeight = math.tan(fovRads) * math.abs(camera.NearPlaneZ)
	local imageWidth = imageHeight * aspectRatio

	local cornerPos = Vector3.new(imageWidth, imageHeight, camera.NearPlaneZ)
	return cornerPos.Magnitude
end
---------------------------------------------------------------------------------
-- End of crusherfire functions
---------------------------------------------------------------------------------

-------------------------
--| Exposed Functions |--
-------------------------

function PopperCam:Update()
	if PopperEnabled then
		-- First, prep some intermediate vars
		local Camera = workspace.CurrentCamera

		if Camera.CameraType.Name == "Fixed" then
			return
		end
		
		local cameraCFrame = Camera.CFrame
		local collisionRadius = GetCollisionRadius()
		local focus = Camera.Focus
		if SubjectPart then
			focus = SubjectPart.CFrame
		end
		local focusPoint = focus.Position

		local ignoreList = {}
		for _, character in pairs(PlayerCharacters) do
			ignoreList[#ignoreList + 1] = character
		end
		for i = 1, #VehicleParts do
			ignoreList[#ignoreList + 1] = VehicleParts[i]
		end
		
		-- Get largest cutoff distance
		local largest = GetLargestCutoffDistance(focus, cameraCFrame, collisionRadius, ignoreList)

		-- Then check if the player zoomed since the last frame,
		-- and if so, reset our pop history so we stop tweening
		local zoomLevel = (cameraCFrame.Position - focusPoint).Magnitude
		if math_abs(zoomLevel - LastZoomLevel) > 0.001 then
			LastPopAmount = 0
		end
		
		-- Finally, zoom the camera in (pop) by that most-cut-off amount, or the last pop amount if that's more
		local popAmount = largest
		if LastPopAmount > popAmount then
			popAmount = LastPopAmount
		end

		if popAmount > 0 then
			Camera.CFrame = cameraCFrame + (cameraCFrame.LookVector * popAmount)
			LastPopAmount = popAmount - POP_RESTORE_RATE -- Shrink it for the next frame
			if LastPopAmount < 0 then
				LastPopAmount = 0
			end
		end

		LastZoomLevel = zoomLevel
	end
end

--------------------
--| Script Logic |--
--------------------


-- Connect to all Players so we can ignore their Characters
Players.ChildRemoved:Connect(OnPlayersChildRemoved)
Players.ChildAdded:Connect(OnPlayersChildAdded)
for _, player in pairs(Players:GetPlayers()) do
	OnPlayersChildAdded(player)
end

return PopperCam