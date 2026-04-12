"use strict";

const GUIDE_SKILL_SUGGESTION_FALLBACK_INTERVAL = 0.15;
const GUIDE_TALENT_LEVELS = [10, 15, 20, 25];
const GUIDE_SKILL_TOOLTIP_SYNC_DELAY = 0.03;
const GUIDE_TOOLTIP_NOTE_EXCLUDED_ITEMS = new Set([
    "item_bag_of_gold",
    "item_bag_of_gold_2",
    "item_bag_of_gold_bablokrad",
    "item_treasure_chest",
    "item_chaos_orb",
    "item_zhenya_present",
]);

const GuideSkillSuggestionState = {
    heroScriptName: "",
    requestedHero: "",
    guide: null,
    updateScheduled: false,
    hoveredTooltipType: "",
    hoveredTooltipKey: "",
    tooltipSyncToken: 0,
    pendingTooltipKey: "",
};

function SetGuideAbilityTooltipDebug(payload) {
    try {
        const debug = Object.assign({
            hovered_tooltip_type: GuideSkillSuggestionState.hoveredTooltipType || "",
            hovered_tooltip_key: GuideSkillSuggestionState.hoveredTooltipKey || "",
            hero: GuideSkillSuggestionState.heroScriptName || "",
        }, payload || {});

        GameUI.CustomUIConfig().guide_ability_tooltip_debug = debug;
    } catch (e) {
    }
}

function GetGuideSuggestionHudRoot() {
    let panel = $.GetContextPanel();
    while (panel && panel.id !== "Hud") {
        panel = panel.GetParent();
    }
    return panel;
}

function FindGuideSuggestionHudElement(id) {
    const hud = GetGuideSuggestionHudRoot();
    return hud ? hud.FindChildTraverse(id) : null;
}

function IsGuideSuggestionPanelValid(panel) {
    return !!(panel && (!panel.IsValid || panel.IsValid()));
}

function ToGuideSuggestionArray(value) {
    if (Array.isArray(value)) {
        return value;
    }
    if (!value || typeof value !== "object") {
        return [];
    }
    return Object.keys(value)
        .sort((a, b) => Number(a) - Number(b))
        .map((key) => value[key]);
}

function NormalizeGuideSuggestionAbilityName(abilityName) {
    return NormalizeGuideAbilityNameShared(abilityName);
}

function NormalizeGuideTooltipItemName(itemName) {
    return NormalizeGuideItemNameShared(itemName);
}

function IsGuideTooltipNoteExcludedItem(itemName) {
    const normalizedItemName = NormalizeGuideTooltipItemName(itemName);
    return GUIDE_TOOLTIP_NOTE_EXCLUDED_ITEMS.has(normalizedItemName);
}

function NormalizeGuideTalentSide(side) {
    const normalized = typeof side === "string" ? side.toLowerCase() : "";
    return normalized === "left" || normalized === "right" ? normalized : "";
}

function SafeGetEntityAbilityPoints(entityIndex) {
    try {
        const points = Entities.GetAbilityPoints(entityIndex);
        return Number.isFinite(points) ? points : 0;
    } catch (e) {
        return 0;
    }
}

function SafeGetEntityLevel(entityIndex) {
    try {
        const level = Entities.GetLevel(entityIndex);
        return Number.isFinite(level) ? level : 0;
    } catch (e) {
        return 0;
    }
}

function GetGuideSuggestionHeroEntity() {
    const localPlayer = Players.GetLocalPlayer();
    const localHero = Players.GetPlayerHeroEntityIndex(localPlayer);
    if (!localHero || localHero === -1 || !Entities.IsValidEntity(localHero)) {
        return -1;
    }

    const portraitUnit = Players.GetLocalPlayerPortraitUnit();
    if (portraitUnit && portraitUnit !== -1 && portraitUnit !== localHero) {
        return -1;
    }

    return localHero;
}

