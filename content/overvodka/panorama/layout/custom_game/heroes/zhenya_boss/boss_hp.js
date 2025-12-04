"use strict";

(function () {
    const BOSS_MODIFIER_NAME      = "modifier_zhenya_boss";
    const BOSS_PHASE2_MODIFIER    = "modifier_zhenya_boss_phase2";

    let gBossEntIndex   = -1;
    let gBossEndTime    = 0;
    let gBossSpawnTime  = 0;
    let gUpdateHandle   = null;

    function GetBossPanel() {
        return $.GetContextPanel().FindChildTraverse("BossHPPanel");
    }

    function ShowBossPanel() {
        const panel = GetBossPanel();
        if (panel) {
            panel.AddClass("BossHPVisible");
        }
    }

    function HideBossPanel() {
        const panel = GetBossPanel();
        if (panel) {
            panel.RemoveClass("BossHPVisible");
        }
        gBossEntIndex  = -1;
        gBossEndTime   = 0;
        gBossSpawnTime = 0;
        gUpdateHandle  = null;
    }

    function OnZhenyaBossSpawned(data) {

        gBossEntIndex  = data.entindex || -1;
        gBossEndTime   = data.end_time || 0;
        gBossSpawnTime = Game.GetGameTime();

        if (gBossEntIndex === -1) {
            $.Msg("[BossHP] invalid entindex, hiding");
            HideBossPanel();
            return;
        }

        const panel = GetBossPanel();
        if (!panel) {
            $.Msg("[BossHP] BossHPPanel not found!");
            return;
        }

        ShowBossPanel();

        if (!gUpdateHandle) {
            gUpdateHandle = $.Schedule(0.03, BossHpThink);
        }
    }

    function BossHpThink() {
        const panel = GetBossPanel();
        if (!panel) {
            gUpdateHandle = null;
            return;
        }
        const now = Game.GetGameTime();
        if (!Entities.IsAlive(gBossEntIndex) && (now - gBossSpawnTime) > 0.5) {
            $.Msg("[BossHP] BossHPPanel not alive!");
            HideBossPanel();
            return;
        }

        const hasBossModifier = HasModifierOnUnit(gBossEntIndex, BOSS_MODIFIER_NAME);

        if (!hasBossModifier && (now - gBossSpawnTime) > 0.5) {
            HideBossPanel();
            return;
        }

        const hp    = Entities.GetHealth(gBossEntIndex);
        const maxHp = Entities.GetMaxHealth(gBossEntIndex);
        const hpBar = panel.FindChildTraverse("BossHPProgress");

        if (hpBar && maxHp > 0) {
            hpBar.value = hp / maxHp;
             $("#hp_burner_container").style.width = hp / maxHp * 595 + "px";
        }

        const timerLabel = panel.FindChildTraverse("BossTimerLabel");
        if (timerLabel && gBossEndTime && gBossEndTime > 0) {
            let remaining = Math.floor(gBossEndTime - now);
            if (remaining < 0) remaining = 0;

            if (remaining > 0) {
                const min = Math.floor(remaining / 60);
                const sec = remaining % 60;
                const mm  = (min < 10 ? "0" : "") + min;
                const ss  = (sec < 10 ? "0" : "") + sec;
                timerLabel.text = mm + ":" + ss;
            } else {
                timerLabel.text = "";
            }
        }

        const avatar = panel.FindChildTraverse("BossAvatarImage");
        if (avatar) {
            const hasPhase2 = HasModifierOnUnit(gBossEntIndex, BOSS_PHASE2_MODIFIER);
            if (hasPhase2) {
                avatar.AddClass("BossAvatarAngry");
            } else {
                avatar.RemoveClass("BossAvatarAngry");
            }
        }

        gUpdateHandle = $.Schedule(0.03, BossHpThink);
    }

    (function Init() {
        GameEvents.Subscribe("zhenya_boss_spawned", OnZhenyaBossSpawned);
    })();
})();
