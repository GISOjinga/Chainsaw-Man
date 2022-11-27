--!strict
local Visualize = require(script.Parent.Visualize)
local Methods = {}


local function CastRay(Origin:Vector3, Direction:Vector3, RayInfo:RayInfo?)
	local RayParams = RaycastParams.new()
	if RayInfo then
		RayParams.FilterType = if RayInfo.Whitelist then Enum.RaycastFilterType.Whitelist elseif RayInfo.Blacklist then Enum.RaycastFilterType.Blacklist else RayParams.FilterType
		RayParams.FilterDescendantsInstances = RayInfo.Blacklist or RayInfo.Whitelist or RayParams.FilterDescendantsInstances
	end
	return workspace:Raycast(Origin, Direction, RayParams)
end

function Methods:CastRay(Origin:Vector3, Direction:Vector3, RayInfo2:RayInfo?)
	local RayInfo = (RayInfo2 or {})::RayInfo
	
	local RayResult:Results
	
	local function Run()
		RayResult = (CastRay(Origin, Direction, RayInfo) or {Position=Origin+Direction, Normal=-Direction.Unit, Distance=Direction.Magnitude})::Results
		
		local Check = true do
			if RayInfo.CustomCheck and RayResult.Instance then
				Check = RayInfo.CustomCheck(RayResult.Instance, RayResult.Position)
			end
		end
		
		if RayInfo and RayInfo.Visualize then
			local Color = if Check then Color3.new(0.262745, 1, 0.14902) else RayInfo.VisualColor
			Visualize:VisualizeRay(Origin, RayResult.Position, .5, Color); Visualize:MarkPart(RayResult.Instance,.5, Color)
		end
		
		--print(RayResult.Instance)
		if RayInfo.CustomCheck then
			if not Check then
				if RayResult then Direction -= (Origin-RayResult.Position);  Origin = RayResult.Position+Direction.Unit; end
				RayResult = nil::any
				Run()
			else 
				return
			end
		else
			return
		end
	end
	Run()
	
	return RayResult
end




type Results = (RaycastResult) & {Position:Vector3, Normal:Vector3, Distance:number}

type RayInfo = {
	Whitelist:{Instance}?,
	Blacklist:{Instance}?,
	Visualize:boolean?,
	VisualColor:Color3|nil,
	CustomCheck:((Instance:Instance, IntersectionPoint:Vector3)->(boolean))?,
}

return Methods