function GetGuideSuggestionHeroScriptName(heroEntity) {
    if (!heroEntity || heroEntity === -1) {
        return "";
    }

    try {
        const unitName = Entities.GetUnitName(heroEntity) || "";
        return unitName.startsWith("npc_dota_hero_") ? unitName : "";
    } catch (e) {
        return "";
    }
}

function RequestGuideSkillSuggestion(heroScriptName) {
    if (!heroScriptName || GuideSkillSuggestionState.requestedHero === heroScriptName) {
        return;
    }

    GuideSkillSuggestionState.requestedHero = heroScriptName;
    GameEvents.SendCustomGameEventToServer("guides_request_skill_suggestion", {
        hero_script_name: heroScriptName,
    });
}

function GetAbilityPanelsContainer() {
    const abilitiesAndStatBranch = FindGuideSuggestionHudElement("AbilitiesAndStatBranch");
    return abilitiesAndStatBranch ? abilitiesAndStatBranch.FindChildTraverse("abilities") : null;
}

function GetGuideTalentRoot() {
    return FindGuideSuggestionHudElement("DOTAStatBranch");
}

function GetGuideSkillAbilityPanels() {
    const abilities = GetAbilityPanelsContainer();
    if (!abilities) {
        return [];
    }

    const panels = [];
    const childCount = abilities.GetChildCount ? abilities.GetChildCount() : 0;
    for (let i = 0; i < childCount; i++) {
        const panel = abilities.GetChild(i);
        const abilityImage = panel ? panel.FindChildTraverse("AbilityImage") : null;
        const abilityName = abilityImage && abilityImage.abilityname ? String(abilityImage.abilityname) : "";
        if (!abilityName) {
            continue;
        }

        panels.push({
            panel,
            buttonSize: panel.FindChildTraverse("ButtonSize"),
            abilityName,
        });
    }

    return panels;
}

function GetGuideSkillOverlay(panelData) {
    if (!panelData || !panelData.panel) {
        return null;
    }

    return panelData.panel.FindChildTraverse("RecommendedUpgradeOverlay")
        || (panelData.buttonSize ? panelData.buttonSize.FindChildTraverse("RecommendedUpgradeOverlay") : null);
}

function SetGuideSkillSuggestionPanelVisible(panelData, visible) {
    const overlay = GetGuideSkillOverlay(panelData);
    if (overlay) {
        overlay.visible = !!visible;
        overlay.style.visibility = visible ? "visible" : "collapse";
        overlay.style.opacity = visible ? "1" : "0";
    }
}

function HideAllGuideSkillSuggestionEffects() {
    const panels = GetGuideSkillAbilityPanels();
    for (const panelData of panels) {
        SetGuideSkillSuggestionPanelVisible(panelData, false);
    }
}

function NormalizeGuideTooltipNote(note) {
    return String(note || "").replace(/\r/g, "").trim();
}

function GetGuideAbilityTooltipRoot() {
    const panel = FindGuideSuggestionHudElement("AbilityDetails");
    return IsGuideSuggestionPanelValid(panel) ? panel : null;
}

function EnsureGuideAbilityTooltipNotePanels() {
    const tooltipRoot = GetGuideAbilityTooltipRoot();
    if (!tooltipRoot) {
        SetGuideAbilityTooltipDebug({ reason: "tooltip_root_missing" });
        return null;
    }

    const coreDetails = tooltipRoot.FindChildTraverse("AbilityCoreDetails");
    if (!coreDetails) {
        SetGuideAbilityTooltipDebug({ reason: "tooltip_core_missing" });
        return null;
    }

    let container = tooltipRoot.FindChildTraverse("GuideAbilityNoteContainer");
    if (!container) {
        container = $.CreatePanel("Panel", tooltipRoot, "GuideAbilityNoteContainer");
        container.style.flowChildren = "down";
        container.style.marginTop = "8px";
        container.style.marginBottom = "4px";
        container.style.paddingTop = "6px";
        container.style.paddingLeft = "0px";
        container.style.width = "100%";
        container.style.paddingRight = "0px";
        container.style.borderTop = "1px solid #3b3f47";
        container.style.visibility = "collapse";

        const header = $.CreatePanel("Label", container, "GuideAbilityNoteHeader");
        header.style.fontSize = "14px";
        header.style.fontWeight = "semi-bold";
        header.style.textTransform = "uppercase";
        header.style.color = "#9fb7d0";
        header.style.marginBottom = "2px";

        const note = $.CreatePanel("Label", container, "GuideAbilityNoteText");
        note.style.fontSize = "16px";
        note.style.color = "#dfe6ee";
        note.style.whiteSpace = "normal";
        note.style.width = "100%";
        note.style.lineHeight = "20px";
    }

    if (container.GetParent && container.GetParent() !== tooltipRoot) {
        container.SetParent(tooltipRoot);
    }

    const header = container.FindChildTraverse("GuideAbilityNoteHeader");
    const note = container.FindChildTraverse("GuideAbilityNoteText");
    if (!IsGuideSuggestionPanelValid(container) || !IsGuideSuggestionPanelValid(header) || !IsGuideSuggestionPanelValid(note)) {
        return null;
    }

    return { container, header, note };
}

