"use strict";

var Menu = {};

(function() {
    const mainPanel = $("#MenuMainPanel");
    const OvervodkaHamster = $("#OvervodkaHamster");
    const ModelPreview3 = $("#ModelPreview3");
    const ModelPreview = $("#ModelPreview");
    const ModelPreview2 = $("#ModelPreview2");
    const ModelPreview4 = $("#ModelPreview4");
    const TipPreview = $("#TipPreview");
    const DoubleRatingPreview = $("#DoubleRatingPreview");
    
    const contentPanels = {
        Leaderboard: $("#Content_Leaderboard"),
        ChatWheel: $("#Content_ChatWheel"),
        Store: $("#Content_Store"),
        Prime: $("#Content_Prime"),
        Vote: $("#Content_Vote")
    };
    const tabButtons = {
        Leaderboard: $("#TabButton_Leaderboard"),
        ChatWheel: $("#TabButton_ChatWheel"),
        Store: $("#TabButton_Store"),
        Prime: $("#TabButton_Prime"),
        Vote: $("#TabButton_Vote")
    };

    function EnsurePrimePreviewScene(parentPanel, panelId, desiredUnit, style) {
        let previewPanel = parentPanel.FindChildTraverse(panelId);
        if (previewPanel) {
            const currentUnit = previewPanel.GetAttributeString("overvodka_unit", "");
            if (currentUnit === desiredUnit) {
                return previewPanel;
            }

            previewPanel.DeleteAsync(0);
        }

        previewPanel = $.CreatePanel("DOTAScenePanel", parentPanel, panelId, {
            class: "hero_model_strategy",
            style: style,
            unit: desiredUnit,
            particleonly: "false",
            renderdeferred: "false",
            antialias: "true",
            renderwaterreflections: "true",
            allowrotation: "true",
            drawbackground: "false"
        });
        previewPanel.SetAttributeString("overvodka_unit", desiredUnit);
        return previewPanel;
    }

    function RefreshPrimePreviewUnits() {
        EnsurePrimePreviewScene(ModelPreview3, "PrimePreviewArsenScene", "arsen_skin_loadout", "width:70%;height:90%;");
        EnsurePrimePreviewScene(
            ModelPreview,
            "PrimePreviewSansScene",
            "sans_arcana_loadout",
            "width:48%;height:80%;"
        );
        EnsurePrimePreviewScene(
            ModelPreview2,
            "PrimePreviewInvincibleScene",
            "invincible_arcana_loadout",
            "width:48%;height:80%;"
        );
        EnsurePrimePreviewScene(ModelPreview4, "PrimePreviewMacanScene", "macan_arcana_loadout", "width:70%;height:95%;");
    }

    RefreshPrimePreviewUnits();
    ModelPreview3.SetHasClass("Visible", false);
    ModelPreview.SetHasClass("Visible", false);
    ModelPreview2.SetHasClass("Visible", false);
    ModelPreview4.SetHasClass("Visible", false);

    const primePreviewPanels = [
        ModelPreview3,
        ModelPreview,
        ModelPreview2,
        ModelPreview4,
        TipPreview,
        DoubleRatingPreview
    ];

    function SetPrimePreviewVisible(isVisible) {
        for (let i = 0; i < primePreviewPanels.length; i++) {
            primePreviewPanels[i].SetHasClass("Visible", isVisible);
        }
    }
    
    let isMenuOpen = false;
    let currentTab = null;

    Menu.Toggle = function() {
        isMenuOpen = !isMenuOpen;
        mainPanel.SetHasClass("Visible", isMenuOpen);
        OvervodkaHamster.SetHasClass("Visible", isMenuOpen);
        RefreshPrimePreviewUnits();

        if (!isMenuOpen) {
            SetPrimePreviewVisible(false);
            if (Store && Store.HideCoinsTooltip) {
                Store.HideCoinsTooltip();
            }
            if (typeof CasesChestAnimation !== "undefined" && CasesChestAnimation && CasesChestAnimation.Close) {
                CasesChestAnimation.Close();
            }
        }
        Game.EmitSound("UUI_SOUNDS.OvervodkaMenu");

        if (isMenuOpen && currentTab === null) {
            Menu.SwitchTab('Leaderboard');
        }
        else {
            SetPrimePreviewVisible(currentTab === 'Prime' && isMenuOpen);
        }
    };

    Menu.SwitchTab = function(tabName) {
        if (currentTab === tabName) return;
        
        Game.EmitSound("ui_topmenu_select");
        currentTab = tabName;
        RefreshPrimePreviewUnits();
        
        const isPrimeOpen = tabName === 'Prime';
        SetPrimePreviewVisible(isPrimeOpen);
        if (Store && Store.HideCoinsTooltip && tabName !== 'Store') {
            Store.HideCoinsTooltip();
        }
        if (tabName !== 'Store' && typeof CasesChestAnimation !== "undefined" && CasesChestAnimation && CasesChestAnimation.Close) {
            CasesChestAnimation.Close();
        }

        for (const name in tabButtons) {
            tabButtons[name].SetHasClass("Selected", name === tabName);
            contentPanels[name].SetHasClass("Visible", name === tabName);
        }

        if (tabName === 'Leaderboard' && Leaderboard && Leaderboard.Initialize) {
            Leaderboard.Initialize();
        } else if (tabName === 'ChatWheel' && ChatWheel && ChatWheel.Initialize) {
            ChatWheel.Initialize();
        } else if (tabName === 'Store' && Store && Store.Initialize) {
            Store.Initialize();
        } else if (tabName === 'Prime' && Prime && Prime.Initialize) {
            Prime.Initialize();
        } else if (tabName === 'Vote' && Vote && Vote.Initialize) {
            Vote.Initialize();
        }
    };
})();
