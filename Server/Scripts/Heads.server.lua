local function processObject(obj)
	if obj:IsA("SpecialMesh") and obj.MeshType == Enum.MeshType.Head then
		local head = obj.Parent

		local col = math.min(head.Size.X,head.Size.Z)
		local thickness = head.Size.Y/col

		if math.abs(thickness-1) <= 0.01 then
			obj.Name = "MeshHead"
			obj.MeshId = "rbxassetid://6906738205"
			obj.Scale = obj.Scale * head.Size.Y
			for _,surface in pairs(Enum.NormalId:GetEnumItems()) do
				head[surface.Name .. "Surface"] = 0
			end
		end
	end
end

for _,desc in pairs(workspace:GetDescendants()) do
	processObject(desc)
end

workspace.DescendantAdded:Connect(processObject)