function GetExistingGuideAbilityTooltipNotePanels() {
    const tooltipRoot = GetGuideAbilityTooltipRoot();
    if (!tooltipRoot) {
        return null;
    }

    const container = tooltipRoot.FindChildTraverse("GuideAbilityNoteContainer");
    if (!container) {
        return null;
    }

    const header = container.FindChildTraverse("GuideAbilityNoteHeader");
    const note = container.FindChildTraverse("GuideAbilityNoteText");
    if (!IsGuideSuggestionPanelValid(container) || !IsGuideSuggestionPanelValid(header) || !IsGuideSuggestionPanelValid(note)) {
        return null;
    }

    return { container, header, note };
}

function SetGuideAbilityTooltipNoteVisible(visible, note) {
    try {
        const panels = visible
            ? EnsureGuideAbilityTooltipNotePanels()
            : GetExistingGuideAbilityTooltipNotePanels();
        if (!panels || !panels.container || !panels.header || !panels.note) {
            if (visible) {
                SetGuideAbilityTooltipDebug({
                    reason: "tooltip_fields_missing",
                    has_container: !!(panels && panels.container),
                    has_header: !!(panels && panels.header),
                    has_comment: !!(panels && panels.note),
                });
            }
            return false;
        }

        const shouldShow = !!visible && !!note;
        panels.container.visible = shouldShow;
        panels.container.style.visibility = shouldShow ? "visible" : "collapse";
        panels.header.text = $.Localize("#GUIDE_SKILL_TOOLTIP_NOTE_HEADER");
        panels.note.text = shouldShow ? note : "";

        SetGuideAbilityTooltipDebug({
            reason: shouldShow ? "tooltip_note_applied" : "tooltip_note_hidden",
            has_header: true,
            note_length: shouldShow ? String(note).length : 0,
        });
        return true;
    } catch (e) {
        SetGuideAbilityTooltipDebug({
            reason: "tooltip_apply_failed",
            error: String(e),
        });
        return false;
    }
}

function HideGuideAbilityTooltipNote() {
    const panels = GetExistingGuideAbilityTooltipNotePanels();
    if (!panels) {
        return false;
    }

    panels.container.visible = false;
    panels.container.style.visibility = "collapse";
    panels.note.text = "";
    return true;
}

function GetGuideAbilityTooltipNote(guide, abilityName) {
    if (!guide || !abilityName) {
        return "";
    }

    const normalizedAbilityName = NormalizeGuideSuggestionAbilityName(abilityName);
    const abilityNotes = ToGuideSuggestionArray(guide.ability_notes);
    for (const entry of abilityNotes) {
        if (!entry || typeof entry.ability_script_name !== "string") {
            continue;
        }

        if (NormalizeGuideSuggestionAbilityName(entry.ability_script_name) !== normalizedAbilityName) {
            continue;
        }

        const note = NormalizeGuideTooltipNote(entry.note);
        if (note) {
            return note;
        }
    }

    const skillBuild = ToGuideSuggestionArray(guide.skill_build);
    for (const entry of skillBuild) {
        if (!entry || typeof entry.ability_script_name !== "string") {
            continue;
        }

        if (NormalizeGuideSuggestionAbilityName(entry.ability_script_name) !== normalizedAbilityName) {
            continue;
        }

        const note = NormalizeGuideTooltipNote(entry.note);
        if (note) {
            return note;
        }
    }

    return "";
}

