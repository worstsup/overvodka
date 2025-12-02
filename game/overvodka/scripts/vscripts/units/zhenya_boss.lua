function Spawn( entityKeyValues )
	Timers:CreateTimer(function()
		ZhenyaBossThink()
		return 0.4
	end)
end

function ZhenyaBossThink()
	if thisEntity:IsNull() then return end
end