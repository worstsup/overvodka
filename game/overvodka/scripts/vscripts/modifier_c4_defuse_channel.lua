modifier_c4_defuse_channel = class({})

function modifier_c4_defuse_channel:IsHidden() return true end
function modifier_c4_defuse_channel:IsPurgable() return false end
function modifier_c4_defuse_channel:OnCreated(kv)
    if not IsServer() then return end
    self.channel_time = self:GetAbility():GetLevelSpecialValueFor("defuse_time", self:GetAbility():GetLevel() - 1)
    self:StartIntervalThink(self.channel_time)
end

function modifier_c4_defuse_channel:OnIntervalThink()
    if not IsServer() then return end

    local bomb = self:GetParent()
    local defuser = self:GetCaster()

    -- Successfully defuse the bomb
    local defuse_particle = "particles/units/heroes/hero_techies/techies_defuse.vpcf"
    local sound_defuse = "Hero_Techies.StasisTrap.Stun"
    EmitSoundOn(sound_defuse, bomb)
    bomb:RemoveModifierByName("modifier_c4_bomb")
    bomb:ForceKill(false)
end