function GetGuideItemTooltipNote(guide, itemName) {
    if (!guide || !itemName) {
        return "";
    }

    const normalizedItemName = NormalizeGuideTooltipItemName(itemName);
    if (IsGuideTooltipNoteExcludedItem(normalizedItemName)) {
        return "";
    }

    const sections = ToGuideSuggestionArray(guide.item_sections);
    for (const section of sections) {
        const items = ToGuideSuggestionArray(section && section.items);
        for (const entry of items) {
            if (!entry || typeof entry.item_name !== "string") {
                continue;
            }

            if (NormalizeGuideTooltipItemName(entry.item_name) !== normalizedItemName) {
                continue;
            }

            const note = NormalizeGuideTooltipNote(entry.note);
            if (note) {
                return note;
            }
        }
    }

    return "";
}

function SyncGuideTooltipNote(token, tooltipType, tooltipKey) {
    if (token !== GuideSkillSuggestionState.tooltipSyncToken) {
        return;
    }

    if (!tooltipType || !tooltipKey) {
        return;
    }

    if (GuideSkillSuggestionState.hoveredTooltipType !== tooltipType || GuideSkillSuggestionState.hoveredTooltipKey !== tooltipKey) {
        return;
    }

    const note = tooltipType === "item"
        ? GetGuideItemTooltipNote(GuideSkillSuggestionState.guide, tooltipKey)
        : GetGuideAbilityTooltipNote(GuideSkillSuggestionState.guide, tooltipKey);
    if (!note) {
        SetGuideAbilityTooltipDebug({
            reason: "note_not_found",
            tooltip_type: tooltipType,
            tooltip_key: tooltipKey,
        });
        HideGuideAbilityTooltipNote();
        return;
    }

    SetGuideAbilityTooltipNoteVisible(true, note);
}

function ScheduleGuideTooltipNoteSync(tooltipType, tooltipKey) {
    const pendingKey = `${tooltipType}:${tooltipKey}`;
    if (!tooltipType || !tooltipKey || GuideSkillSuggestionState.pendingTooltipKey === pendingKey) {
        return;
    }

    GuideSkillSuggestionState.pendingTooltipKey = pendingKey;
    const token = ++GuideSkillSuggestionState.tooltipSyncToken;
    $.Schedule(GUIDE_SKILL_TOOLTIP_SYNC_DELAY, () => {
        GuideSkillSuggestionState.pendingTooltipKey = "";
        try {
            SyncGuideTooltipNote(token, tooltipType, tooltipKey);
        } catch (e) {
            SetGuideAbilityTooltipDebug({
                reason: "tooltip_sync_failed",
                error: String(e),
                tooltip_type: tooltipType,
                tooltip_key: tooltipKey,
            });
        }
    });
}

function OnGuideAbilityTooltipShown(_panel, abilityName) {
    const normalizedAbilityName = NormalizeGuideSuggestionAbilityName(abilityName);
    if (!normalizedAbilityName) {
        return;
    }

    GuideSkillSuggestionState.hoveredTooltipType = "ability";
    GuideSkillSuggestionState.hoveredTooltipKey = normalizedAbilityName;
    SetGuideAbilityTooltipDebug({
        reason: "tooltip_event_show",
        ability_name: normalizedAbilityName,
    });
    ScheduleGuideTooltipNoteSync("ability", normalizedAbilityName);
}

function ExtractGuideTooltipItemName(args) {
    for (const arg of args) {
        if (typeof arg !== "string") {
            continue;
        }

        const normalized = NormalizeGuideTooltipItemName(arg);
        if (normalized.startsWith("item_")) {
            return normalized;
        }
    }

    return "";
}

