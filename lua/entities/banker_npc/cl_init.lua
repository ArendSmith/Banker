include( "shared.lua" )

function ENT:Initialize()
	self.AutomaticFrameAdvance = true
end

function ENT:Draw()
	self:DrawModel()
end
