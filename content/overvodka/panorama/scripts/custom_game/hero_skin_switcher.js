const HeroSkinSwitcherRoot = $.GetContextPanel();
let HeroSkinSwitcherOriginalParent = null;
let HeroSkinSwitcherPanel = null;
let HeroSkinBaseButton = null;
let HeroSkinSpecialButton = null;
let HeroSkinBaseButtonLabel = null;
let HeroSkinSpecialButtonLabel = null;
let HeroSkinWarningPanel = null;
let HeroSkinWarningLabel = null;
let HeroSkinSubscribeButton = null;
let HeroSkinSubscribeButtonLabel = null;
let HeroSkinSubscribeButtonIcon = null;
let HeroSkinSubscribeButtonPrice = null;
let HeroSkinSwitcherUpdateToken = 0;
let HeroSkinSwitcherPulseToken = 0;
let HeroSkinSwitcherWarningToken = 0;
let HeroSkinPendingPurchaseItemId = null;
let HeroSkinPendingEquipItemId = null;
let HeroSkinPendingEquipRequestItemId = null;

const HEROES_WITH_NO_FACET = {
    necrolyte: true,
    skeleton_king: true,
    bloodseeker: true,
    ursa: true,
    zuus: true,
    tidehunter: true,
    beastmaster: true,
    abaddon: true,
    bounty_hunter: true,
    warlock: true,
    antimage: true,
    morphling: true,
    faceless_void: true,
    bristleback: true,
    nyx_assassin: true,
    kunkka: true,
    axe: true,
    tusk: true,
    primal_beast: true,
    mars: true,
    slardar: true,
    lion: true,
    omniknight: true,
    ogre_magi: true,
    earthshaker: true,
    meepo: true,
    hoodwink: true,
    phantom_lancer: true,
    terrorblade: true,
    ringmaster: true,
    void_spirit: true,
    slark: true,
    spectre: true,
    puck: true,
    templar_assassin: true,
    brewmaster: true,
    juggernaut: true,
    tinker: true,
    winter_wyvern: true,
    ancient_apparition: true,
    storm_spirit: true,
    sniper: true,
    rattletrap: true,
    riki: true,
    rubick: true,
};

function GetFacetHeroShortName(heroName) {
    return String(heroName || "").replace(/^npc_dota_hero_/, "");
}

function HasHeroFacet(heroName) {
    const heroShortName = GetFacetHeroShortName(heroName);
    return !!heroShortName && !HEROES_WITH_NO_FACET[heroShortName];
}

function EnsureHeroSkinSwitcherOriginalParent() {
    if (
        HeroSkinSwitcherOriginalParent &&
        HeroSkinSwitcherOriginalParent.IsValid &&
        HeroSkinSwitcherOriginalParent.IsValid()
    ) {
        return HeroSkinSwitcherOriginalParent;
    }

    if (HeroSkinSwitcherRoot && HeroSkinSwitcherRoot.GetParent) {
        const parent = HeroSkinSwitcherRoot.GetParent();
        if (parent && parent.IsValid && parent.IsValid()) {
            HeroSkinSwitcherOriginalParent = parent;
        }
    }

    return HeroSkinSwitcherOriginalParent;
}

function UpdateHeroSkinSwitcherDock() {
    if (!(HeroSkinSwitcherRoot && HeroSkinSwitcherRoot.GetParent && HeroSkinSwitcherRoot.SetParent)) {
        return;
    }

    const originalParent = EnsureHeroSkinSwitcherOriginalParent();
    if (!(originalParent && originalParent.IsValid && originalParent.IsValid())) {
        return;
    }

    let targetParent = originalParent;
    if (Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_STRATEGY_TIME)) {
        const strategyScreen = FindDotaHudElement("StrategyScreen");
        if (strategyScreen && strategyScreen.IsValid && strategyScreen.IsValid()) {
            targetParent = strategyScreen;
        }
    }

    if (HeroSkinSwitcherRoot.GetParent() !== targetParent) {
        HeroSkinSwitcherRoot.SetParent(targetParent);
    }
}