function OnGuideItemTooltipShown(...args) {
    const itemName = ExtractGuideTooltipItemName(args);
    if (!itemName) {
        return;
    }

    if (IsGuideTooltipNoteExcludedItem(itemName)) {
        GuideSkillSuggestionState.hoveredTooltipType = "";
        GuideSkillSuggestionState.hoveredTooltipKey = "";
        GuideSkillSuggestionState.tooltipSyncToken++;
        GuideSkillSuggestionState.pendingTooltipKey = "";
        HideGuideAbilityTooltipNote();
        SetGuideAbilityTooltipDebug({
            reason: "item_tooltip_note_excluded",
            item_name: itemName,
        });
        return;
    }

    GuideSkillSuggestionState.hoveredTooltipType = "item";
    GuideSkillSuggestionState.hoveredTooltipKey = itemName;
    SetGuideAbilityTooltipDebug({
        reason: "item_tooltip_event_show",
        item_name: itemName,
    });
    ScheduleGuideTooltipNoteSync("item", itemName);
}

function OnGuideAbilityTooltipHidden() {
    GuideSkillSuggestionState.hoveredTooltipType = "";
    GuideSkillSuggestionState.hoveredTooltipKey = "";
    GuideSkillSuggestionState.tooltipSyncToken++;
    GuideSkillSuggestionState.pendingTooltipKey = "";
    SetGuideAbilityTooltipDebug({
        reason: "tooltip_event_hide",
    });
}

function GetGuideTalentOptionIndex(level) {
    const numericLevel = Number(level);
    const index = GUIDE_TALENT_LEVELS.indexOf(numericLevel);
    return index >= 0 ? index + 1 : 0;
}

function GetGuideTalentOptionPanel(level) {
    const root = GetGuideTalentRoot();
    const optionIndex = GetGuideTalentOptionIndex(level);
    if (!root || optionIndex <= 0) {
        return null;
    }

    const column = root.FindChildTraverse("StatBranchColumn");
    return column ? column.FindChildTraverse(`UpgradeOption${optionIndex}`) : null;
}

function CollectGuideTalentButtons(panel, out) {
    if (!panel) {
        return;
    }

    if (panel.BHasClass && panel.BHasClass("BranchChoice")) {
        out.push(panel);
    }

    const childCount = panel.GetChildCount ? panel.GetChildCount() : 0;
    for (let i = 0; i < childCount; i++) {
        CollectGuideTalentButtons(panel.GetChild(i), out);
    }
}

function GetGuideTalentButtons(optionPanel) {
    const buttons = [];
    CollectGuideTalentButtons(optionPanel, buttons);
    return buttons;
}

function FindGuideTalentButton(optionPanel, side) {
    const normalizedSide = NormalizeGuideTalentSide(side);
    if (!optionPanel || !normalizedSide) {
        return null;
    }

    const sideClass = normalizedSide === "left" ? "LeftBranch" : "RightBranch";
    const buttons = GetGuideTalentButtons(optionPanel);
    for (const button of buttons) {
        if (button.BHasClass && button.BHasClass(sideClass)) {
            return button;
        }
    }

    return null;
}

function IsGuideTalentButtonChosen(button) {
    return !!(button && button.BHasClass && (button.BHasClass("Chosen") || button.BHasClass("Activated")));
}

function IsGuideTalentOptionAlreadyChosen(optionPanel) {
    const buttons = GetGuideTalentButtons(optionPanel);
    return buttons.some((button) => IsGuideTalentButtonChosen(button));
}

function IsGuideTalentButtonAvailable(button) {
    if (!button || !button.BHasClass) {
        return false;
    }

    return !button.BHasClass("Disabled");
}

function GetGuideTalentOverlay(button) {
    return button ? button.FindChildTraverse("RecommendedUpgradeOverlay") : null;
}

