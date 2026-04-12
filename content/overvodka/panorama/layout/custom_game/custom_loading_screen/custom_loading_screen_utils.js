const dotaLoadingScreen = (() => {
    let panel = $.GetContextPanel();
    while (panel) {
        if (panel.id === "LoadingScreen") {
            return panel;
        }
        panel = panel.GetParent();
    }
    return $.GetContextPanel();
})();

const FindDotaHudElementInLS = (id) => {
    return dotaLoadingScreen && dotaLoadingScreen.FindChildTraverse
        ? dotaLoadingScreen.FindChildTraverse(id)
        : null;
};