function EnsureHeroSkinSwitcherPanels() {
    if (
        HeroSkinSwitcherPanel &&
        HeroSkinSwitcherPanel.IsValid &&
        HeroSkinSwitcherPanel.IsValid() &&
        HeroSkinBaseButton &&
        HeroSkinBaseButton.IsValid &&
        HeroSkinBaseButton.IsValid() &&
        HeroSkinSpecialButton &&
        HeroSkinSpecialButton.IsValid &&
        HeroSkinSpecialButton.IsValid() &&
        HeroSkinBaseButtonLabel &&
        HeroSkinBaseButtonLabel.IsValid &&
        HeroSkinBaseButtonLabel.IsValid() &&
        HeroSkinSpecialButtonLabel &&
        HeroSkinSpecialButtonLabel.IsValid &&
        HeroSkinSpecialButtonLabel.IsValid() &&
        HeroSkinWarningPanel &&
        HeroSkinWarningPanel.IsValid &&
        HeroSkinWarningPanel.IsValid() &&
        HeroSkinWarningLabel &&
        HeroSkinWarningLabel.IsValid &&
        HeroSkinWarningLabel.IsValid() &&
        HeroSkinSubscribeButton &&
        HeroSkinSubscribeButton.IsValid &&
        HeroSkinSubscribeButton.IsValid() &&
        HeroSkinSubscribeButtonLabel &&
        HeroSkinSubscribeButtonLabel.IsValid &&
        HeroSkinSubscribeButtonLabel.IsValid() &&
        HeroSkinSubscribeButtonIcon &&
        HeroSkinSubscribeButtonIcon.IsValid &&
        HeroSkinSubscribeButtonIcon.IsValid() &&
        HeroSkinSubscribeButtonPrice &&
        HeroSkinSubscribeButtonPrice.IsValid &&
        HeroSkinSubscribeButtonPrice.IsValid()
    ) {
        return true;
    }

    HeroSkinSwitcherPanel = HeroSkinSwitcherRoot.FindChildTraverse("HeroSkinSwitcher");
    HeroSkinBaseButton = HeroSkinSwitcherRoot.FindChildTraverse("HeroSkinBaseButton");
    HeroSkinSpecialButton = HeroSkinSwitcherRoot.FindChildTraverse("HeroSkinSpecialButton");
    HeroSkinBaseButtonLabel = HeroSkinSwitcherRoot.FindChildTraverse("HeroSkinBaseButtonLabel");
    HeroSkinSpecialButtonLabel = HeroSkinSwitcherRoot.FindChildTraverse("HeroSkinSpecialButtonLabel");
    HeroSkinWarningPanel = HeroSkinSwitcherRoot.FindChildTraverse("HeroSkinSwitcherWarning");
    HeroSkinWarningLabel = HeroSkinSwitcherRoot.FindChildTraverse("HeroSkinSwitcherWarningLabel");
    HeroSkinSubscribeButton = HeroSkinSwitcherRoot.FindChildTraverse("HeroSkinSubscribeButton");
    HeroSkinSubscribeButtonLabel = HeroSkinSwitcherRoot.FindChildTraverse("HeroSkinSubscribeButtonLabel");
    HeroSkinSubscribeButtonIcon = HeroSkinSwitcherRoot.FindChildTraverse("HeroSkinSubscribeButtonIcon");
    HeroSkinSubscribeButtonPrice = HeroSkinSwitcherRoot.FindChildTraverse("HeroSkinSubscribeButtonPrice");

    return !!(
        HeroSkinSwitcherPanel &&
        HeroSkinBaseButton &&
        HeroSkinSpecialButton &&
        HeroSkinBaseButtonLabel &&
        HeroSkinSpecialButtonLabel &&
        HeroSkinWarningPanel &&
        HeroSkinWarningLabel &&
        HeroSkinSubscribeButton &&
        HeroSkinSubscribeButtonLabel &&
        HeroSkinSubscribeButtonIcon &&
        HeroSkinSubscribeButtonPrice
    );
}

