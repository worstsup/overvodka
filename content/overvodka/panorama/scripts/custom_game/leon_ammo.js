"use strict";

let Container = null;
let UISCALE_X = 1;
let UISCALE_Y = 1;

const LEON_Q_CHARGE_CD = [3.0, 2.6, 2.2, 1.8, 1.4];

function GetLeonQChargeCdByLevel(ab) {
    let lvl = 0;
    try { lvl = Abilities.GetLevel(ab) || 0; } catch (e) { lvl = 0; }

    lvl = Math.max(1, Math.min(LEON_Q_CHARGE_CD.length, lvl));
    return LEON_Q_CHARGE_CD[lvl - 1];
}

const LeonAbilityCache = new Map();

function SafeGetAbilityName(ab) {
    try { return Abilities.GetAbilityName(ab) || ""; }
    catch (e) { return ""; }
}

function GetLeonQAbility(unit) {
    if (!Entities.IsValidEntity(unit)) return -1;

    const cached = LeonAbilityCache.get(unit);
    if (cached !== undefined && cached !== -1) {
        if (SafeGetAbilityName(cached) === "leon_q") return cached;
        LeonAbilityCache.delete(unit);
    }

    const count = Entities.GetAbilityCount(unit);
    for (let i = 0; i < count; i++) {
        const ab = Entities.GetAbility(unit, i);
        if (ab !== -1 && SafeGetAbilityName(ab) === "leon_q") {
            LeonAbilityCache.set(unit, ab);
            return ab;
        }
    }

    LeonAbilityCache.set(unit, -1);
    return -1;
}

function GetOrCreatePanel(unit) {
    const id = `leon_ammo_unit_${unit}`;
    let p = Container.FindChildTraverse(id);
    if (p) return p;

    p = $.CreatePanel("Panel", Container, id, { hittest: "false" });
    p.unit = unit;
    p.BLoadLayoutSnippet("LeonAmmoUnitSnippet");

    p._checked = true;
    return p;
}

function DeletePanel(unit) {
    const id = `leon_ammo_unit_${unit}`;
    const p = Container.FindChildTraverse(id);
    if (p) p.DeleteAsync(0);
}

function SetFill(panel, idx, pct) {
    const fill = panel.FindChildTraverse(`Fill${idx}`);
    if (!fill) return;
    pct = Math.max(0, Math.min(1, pct));
    fill.style.width = `${pct * 100}%`;
}

function UpdateUiScale() {
    let p = $.GetContextPanel();
    while (p) {
        if (p.actualuiscale_x !== undefined) {
            UISCALE_X = p.actualuiscale_x;
            UISCALE_Y = p.actualuiscale_y;
            return;
        }
        p = p.GetParent();
    }
}

function UpdateOneData(unit) {
    const ab = GetLeonQAbility(unit);
    if (ab === -1) {
        DeletePanel(unit);
        return;
    }

    const panel = GetOrCreatePanel(unit);
    panel._checked = true;

    if (!Entities.IsAlive(unit)) {
        panel.AddClass("Hidden");
        return;
    }

    const cur = Abilities.GetCurrentAbilityCharges(ab);
    const max = Abilities.GetMaxAbilityCharges(ab);
    const rem = Abilities.GetAbilityChargeRestoreTimeRemaining(ab);

    const tot = GetLeonQChargeCdByLevel(ab);

    for (let i = 1; i <= 3; i++) {
        if (i <= cur) {
            SetFill(panel, i, 1);
        } else if (i === cur + 1 && cur < max && tot > 0) {
            const prog = 1.0 - (rem / tot);
            SetFill(panel, i, prog);
        } else {
            SetFill(panel, i, 0);
        }
    }
}

function UpdateOnePosition(panel) {
    const unit = panel.unit;
    if (unit === undefined || unit === null || !Entities.IsValidEntity(unit)) {
        panel.DeleteAsync(0);
        return;
    }

    if (!Entities.IsAlive(unit)) {
        panel.AddClass("Hidden");
        return;
    }

    const origin = Entities.GetAbsOrigin(unit);
    if (!origin) {
        panel.AddClass("Hidden");
        return;
        }

    let hb = Entities.GetHealthBarOffset(unit) || 0;
    if (Entities.IsIllusion(unit)) hb -= 10;
    const worldZ = origin[2] + hb + 10;

    const sx = Game.WorldToScreenX(origin[0], origin[1], worldZ);
    const sy = Game.WorldToScreenY(origin[0], origin[1], worldZ);

    const bIsOutScreen = (GameUI.GetScreenWorldPosition(sx, sy) == null);
    panel.SetHasClass("Hidden", bIsOutScreen);
    if (bIsOutScreen) return;

    const x = (sx - (37 * UISCALE_Y)) / UISCALE_X;
    const y = (sy - (4  * UISCALE_Y)) / UISCALE_Y;

    panel.style.position = `${x}px ${y}px 0`;
}

function ThinkData() {
    $.Schedule(0.05, ThinkData);

    UpdateUiScale();

    for (let i = Container.GetChildCount() - 1; i >= 0; i--) {
        const p = Container.GetChild(i);
        if (p) p._checked = false;
    }

    const heroes = Entities.GetAllHeroEntities();
    for (const unit of heroes) {
        if (!Entities.IsValidEntity(unit)) continue;
        if (Entities.GetUnitName(unit) !== "npc_dota_hero_hoodwink") continue;

        UpdateOneData(unit);
    }

    for (let i = Container.GetChildCount() - 1; i >= 0; i--) {
        const p = Container.GetChild(i);
        if (!p) continue;
        const unit = p.unit;
        if (!p._checked) {
            p.DeleteAsync(0);
        }
    }
}

function ThinkPosition() {
    $.Schedule(0.0, ThinkPosition);

    UpdateUiScale();

    for (let i = Container.GetChildCount() - 1; i >= 0; i--) {
        const p = Container.GetChild(i);
        if (!p) continue;
        UpdateOnePosition(p);
    }
}

(function () {
    Container = $.GetContextPanel().FindChildTraverse("LeonAmmoContainer");
    if (!Container) {
        $.Msg("[leon_ammo] No LeonAmmoContainer panel found");
        return;
    }

    ThinkData();
    ThinkPosition();
})();
