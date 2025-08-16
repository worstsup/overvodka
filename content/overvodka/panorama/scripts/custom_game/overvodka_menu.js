"use strict";

var Menu = {};

(function() {
    const mainPanel = $("#MenuMainPanel");
    const OvervodkaHamster = $("#OvervodkaHamster");
    const ModelPreview = $("#ModelPreview");
    const ModelPreview2 = $("#ModelPreview2");
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

    $.CreatePanel("DOTAScenePanel", ModelPreview, "", { class: "hero_model_strategy", style: "width:48%;height:80%;", unit: "sans_arcana_loadout", particleonly:"false", renderdeferred:"false", antialias:"true", renderwaterreflections:"true", allowrotation: "true", drawbackground: "false" });
    ModelPreview.SetHasClass("Visible", false);
    $.CreatePanel("DOTAScenePanel", ModelPreview2, "", { class: "hero_model_strategy", style: "width:48%;height:80%;", unit: "invincible_arcana_loadout", particleonly:"false", renderdeferred:"false", antialias:"true", renderwaterreflections:"true", allowrotation: "true", drawbackground: "false" });
    ModelPreview2.SetHasClass("Visible", false);
    
    let isMenuOpen = false;
    let currentTab = null;

    Menu.Toggle = function() {
        isMenuOpen = !isMenuOpen;
        mainPanel.SetHasClass("Visible", isMenuOpen);
        OvervodkaHamster.SetHasClass("Visible", isMenuOpen);

        if (!isMenuOpen) {
            TipPreview.SetHasClass("Visible", false);
            DoubleRatingPreview.SetHasClass("Visible", false);
            ModelPreview.SetHasClass("Visible", false);
            ModelPreview2.SetHasClass("Visible", false);
        }
        Game.EmitSound("UUI_SOUNDS.OvervodkaMenu");

        if (isMenuOpen && currentTab === null) {
            Menu.SwitchTab('Leaderboard');
        }
        if (currentTab === 'Prime' && isMenuOpen) {
            ModelPreview.SetHasClass("Visible", true);
            ModelPreview2.SetHasClass("Visible", true);
            TipPreview.SetHasClass("Visible", true);
            DoubleRatingPreview.SetHasClass("Visible", true);
        }
    };

    Menu.SwitchTab = function(tabName) {
        if (currentTab === tabName) return;
        
        Game.EmitSound("ui_topmenu_select");
        currentTab = tabName;
        
        const isPrimeOpen = tabName === 'Prime';
        ModelPreview.SetHasClass("Visible", isPrimeOpen);
        ModelPreview2.SetHasClass("Visible", isPrimeOpen);
        TipPreview.SetHasClass("Visible", isPrimeOpen);
        DoubleRatingPreview.SetHasClass("Visible", isPrimeOpen);

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
