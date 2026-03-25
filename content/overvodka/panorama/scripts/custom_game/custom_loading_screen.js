(function () {
    GameEvents.Subscribe("gamesetup", GameSetup);
    GameEvents.Subscribe("custom_loading_screen_state", OnCustomLoadingScreenState);
    GameEvents.Subscribe("game_rules_state_change", RefreshCustomLoadingScreenState);
    RefreshCustomLoadingScreenState();
    DisableSidebarHitTest();
})();

function GameSetup() {
    $.Schedule(1, GameSetup)
}
GameSetup()
var hittestBlocker = $.GetContextPanel().GetParent().FindChild("SidebarAndBattleCupLayoutContainer");

if (hittestBlocker) {
    hittestBlocker.hittest = false;
    hittestBlocker.hittestchildren = false;
}

function SetCustomLoadingScreenVisible(visible) {
    const panel = $.GetContextPanel();

    panel.style.visibility = visible ? "visible" : "collapse";
    panel.hittest = visible;
    panel.hittestchildren = visible;
}

function ShouldShowCustomLoadingScreen() {
    const state = Game.GetState();
    return state === DOTA_GameState.DOTA_GAMERULES_STATE_INIT ||
        state === DOTA_GameState.DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD || state === DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP;
}

function OnCustomLoadingScreenState(data) {
    SetCustomLoadingScreenVisible(!!data && Number(data.visible) === 1);
}

function RefreshCustomLoadingScreenState() {
    SetCustomLoadingScreenVisible(ShouldShowCustomLoadingScreen());
}

function DisableSidebarHitTest() {
    let panel = $.GetContextPanel();
    while (panel) {
        const hittestBlocker = panel.FindChildTraverse("SidebarAndBattleCupLayoutContainer");
        if (hittestBlocker) {
            hittestBlocker.hittest = false;
            hittestBlocker.hittestchildren = false;
            return;
        }
        panel = panel.GetParent();
    }
}
