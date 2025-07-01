"use strict";

// Create a global object to hold all Menu functions
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
        Prime: $("#Content_Prime")
    };
    const tabButtons = {
        Leaderboard: $("#TabButton_Leaderboard"),
        ChatWheel: $("#TabButton_ChatWheel"),
        Prime: $("#TabButton_Prime")
    };
    let scene_panel = $.CreatePanel("DOTAScenePanel", $("#ModelPreview"), "", { 
        class: "hero_model_strategy", 
        style: "width:48%;height:80%;",
        unit: "sans_arcana_loadout", 
        particleonly:"false", 
        renderdeferred:"false", 
        antialias:"true", 
        renderwaterreflections:"true", 
        allowrotation: "true",
        drawbackground: "false"
    });
    ModelPreview.style.visibility = "collapse";
    let scene_panel_2 = $.CreatePanel("DOTAScenePanel", $("#ModelPreview2"), "", { 
        class: "hero_model_strategy", 
        style: "width:48%;height:80%;",
        unit: "invincible_arcana_loadout", 
        particleonly:"false", 
        renderdeferred:"false", 
        antialias:"true", 
        renderwaterreflections:"true", 
        allowrotation: "true",
        drawbackground: "false"
    });
    ModelPreview2.style.visibility = "collapse";
    let isMenuOpen = false;
    let currentTab = null;
    let isPrimeOpen = false;

    /**
     * Toggles the entire menu's visibility.
     */
    Menu.Toggle = function() {
        isMenuOpen = !isMenuOpen;
        mainPanel.SetHasClass("Visible", isMenuOpen);
        OvervodkaHamster.SetHasClass("Visible", isMenuOpen);
        if (!isMenuOpen){
            TipPreview.SetHasClass("Visible", false);
            DoubleRatingPreview.SetHasClass("Visible", false);
            ModelPreview.style.visibility = "collapse";
            ModelPreview2.style.visibility = "collapse";
        }
        Game.EmitSound("ui_general_button_click");

        // If we are opening the menu for the first time, switch to a default tab
        if (isMenuOpen && currentTab === null) {
            Menu.SwitchTab('Leaderboard');
        }
        if (currentTab === 'Prime' && isMenuOpen) {
            ModelPreview.style.visibility = "visible";
            ModelPreview2.style.visibility = "visible";
            TipPreview.SetHasClass("Visible", true);
            DoubleRatingPreview.SetHasClass("Visible", true);
        }
    };

    /**
     * Switches the visible content panel.
     * @param {string} tabName - The name of the tab to switch to ('Leaderboard', 'ChatWheel', 'Prime').
     */
    Menu.SwitchTab = function(tabName) {
        if (currentTab === tabName) return;
        
        Game.EmitSound("ui_topmenu_select");
        currentTab = tabName;
        isPrimeOpen = tabName === 'Prime';
        ModelPreview.style.visibility = "collapse";
        ModelPreview2.style.visibility = "collapse";
        TipPreview.SetHasClass("Visible", isPrimeOpen);
        DoubleRatingPreview.SetHasClass("Visible", isPrimeOpen);
        for (const [name, button] of Object.entries(tabButtons)) {
            button.SetHasClass("Selected", name === tabName);
        }

        for (const [name, panel] of Object.entries(contentPanels)) {
            panel.SetHasClass("Visible", name === tabName);
        }

        if (tabName === 'Leaderboard') {
            if (Leaderboard && Leaderboard.Initialize) {
                Leaderboard.Initialize();
            }
        } else if (tabName === 'ChatWheel') {
            // This calls the function from your chat_wheel.js
            if (ChatWheel && ChatWheel.Initialize) {
                ChatWheel.Initialize();
            }
        }
        else if (tabName === 'Prime'){
            if (Prime && Prime.Initialize) {
                Prime.Initialize();
                if(ModelPreview.style.visibility == "visible"){
                    ModelPreview.style.visibility = "collapse";
                }else{
                    ModelPreview.style.visibility = "visible";
                }
                if(ModelPreview2.style.visibility == "visible"){
                    ModelPreview2.style.visibility = "collapse";
                }else{
                    ModelPreview2.style.visibility = "visible";
                }
            }
        }
    };
})();
