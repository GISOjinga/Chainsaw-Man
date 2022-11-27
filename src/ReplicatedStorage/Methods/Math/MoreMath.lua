--!strict

-->> Set Up
local Equations = {Region = require(script.Parent.Region3.RealRegion)}
Equations.__index = Equations

-->> Vars <<--
local rad = math.rad
local rand = math.random


Equations.Wave = function(Scalar:number,Amplitude:number,Amount:number,StartFromAmplitude:boolean?)
	local equ:(...any)->number = if StartFromAmplitude then math.cos else math.sin
	local amount = Amplitude*equ((((2*math.pi)/Amount)*0)-(((2*math.pi)/1)*Scalar))
	return amount
end

Equations.Lerp = {
	Wave = function(Scalar:number,Amount:number,Amplitude:number?)
		return Equations.Wave(Amount*Scalar,(Amplitude or 1)*(1-Scalar),1)
	end
}


Equations.Scale = function(self:ModuleType,CurrentScale:number,WantedScale:number)
	local ScaledBy = WantedScale/CurrentScale
	CurrentScale = CurrentScale*ScaledBy
	return {CurrentScale=CurrentScale,ScaledBy=ScaledBy}
end

Equations.DecimalPlaces = function(self:ModuleType,Number:number):number
	local Stringed:string = tostring(Number)
	local FoundDecimal = string.find(Stringed,".")
	if FoundDecimal == #Stringed then return 0 end
	if FoundDecimal then return #string.sub(Stringed,FoundDecimal+1,#Stringed) end
	return 0
end

Equations.MoveAttachments = function(self:ModuleType,NewCFrame:CFrame,Attach1:Attachment,Attach2:Attachment,Length:number)
	Attach1.WorldCFrame = NewCFrame*CFrame.new(0,0,Length/2)
	Attach2.WorldCFrame = NewCFrame*CFrame.new(0,0,-Length/2)
end

Equations.RayToBeziers = function(self:ModuleType,ray:Ray,amount:number,range:{number}|number)

end

Equations.IsInFOV = function(self:ModuleType,LookVector:Vector3,angle:number,point1:Vector3,point2:Vector3,MaxDistance:nil|number)
	local dir = (point2-point1)
	if dir.Magnitude>(MaxDistance or dir.Magnitude) then return end
	if point1 == point2 then return true end
	local vector = dir.Unit
	local angle2 = math.acos(LookVector:Dot(vector)) 
	return math.deg(angle2)<=angle
end

Equations.AngleDistanceNegOrPositive = function(self:ModuleType,LookVector:Vector3,point1:Vector3,point2:Vector3)
	local dir = (point2-point1)
	--if point1 == point2 then return 0 end
	local vector = dir.Unit
	return ((LookVector:Dot(vector)<0 and -1) or 1)
end

Equations.RayGetClosestPointOnRay = function(self:ModuleType,ray:Ray, point:Vector3)--opp=sin(angle)*hyp or sin(angle) = opp/hyp
	local a, b = ray.Origin - point, ray.Direction
	local v = a - ((a:Dot(b)) / (b:Dot(b))) * b
	local Difference = (point + v)-ray.Origin
	local Amount = math.min(ray.Direction.Magnitude,Difference.Magnitude)
	local PointOnRay = ray.Origin+(ray.Direction.Unit*Amount)
	local OppPointOnRay = ray.Origin+(ray.Direction.Unit*-Amount)
	return if (PointOnRay-point).Magnitude<=(OppPointOnRay-point).Magnitude then PointOnRay else ray.Origin
end

Equations.RayRangeHit = function(self:ModuleType,ray:Ray,Vector:Vector3,Range:number)
	local closestPoint:Vector3 = self:RayGetClosestPointOnRay(ray,Vector)
	return if (Vector-closestPoint).Magnitude<=Range then closestPoint else nil
end

Equations.CircleCircumference = function(self:ModuleType,radius)
	return 2*math.pi*radius
end