function GetHeroSkinSwitcherLocalHeroName() {
    const localPlayerId = GetOvervodkaLocalPlayerID();
    const playerInfo = Game.GetPlayerInfo(localPlayerId) || Game.GetLocalPlayerInfo();
    if (!playerInfo) {
        return "";
    }

    return String(playerInfo.player_selected_hero || "");
}

function GetHeroSkinSwitcherModelLoadoutPanel() {
    return FindDotaHudElement("HeroModelLoadout");
}

function IsHeroSkinSwitcherPanelAlive(panel) {
    return !!(panel && (!panel.IsValid || panel.IsValid()));
}

function ClearHeroSkinSwitcherPreviewModel() {
    const strategyScreen = FindDotaHudElement("StrategyScreen");
    const existingPanel = strategyScreen ? strategyScreen.FindChildTraverse("custom_hero_model_panel") : null;
    if (IsHeroSkinSwitcherPanelAlive(existingPanel)) {
        existingPanel.DeleteAsync(0);
    }

    const heroModelLoadout = GetHeroSkinSwitcherModelLoadoutPanel();
    if (heroModelLoadout) {
        heroModelLoadout.style.visibility = "visible";
    }
}

function RefreshHeroSkinSwitcherPreviewModel(heroName) {
    const localPlayerId = GetOvervodkaLocalPlayerID();
    const config = GetHeroSkinConfig(heroName);
    const strategyScreen = FindDotaHudElement("StrategyScreen");
    const heroModelLoadout = GetHeroSkinSwitcherModelLoadoutPanel();
    if (!strategyScreen || !heroModelLoadout || !config) {
        ClearHeroSkinSwitcherPreviewModel();
        return;
    }

    if (!IsSpecialHeroSkinEquippedForPlayer(localPlayerId, heroName)) {
        ClearHeroSkinSwitcherPreviewModel();
        return;
    }

    heroModelLoadout.style.visibility = "collapse";

    const desiredUnit = config.previewUnit;
    const existingPanel = strategyScreen.FindChildTraverse("custom_hero_model_panel");
    if (IsHeroSkinSwitcherPanelAlive(existingPanel)) {
        const currentUnit = existingPanel.GetAttributeString("overvodka_unit", "");
        if (currentUnit === desiredUnit) {
            existingPanel.style.visibility = "visible";
            return;
        }

        existingPanel.DeleteAsync(0);
    }

    const customModelPanel = $.CreatePanel("DOTAScenePanel", strategyScreen, "custom_hero_model_panel", {
        class: "hero_model_strategy",
        style: "width:45%;height:100%;margin-top:0px;",
        drawbackground: true,
        unit: desiredUnit,
        particleonly: "false",
        renderdeferred: "false",
        antialias: "true",
        renderwaterreflections: "true",
        allowrotation: "true"
    });
    customModelPanel.SetAttributeString("overvodka_unit", desiredUnit);

    try {
        const firstChild = strategyScreen.GetChild(0);
        if (firstChild && strategyScreen.MoveChildBefore) {
            strategyScreen.MoveChildBefore(customModelPanel, firstChild);
        }
    } catch (error) {
    }
}

function ApplyHeroSkinSwitcherSelection(heroName, equipSpecialSkin) {
    const config = GetHeroSkinConfig(heroName);
    const localPlayerId = GetOvervodkaLocalPlayerID();
    if (!config) {
        return;
    }

    SetLocalHeroSkinSelectionOverride(heroName, equipSpecialSkin ? config.itemId : null);
    RequestHeroSkinSwitcherPreviewSound(heroName, equipSpecialSkin);

    const actuallyEquippedSpecialSkin = GetEquippedSkinForPlayer(localPlayerId) === config.itemId;
    const hasSpecialSkinAccess = HasAccessToSpecialHeroSkin(localPlayerId, heroName);

    if (equipSpecialSkin) {
        if (hasSpecialSkinAccess && !actuallyEquippedSpecialSkin) {
            GameEvents.SendCustomGameEventToServer("store_equip_item", {
                item_id: config.itemId,
                item_type: "skins"
            });
        }
    } else {
        if (actuallyEquippedSpecialSkin) {
            GameEvents.SendCustomGameEventToServer("store_unequip_item", {
                item_type: "skins"
            });
        }
    }

    RefreshHeroSkinSwitcherState();
    RefreshHeroSkinSwitcherPreviewModel(heroName);
}

