local ZERO = Vector3.new(0, 0, 0)
local RIGHT = Vector3.new(1, 0, 0)

--

local function rayPlane(p, v, s, n)
	local r = p - s;
	local g = -r:Dot(n) / v:Dot(n)
	return p + g * v, g
end;

--

local Supports = {}

function Supports.PointCloud(set, Direction)
	local max, maxDot = set[1], set[1]:Dot(Direction)
	for i = 2, #set do
		local dot = set[i]:Dot(Direction)
		if (dot > maxDot) then
			max = set[i]
			maxDot = dot
		end
	end
	return max
end

function Supports.Cylinder(set, Direction)
	local cf, size2 = unpack(set)
	Direction = cf:VectorToObjectSpace(Direction)
	local radius = math.min(size2.y, size2.z)
	local dotT, cPoint = Direction:Dot(RIGHT), Vector3.new(size2.x, 0, 0)
	local h, final
	
	if (dotT == 0) then
		final = Direction.Unit * radius
	else
		cPoint = dotT > 0 and cPoint or -cPoint
		h = rayPlane(ZERO, Direction, cPoint, RIGHT)
		final = cPoint + (h - cPoint).Unit * radius
	end
	
	return cf:PointToWorldSpace(final)
end

function Supports.Ellipsoid(set, Direction)
	local cf, size2 = unpack(set)
	return cf:PointToWorldSpace(size2 * (size2 * cf:VectorToObjectSpace(Direction)).Unit)
end

return Supports