Equations.DisFromTimeSpeed = function(self:ModuleType,Time:number,speed:number)
	return Time*speed
end

Equations.TimeFromDisSpeed = function(self:ModuleType,distance:number,speed:number)
	return distance/speed
end

Equations.SpeedFromTimeDis = function(self:ModuleType,distance:number,Time:number)
	return distance/Time
end

Equations.GetPointWithinMag = function(self:ModuleType,Pos1:Vector3,Pos2:Vector3,Mag:number)
	return Pos1+((Pos2-Pos1).Unit*Mag)
end

Equations.GetMag = function(self:ModuleType,Pos1:Vector3,Pos2:Vector3)
	return (Pos1-Pos2).Magnitude
end

Equations.GetDir = function(self:ModuleType,Pos1:Vector3,Pos2:Vector3,Unit:Vector3)
	return if Unit then (Pos2-Pos1).Unit else (Pos2-Pos1)
end

Equations.GetMiddlePoint = function(self:ModuleType,Point1:Vector3,Point2:Vector3,adjust:number?)
	return (Point1+Point2)*(adjust or .5)
end

Equations.GetMiddlePointToCF = function(self:ModuleType,Point1:Vector3,Point2:Vector3,adjust:number?)
	local point = (Point1+Point2)*(adjust or .5)
	return CFrame.lookAt(point,point+(Point2-Point1).Unit)
end

Equations.GridAxesCal = function(self:ModuleType,GridSize:number,Number:number)
	return math.floor((Number / GridSize) + 0.5) * GridSize
end

Equations.GetGridPos = function(self:ModuleType,GridSize,Position)
	local X:number,Y:number,Z:number = self:GridAxesCal(GridSize,Position.X),self:GridAxesCal(GridSize,Position.Y),self:GridAxesCal(GridSize,Position.Z)
	return Vector3.new(X,Y,Z)
end

Equations.CFrameLookXZ = function(self:ModuleType,Cframe:CFrame)
	local LVector = Cframe.LookVector
	return CFrame.lookAt(Cframe.Position,Cframe.Position+Vector3.new(LVector.X,0,LVector.Z))
end

Equations.CFrameRelativeLookY = function(self:ModuleType,Cframe:CFrame,Point:Vector3)
	local LookAtCF = CFrame.lookAt(Cframe.Position,Point)
	local Difference = Cframe:ToObjectSpace(LookAtCF)
	local NewAngle = {Difference:ToEulerAnglesXYZ()}
	return Cframe*CFrame.fromAxisAngle(Cframe.UpVector,NewAngle[2])
end

Equations.CFrameRelativeLookX = function(self:ModuleType,Cframe:CFrame,Point:Vector3)
	local LookAtCF = CFrame.lookAt(Cframe.Position,Point)
	local NormAngle = {Cframe:ToEulerAnglesXYZ()}
	local NewAngle = {LookAtCF:ToEulerAnglesXYZ()}
	return CFrame.new(Cframe.Position)*CFrame.Angles(NormAngle[1],NewAngle[2],NewAngle[3])
end

Equations.CFrameLookY = function(self:ModuleType,Cframe:CFrame)
	local LVector = Cframe.LookVector
	return CFrame.lookAt(Cframe.Position,Cframe.Position+Vector3.new(0,LVector.Y,0))
end

Equations.Vector3ToRadians = function(self:ModuleType,Vector:Vector3)
	return Vector3.new(rad(Vector.X),rad(Vector.Y),rad(Vector.Z))
end

Equations.Vector3ToCFrameAngles = function(self:ModuleType,Vector:Vector3)
	return CFrame.Angles(Vector.X,Vector.Y,Vector.Z)
end



Equations.QuadBezier = function(self:ModuleType,t:number, p0:Vector3, p1:Vector3, p2:Vector3):Vector3
	return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