function HideAllGuideTalentSuggestionOverlays() {
    for (const level of GUIDE_TALENT_LEVELS) {
        const optionPanel = GetGuideTalentOptionPanel(level);
        if (!optionPanel) {
            continue;
        }

        const buttons = GetGuideTalentButtons(optionPanel);
        for (const button of buttons) {
            const overlay = GetGuideTalentOverlay(button);
            if (overlay) {
                overlay.visible = false;
                overlay.style.visibility = "collapse";
                overlay.style.opacity = "0";
            }
        }
    }
}

function GetNextGuideSuggestionLevel(heroEntity) {
    const heroLevel = SafeGetEntityLevel(heroEntity);
    const abilityPoints = SafeGetEntityAbilityPoints(heroEntity);
    if (heroLevel <= 0 || abilityPoints <= 0) {
        return 0;
    }

    return Math.max(1, heroLevel - abilityPoints + 1);
}

function GetGuideAbilityPanelsWithLevels(heroEntity) {
    const panels = GetGuideSkillAbilityPanels();
    const result = [];

    for (const panelData of panels) {
        const abilityEntity = Entities.GetAbilityByName(heroEntity, panelData.abilityName);
        if (!abilityEntity || abilityEntity === -1) {
            result.push(Object.assign({}, panelData, {
                abilityEntity: -1,
                level: 0,
            }));
            continue;
        }

        let level = 0;
        try {
            level = Abilities.GetLevel(abilityEntity) || 0;
        } catch (e) {
            level = 0;
        }

        result.push(Object.assign({}, panelData, {
            abilityEntity,
            level,
        }));
    }

    return result;
}

function GetGuideRegularSkillBudget(heroEntity, panelDataList) {
    const abilityPoints = SafeGetEntityAbilityPoints(heroEntity);
    if (abilityPoints <= 0) {
        return 0;
    }

    let spentRegularPoints = 0;
    for (const panelData of panelDataList) {
        spentRegularPoints += Math.max(0, Number(panelData && panelData.level) || 0);
    }

    return spentRegularPoints + abilityPoints;
}

function GetOrderedGuideSkillEntries(guide) {
    return ToGuideSuggestionArray(guide && guide.skill_build)
        .map((entry) => {
            if (!entry || typeof entry.ability_script_name !== "string") {
                return null;
            }

            const abilityName = NormalizeGuideSuggestionAbilityName(entry.ability_script_name);
            if (!abilityName) {
                return null;
            }

            return Object.assign({}, entry, {
                ability_script_name: abilityName,
            });
        })
        .filter((entry) => !!entry)
        .sort((a, b) => Number(a.level || 0) - Number(b.level || 0));
}

function FindCatchUpGuideAbilityName(guide, heroEntity, panelDataList) {
    const orderedEntries = GetOrderedGuideSkillEntries(guide);
    if (!orderedEntries.length) {
        return "";
    }

    const budget = GetGuideRegularSkillBudget(heroEntity, panelDataList);
    if (budget <= 0) {
        return "";
    }

    const actualLevels = {};
    for (const panelData of panelDataList) {
        actualLevels[panelData.abilityName] = Math.max(0, Number(panelData.level) || 0);
    }

    const expectedLevels = {};
    const cappedLength = Math.min(budget, orderedEntries.length);
    for (let i = 0; i < cappedLength; i++) {
        const abilityName = orderedEntries[i].ability_script_name;
        expectedLevels[abilityName] = (expectedLevels[abilityName] || 0) + 1;

        if ((actualLevels[abilityName] || 0) < expectedLevels[abilityName]) {
            return abilityName;
        }
    }

    return "";
}

function GetOrderedGuideTalentChoices(guide) {
    return ToGuideSuggestionArray(guide && guide.talent_choices)
        .map((entry) => {
            if (!entry) {
                return null;
            }

            const level = Number(entry.level);
            const side = NormalizeGuideTalentSide(entry.side);
            if (!GUIDE_TALENT_LEVELS.includes(level) || !side) {
                return null;
            }

            return {
                level,
                side,
            };
        })
        .filter((entry) => !!entry)
        .sort((a, b) => a.level - b.level);
}

