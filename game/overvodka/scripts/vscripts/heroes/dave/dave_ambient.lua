LinkLuaModifier("modifier_dave_ambient", "heroes/dave/dave_ambient", LUA_MODIFIER_MOTION_NONE)

dave_ambient = class({})

function dave_ambient:GetIntrinsicModifierName()
    return "modifier_dave_ambient"
end

modifier_dave_ambient = class({})

function modifier_dave_ambient:IsHidden()
    return true
end

function modifier_dave_ambient:IsPurgable()
    return false
end

function modifier_dave_ambient:RemoveOnDeath()
    return false
end

if IsServer() then
    function modifier_dave_ambient:OnCreated()
        self.musicPlaying = "dave_ambient_1"
        self:StartMusicLoop()
        self:StartIntervalThink(1)
    end
    function modifier_dave_ambient:OnRefresh()
        self.musicPlaying = "dave_ambient_1"
        self:StartMusicLoop()
        self:StartIntervalThink(1)
    end
    function modifier_dave_ambient:OnDestroy()
        self:StopMusicLoop()
    end
    function modifier_dave_ambient:StartMusicLoop()
        if not self:GetParent():IsAlive() then
            self:StopMusicLoop()
            return
        end
        EmitSoundOn(self.musicPlaying, self:GetParent())
    end

    function modifier_dave_ambient:OnIntervalThink()
        if not self:GetParent():IsAlive() then
            self:StopMusicLoop()
            return
        end
        local gameTime = GameRules:GetDOTATime(false, false)
        if gameTime >= 600 and self.musicPlaying ~= "dave_ambient_2" then
            StopSoundOn(self.musicPlaying, self:GetParent())
            self.musicPlaying = "dave_ambient_2"
            EmitSoundOn(self.musicPlaying, self:GetParent())
        elseif gameTime < 600 and self.musicPlaying ~= "dave_ambient_1" then
            StopSoundOn(self.musicPlaying, self:GetParent())
            self.musicPlaying = "dave_ambient_1"
            EmitSoundOn(self.musicPlaying, self:GetParent())
        end
    end

    function modifier_dave_ambient:StopMusicLoop()
        StopSoundOn(self.musicPlaying, self:GetParent())
    end
end