function RequestHeroSkinSwitcherPreviewSound(heroName, equipSpecialSkin) {
    if (heroName !== "npc_dota_hero_morphling" && heroName !== "npc_dota_hero_bounty_hunter") {
        return;
    }

    GameEvents.SendCustomGameEventToServer("hero_skin_switcher_preview_sound", {
        hero_name: heroName,
        preview_special_skin: equipSpecialSkin ? 1 : 0
    });
}

function HideHeroSkinPrimeWarning() {
    if (!HeroSkinWarningPanel) {
        return;
    }

    HeroSkinSwitcherWarningToken++;
    HeroSkinWarningPanel.SetHasClass("Visible", false);
}

function ShowHeroSkinPrimeWarning(textToken) {
    if (!HeroSkinWarningPanel || !HeroSkinWarningLabel) {
        return;
    }

    HeroSkinWarningLabel.text = $.Localize(textToken || "#HeroSkinToggle_PrimeOnly");
    const warningToken = ++HeroSkinSwitcherWarningToken;
    HeroSkinWarningPanel.SetHasClass("Visible", true);

    $.Schedule(5, function () {
        if (warningToken !== HeroSkinSwitcherWarningToken) {
            return;
        }

        HideHeroSkinPrimeWarning();
    });
}

function PlayHeroSkinSwitcherButtonFeedback(buttonPanel) {
    Game.EmitSound("UUI_SOUNDS.SkinChange");

    if (!buttonPanel) {
        return;
    }

    const pulseToken = ++HeroSkinSwitcherPulseToken;
    buttonPanel.SetHasClass("ButtonPulse", false);
    $.Schedule(0.0, function () {
        if (pulseToken !== HeroSkinSwitcherPulseToken || !buttonPanel || (buttonPanel.IsValid && !buttonPanel.IsValid())) {
            return;
        }

        buttonPanel.SetHasClass("ButtonPulse", true);
        $.Schedule(0.09, function () {
            if (!buttonPanel || (buttonPanel.IsValid && !buttonPanel.IsValid())) {
                return;
            }

            buttonPanel.SetHasClass("ButtonPulse", false);
        });
    });
}

function OpenHeroSkinPrimeSubscribe() {
    $.DispatchEvent("ExternalBrowserGoToURL", "https://t.me/overvodka_bot");
}

function GetHeroSkinActionState(heroName, playerId) {
    const config = GetHeroSkinConfig(heroName);
    if (!config || !IsSpecialHeroSkinEquippedForPlayer(playerId, heroName) || HasAccessToSpecialHeroSkin(playerId, heroName)) {
        return null;
    }

    if (config.accessType === "prime") {
        return {
            kind: "prime",
            warningTextToken: "#HeroSkinToggle_PrimeOnly",
            buttonTextToken: "#Store_Need_Prime_Button",
            iconSrc: "file://{images}/custom_game/tg_icon.png",
            priceText: "",
        };
    }

    const itemData = GetStoreItemData(config.itemId);
    const priceValue = itemData && typeof itemData.price !== "undefined" ? itemData.price : config.price;
    return {
        kind: "purchase",
        warningTextToken: "#HeroSkinToggle_NotOwned",
        buttonTextToken: "#Store_Buy_Item",
        iconSrc: "file://{images}/custom_game/subscribe_button.png",
        priceText: typeof priceValue !== "undefined" && priceValue !== null ? String(priceValue) : "",
    };
}

