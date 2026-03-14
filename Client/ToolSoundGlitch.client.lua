local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")

local function onGlitchSoundAdded(glitchSound)
	if TeleportService:GetTeleportSetting("SoundEquipBug") then
		glitchSound.RollOffMaxDistance = 10000
		glitchSound:Play()
	end
end

local addSignal = CollectionService:GetInstanceAddedSignal("ToolSoundGlitch")
addSignal:Connect(onGlitchSoundAdded)