function FindCatchUpGuideTalentSuggestion(guide, heroEntity) {
    const heroLevel = SafeGetEntityLevel(heroEntity);
    if (heroLevel <= 0) {
        return null;
    }

    const orderedChoices = GetOrderedGuideTalentChoices(guide);
    for (const choice of orderedChoices) {
        if (choice.level > heroLevel) {
            continue;
        }

        const optionPanel = GetGuideTalentOptionPanel(choice.level);
        if (!optionPanel || IsGuideTalentOptionAlreadyChosen(optionPanel)) {
            continue;
        }

        const targetButton = FindGuideTalentButton(optionPanel, choice.side);
        if (!targetButton || !IsGuideTalentButtonAvailable(targetButton)) {
            continue;
        }

        return {
            level: choice.level,
            side: choice.side,
            button: targetButton,
        };
    }

    return null;
}

function CanGuideAbilityPanelBeHighlighted(panelData, heroEntity) {
    if (!panelData || !panelData.panel || !panelData.buttonSize) {
        return false;
    }

    if (panelData.panel.BHasClass && panelData.panel.BHasClass("CanLearn")) {
        return true;
    }

    const abilityEntity = Entities.GetAbilityByName(heroEntity, panelData.abilityName);
    if (!abilityEntity || abilityEntity === -1) {
        return false;
    }

    if (typeof Abilities.CanAbilityBeUpgraded === "function") {
        try {
            const result = Abilities.CanAbilityBeUpgraded(abilityEntity);
            if (result === true || result === 0) {
                return true;
            }
        } catch (e) {
        }
    }

    return true;
}

function UpdateGuideSkillSuggestion() {
    GuideSkillSuggestionState.updateScheduled = false;

    const heroEntity = GetGuideSuggestionHeroEntity();
    const heroScriptName = GetGuideSuggestionHeroScriptName(heroEntity);
    if (!heroScriptName) {
        GuideSkillSuggestionState.heroScriptName = "";
        GuideSkillSuggestionState.requestedHero = "";
        GuideSkillSuggestionState.guide = null;
        GuideSkillSuggestionState.hoveredTooltipType = "";
        GuideSkillSuggestionState.hoveredTooltipKey = "";
        GuideSkillSuggestionState.tooltipSyncToken++;
        GuideSkillSuggestionState.pendingTooltipKey = "";
        HideGuideAbilityTooltipNote();
        HideAllGuideSkillSuggestionEffects();
        HideAllGuideTalentSuggestionOverlays();
        return;
    }

    if (GuideSkillSuggestionState.heroScriptName !== heroScriptName) {
        GuideSkillSuggestionState.heroScriptName = heroScriptName;
        GuideSkillSuggestionState.requestedHero = "";
        GuideSkillSuggestionState.guide = null;
        RequestGuideSkillSuggestion(heroScriptName);
    }

    const guide = GuideSkillSuggestionState.guide;
    if (!guide || (guide.hero_script_name || "") !== heroScriptName) {
        HideAllGuideSkillSuggestionEffects();
        HideAllGuideTalentSuggestionOverlays();
        return;
    }

    const nextLevel = GetNextGuideSuggestionLevel(heroEntity);
    const talentSuggestion = FindCatchUpGuideTalentSuggestion(guide, heroEntity);
    HideAllGuideTalentSuggestionOverlays();
    if (talentSuggestion && talentSuggestion.button) {
        const talentOverlay = GetGuideTalentOverlay(talentSuggestion.button);
        if (talentOverlay) {
            talentOverlay.visible = true;
            talentOverlay.style.visibility = "visible";
            talentOverlay.style.opacity = "1";
        }
    }

    if (nextLevel <= 0) {
        HideAllGuideSkillSuggestionEffects();
        return;
    }

    const panels = GetGuideAbilityPanelsWithLevels(heroEntity);
    if (!panels.length) {
        HideAllGuideSkillSuggestionEffects();
        return;
    }

    const targetAbilityName = FindCatchUpGuideAbilityName(guide, heroEntity, panels);
    if (!targetAbilityName) {
        HideAllGuideSkillSuggestionEffects();
        return;
    }

    let highlighted = false;
    for (const panelData of panels) {
        const shouldHighlight = !highlighted &&
            panelData.abilityName === targetAbilityName &&
            CanGuideAbilityPanelBeHighlighted(panelData, heroEntity);

        SetGuideSkillSuggestionPanelVisible(panelData, shouldHighlight);
        highlighted = highlighted || shouldHighlight;
    }
}