function OnHeroSkinActionButtonClick(heroName, playerId) {
    const config = GetHeroSkinConfig(heroName);
    const actionState = GetHeroSkinActionState(heroName, playerId);
    if (!config || !actionState) {
        return;
    }

    Game.EmitSound("ui.option_toggle");

    if (actionState.kind === "prime") {
        OpenHeroSkinPrimeSubscribe();
        return;
    }

    HeroSkinPendingPurchaseItemId = config.itemId;
    HideHeroSkinPrimeWarning();
    GameEvents.SendCustomGameEventToServer("store_buy_item", {
        item_id: config.itemId,
    });
}

function RefreshHeroSkinSwitcherState() {
    UpdateHeroSkinSwitcherDock();
    if (!EnsureHeroSkinSwitcherPanels()) {
        return;
    }

    const heroName = GetHeroSkinSwitcherLocalHeroName();
    const localPlayerId = GetOvervodkaLocalPlayerID();
    const config = GetHeroSkinConfig(heroName);
    const shouldShow = Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_STRATEGY_TIME) && !!config;
    const heroHasFacet = HasHeroFacet(heroName);

    HeroSkinSwitcherRoot.SetHasClass("Visible", shouldShow);
    HeroSkinSwitcherRoot.SetHasClass("HasFacet", heroHasFacet);
    HeroSkinSwitcherRoot.visible = shouldShow;

    if (!shouldShow) {
        ClearHeroSkinSwitcherPreviewModel();
        HideHeroSkinPrimeWarning();
        HeroSkinSubscribeButton.SetHasClass("Visible", false);
        HeroSkinSubscribeButton.SetHasClass("HasPrice", false);
        HeroSkinSubscribeButton.SetHasClass("IsPrimeAction", false);
        HeroSkinSubscribeButton.SetHasClass("IsPurchaseAction", false);
        HeroSkinSubscribeButton.hittest = false;
        return;
    }

    const hasSpecialSkin = IsSpecialHeroSkinEquippedForPlayer(localPlayerId, heroName);
    const hasSpecialSkinAccess = HasAccessToSpecialHeroSkin(localPlayerId, heroName);
    const actionState = GetHeroSkinActionState(heroName, localPlayerId);
    const shouldShowSubscribeButton = !!actionState;

    HeroSkinBaseButtonLabel.text = $.Localize(config.baseLabel);
    HeroSkinSpecialButtonLabel.text = $.Localize(config.specialLabel);
    if (actionState) {
        HeroSkinWarningLabel.text = $.Localize(actionState.warningTextToken);
    } else {
        HideHeroSkinPrimeWarning();
    }

    HeroSkinBaseButton.SetHasClass("IsSelected", !hasSpecialSkin);
    HeroSkinSpecialButton.SetHasClass("IsSelected", hasSpecialSkin);
    HeroSkinSpecialButton.enabled = true;
    HeroSkinSpecialButton.SetHasClass("IsDisabled", !hasSpecialSkinAccess);
    HeroSkinSubscribeButton.SetHasClass("Visible", shouldShowSubscribeButton);
    HeroSkinSubscribeButton.SetHasClass("HasPrice", !!(actionState && actionState.priceText));
    HeroSkinSubscribeButton.SetHasClass("IsPrimeAction", !!(actionState && actionState.kind === "prime"));
    HeroSkinSubscribeButton.SetHasClass("IsPurchaseAction", !!(actionState && actionState.kind === "purchase"));
    HeroSkinSubscribeButton.hittest = shouldShowSubscribeButton;
    HeroSkinSubscribeButtonLabel.text = $.Localize(actionState ? actionState.buttonTextToken : "#Store_Need_Prime_Button");
    HeroSkinSubscribeButtonPrice.text = actionState ? actionState.priceText : "";
    HeroSkinSubscribeButtonIcon.SetImage(actionState ? actionState.iconSrc : "file://{images}/custom_game/tg_icon.png");
    HeroSkinSubscribeButton.SetPanelEvent("onactivate", function () {
        OnHeroSkinActionButtonClick(heroName, localPlayerId);
    });

    HeroSkinBaseButton.SetPanelEvent("onactivate", function () {
        if (!IsSpecialHeroSkinEquippedForPlayer(localPlayerId, heroName)) {
            return;
        }

        HideHeroSkinPrimeWarning();
        PlayHeroSkinSwitcherButtonFeedback(HeroSkinBaseButton);
        ApplyHeroSkinSwitcherSelection(heroName, false);
    });

    HeroSkinSpecialButton.SetPanelEvent("onactivate", function () {
        if (IsSpecialHeroSkinEquippedForPlayer(localPlayerId, heroName)) {
            return;
        }

        PlayHeroSkinSwitcherButtonFeedback(HeroSkinSpecialButton);
        if (!HasAccessToSpecialHeroSkin(localPlayerId, heroName)) {
            ShowHeroSkinPrimeWarning(actionState ? actionState.warningTextToken : "#HeroSkinToggle_PrimeOnly");
        } else {
            HideHeroSkinPrimeWarning();
        }
        ApplyHeroSkinSwitcherSelection(heroName, true);
    });

    RefreshHeroSkinSwitcherPreviewModel(heroName);
}

