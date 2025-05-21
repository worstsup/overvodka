(function () {
    GameEvents.Subscribe("gamesetup", GameSetup )
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
