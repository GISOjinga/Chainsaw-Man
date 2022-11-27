local Debris = game:GetService("Debris")
local Anchor = {}


function Anchor:SetPropertyEnabled(items:{LinearVelocity:boolean?,AlignPosition:boolean?,AlignOrientation:boolean?})
	for i,v in pairs(self.Anchor:GetChildren()) do
		v.Enabled = items[v.Name]
	end
end

function Anchor:LookAt(cframe:CFrame)
	self:SetPropertyEnabled({AlignOrientation=true})
	self.Anchor.AlignOrientation.CFrame = cframe
	return self
end


function Anchor:SetMultiplier(Number:number)
	self.ForceMultiplier = Number
	return self
end

function Anchor:SetRigidRotation(boolean:number)
	self.Anchor.AlignOrientation.RigidityEnabled = boolean
	return self
end


function Anchor:PivotTo(targetCFrame:CFrame)
	self:SetPropertyEnabled({AlignPosition=true,AlignOrientation=true})
	self.Anchor.AlignPosition.Position = targetCFrame.Position
	self.Anchor.AlignOrientation.CFrame = targetCFrame
	return self
end

function Anchor:MoveTo(position:Vector3)
	self:SetPropertyEnabled({AlignPosition=true})
	self.Anchor.AlignPosition.Position = position
	return self
end


function Anchor:SetVelocity(direction:Vector3,rotateTowards:CFrame?)
	self:SetPropertyEnabled({LinearVelocity=true,AlignOrientation=rotateTowards and true})
	if rotateTowards then self.Anchor.AlignOrientation.CFrame = rotateTowards end
	if self.Anchor.LinearVelocity.VelocityConstraintMode == Enum.VelocityConstraintMode.Line then
		self.Anchor.LinearVelocity.LineVelocity = direction.Magnitude
		self.Anchor.LinearVelocity.LineDirection = direction.Unit
	elseif self.Anchor.LinearVelocity.VelocityConstraintMode == Enum.VelocityConstraintMode.Vector then
		self.Anchor.LinearVelocity.VectorVelocity = direction
	end
	return self
end


function Anchor:GetMass(part:BasePart?):number
	local ConnectedParts:{BasePart} = ((part or self.Anchor.Parent)::BasePart):GetConnectedParts()::any
	local TotalMass = ((part or self.Anchor.Parent)::BasePart):GetMass()
	for i = 1,#ConnectedParts do TotalMass+=ConnectedParts[i]:GetMass()end
	return TotalMass
end

function Anchor:SetForce(Amount:number)
	self.Anchor.AlignPosition.MaxForce = Amount
	self.Anchor.LinearVelocity.MaxForce = Amount
	return self
end

function Anchor:Disable()
	self:SetPropertyEnabled({})
	self:SetForce(0)
	return self
end

function Anchor:Enable()
	self:ResetForce()
	return self
end

function Anchor:Destroy(part:BasePart?)
	if self.Anchor then self.Anchor:Destroy() end
	table.clear(self)
end

function Anchor:ResetForce(part:BasePart?)
	local TotalMass = (self:GetMass(part)*workspace.Gravity)*self.ForceMultiplier*10
	self.Anchor.AlignPosition.Position = (part or self.Anchor.Parent).Position
	self.Anchor.AlignPosition.MaxForce = TotalMass
	self.Anchor.LinearVelocity.MaxForce = TotalMass
	return self
end



local Opperator = {
	new = function(parent:BasePart,duration:number?,...)
		local anchor = Instance.new("Attachment")
		local AlignOrientation, AlignPosition, LinearVelocity = Instance.new("AlignOrientation"), Instance.new("AlignPosition"), Instance.new("LinearVelocity")
		AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment; AlignOrientation.Attachment0 = anchor; AlignOrientation.MaxTorque = math.huge; AlignOrientation.Responsiveness = 30; AlignOrientation.PrimaryAxisOnly = false; AlignOrientation.ReactionTorqueEnabled = false; AlignOrientation.RigidityEnabled = false; AlignOrientation.Enabled = false;
		AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment; AlignPosition.Attachment0 = anchor; AlignPosition.MaxForce = math.huge; AlignPosition.Responsiveness = 200; AlignPosition.ApplyAtCenterOfMass = false; AlignPosition.ReactionForceEnabled = false; AlignPosition.RigidityEnabled = false; AlignPosition.Enabled = false;
		LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World; LinearVelocity.Attachment0 = anchor; LinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; LinearVelocity.MaxForce = math.huge; LinearVelocity.Enabled = false;

		AlignOrientation.Parent = anchor; AlignPosition.Parent = anchor; LinearVelocity.Parent = anchor;
		local Object = setmetatable({},{
			__index=Anchor,
		})
		Object.__newindex = function(table, index, value)
			rawset(table,index,value)
			if index == "ForceMultiplier" then Object:ResetForce() end
		end
		
		Object.ForceMultiplier=1
		Object.Anchor = anchor
		
		Object:ResetForce(parent)
		
		anchor.Parent = parent
		if duration then Debris:AddItem(anchor,duration)end-- prepares item for distruction
		
		return Object::typeof(Object)
	end
}

export type ModuleType = typeof(Opperator.new( (nil::any)() ))
return Opperator