Equations.ArcLength = function(self:ModuleType,a:Vector3,b:Vector3,c:Vector3):number
	local v:Vector3 = Vector3.new(2*(b.X - a.X),2*(b.Y - a.Y),2*(b.Z - a.Z))
	local w:Vector3 = Vector3.new(c.X - 2*b.X + a.X,c.Y - 2*b.Y + a.Y,c.Z - 2*b.Z + a.Z)

	local uu:number = 4*(w.X*w.X + w.Y*w.Y + w.Z*w.Z);

	if (uu < 0.00001) then
		return math.sqrt((c.X - a.X)*(c.X - a.X) + (c.Y - a.Y)*(c.Y - a.Y) + (c.Z - a.Z)*(c.Z - a.Z))/2;
	end

	local vv = 4*(v.X*w.X + v.Y*w.Y + v.Z*w.Z);
	local ww = v.X*v.X + v.Y*v.Y + v.Z*v.Z;

	local t1 = (2*math.sqrt(uu*(uu + vv + ww)));
	local t2 = 2*uu+vv;
	local t3 = vv*vv - 4*uu*ww;
	local t4 = (2*math.sqrt(uu*ww));

	return ((t1*t2 - t3*math.log(t2+t1) -(vv*t4 - t3*math.log(vv+t4))) / (8*math.pow(uu, 1.5)))/2;
end

Equations.TotalLengthOfArcs = function(self:ModuleType,Points:{Vector3}):number
	local length:number = self:ArcLength(Points[1],Points[2],Points[3])
	for i = 1,#Points do
		local Point1 = Points[i]
		local Point2 = Points[i+1]
		local Point3 = Points[i+2]
		if not (Point3 and Point2 and Point1) then break end
		local arcLength = self:ArcLength(Point1,Point2,Point3)
		length += arcLength*1/2
	end
	return length
end

Equations.NextPointInBezier = function(self:ModuleType,Scalar:number,Points:{Vector3}):Vector3
	for i = 1,#Points do
		local Point1 = Points[i]
		local Point2 = Points[i+1]
		local Point3 = Points[i+2]
		if not (Point3 and Point2 and Point1) then break end

		local Difference = 1/#Points
		local ScalarEnd = Difference*(i+2)
		local ScalarStart = ScalarEnd-(Difference*(i+2))
		if Scalar<=ScalarEnd and Scalar>=ScalarStart then
			local CurrentScalarDifference = ScalarEnd-ScalarStart
			local CheckingScalarDifference = Scalar-ScalarStart

			local ScalarOfAScalar = CheckingScalarDifference/(CurrentScalarDifference)
			return self:QuadBezier(ScalarOfAScalar, Point1, Point2, Point3)
		end
	end
	if Scalar >=.5 then
		return self:QuadBezier(Scalar, Points[#Points-2], Points[#Points-1], Points[#Points])
	end
	return self:QuadBezier(Scalar, Points[1], Points[2], Points[3])
end




Equations.GetIndexInTableRelativeToTime = function(self:ModuleType,Tabl:{any},TimePerIndex:number,TimePassed:number):any|nil
	local NumsBeforeDigit:number = 10^(self:DecimalPlaces(TimePerIndex)-1)
	local WaitMoved = math.floor(TimePerIndex*NumsBeforeDigit)
	TimePassed = math.floor(TimePassed*NumsBeforeDigit)
	if TimePassed%WaitMoved == 0 then
		return Tabl[TimePassed/WaitMoved]
	end
	return nil
end


Equations.RandomDirectionsWithTime = function(self:ModuleType,WaitsPerShot:number,TotalTime:number,MaxAngle:number,TimesDecimalPlaces:number?):{CFrame}
	local MoveTo:number = (10^(TimesDecimalPlaces or 0))
	MaxAngle = MaxAngle * MoveTo
	local tabl:{CFrame} = {}
	for i = 1,TotalTime/WaitsPerShot do
		tabl[#tabl+1] = CFrame.Angles(rad(rand(-MaxAngle,MaxAngle)/MoveTo),rad(rand(-MaxAngle,MaxAngle)/MoveTo),0)
	end
	return tabl
end


export type ModuleType = typeof(Equations)
return Equations
