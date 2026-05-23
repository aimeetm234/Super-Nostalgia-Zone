-- RaygionUtil
-- By TheFastOneIsBack

-- A module that acts as a compatibility layer for the deprecated Workspace
-- methods "FindPartOnRay*" and "FindPartsInRegion3*"

-- Services
local Workspace = game:GetService("Workspace")

-- Stuff to speed things up
local Raycast = Workspace.Raycast
local GetPartBoundsInBox = Workspace.GetPartBoundsInBox
local NewOverlapParams = OverlapParams.new
local NewRaycastParams = RaycastParams.new

-- Base functions
local function PrepareForFilter(Object: Instance? | Instances?): Instances
	if Object == nil then
		return {}
	else
		if typeof(Object) == "Instance" then
			return {Object}
		elseif type(Object) == "table" then
			return Object
		else
			warn("Object specified is of unknown/unsupported type")
			return {}
		end
	end
end

local function BaseCastRay(RayToUse: Ray, Ignore: Instance? | Instances?, IgnoreWater: boolean?, WhiteList: boolean?): (BasePart | Terrain?, Vector3, Vector3?, Enum.Material?)
	assert(RayToUse, "Argument 1 missing or nil")
	assert(typeof(RayToUse) == "Ray", "Argument 1 expects a Ray")
	if Ignore ~= nil then
		assert(typeof(Ignore) == "Instance" or type(Ignore) == "table", "Optional argument 2 expects either an Instance or a table of them")
	end
	if IgnoreWater == nil then
		IgnoreWater = false
	else			
		assert(type(IgnoreWater) == "boolean", "Optional argument 3 expects a boolean")
	end
	if WhiteList == nil then
		WhiteList = false
	else			
		assert(type(WhiteList) == "boolean", "Optional argument 4 expects a boolean")
	end
	local FilterType = WhiteList and "Include" or "Exclude"
	local Params = NewRaycastParams()
	Params[FilterType .. "Instances"] = PrepareForFilter(Ignore)
	Params.IgnoreWater = IgnoreWater
	local Cast = Raycast(Workspace, RayToUse.Origin, RayToUse.Direction, Params)
	if Cast then
		return Cast.Instance, Cast.Position, Cast.Normal, Cast.Material
	else
		return nil, (RayToUse.Origin + RayToUse.Direction)
	end
end

local function BaseCastRegion(Region: Region3, Ignore: Instance? | Instances?, MaxParts: number?, WhiteList: boolean?): Instances
	assert(Region, "Argument 1 missing or nil")
	assert(typeof(Region) == "Region3", "Argument 1 expects a Region3")
	if Ignore ~= nil then
		assert(typeof(Ignore) == "Instance" or type(Ignore) == "table", "Optional argument 2 expects either an Instance or a table of them")
	end
	if MaxParts == nil then
		MaxParts = 20
	else			
		assert(type(MaxParts) == "number", "Optional argument 3 expects a number")
	end
	if WhiteList == nil then
		WhiteList = false
	else			
		assert(type(WhiteList) == "boolean", "Optional argument 4 expects a boolean")
	end
	local FilterType = WhiteList and "Include" or "Exclude"
	local Params = NewOverlapParams()
	Params[FilterType .. "Instances"] = PrepareForFilter(Ignore)
	Params.MaxParts = MaxParts
	return GetPartBoundsInBox(Workspace, Region.CFrame, Region.Size, Params)
end

local RaygionUtil = {}

function RaygionUtil:FindPartOnRay(RayToUse: Ray, IgnoreInstance: Instance?, TerrainCellsAreCubes: boolean?, IgnoreWater: boolean?): (BasePart | Terrain?, Vector3, Vector3?, Enum.Material?)
	return BaseCastRay(RayToUse, IgnoreInstance, IgnoreWater, false)
end

function RaygionUtil:FindPartOnRayWithIgnoreList(RayToUse: Ray, IgnoreTable: Instances, TerrainCellsAreCubes: boolean?, IgnoreWater: boolean?): (BasePart | Terrain?, Vector3, Vector3?, Enum.Material?)
	assert(IgnoreTable, "Argument 2 missing or nil")
	assert(type(IgnoreTable) == "table", "Argument 2 expects a table of Instances")
	return BaseCastRay(RayToUse, IgnoreTable, IgnoreWater, false)
end

function RaygionUtil:FindPartOnRayWithWhitelist(RayToUse: Ray, WhitelistTable: Instances, IgnoreWater: boolean?): (BasePart | Terrain?, Vector3, Vector3?, Enum.Material?)
	assert(WhitelistTable, "Argument 2 missing or nil")
	assert(type(WhitelistTable) == "table", "Argument 2 expects a table of Instances")
	return BaseCastRay(RayToUse, WhitelistTable, IgnoreWater, true)
end

function RaygionUtil:FindPartsInRegion3(Region: Region3, IgnoreInstance: Instance?, MaxParts: number?): Instances
	return BaseCastRegion(Region, IgnoreInstance, MaxParts, false)
end

function RaygionUtil:FindPartsInRegion3WithIgnoreList(Region: Region3, IgnoreTable: Instances, MaxParts: number?): Instances
	assert(IgnoreTable, "Argument 2 missing or nil")
	assert(type(IgnoreTable) == "table", "Argument 2 expects a table of Instances")
	return BaseCastRegion(Region, IgnoreTable, MaxParts, false)
end

function RaygionUtil:FindPartsInRegion3WithWhiteList(Region: Region3, WhitelistTable: Instances, MaxParts: number?): Instances
	assert(WhitelistTable, "Argument 2 missing or nil")
	assert(type(WhitelistTable) == "table", "Argument 2 expects a table of Instances")
	return BaseCastRegion(Region, WhitelistTable, MaxParts, true)
end

-- compatibility for the weird people using deprecated aliases
RaygionUtil.findPartOnRay = RaygionUtil.FindPartOnRay
RaygionUtil.findPartsInRegion3 = RaygionUtil.FindPartsInRegion3

return RaygionUtil