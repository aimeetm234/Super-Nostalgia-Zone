-- A module intended to replace game.ItemChanged
local ItemChanged = Instance.new("BindableEvent")
local Connections = {}
local function Cleanup(Object)
	pcall(function()
		for _, Connection in pairs(Connections[Object]) do
			Connection:Disconnect()
		end
		table.clear(Connections[Object])
		Connections[Object] = nil
	end)
end
local function Changed(Object)
	if not Connections[Object] then
		Connections[Object] = {
			Object.Changed:Connect(function(Property)
				ItemChanged:Fire(Object, Property)
			end),
			Object.Destroying:Once(function()
				Cleanup(Object)
			end)
		}
	end
end
local Descendants = game:GetDescendants()
for _, Object in pairs(Descendants) do
	Changed(Object)
end
table.clear(Descendants)
Descendants = nil
game.DescendantAdded:Connect(Changed)
game.DescendantRemoving:Connect(Cleanup)
return ItemChanged.Event