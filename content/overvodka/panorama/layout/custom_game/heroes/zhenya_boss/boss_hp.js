"use strict";

(function () {
    const DEFAULT_BOSS_DATA = {
        entindex: -1,
        end_time: 0,
        boss_modifier: "modifier_zhenya_boss",
        phase2_modifier: "modifier_zhenya_boss_phase2",
        name: "#npc_zhenya_boss",
        avatar: "file://{images}/custom_game/zhenya_boss_avatar.png",
        avatar_phase2: "file://{images}/custom_game/zhenya_boss_avatar_angry.png",
        theme: "",
    };

    let gBossData = null;
    let gUpdateHandle = null;

    function GetBossPanel() {
        return $.GetContextPanel().FindChildTraverse("BossHPPanel");
    }

    function GetAvatarImage() {
        const panel = GetBossPanel();
        return panel ? panel.FindChildTraverse("BossAvatarImage") : null;
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

        gBossData = null;
        gUpdateHandle = null;
    }

    function LocalizeText(text) {
        if (!text) {
            return "";
        }

        return text[0] === "#" ? $.Localize(text) : text;
    }

    function NormalizeBossData(data) {
        return {
            entindex: Number(data.entindex || DEFAULT_BOSS_DATA.entindex),
            end_time: Number(data.end_time || DEFAULT_BOSS_DATA.end_time),
            boss_modifier: data.boss_modifier || data.required_modifier || DEFAULT_BOSS_DATA.boss_modifier,
            phase2_modifier: data.phase2_modifier || DEFAULT_BOSS_DATA.phase2_modifier,
            name: data.name || DEFAULT_BOSS_DATA.name,
            avatar: data.avatar || DEFAULT_BOSS_DATA.avatar,
            avatar_phase2: data.avatar_phase2 || data.avatar || DEFAULT_BOSS_DATA.avatar_phase2,
            theme: data.theme || DEFAULT_BOSS_DATA.theme,
            spawn_time: Game.GetGameTime(),
        };
    }

    function ApplyBossPresentation() {
        const panel = GetBossPanel();
        if (!panel || !gBossData) {
            return;
        }

        panel.SetHasClass("BossThemeBloody", gBossData.theme === "bloody");

        const nameLabel = panel.FindChildTraverse("BossNameLabel");
        if (nameLabel) {
            nameLabel.text = LocalizeText(gBossData.name);
        }

        const avatar = GetAvatarImage();
        if (avatar) {
            avatar.SetImage(gBossData.avatar);
        }

        const divider = panel.FindChildTraverse("BossHPPhaseDivider");
        if (divider) {
            divider.style.visibility = gBossData.phase2_modifier ? "visible" : "collapse";
        }
    }

    function OnHeroBossSpawned(data) {
        gBossData = NormalizeBossData(data || {});
        if (gBossData.entindex === -1) {
            HideBossPanel();
            return;
        }

        ApplyBossPresentation();
        ShowBossPanel();

        if (!gUpdateHandle) {
            gUpdateHandle = $.Schedule(0.03, BossHpThink);
        }
    }

    function OnZhenyaBossSpawned(data) {
        OnHeroBossSpawned(data || {});
    }

    function OnHeroBossCleared() {
        HideBossPanel();
    }

    function BossHpThink() {
        const panel = GetBossPanel();
        if (!panel || !gBossData) {
            gUpdateHandle = null;
            return;
        }

        const entindex = gBossData.entindex;
        const now = Game.GetGameTime();

        if (!Entities.IsValidEntity(entindex)) {
            if ((now - gBossData.spawn_time) <= 0.75) {
                gUpdateHandle = $.Schedule(0.03, BossHpThink);
                return;
            }

            HideBossPanel();
            return;
        }

        if (!Entities.IsAlive(entindex) && (now - gBossData.spawn_time) > 0.5) {
            HideBossPanel();
            return;
        }

        const hp = Entities.GetHealth(entindex);
        const maxHp = Entities.GetMaxHealth(entindex);
        const hpBar = panel.FindChildTraverse("BossHPProgress");

        if (hpBar && maxHp > 0) {
            hpBar.value = hp / maxHp;
            $("#hp_burner_container").style.width = hp / maxHp * 595 + "px";
        }

        const timerLabel = panel.FindChildTraverse("BossTimerLabel");
        if (timerLabel) {
            if (gBossData.end_time > 0) {
                let remaining = Math.floor(gBossData.end_time - now);
                if (remaining < 0) {
                    remaining = 0;
                }

                if (remaining > 0) {
                    const minutes = Math.floor(remaining / 60);
                    const seconds = remaining % 60;
                    timerLabel.text = (minutes < 10 ? "0" : "") + minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
                } else {
                    timerLabel.text = "";
                }
            } else {
                timerLabel.text = "";
            }
        }

        const avatar = GetAvatarImage();
        if (avatar) {
            const phase2 = gBossData.phase2_modifier && HasModifierOnUnit(entindex, gBossData.phase2_modifier);
            avatar.SetImage(phase2 ? gBossData.avatar_phase2 : gBossData.avatar);
        }

        gUpdateHandle = $.Schedule(0.03, BossHpThink);
    }

    (function Init() {
        GameEvents.Subscribe("hero_boss_event_spawned", OnHeroBossSpawned);
        GameEvents.Subscribe("hero_boss_event_cleared", OnHeroBossCleared);
        GameEvents.Subscribe("zhenya_boss_spawned", OnZhenyaBossSpawned);
    })();
})();