function RunHeroSkinSwitcherUpdateLoop() {
    const token = ++HeroSkinSwitcherUpdateToken;

    function Tick() {
        if (token !== HeroSkinSwitcherUpdateToken) {
            return;
        }

        RefreshHeroSkinSwitcherState();
        $.Schedule(0.1, Tick);
    }

    Tick();
}

(function () {
    GameEvents.Subscribe("dota_player_hero_selection_dirty", RefreshHeroSkinSwitcherState);
    GameEvents.Subscribe("dota_player_update_hero_selection", RefreshHeroSkinSwitcherState);
    GameEvents.Subscribe("store_buy_response", function (data) {
        const itemId = data && data.item_id ? data.item_id : HeroSkinPendingPurchaseItemId;
        if (!itemId || itemId !== HeroSkinPendingPurchaseItemId) {
            return;
        }

        HeroSkinPendingPurchaseItemId = null;

        if (data.success) {
            Game.EmitSound("General.Buy");
            HideHeroSkinPrimeWarning();
            HeroSkinPendingEquipItemId = itemId;
            HeroSkinPendingEquipRequestItemId = null;
        } else {
            Game.EmitSound("UUI_SOUNDS.NoMoney");
        }

        RefreshHeroSkinSwitcherState();
    });
    CustomNetTables.SubscribeNetTableListener("player_data", function (tableName, key, data) {
        const localSteamId = GetSteamID32(GetOvervodkaLocalPlayerID()).toString();
        if (key !== localSteamId) {
            return;
        }

        const heroName = GetHeroSkinSwitcherLocalHeroName();
        const config = GetHeroSkinConfig(heroName);
        const pendingEquipItemId = HeroSkinPendingEquipItemId;
        const inventory = data && data.inventory ? data.inventory : null;
        const equippedSkin = data && data.equipped_skin ? data.equipped_skin : null;
        const shouldKeepPurchasedPreview =
            pendingEquipItemId &&
            config &&
            config.itemId === pendingEquipItemId &&
            inventory &&
            inventory[pendingEquipItemId];

        if (shouldKeepPurchasedPreview) {
            SetLocalHeroSkinSelectionOverride(heroName, pendingEquipItemId);

            if (equippedSkin === pendingEquipItemId) {
                HeroSkinPendingEquipItemId = null;
                HeroSkinPendingEquipRequestItemId = null;
                ClearLocalHeroSkinSelectionOverrides();
            } else if (HeroSkinPendingEquipRequestItemId !== pendingEquipItemId) {
                HeroSkinPendingEquipRequestItemId = pendingEquipItemId;
                GameEvents.SendCustomGameEventToServer("store_equip_item", {
                    item_id: pendingEquipItemId,
                    item_type: "skins"
                });
            }

            RefreshHeroSkinSwitcherState();
            RefreshHeroSkinSwitcherPreviewModel(heroName);
            return;
        }

        ClearLocalHeroSkinSelectionOverrides();
        RefreshHeroSkinSwitcherState();
        RefreshHeroSkinSwitcherPreviewModel(heroName);
    });

    RunHeroSkinSwitcherUpdateLoop();
})();
