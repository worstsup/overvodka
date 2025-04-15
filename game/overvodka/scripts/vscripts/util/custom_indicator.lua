local BEHAVIOR_EVENT_START = 0;
local BEHAVIOR_EVENT_UPDATE = 1;
local BEHAVIOR_EVENT_END = 2;

if not CustomIndicator then
	CustomIndicator = {}
end

function CustomIndicator:Init()
	if self.initialized then return end
	print('inited custom indicator')
	self.initialized = true
	self.listeners = {}
	ListenToGameEvent("custom_indicator", Dynamic_Wrap(CustomIndicator, 'PanoramaListener'), self)
end

function CustomIndicator:RegisterAbility( ability )
	local ability_index = ability:entindex()
	self.listeners[ ability_index ] = ability
end

function CustomIndicator:PanoramaListener( data )
	local ability = self.listeners[ data.ability ]
	if ability then
		local pos = Vector( data.worldX, data.worldY, data.worldZ )
		local unit = nil
		if data.unit then
			unit = EntIndexToHScript( data.unit )
		end

		if data.event==BEHAVIOR_EVENT_START then
			if ability.CreateCustomIndicator then
				ability:CreateCustomIndicator( pos, unit, data.behavior )
			end
		elseif data.event==BEHAVIOR_EVENT_UPDATE then
			if ability.UpdateCustomIndicator then
				ability:UpdateCustomIndicator( pos, unit, data.behavior )
			end
		elseif data.event==BEHAVIOR_EVENT_END then
			if ability.DestroyCustomIndicator then
				ability:DestroyCustomIndicator( pos, unit, data.behavior )
			end
		end
	end
end

CustomIndicator:Init()

return CustomIndicator