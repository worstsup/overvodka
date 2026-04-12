const StrategyLinksRoot = $.GetContextPanel();
let StrategyLinksOriginalParent = null;
let strategyLinksDockToken = 0;

function EnsureStrategyLinksOriginalParent() {
    if (
        StrategyLinksOriginalParent &&
        StrategyLinksOriginalParent.IsValid &&
        StrategyLinksOriginalParent.IsValid()
    ) {
        return StrategyLinksOriginalParent;
    }

    if (StrategyLinksRoot && StrategyLinksRoot.GetParent) {
        const parent = StrategyLinksRoot.GetParent();
        if (parent && parent.IsValid && parent.IsValid()) {
            StrategyLinksOriginalParent = parent;
        }
    }

    return StrategyLinksOriginalParent;
}

function TryDockStrategyLinks(token, retriesLeft) {
    if (token !== strategyLinksDockToken) {
        return;
    }

    const originalParent = EnsureStrategyLinksOriginalParent();
    if (!(originalParent && originalParent.IsValid && originalParent.IsValid())) {
        return;
    }

    const strategyScreen = FindDotaHudElement("StrategyScreen");
    if (strategyScreen && strategyScreen.IsValid && strategyScreen.IsValid()) {
        if (StrategyLinksRoot.GetParent() !== strategyScreen) {
            StrategyLinksRoot.SetParent(strategyScreen);
        }

        StrategyLinksRoot.SetHasClass("Ready", true);
        return;
    }

    StrategyLinksRoot.SetHasClass("Ready", false);

    if (retriesLeft > 0) {
        $.Schedule(0.15, () => {
            TryDockStrategyLinks(token, retriesLeft - 1);
        });
    }
}

function InitializeStrategyLinks() {
    strategyLinksDockToken += 1;
    TryDockStrategyLinks(strategyLinksDockToken, 40);
}

InitializeStrategyLinks();