function ScheduleGuideSkillSuggestionUpdate() {
    if (GuideSkillSuggestionState.updateScheduled) {
        return;
    }

    GuideSkillSuggestionState.updateScheduled = true;
    $.Schedule(0.0, UpdateGuideSkillSuggestion);
}

function OnGuideSkillSuggestionResponse(event) {
    const guide = event && event.guide ? event.guide : null;
    const heroScriptName = event && event.hero_script_name ? String(event.hero_script_name) : (guide && guide.hero_script_name) || "";
    if (!heroScriptName) {
        return;
    }

    if (GuideSkillSuggestionState.heroScriptName && heroScriptName !== GuideSkillSuggestionState.heroScriptName) {
        return;
    }

    GuideSkillSuggestionState.requestedHero = heroScriptName;
    GuideSkillSuggestionState.guide = guide;
    SetGuideAbilityTooltipDebug({
        reason: "guide_response",
        response_hero: heroScriptName,
        has_guide: !!guide,
        ability_notes_count: ToGuideSuggestionArray(guide && guide.ability_notes).length,
        skill_build_count: ToGuideSuggestionArray(guide && guide.skill_build).length,
    });
    if (GuideSkillSuggestionState.hoveredTooltipType && GuideSkillSuggestionState.hoveredTooltipKey) {
        ScheduleGuideTooltipNoteSync(
            GuideSkillSuggestionState.hoveredTooltipType,
            GuideSkillSuggestionState.hoveredTooltipKey
        );
    }
    ScheduleGuideSkillSuggestionUpdate();
}

function GuideSkillSuggestionThink() {
    const heroEntity = GetGuideSuggestionHeroEntity();
    const heroScriptName = GetGuideSuggestionHeroScriptName(heroEntity);

    if (heroScriptName && GuideSkillSuggestionState.requestedHero !== heroScriptName) {
        RequestGuideSkillSuggestion(heroScriptName);
    }

    ScheduleGuideSkillSuggestionUpdate();
    $.Schedule(GUIDE_SKILL_SUGGESTION_FALLBACK_INTERVAL, GuideSkillSuggestionThink);
}

(function () {
    GameEvents.Subscribe("guides_guide_response", OnGuideSkillSuggestionResponse);
    GameEvents.Subscribe("guides_skill_suggestion_response", OnGuideSkillSuggestionResponse);

    $.RegisterForUnhandledEvent("DOTAShowAbilityTooltipForEntityIndex", OnGuideAbilityTooltipShown);
    $.RegisterForUnhandledEvent("DOTAShowAbilityShopItemTooltip", OnGuideItemTooltipShown);
    $.RegisterForUnhandledEvent("DOTAHideAbilityTooltip", OnGuideAbilityTooltipHidden);

    GameEvents.Subscribe("dota_hero_ability_points_changed", ScheduleGuideSkillSuggestionUpdate);
    GameEvents.Subscribe("dota_player_gained_level", ScheduleGuideSkillSuggestionUpdate);
    GameEvents.Subscribe("dota_player_learned_ability", ScheduleGuideSkillSuggestionUpdate);
    GameEvents.Subscribe("dota_player_update_query_unit", ScheduleGuideSkillSuggestionUpdate);
    GameEvents.Subscribe("dota_player_update_selected_unit", ScheduleGuideSkillSuggestionUpdate);
    GameEvents.Subscribe("dota_portrait_ability_layout_changed", ScheduleGuideSkillSuggestionUpdate);

    $.Schedule(0.0, GuideSkillSuggestionThink);
})();
