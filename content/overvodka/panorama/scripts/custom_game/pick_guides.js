const PickGuidesRoot = $.GetContextPanel();
let PickGuidesFrame = null;
let PickGuidesHeader = null;
let PickGuidesButton = null;
let PickGuidesStatePanel = null;
let PickGuidesSelectedTitle = null;
let PickGuidesSelectedMeta = null;
let PickGuidesPicker = null;
let PickGuidesPickerContent = null;
let PickGuidesPickerSearchWrap = null;
let PickGuidesPickerList = null;
let PickGuidesPickerPagination = null;
let PickGuidesPickerSearchEntry = null;
let PickGuidesPickerSearchPlaceholder = null;
let PickGuidesPickerFavoritesButton = null;
let PickGuidesPreview = null;
let PickGuidesPreviewHeroImage = null;
let PickGuidesPreviewTitle = null;
let PickGuidesPreviewMeta = null;
let PickGuidesPreviewBody = null;
let PickGuidesPreviewLoading = null;
let PickGuidesPreviewContent = null;
let PickGuidesPreviewSkillsBlock = null;
let PickGuidesPreviewSkillsList = null;
let PickGuidesPreviewTalentsBlock = null;
let PickGuidesPreviewTalentsList = null;
let PickGuidesPreviewItemsBlock = null;
let PickGuidesPreviewItemsSections = null;
let PickGuidesStrategyItemsGuide = null;
let PickGuidesStrategyItemsSuggestions = null;
let PickGuidesStrategyOriginalItemsSuggestionsText = null;
let PickGuidesOriginalParent = null;

const PICK_GUIDE_SECTION_TITLES = {
    starting: "#SHOP_GUIDES_SECTION_STARTING",
    early: "#SHOP_GUIDES_SECTION_EARLY",
    core: "#SHOP_GUIDES_SECTION_CORE",
    luxury: "#SHOP_GUIDES_SECTION_LUXURY",
    situational: "#SHOP_GUIDES_SECTION_SITUATIONAL",
};

const PICK_GUIDES_PAGE_SIZE = 5;
const PICK_GUIDES_AUTO_OPEN_DELAY = 0.5;
const PICK_GUIDES_AUTO_OPEN_RETRY_DELAY = 0.2;
const PICK_GUIDES_AUTO_OPEN_MAX_RETRIES = 6;
const PICK_GUIDES_HEIGHT_ANIMATION_START_DELAY = 0.03;
const PICK_GUIDES_HEIGHT_ANIMATION_LATE_DELAY = 0.15;
const PICK_GUIDES_HEIGHT_ANIMATION_EXTRA_LATE_DELAY = 0.28;
const PICK_GUIDES_LATE_HEIGHT_SYNC_MAX_SCREEN_HEIGHT = 1200;

const PickGuidesState = {
    heroScriptName: "",
    requestedHero: "",
    list: [],
    selectedGuideId: 0,
    guide: null,
    pickerOpen: false,
    pickerPage: 1,
    pickerSearchText: "",
    pickerFavoritesOnly: false,
    loading: false,
    pickerSearchFocused: false,
    strategyItemsRenderKey: "",
    strategyBaselineHero: "",
    strategyBaselineTitle: "",
    strategyBaselineItems: [],
    previewGuideId: null,
    previewGuide: null,
    previewPendingGuideId: null,
    previewCache: {},
};

let pickGuidesStrategySyncToken = 0;
let pickGuidesPreviewHoverToken = 0;
let pickGuidesAutoOpenToken = 0;

function EnsurePickGuidesOriginalParent() {
    if (
        PickGuidesOriginalParent &&
        PickGuidesOriginalParent.IsValid &&
        PickGuidesOriginalParent.IsValid()
    ) {
        return PickGuidesOriginalParent;
    }

    if (PickGuidesRoot && PickGuidesRoot.GetParent) {
        const parent = PickGuidesRoot.GetParent();
        if (parent && parent.IsValid && parent.IsValid()) {
            PickGuidesOriginalParent = parent;
        }
    }

    return PickGuidesOriginalParent;
}

function UpdatePickGuidesRootDock() {
    if (!(PickGuidesRoot && PickGuidesRoot.IsValid && PickGuidesRoot.IsValid() && PickGuidesRoot.GetParent && PickGuidesRoot.SetParent)) {
        return;
    }

    const originalParent = EnsurePickGuidesOriginalParent();
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

    if (PickGuidesRoot.GetParent() === targetParent) {
        return;
    }

    PickGuidesRoot.SetParent(targetParent);
}

function InvalidatePickGuidesAutoOpen() {
    pickGuidesAutoOpenToken += 1;
}

function TryAutoOpenPickGuidesForHero(token, heroScriptName, retriesLeft) {
    if (token !== pickGuidesAutoOpenToken) {
        return;
    }

    if (
        !heroScriptName ||
        heroScriptName !== PickGuidesState.heroScriptName ||
        PickGuidesState.requestedHero !== heroScriptName ||
        !Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_STRATEGY_TIME)
    ) {
        return;
    }

    if (PickGuidesState.pickerOpen) {
        return;
    }

    if (PickGuidesState.loading || PickGuidesState.list.length <= 0) {
        if (retriesLeft > 0) {
            $.Schedule(PICK_GUIDES_AUTO_OPEN_RETRY_DELAY, () => {
                TryAutoOpenPickGuidesForHero(token, heroScriptName, retriesLeft - 1);
            });
        }
        return;
    }

    SetPickGuidesPickerOpen(true);
}

function SchedulePickGuidesAutoOpen(heroScriptName) {
    InvalidatePickGuidesAutoOpen();

    if (!heroScriptName || !Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_STRATEGY_TIME)) {
        return;
    }

    const token = pickGuidesAutoOpenToken;
    $.Schedule(PICK_GUIDES_AUTO_OPEN_DELAY, () => {
        TryAutoOpenPickGuidesForHero(token, heroScriptName, PICK_GUIDES_AUTO_OPEN_MAX_RETRIES);
    });
}

function GetPanelHeightSafe(panel) {
    if (!(panel && panel.IsValid && panel.IsValid())) {
        return 0;
    }

    const value = Number(panel.actuallayoutheight || 0);
    if (!Number.isFinite(value) || Math.abs(value) >= 1000000) {
        return 0;
    }

    return Math.max(0, value);
}

function IsPanelTreeVisible(panel) {
    if (!(panel && panel.IsValid && panel.IsValid())) {
        return false;
    }

    let current = panel;
    while (current) {
        if (current.visible === false) {
            return false;
        }

        try {
            const visibility = String(current.style && current.style.visibility || "").toLowerCase();
            if (visibility === "collapse") {
                return false;
            }
        } catch (error) {
        }

        current = current.GetParent ? current.GetParent() : null;
    }

    return true;
}

function GetPanelWindowPositionSafe(panel) {
    if (!(panel && panel.IsValid && panel.IsValid() && panel.GetPositionWithinWindow)) {
        return null;
    }

    const position = panel.GetPositionWithinWindow();
    if (!position || typeof position !== "object") {
        return null;
    }

    const x = Number(position.x);
    const y = Number(position.y);
    if (!Number.isFinite(x) || !Number.isFinite(y)) {
        return null;
    }

    if (Math.abs(x) >= 1000000 || Math.abs(y) >= 1000000) {
        return null;
    }

    return { x, y };
}

function FindVisibleDescendantById(root, panelId) {
    if (!(root && root.IsValid && root.IsValid())) {
        return null;
    }

    if (root.id === panelId && IsPanelTreeVisible(root)) {
        return root;
    }

    const childCount = root.GetChildCount ? root.GetChildCount() : 0;
    for (let childIndex = 0; childIndex < childCount; childIndex++) {
        const child = root.GetChild(childIndex);
        const match = FindVisibleDescendantById(child, panelId);
        if (match) {
            return match;
        }
    }

    return null;
}

function PanelHasClassSafe(panel, className) {
    if (!(panel && panel.IsValid && panel.IsValid() && panel.BHasClass)) {
        return false;
    }

    try {
        return panel.BHasClass(className);
    } catch (error) {
        return false;
    }
}

function FindNearestAncestorByIdOrClass(panel, panelId, className) {
    let current = panel;
    while (current && current.GetParent) {
        if ((panelId && current.id === panelId) || (className && PanelHasClassSafe(current, className))) {
            return current;
        }

        current = current.GetParent();
    }

    return null;
}

function FindRelatedPanelById(panel, panelId, maxDepth) {
    let current = panel;
    let depth = 0;
    const maxSearchDepth = Math.max(0, Number(maxDepth) || 0);

    while (current && depth <= maxSearchDepth) {
        const found = current.FindChildTraverse ? current.FindChildTraverse(panelId) : null;
        if (found) {
            return found;
        }

        current = current.GetParent ? current.GetParent() : null;
        depth += 1;
    }

    return null;
}

function FindFirstVisiblePanelByClass(root, className) {
    if (!(root && root.IsValid && root.IsValid() && root.FindChildrenWithClassTraverse)) {
        return null;
    }

    let panels = null;
    try {
        panels = root.FindChildrenWithClassTraverse(className);
    } catch (error) {
        panels = null;
    }

    if (!panels || typeof panels.length !== "number") {
        return null;
    }

    for (let panelIndex = 0; panelIndex < panels.length; panelIndex++) {
        const panel = panels[panelIndex];
        if (panel && IsPanelTreeVisible(panel)) {
            return panel;
        }
    }

    return null;
}

function GetPanelStyleHeightNumber(panel) {
    if (!(panel && panel.IsValid && panel.IsValid() && panel.style)) {
        return null;
    }

    try {
        const raw = String(panel.style.height || "").trim();
        if (!raw || raw === "fit-children") {
            return null;
        }

        const numeric = Number(raw.replace("px", "").trim());
        if (!Number.isFinite(numeric) || Math.abs(numeric) >= 1000000) {
            return null;
        }

        return Math.max(0, numeric);
    } catch (error) {
        return null;
    }
}

function SetPickGuidesPickerHeightPx(height) {
    if (!EnsurePickGuidesPanels() || !PickGuidesPicker) {
        return;
    }

    const normalized = Math.max(0, Math.ceil(Number(height) || 0));
    const current = GetPanelStyleHeightNumber(PickGuidesPicker);
    if (current !== null && Math.abs(current - normalized) < 0.5) {
        return;
    }

    PickGuidesPicker.style.height = `${normalized}px`;
}

function LockPickGuidesPickerCurrentHeightPx() {
    if (!EnsurePickGuidesPanels() || !PickGuidesPicker) {
        return;
    }

    const currentHeight = GetPanelHeightSafe(PickGuidesPicker);
    SetPickGuidesPickerHeightPx(currentHeight);
}

function GetVisiblePickGuidesListChildren() {
    if (!EnsurePickGuidesPanels() || !PickGuidesPickerList) {
        return [];
    }

    const children = [];
    for (let i = 0; i < PickGuidesPickerList.GetChildCount(); i++) {
        const child = PickGuidesPickerList.GetChild(i);
        if (!child || child.visible === false) {
            continue;
        }

        children.push(child);
    }

    return children;
}

function RefreshPickGuidesSearchPlaceholder() {
    if (!EnsurePickGuidesPanels() || !PickGuidesPickerSearchPlaceholder || !PickGuidesPickerSearchEntry) {
        return;
    }

    const hasText = String(PickGuidesPickerSearchEntry.text || "").length > 0;
    PickGuidesPickerSearchPlaceholder.SetHasClass("Hidden", hasText || PickGuidesState.pickerSearchFocused);
}

function NormalizePickGuideItemName(itemName) {
    return NormalizeGuideItemNameShared(itemName);
}

function NormalizePickGuideAbilityName(abilityName) {
    return NormalizeGuideAbilityNameShared(abilityName);
}

function IsRenderablePickGuideAbilityName(abilityName) {
    return !!abilityName &&
        abilityName.indexOf("special_bonus_") !== 0 &&
        abilityName !== "attribute_bonus";
}

function GetOrderedPickGuidePreviewAbilities(guide) {
    const skillBuild = PickGuidesToArray(guide?.skill_build);
    const discoveredAbilities = [];
    for (const skillEntry of skillBuild) {
        const abilityName = NormalizePickGuideAbilityName(skillEntry?.ability_script_name || "");
        if (!IsRenderablePickGuideAbilityName(abilityName)) {
            continue;
        }

        if (discoveredAbilities.indexOf(abilityName) === -1) {
            discoveredAbilities.push(abilityName);
        }
    }

    const orderedAbilities = [];
    const abilityOrder = PickGuidesToArray(guide?.ability_order);
    for (const rawAbilityName of abilityOrder) {
        const abilityName = NormalizePickGuideAbilityName(rawAbilityName || "");
        if (!IsRenderablePickGuideAbilityName(abilityName)) {
            continue;
        }

        if (discoveredAbilities.indexOf(abilityName) !== -1 && orderedAbilities.indexOf(abilityName) === -1) {
            orderedAbilities.push(abilityName);
        }
    }

    for (const abilityName of discoveredAbilities) {
        if (orderedAbilities.indexOf(abilityName) === -1) {
            orderedAbilities.push(abilityName);
        }
    }

    return orderedAbilities;
}

function GetPickGuideSectionTitle(sectionKey, customTitle) {
    if (customTitle && customTitle.length > 0) {
        return customTitle.startsWith("#") ? $.Localize(customTitle) : customTitle;
    }

    const token = PICK_GUIDE_SECTION_TITLES[sectionKey];
    return token ? $.Localize(token) : String(sectionKey || "");
}

function EnsurePickGuidesStrategyPanels() {
    if (
        PickGuidesStrategyItemsGuide &&
        PickGuidesStrategyItemsGuide.IsValid &&
        PickGuidesStrategyItemsGuide.IsValid() &&
        PickGuidesStrategyItemsSuggestions &&
        PickGuidesStrategyItemsSuggestions.IsValid &&
        PickGuidesStrategyItemsSuggestions.IsValid() &&
        IsPanelTreeVisible(PickGuidesStrategyItemsGuide) &&
        IsPanelTreeVisible(PickGuidesStrategyItemsSuggestions)
    ) {
        return true;
    }

    const strategyScreen = FindDotaHudElement("StrategyScreen");
    const strategyRoot = strategyScreen && strategyScreen.IsValid && strategyScreen.IsValid()
        ? strategyScreen
        : GetDotaHud();
    const itemsGuide = FindVisibleDescendantById(strategyRoot, "StartingItemsGuide") || FindDotaHudElement("StartingItemsGuide");
    const startingItemsPanel = FindNearestAncestorByIdOrClass(itemsGuide, "StartingItems", null);
    const strategyPanel = FindNearestAncestorByIdOrClass(itemsGuide, null, "StrategyPanel");
    const strategyControl = FindNearestAncestorByIdOrClass(itemsGuide, null, "StrategyControl");

    let itemsSuggestions =
        FindRelatedPanelById(itemsGuide, "ItemsSuggestions", 7) ||
        (strategyControl && strategyControl.FindChildTraverse ? strategyControl.FindChildTraverse("ItemsSuggestions") : null) ||
        (startingItemsPanel && startingItemsPanel.FindChildTraverse ? startingItemsPanel.FindChildTraverse("ItemsSuggestions") : null) ||
        (strategyPanel && strategyPanel.FindChildTraverse ? strategyPanel.FindChildTraverse("ItemsSuggestions") : null);

    if (!(itemsSuggestions && itemsSuggestions.IsValid && itemsSuggestions.IsValid())) {
        itemsSuggestions =
            FindFirstVisiblePanelByClass(strategyControl, "StrategyControlTitle") ||
            FindFirstVisiblePanelByClass(startingItemsPanel, "StrategyControlTitle") ||
            FindFirstVisiblePanelByClass(strategyPanel, "StrategyControlTitle");
    }

    if (!(itemsSuggestions && itemsSuggestions.IsValid && itemsSuggestions.IsValid())) {
        itemsSuggestions = FindVisibleDescendantById(strategyRoot, "ItemsSuggestions") || FindDotaHudElement("ItemsSuggestions");
    }

    if (!itemsGuide) {
        return false;
    }

    PickGuidesStrategyItemsGuide = itemsGuide;
    PickGuidesStrategyItemsSuggestions = itemsSuggestions || null;

    if (PickGuidesStrategyItemsSuggestions && PickGuidesStrategyOriginalItemsSuggestionsText == null) {
        PickGuidesStrategyOriginalItemsSuggestionsText = String(itemsSuggestions.text || "");
    }

    return true;
}

function GetPickGuidesStrategyItemName(shopItem) {
    if (!shopItem) {
        return "";
    }

    if (typeof shopItem.itemname === "string" && shopItem.itemname.length > 0) {
        return shopItem.itemname;
    }

    const itemImage = shopItem.FindChildTraverse ? shopItem.FindChildTraverse("ItemImage") : null;
    if (itemImage && typeof itemImage.itemname === "string" && itemImage.itemname.length > 0) {
        return itemImage.itemname;
    }

    return "";
}

function GetPickGuidesStrategyItemPanels() {
    if (!(PickGuidesStrategyItemsGuide && PickGuidesStrategyItemsGuide.GetChildCount)) {
        return [];
    }

    const panels = [];
    for (let childIndex = 0; childIndex < PickGuidesStrategyItemsGuide.GetChildCount(); childIndex++) {
        const child = PickGuidesStrategyItemsGuide.GetChild(childIndex);
        if (!child) {
            continue;
        }

        if (child.paneltype === "DOTAShopItem" || child.BHasClass && child.BHasClass("MainShopItem")) {
            panels.push(child);
        }
    }

    return panels;
}

function SetPanelAttributeStringSafe(panel, attributeName, value) {
    if (!(panel && panel.IsValid && panel.IsValid() && panel.SetAttributeString)) {
        return;
    }

    try {
        panel.SetAttributeString(attributeName, String(value || ""));
    } catch (error) {
    }
}

function SetPickGuidesStrategyShopItemName(shopItem, itemName) {
    if (!shopItem) {
        return;
    }

    const normalizedName = NormalizePickGuideItemName(itemName);
    SetPanelAttributeStringSafe(shopItem, "itemname", normalizedName);
    shopItem.itemname = normalizedName;

    const itemImage = shopItem.FindChildTraverse ? shopItem.FindChildTraverse("ItemImage") : null;
    if (itemImage) {
        SetPanelAttributeStringSafe(itemImage, "itemname", normalizedName);
        itemImage.itemname = normalizedName;
    }
}

function GetPickGuidePrimaryItemSection(guide) {
    const sections = PickGuidesToArray(guide?.item_sections);
    for (const section of sections) {
        if (PickGuidesToArray(section?.items).length > 0) {
            return section;
        }
    }

    return null;
}

function InvalidatePickGuidesStrategySync() {
    pickGuidesStrategySyncToken += 1;
}

function ShouldShowPickGuidesStrategySync() {
    return !!PickGuidesState.heroScriptName &&
        IsPickGuidesGameState() &&
        !!(PickGuidesFrame && PickGuidesFrame.visible);
}

function SchedulePickGuidesStrategySync(delays) {
    const syncToken = ++pickGuidesStrategySyncToken;
    const retryDelays = Array.isArray(delays) && delays.length > 0
        ? delays
        : [0.0, 0.03, 0.1, 0.25, 0.5];

    for (const delay of retryDelays) {
        $.Schedule(delay, () => {
            if (syncToken !== pickGuidesStrategySyncToken) {
                return;
            }

            if (!ShouldShowPickGuidesStrategySync()) {
                return;
            }

            if (!EnsurePickGuidesStrategyPanels()) {
                return;
            }

            if (!PickGuidesState.guide) {
                return;
            }

            RenderPickGuidesStrategyStartingItems();
        });
    }
}

function BuildPickGuidesStrategyItemsRenderKey(guide, section) {
    if (!guide) {
        return "";
    }

    if (!section) {
        return [
            String(guide.hero_script_name || ""),
            String(guide.id || 0),
            "__baseline__",
        ].join("::");
    }

    const items = PickGuidesToArray(section.items)
        .map((item) => NormalizePickGuideItemName(item?.item_name || ""))
        .join("|");
    const title = GetPickGuideSectionTitle(section.key, section.title);
    return [
        String(guide.hero_script_name || ""),
        String(guide.id || 0),
        String(title || ""),
        items,
    ].join("::");
}

function EnsurePickGuidesStrategyBaselineCaptured() {
    if (!EnsurePickGuidesStrategyPanels() || !PickGuidesStrategyItemsGuide) {
        return false;
    }

    if (
        PickGuidesState.strategyBaselineHero === PickGuidesState.heroScriptName &&
        PickGuidesState.strategyBaselineItems.length > 0
    ) {
        return true;
    }

    const baselineItems = [];
    for (const panel of GetPickGuidesStrategyItemPanels()) {
        const itemName = NormalizePickGuideItemName(GetPickGuidesStrategyItemName(panel));
        if (!itemName) {
            continue;
        }

        baselineItems.push({
            item_name: itemName,
        });
    }

    if (!baselineItems.length) {
        return false;
    }

    PickGuidesState.strategyBaselineHero = PickGuidesState.heroScriptName;
    PickGuidesState.strategyBaselineItems = baselineItems;
    PickGuidesState.strategyBaselineTitle = PickGuidesStrategyItemsSuggestions
        ? String(PickGuidesStrategyItemsSuggestions.text || "")
        : (PickGuidesStrategyOriginalItemsSuggestionsText || "");
    return true;
}

function SchedulePickGuidesStrategyBaselineCapture(delays) {
    const syncToken = ++pickGuidesStrategySyncToken;
    const retryDelays = Array.isArray(delays) && delays.length > 0
        ? delays
        : [0.0, 0.03, 0.1, 0.25, 0.5];

    for (const delay of retryDelays) {
        $.Schedule(delay, () => {
            if (syncToken !== pickGuidesStrategySyncToken) {
                return;
            }

            if (ShouldShowPickGuidesStrategySync()) {
                EnsurePickGuidesStrategyBaselineCaptured();
            }
        });
    }
}

function ClearPickGuidesStrategyRenderedItems() {
    if (!(PickGuidesStrategyItemsGuide && PickGuidesStrategyItemsGuide.GetChildCount)) {
        return;
    }

    const childrenToDelete = [];
    for (let childIndex = 0; childIndex < PickGuidesStrategyItemsGuide.GetChildCount(); childIndex++) {
        const child = PickGuidesStrategyItemsGuide.GetChild(childIndex);
        if (!child) {
            continue;
        }

        if (
            child.paneltype === "DOTAShopItem" ||
            GetPickGuidesStrategyItemName(child) ||
            String(child.id || "").indexOf("PickGuide") === 0
        ) {
            childrenToDelete.push(child);
        }
    }

    for (const child of childrenToDelete) {
        child.DeleteAsync(0);
    }
}

function PopulatePickGuidesStrategyStartingItems(section) {
    if (!EnsurePickGuidesStrategyPanels() || !PickGuidesStrategyItemsGuide) {
        return;
    }

    const items = PickGuidesToArray(section?.items);
    ClearPickGuidesStrategyRenderedItems();

    for (let itemIndex = 0; itemIndex < items.length; itemIndex++) {
        const item = items[itemIndex];
        const shopItem = $.CreatePanel("DOTAShopItem", PickGuidesStrategyItemsGuide, `PickGuideStartingItem_${itemIndex}`, {
            itemname: NormalizePickGuideItemName(item?.item_name),
            style: "width: 42px; height: width-percentage(72.7%); margin-bottom: 5px; margin-right: 6px;",
        });

        shopItem.style.width = "42px";
        shopItem.style.height = "width-percentage(72.7%)";
        shopItem.style.marginBottom = "5px";
        shopItem.style.marginRight = "6px";
        SetPickGuidesStrategyShopItemName(shopItem, item?.item_name);
    }
}

function RestorePickGuidesStrategyBaseline() {
    if (!EnsurePickGuidesStrategyBaselineCaptured()) {
        return false;
    }

    if (PickGuidesStrategyItemsSuggestions) {
        PickGuidesStrategyItemsSuggestions.text = PickGuidesState.strategyBaselineTitle || PickGuidesStrategyOriginalItemsSuggestionsText || "";
    }

    PopulatePickGuidesStrategyStartingItems({
        items: PickGuidesState.strategyBaselineItems,
    });
    return true;
}

function RenderPickGuidesStrategyStartingItems() {
    if (!EnsurePickGuidesStrategyPanels()) {
        return;
    }

    const guide = PickGuidesState.guide;
    if (!guide) {
        return;
    }

    if (!EnsurePickGuidesStrategyBaselineCaptured()) {
        return;
    }

    const section = GetPickGuidePrimaryItemSection(guide);
    const renderKey = BuildPickGuidesStrategyItemsRenderKey(guide, section);
    if (PickGuidesState.strategyItemsRenderKey === renderKey) {
        return;
    }

    PickGuidesState.strategyItemsRenderKey = renderKey;

    if (!section) {
        RestorePickGuidesStrategyBaseline();
        return;
    }

    if (PickGuidesStrategyItemsSuggestions) {
        PickGuidesStrategyItemsSuggestions.text = GetPickGuideSectionTitle(section.key, section.title);
    }

    PopulatePickGuidesStrategyStartingItems(section);
}

function GetPickGuidesExpandedContentHeight() {
    if (!EnsurePickGuidesPanels()) {
        return 0;
    }

    const naturalContentHeight = GetPanelHeightSafe(PickGuidesPickerContent);
    if (ShouldPreferNaturalPickGuidesContentHeight() && naturalContentHeight > 0) {
        return Math.max(0, Math.ceil(naturalContentHeight));
    }

    const pickerPos = GetPanelWindowPositionSafe(PickGuidesPicker);
    if (pickerPos) {
        let bottom = pickerPos.y;
        const candidates = [PickGuidesPickerSearchWrap, PickGuidesPickerList];

        if (
            PickGuidesPickerPagination &&
            PickGuidesPickerPagination.visible &&
            PickGuidesPickerPagination.GetChildCount() > 0
        ) {
            candidates.push(PickGuidesPickerPagination);
        }

        for (const panel of candidates) {
            const pos = GetPanelWindowPositionSafe(panel);
            if (!pos) {
                continue;
            }

            bottom = Math.max(bottom, pos.y + GetPanelHeightSafe(panel));
        }

        if (bottom > pickerPos.y) {
            return Math.max(0, Math.ceil(bottom - pickerPos.y));
        }
    }

    if (naturalContentHeight > 0) {
        return Math.max(0, Math.ceil(naturalContentHeight));
    }

    const pickerContentPos = GetPanelWindowPositionSafe(PickGuidesPickerContent);
    if (pickerPos && pickerContentPos) {
        const pickerContentBottom = pickerContentPos.y + GetPanelHeightSafe(PickGuidesPickerContent);
        if (pickerContentBottom > pickerPos.y) {
            return Math.max(0, Math.ceil(pickerContentBottom - pickerPos.y));
        }
    }

    let fallbackHeight = GetPanelHeightSafe(PickGuidesPickerSearchWrap);

    if (
        PickGuidesPickerPagination &&
        PickGuidesPickerPagination.visible &&
        PickGuidesPickerPagination.GetChildCount() > 0
    ) {
        fallbackHeight += GetPanelHeightSafe(PickGuidesPickerPagination);
    }

    return Math.max(0, Math.ceil(fallbackHeight));
}

let pickGuidesFrameHeightSyncToken = 0;

function ShouldDisableLatePickGuidesHeightSyncForLargeScreen() {
    const screenHeight = Game.GetScreenHeight ? Number(Game.GetScreenHeight() || 0) : 0;
    return Number.isFinite(screenHeight) && screenHeight > PICK_GUIDES_LATE_HEIGHT_SYNC_MAX_SCREEN_HEIGHT;
}

function ShouldPreferNaturalPickGuidesContentHeight() {
    const visibleEntries = GetVisiblePickGuidesListChildren().length;
    return visibleEntries > 0 && visibleEntries < 4;
}

function ShouldRunLateOpenPickGuidesHeightSync() {
    const visibleEntries = GetVisiblePickGuidesListChildren().length;
    const filteredGuides = GetFilteredPickGuidesList();
    const totalPages = Math.max(1, Math.ceil(filteredGuides.length / PICK_GUIDES_PAGE_SIZE));
    const hasPagination = totalPages > 1;
    const isShortPage = visibleEntries > 0 && visibleEntries < 4;
    const isShortNonFirstPage =
        isShortPage &&
        PickGuidesState.pickerPage > 1 &&
        totalPages > 1;
    const isShortSinglePage = isShortPage && totalPages === 1;

    if (isShortNonFirstPage || isShortSinglePage) {
        return true;
    }

    if (ShouldDisableLatePickGuidesHeightSyncForLargeScreen()) {
        return false;
    }

    return hasPagination;
}

function ShouldRunLatePickGuidesHeightSync(mode) {
    const refreshMode = String(mode || "");
    if (refreshMode !== "open" && refreshMode !== "resize") {
        return false;
    }

    return ShouldRunLateOpenPickGuidesHeightSync();
}

function ShouldRunExtraLatePickGuidesHeightSync() {
    return !ShouldDisableLatePickGuidesHeightSyncForLargeScreen() &&
        GetVisiblePickGuidesListChildren().length > 0 &&
        GetVisiblePickGuidesListChildren().length < 4 &&
        Math.max(1, Math.ceil(GetFilteredPickGuidesList().length / PICK_GUIDES_PAGE_SIZE)) === 1;
}

function RefreshPickGuidesFrameHeight(animated, mode) {
    if (!EnsurePickGuidesPanels() || !PickGuidesFrame || !PickGuidesFrame.visible) {
        return;
    }

    const refreshMode = String(mode || "");
    PickGuidesFrame.style.height = "fit-children";

    if (!PickGuidesState.pickerOpen) {
        if (!animated) {
            SetPickGuidesPickerHeightPx(0);
            return;
        }

        const closeToken = ++pickGuidesFrameHeightSyncToken;
        LockPickGuidesPickerCurrentHeightPx();
        $.Schedule(0.0, () => {
            if (closeToken !== pickGuidesFrameHeightSyncToken) {
                return;
            }

            SetPickGuidesPickerHeightPx(0);
        });
        return;
    }

    const applyTargetHeight = () => {
        if (!EnsurePickGuidesPanels() || !PickGuidesFrame || !PickGuidesFrame.visible || !PickGuidesState.pickerOpen) {
            return;
        }

        SetPickGuidesPickerHeightPx(GetPickGuidesExpandedContentHeight());
    };

    if (!animated) {
        applyTargetHeight();
        return;
    }

    const token = ++pickGuidesFrameHeightSyncToken;
    if (refreshMode === "open") {
        SetPickGuidesPickerHeightPx(0);
    } else {
        LockPickGuidesPickerCurrentHeightPx();
    }

    $.Schedule(PICK_GUIDES_HEIGHT_ANIMATION_START_DELAY, () => {
        if (token !== pickGuidesFrameHeightSyncToken) {
            return;
        }

        applyTargetHeight();
    });

    const lateSyncDelays = [];
    if (ShouldRunLatePickGuidesHeightSync(refreshMode)) {
        lateSyncDelays.push(PICK_GUIDES_HEIGHT_ANIMATION_LATE_DELAY);
    }
    if (ShouldRunExtraLatePickGuidesHeightSync()) {
        lateSyncDelays.push(PICK_GUIDES_HEIGHT_ANIMATION_EXTRA_LATE_DELAY);
    }

    for (const lateDelay of lateSyncDelays) {
        $.Schedule(lateDelay, () => {
            if (token !== pickGuidesFrameHeightSyncToken) {
                return;
            }

            const currentTarget = GetPanelStyleHeightNumber(PickGuidesPicker);
            const nextTarget = Math.max(0, Math.ceil(GetPickGuidesExpandedContentHeight()));
            if (currentTarget === null || nextTarget > currentTarget + 1) {
                SetPickGuidesPickerHeightPx(nextTarget);
            }
        });
    }
}

function RunPickGuidesFrameHeightAnimation(opening) {
    if (!EnsurePickGuidesPanels() || !PickGuidesFrame || !PickGuidesPicker) {
        return;
    }

    const wasOpen = PickGuidesState.pickerOpen;
    PickGuidesState.pickerOpen = !!opening;
    PickGuidesFrame.SetHasClass("Expanded", PickGuidesState.pickerOpen);
    PickGuidesPicker.hittest = PickGuidesState.pickerOpen;
    PickGuidesPicker.hittestchildren = PickGuidesState.pickerOpen;
    const mode = opening
        ? (wasOpen ? "resize" : "open")
        : (wasOpen ? "close" : "collapsed");
    RefreshPickGuidesFrameHeight(true, mode);
}

function EnsurePickGuidesPanels() {
    if (
        PickGuidesFrame && PickGuidesFrame.IsValid && PickGuidesFrame.IsValid() &&
        PickGuidesHeader && PickGuidesHeader.IsValid && PickGuidesHeader.IsValid() &&
        PickGuidesButton && PickGuidesButton.IsValid && PickGuidesButton.IsValid() &&
        PickGuidesStatePanel && PickGuidesStatePanel.IsValid && PickGuidesStatePanel.IsValid() &&
        PickGuidesSelectedTitle && PickGuidesSelectedTitle.IsValid && PickGuidesSelectedTitle.IsValid() &&
        PickGuidesSelectedMeta && PickGuidesSelectedMeta.IsValid && PickGuidesSelectedMeta.IsValid() &&
        PickGuidesPicker && PickGuidesPicker.IsValid && PickGuidesPicker.IsValid() &&
        PickGuidesPickerContent && PickGuidesPickerContent.IsValid && PickGuidesPickerContent.IsValid() &&
        PickGuidesPickerSearchWrap && PickGuidesPickerSearchWrap.IsValid && PickGuidesPickerSearchWrap.IsValid() &&
        PickGuidesPickerList && PickGuidesPickerList.IsValid && PickGuidesPickerList.IsValid() &&
        PickGuidesPickerPagination && PickGuidesPickerPagination.IsValid && PickGuidesPickerPagination.IsValid() &&
        PickGuidesPickerSearchEntry && PickGuidesPickerSearchEntry.IsValid && PickGuidesPickerSearchEntry.IsValid() &&
        PickGuidesPickerFavoritesButton && PickGuidesPickerFavoritesButton.IsValid && PickGuidesPickerFavoritesButton.IsValid()
        && PickGuidesPreview && PickGuidesPreview.IsValid && PickGuidesPreview.IsValid()
        && PickGuidesPreviewHeroImage && PickGuidesPreviewHeroImage.IsValid && PickGuidesPreviewHeroImage.IsValid()
        && PickGuidesPreviewTitle && PickGuidesPreviewTitle.IsValid && PickGuidesPreviewTitle.IsValid()
        && PickGuidesPreviewMeta && PickGuidesPreviewMeta.IsValid && PickGuidesPreviewMeta.IsValid()
        && PickGuidesPreviewBody && PickGuidesPreviewBody.IsValid && PickGuidesPreviewBody.IsValid()
        && PickGuidesPreviewLoading && PickGuidesPreviewLoading.IsValid && PickGuidesPreviewLoading.IsValid()
        && PickGuidesPreviewContent && PickGuidesPreviewContent.IsValid && PickGuidesPreviewContent.IsValid()
        && PickGuidesPreviewSkillsBlock && PickGuidesPreviewSkillsBlock.IsValid && PickGuidesPreviewSkillsBlock.IsValid()
        && PickGuidesPreviewSkillsList && PickGuidesPreviewSkillsList.IsValid && PickGuidesPreviewSkillsList.IsValid()
        && PickGuidesPreviewTalentsBlock && PickGuidesPreviewTalentsBlock.IsValid && PickGuidesPreviewTalentsBlock.IsValid()
        && PickGuidesPreviewTalentsList && PickGuidesPreviewTalentsList.IsValid && PickGuidesPreviewTalentsList.IsValid()
        && PickGuidesPreviewItemsBlock && PickGuidesPreviewItemsBlock.IsValid && PickGuidesPreviewItemsBlock.IsValid()
        && PickGuidesPreviewItemsSections && PickGuidesPreviewItemsSections.IsValid && PickGuidesPreviewItemsSections.IsValid()
    ) {
        return true;
    }

    PickGuidesFrame = PickGuidesRoot.FindChildTraverse("PickGuidesFrame");
    PickGuidesHeader = PickGuidesRoot.FindChildTraverse("PickGuidesHeader");
    PickGuidesButton = PickGuidesRoot.FindChildTraverse("PickGuidesButton");
    PickGuidesStatePanel = PickGuidesRoot.FindChildTraverse("PickGuidesState");
    PickGuidesSelectedTitle = PickGuidesRoot.FindChildTraverse("PickGuidesSelectedTitle");
    PickGuidesSelectedMeta = PickGuidesRoot.FindChildTraverse("PickGuidesSelectedMeta");
    PickGuidesPicker = PickGuidesRoot.FindChildTraverse("PickGuidesPicker");
    PickGuidesPickerContent = PickGuidesRoot.FindChildTraverse("PickGuidesPickerContent");
    PickGuidesPickerSearchWrap = PickGuidesRoot.FindChildTraverse("PickGuidesPickerSearchWrap");
    PickGuidesPickerList = PickGuidesRoot.FindChildTraverse("PickGuidesPickerList");
    PickGuidesPickerPagination = PickGuidesRoot.FindChildTraverse("PickGuidesPickerPagination");
    PickGuidesPickerSearchEntry = PickGuidesRoot.FindChildTraverse("PickGuidesPickerSearchEntry");
    PickGuidesPickerSearchPlaceholder = PickGuidesRoot.FindChildTraverse("PickGuidesPickerSearchPlaceholder");
    PickGuidesPickerFavoritesButton = PickGuidesRoot.FindChildTraverse("PickGuidesPickerFavoritesButton");
    PickGuidesPreview = PickGuidesRoot.FindChildTraverse("PickGuidesPreview");
    PickGuidesPreviewHeroImage = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewHeroImage");
    PickGuidesPreviewTitle = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewTitle");
    PickGuidesPreviewMeta = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewMeta");
    PickGuidesPreviewBody = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewBody");
    PickGuidesPreviewLoading = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewLoading");
    PickGuidesPreviewContent = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewContent");
    PickGuidesPreviewSkillsBlock = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewSkillsBlock");
    PickGuidesPreviewSkillsList = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewSkillsList");
    PickGuidesPreviewTalentsBlock = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewTalentsBlock");
    PickGuidesPreviewTalentsList = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewTalentsList");
    PickGuidesPreviewItemsBlock = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewItemsBlock");
    PickGuidesPreviewItemsSections = PickGuidesRoot.FindChildTraverse("PickGuidesPreviewItemsSections");

    if (PickGuidesButton) {
        PickGuidesButton.SetPanelEvent("onactivate", TogglePickGuidesPicker);
    }

    if (PickGuidesPickerFavoritesButton) {
        PickGuidesPickerFavoritesButton.SetPanelEvent("onactivate", TogglePickGuidesFavoritesOnly);
    }

    if (PickGuidesPickerSearchEntry) {
        PickGuidesPickerSearchEntry.SetPanelEvent("ontextentrychange", OnPickGuidesSearchChanged);
        PickGuidesPickerSearchEntry.SetPanelEvent("onfocus", OnPickGuidesSearchFocus);
        PickGuidesPickerSearchEntry.SetPanelEvent("onblur", OnPickGuidesSearchBlur);
    }

    return !!(
        PickGuidesFrame &&
        PickGuidesHeader &&
        PickGuidesButton &&
        PickGuidesStatePanel &&
        PickGuidesSelectedTitle &&
        PickGuidesSelectedMeta &&
        PickGuidesPicker &&
        PickGuidesPickerContent &&
        PickGuidesPickerSearchWrap &&
        PickGuidesPickerList &&
        PickGuidesPickerPagination &&
        PickGuidesPickerSearchEntry &&
        PickGuidesPickerSearchPlaceholder &&
        PickGuidesPickerFavoritesButton &&
        PickGuidesPreview &&
        PickGuidesPreviewHeroImage &&
        PickGuidesPreviewTitle &&
        PickGuidesPreviewMeta &&
        PickGuidesPreviewBody &&
        PickGuidesPreviewLoading &&
        PickGuidesPreviewContent &&
        PickGuidesPreviewSkillsBlock &&
        PickGuidesPreviewSkillsList &&
        PickGuidesPreviewTalentsBlock &&
        PickGuidesPreviewTalentsList &&
        PickGuidesPreviewItemsBlock &&
        PickGuidesPreviewItemsSections
    );
}

function PickGuidesToArray(value) {
    if (!value || typeof value !== "object") {
        return [];
    }

    return toArray(value);
}

function IsDefaultPickGuide(guide) {
    return !!guide && (Number(guide.id) === 0 || Number(guide.is_default_guide || 0) === 1);
}

function GetPickGuideDisplayTitle(guide) {
    if (IsDefaultPickGuide(guide)) {
        return $.Localize("#SHOP_GUIDES_DEFAULT_TITLE");
    }

    return guide?.title || $.Localize("#SHOP_GUIDES_UNTITLED");
}

function GetPickGuideMetaText(guide) {
    if (!guide) {
        return "";
    }

    if (IsDefaultPickGuide(guide)) {
        return $.Localize("#SHOP_GUIDES_DEFAULT_PICKER_META");
    }

    const author = guide.author_display_name || guide.author?.display_name || "";
    return `${author} | ${$.Localize("#SHOP_GUIDES_RATING")} ${Number(guide.rating || 0)}`;
}

function HasPickGuidePreviewData(guide) {
    if (!guide || typeof guide !== "object") {
        return false;
    }

    return guide.item_sections !== undefined ||
        guide.skill_build !== undefined ||
        guide.talent_choices !== undefined;
}

function HasRenderablePickGuidePreviewData(guide) {
    if (!guide || typeof guide !== "object") {
        return false;
    }

    const itemSections = PickGuidesToArray(guide.item_sections);
    for (const section of itemSections) {
        if (PickGuidesToArray(section?.items).length > 0) {
            return true;
        }
    }

    if (PickGuidesToArray(guide.skill_build).length > 0) {
        return true;
    }

    if (PickGuidesToArray(guide.talent_choices).length > 0) {
        return true;
    }

    return false;
}

function AreSamePickGuideIds(leftGuideId, rightGuideId) {
    if (leftGuideId === null || leftGuideId === undefined || rightGuideId === null || rightGuideId === undefined) {
        return false;
    }

    return Number(leftGuideId) === Number(rightGuideId);
}

function GetPickGuidePreviewCacheKey(guideId) {
    return `${PickGuidesState.heroScriptName}::${Number(guideId || 0)}`;
}

function CachePickGuidePreview(guide) {
    if (!guide) {
        return;
    }

    const heroScriptName = NormalizePickHeroName(guide.hero_script_name || "");
    if (!heroScriptName || heroScriptName !== PickGuidesState.heroScriptName) {
        return;
    }

    PickGuidesState.previewCache[GetPickGuidePreviewCacheKey(guide.id)] = guide;
}

function GetCachedPickGuidePreview(guideId) {
    return PickGuidesState.previewCache[GetPickGuidePreviewCacheKey(guideId)] || null;
}

function CreatePickGuidePreviewWrappedItems(parent, items) {
    const perRow = 5;

    for (let index = 0; index < items.length; index += perRow) {
        const row = $.CreatePanel("Panel", parent, "");
        row.AddClass("PickGuidesPreviewItemsRow");

        const rowItems = items.slice(index, index + perRow);
        for (let rowIndex = 0; rowIndex < rowItems.length; rowIndex++) {
            const item = rowItems[rowIndex];
            const shopItem = $.CreatePanel("DOTAShopItem", row, `PickGuidePreviewItem_${index + rowIndex}`, {
                itemname: NormalizePickGuideItemName(item.item_name),
                style: "width: 34px; height: width-percentage(72.7%); margin-top: 1px; margin-bottom: 1px; margin-right: 4px;",
            });
            shopItem.AddClass("PickGuidesPreviewShopItem");
        }
    }
}

function RenderPickGuidePreviewSkillRows(guide) {
    DeleteAllChildren(PickGuidesPreviewSkillsList);

    const skillBuild = PickGuidesToArray(guide?.skill_build);
    const rowAbilities = GetOrderedPickGuidePreviewAbilities(guide);

    PickGuidesPreviewSkillsBlock.visible = rowAbilities.length > 0;
    if (!rowAbilities.length) {
        return;
    }

    const maxLevel = 18;
    for (const abilityName of rowAbilities.slice(0, 4)) {
        const row = $.CreatePanel("Panel", PickGuidesPreviewSkillsList, "");
        row.AddClass("PickGuidesPreviewSkillRow");

        const icon = $.CreatePanel("DOTAAbilityImage", row, "");
        icon.AddClass("PickGuidesPreviewSkillIcon");
        icon.abilityname = abilityName;

        const levels = $.CreatePanel("Panel", row, "");
        levels.AddClass("PickGuidesPreviewSkillLevels");

        for (let level = 1; level <= maxLevel; level++) {
            const cell = $.CreatePanel("Panel", levels, "");
            cell.AddClass("PickGuidesPreviewSkillLevelCell");

            const cellText = $.CreatePanel("Label", cell, "");
            cellText.AddClass("PickGuidesPreviewSkillLevelCellText");

            const picked = skillBuild.find((entry) =>
                Number(entry?.level || 0) === level &&
                NormalizePickGuideAbilityName(entry?.ability_script_name || "") === abilityName
            );

            if (picked) {
                cell.AddClass("Active");
                cellText.text = `${level}`;
            } else {
                cellText.text = "";
            }
        }
    }
}

function RenderPickGuidePreviewTalents(guide) {
    DeleteAllChildren(PickGuidesPreviewTalentsList);

    const talentChoices = PickGuidesToArray(guide?.talent_choices)
        .slice()
        .sort((left, right) => Number(right?.level || 0) - Number(left?.level || 0));
    PickGuidesPreviewTalentsBlock.visible = talentChoices.length > 0;
    for (const talentChoice of talentChoices) {
        const row = $.CreatePanel("Panel", PickGuidesPreviewTalentsList, "");
        row.AddClass("PickGuidesPreviewTalentRow");

        const left = $.CreatePanel("Panel", row, "");
        left.AddClass("PickGuidesPreviewTalentBranch");
        left.AddClass("Left");
        left.SetHasClass("Active", talentChoice.side === "left");

        const leftLabel = $.CreatePanel("Label", left, "");
        leftLabel.AddClass("PickGuidesPreviewTalentBranchLabel");
        leftLabel.text = "L";

        const level = $.CreatePanel("Panel", row, "");
        level.AddClass("PickGuidesPreviewTalentLevel");

        const levelText = $.CreatePanel("Label", level, "");
        levelText.AddClass("PickGuidesPreviewTalentLevelText");
        levelText.text = `${talentChoice.level}`;

        const right = $.CreatePanel("Panel", row, "");
        right.AddClass("PickGuidesPreviewTalentBranch");
        right.AddClass("Right");
        right.SetHasClass("Active", talentChoice.side === "right");

        const rightLabel = $.CreatePanel("Label", right, "");
        rightLabel.AddClass("PickGuidesPreviewTalentBranchLabel");
        rightLabel.text = "R";
    }
}

function RenderPickGuidePreviewItems(guide) {
    DeleteAllChildren(PickGuidesPreviewItemsSections);

    const itemSections = PickGuidesToArray(guide?.item_sections)
        .filter((section) => PickGuidesToArray(section?.items).length > 0);

    for (let index = 0; index < itemSections.length; index += 2) {
        const row = $.CreatePanel("Panel", PickGuidesPreviewItemsSections, "");
        row.AddClass("PickGuidesPreviewItemsSectionsRow");

        const rowSections = itemSections.slice(index, index + 2);
        for (let sectionIndex = 0; sectionIndex < rowSections.length; sectionIndex++) {
            const section = rowSections[sectionIndex];
            const items = PickGuidesToArray(section?.items);
            const sectionPanel = $.CreatePanel("Panel", row, "");
            sectionPanel.AddClass("PickGuidesPreviewItemSection");
            if (sectionIndex === rowSections.length - 1) {
                sectionPanel.AddClass("LastInRow");
            }

            const title = $.CreatePanel("Label", sectionPanel, "");
            title.AddClass("PickGuidesPreviewItemSectionTitle");
            title.text = GetPickGuideSectionTitle(section.key, section.title);

            const itemsWrap = $.CreatePanel("Panel", sectionPanel, "");
            itemsWrap.AddClass("PickGuidesPreviewItemsWrap");

            CreatePickGuidePreviewWrappedItems(itemsWrap, items);
        }
    }

    PickGuidesPreviewItemsBlock.visible = itemSections.length > 0;
}

function RenderPickGuidesPreview() {
    if (!EnsurePickGuidesPanels()) {
        return;
    }

    const previewGuideId = PickGuidesState.previewGuideId;
    const shouldShow = PickGuidesState.pickerOpen && previewGuideId !== null && previewGuideId !== undefined;
    PickGuidesPreview.SetHasClass("Visible", shouldShow);

    if (!shouldShow) {
        return;
    }

    const fallbackGuide = FindPickGuideById(previewGuideId);
    const guide = PickGuidesState.previewGuide && AreSamePickGuideIds(PickGuidesState.previewGuide.id, previewGuideId)
        ? PickGuidesState.previewGuide
        : fallbackGuide;

    PickGuidesPreviewHeroImage.heroname = PickGuidesState.heroScriptName;
    PickGuidesPreviewTitle.text = guide ? GetPickGuideDisplayTitle(guide) : $.Localize("#SHOP_GUIDES_LOADING");
    PickGuidesPreviewMeta.text = guide ? GetPickGuideMetaText(guide) : "";

    const hasPreviewData = HasPickGuidePreviewData(guide);
    const isLoading = !hasPreviewData && AreSamePickGuideIds(PickGuidesState.previewPendingGuideId, previewGuideId);
    PickGuidesPreviewLoading.visible = isLoading;
    PickGuidesPreviewContent.visible = hasPreviewData;

    if (!hasPreviewData) {
        DeleteAllChildren(PickGuidesPreviewSkillsList);
        DeleteAllChildren(PickGuidesPreviewTalentsList);
        DeleteAllChildren(PickGuidesPreviewItemsSections);
        PickGuidesPreviewSkillsBlock.visible = false;
        PickGuidesPreviewTalentsBlock.visible = false;
        PickGuidesPreviewItemsBlock.visible = false;
        return;
    }

    RenderPickGuidePreviewSkillRows(guide);
    RenderPickGuidePreviewTalents(guide);
    RenderPickGuidePreviewItems(guide);
}

function RequestPickGuidePreview(guideId) {
    const numericGuideId = Number(guideId);
    if (!Number.isFinite(numericGuideId) || numericGuideId < 0 || !PickGuidesState.heroScriptName) {
        return;
    }

    if (AreSamePickGuideIds(PickGuidesState.previewPendingGuideId, numericGuideId)) {
        return;
    }

    PickGuidesState.previewPendingGuideId = numericGuideId;
    GameEvents.SendCustomGameEventToServer("guides_request_preview", {
        guide_id: numericGuideId,
        hero_script_name: PickGuidesState.heroScriptName,
    });
}

function ShowPickGuidePreview(guideId) {
    const numericGuideId = Number(guideId);
    if (!Number.isFinite(numericGuideId) || numericGuideId < 0) {
        return;
    }

    pickGuidesPreviewHoverToken += 1;
    PickGuidesState.previewGuideId = numericGuideId;

    const cachedGuide = GetCachedPickGuidePreview(numericGuideId);
    if (cachedGuide && HasRenderablePickGuidePreviewData(cachedGuide)) {
        PickGuidesState.previewGuide = cachedGuide;
        PickGuidesState.previewPendingGuideId = null;
    } else {
        PickGuidesState.previewGuide = cachedGuide || FindPickGuideById(numericGuideId);
        RequestPickGuidePreview(numericGuideId);
    }

    RenderPickGuidesPreview();
}

function HidePickGuidePreview(guideId) {
    const hoverToken = ++pickGuidesPreviewHoverToken;
    const numericGuideId = Number(guideId);

    $.Schedule(0.03, () => {
        if (hoverToken !== pickGuidesPreviewHoverToken) {
            return;
        }

        if (!AreSamePickGuideIds(PickGuidesState.previewGuideId, numericGuideId)) {
            return;
        }

        PickGuidesState.previewGuideId = null;
        PickGuidesState.previewGuide = null;
        PickGuidesState.previewPendingGuideId = null;
        RenderPickGuidesPreview();
    });
}

function MoveDefaultPickGuideToTop(list) {
    const guides = list && typeof list.length === "number" ? list.slice() : [];
    const defaultGuides = guides.filter((guide) => IsDefaultPickGuide(guide));
    const otherGuides = guides.filter((guide) => !IsDefaultPickGuide(guide));
    return defaultGuides.concat(otherGuides);
}

function NormalizePickGuidesSearchText(value) {
    return String(value || "").trim().toLowerCase();
}

function GetFilteredPickGuidesList() {
    const query = NormalizePickGuidesSearchText(PickGuidesState.pickerSearchText);

    return PickGuidesState.list.filter((guide) => {
        if (PickGuidesState.pickerFavoritesOnly && !(guide?.is_favorite === true || Number(guide?.is_favorite || 0) === 1)) {
            return false;
        }

        if (!query) {
            return true;
        }

        const title = String(GetPickGuideDisplayTitle(guide) || "").toLowerCase();
        const author = String(guide?.author_display_name || guide?.author?.display_name || "").toLowerCase();
        return title.includes(query) || author.includes(query);
    });
}

function ClampPickGuidesPickerPage(page, totalPages) {
    return Math.max(1, Math.min(totalPages, Number(page) || 1));
}

function NormalizePickHeroName(value) {
    const raw = String(value || "").trim();
    if (!raw) {
        return "";
    }

    return raw.indexOf("npc_dota_hero_") === 0 ? raw : `npc_dota_hero_${raw}`;
}

function GetLocalPickHeroScriptName() {
    const playerInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID()) || Game.GetLocalPlayerInfo();
    if (!playerInfo) {
        return "";
    }

    return NormalizePickHeroName(playerInfo.player_selected_hero || "");
}

function IsPickGuidesGameState() {
    return Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION) ||
        Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_STRATEGY_TIME);
}

function FindPickGuideById(guideId) {
    const numericGuideId = Number(guideId || 0);
    return PickGuidesState.list.find((guide) => Number(guide?.id || 0) === numericGuideId) || null;
}

function SetPickGuidesPickerOpen(isOpen) {
    if (!EnsurePickGuidesPanels()) {
        return;
    }

    const nextOpen = !!isOpen && PickGuidesState.list.length > 0;
    if (PickGuidesState.pickerOpen === nextOpen) {
        return;
    }

    if (!nextOpen) {
        PickGuidesState.previewGuideId = null;
        PickGuidesState.previewGuide = null;
        PickGuidesState.previewPendingGuideId = null;
        RenderPickGuidesPreview();
    }

    RunPickGuidesFrameHeightAnimation(nextOpen);
}

function TogglePickGuidesPicker() {
    SetPickGuidesPickerOpen(!PickGuidesState.pickerOpen);
}

function SetPickGuidesPickerPage(page) {
    const filteredGuides = GetFilteredPickGuidesList();
    const totalPages = Math.max(1, Math.ceil(filteredGuides.length / PICK_GUIDES_PAGE_SIZE));
    PickGuidesState.pickerPage = ClampPickGuidesPickerPage(page, totalPages);
    RenderPickGuidesPicker();
}

function OnPickGuidesSearchChanged() {
    if (!EnsurePickGuidesPanels() || !PickGuidesPickerSearchEntry) {
        return;
    }

    PickGuidesState.pickerSearchText = PickGuidesPickerSearchEntry.text || "";
    RefreshPickGuidesSearchPlaceholder();
    PickGuidesState.pickerPage = 1;
    RenderPickGuidesPicker();
}

function OnPickGuidesSearchFocus() {
    PickGuidesState.pickerSearchFocused = true;
    RefreshPickGuidesSearchPlaceholder();
}

function OnPickGuidesSearchBlur() {
    PickGuidesState.pickerSearchFocused = false;
    RefreshPickGuidesSearchPlaceholder();
}

function TogglePickGuidesFavoritesOnly() {
    PickGuidesState.pickerFavoritesOnly = !PickGuidesState.pickerFavoritesOnly;
    PickGuidesState.pickerPage = 1;
    RenderPickGuidesPicker();
}

function RenderPickGuidesState() {
    if (!EnsurePickGuidesPanels()) {
        return;
    }

    if (PickGuidesState.loading) {
        PickGuidesSelectedTitle.text = $.Localize("#SHOP_GUIDES_LOADING");
        PickGuidesSelectedMeta.text = "";
        if (PickGuidesState.pickerOpen) {
            RefreshPickGuidesFrameHeight(true);
        }
        return;
    }

    const guide = FindPickGuideById(PickGuidesState.selectedGuideId) || PickGuidesState.list[0] || null;
    if (!guide) {
        PickGuidesSelectedTitle.text = $.Localize("#SHOP_GUIDES_EMPTY_SHORT");
        PickGuidesSelectedMeta.text = "";
        if (PickGuidesState.pickerOpen) {
            RefreshPickGuidesFrameHeight(true);
        }
        return;
    }

    PickGuidesSelectedTitle.text = GetPickGuideDisplayTitle(guide);
    PickGuidesSelectedMeta.text = GetPickGuideMetaText(guide);

    if (PickGuidesState.pickerOpen) {
        RefreshPickGuidesFrameHeight(true);
    }
}

function RenderPickGuidesPicker() {
    if (!EnsurePickGuidesPanels()) {
        return;
    }

    if (PickGuidesState.previewGuideId !== null) {
        PickGuidesState.previewGuideId = null;
        PickGuidesState.previewGuide = null;
        PickGuidesState.previewPendingGuideId = null;
        RenderPickGuidesPreview();
    }

    DeleteAllChildren(PickGuidesPickerList);
    DeleteAllChildren(PickGuidesPickerPagination);

    if (PickGuidesPickerSearchEntry.text !== PickGuidesState.pickerSearchText) {
        PickGuidesPickerSearchEntry.text = PickGuidesState.pickerSearchText;
    }
    RefreshPickGuidesSearchPlaceholder();

    PickGuidesPickerFavoritesButton.SetHasClass("Active", PickGuidesState.pickerFavoritesOnly);

    const filteredGuides = GetFilteredPickGuidesList();
    const totalPages = Math.max(1, Math.ceil(filteredGuides.length / PICK_GUIDES_PAGE_SIZE));
    PickGuidesState.pickerPage = ClampPickGuidesPickerPage(PickGuidesState.pickerPage, totalPages);

    const hasPagination = filteredGuides.length > PICK_GUIDES_PAGE_SIZE;
    PickGuidesPickerPagination.visible = hasPagination;
    PickGuidesPickerPagination.hittest = hasPagination;
    PickGuidesPickerPagination.hittestchildren = hasPagination;

    if (!filteredGuides.length) {
        const empty = $.CreatePanel("Label", PickGuidesPickerList, "");
        empty.AddClass("PickGuidesPickerEmpty");
        empty.text = $.Localize("#SHOP_GUIDES_SEARCH_EMPTY");

        RefreshPickGuidesFrameHeight(true);
        return;
    }

    const pageStart = (PickGuidesState.pickerPage - 1) * PICK_GUIDES_PAGE_SIZE;
    const pageGuides = filteredGuides.slice(pageStart, pageStart + PICK_GUIDES_PAGE_SIZE);

    for (const guide of pageGuides) {
        const entry = $.CreatePanel("Button", PickGuidesPickerList, "");
        entry.AddClass("PickGuidesPickerEntry");
        entry.SetHasClass("Selected", Number(guide.id || 0) === PickGuidesState.selectedGuideId);
        entry.SetPanelEvent("onmouseover", () => ShowPickGuidePreview(guide.id));
        entry.SetPanelEvent("onmouseout", () => HidePickGuidePreview(guide.id));
        entry.SetPanelEvent("onactivate", () => SelectPickGuide(guide.id));

        const title = $.CreatePanel("Label", entry, "");
        title.AddClass("PickGuidesPickerEntryTitle");
        title.text = GetPickGuideDisplayTitle(guide);

        const meta = $.CreatePanel("Label", entry, "");
        meta.AddClass("PickGuidesPickerEntryMeta");
        meta.text = GetPickGuideMetaText(guide);
    }

    for (let i = 0; i < PickGuidesPickerList.GetChildCount(); i++) {
        const child = PickGuidesPickerList.GetChild(i);
        if (!child) {
            continue;
        }

        child.SetHasClass("LastEntry", i === PickGuidesPickerList.GetChildCount() - 1);
    }

    if (hasPagination) {
        for (let page = 1; page <= totalPages; page++) {
            const button = $.CreatePanel("Button", PickGuidesPickerPagination, "");
            button.AddClass("PickGuidesPageButton");
            button.SetHasClass("Active", page === PickGuidesState.pickerPage);
            button.SetPanelEvent("onactivate", () => SetPickGuidesPickerPage(page));

            const label = $.CreatePanel("Label", button, "");
            label.AddClass("PickGuidesPageButtonLabel");
            label.text = `${page}`;
        }
    }

    RefreshPickGuidesFrameHeight(true);
}

function RequestPickGuidesForHero(heroScriptName) {
    InvalidatePickGuidesStrategySync();
    InvalidatePickGuidesAutoOpen();
    PickGuidesState.requestedHero = heroScriptName;
    PickGuidesState.list = [];
    PickGuidesState.selectedGuideId = 0;
    PickGuidesState.guide = null;
    PickGuidesState.loading = true;
    PickGuidesState.pickerPage = 1;
    PickGuidesState.pickerSearchText = "";
    PickGuidesState.pickerFavoritesOnly = false;
    PickGuidesState.pickerSearchFocused = false;
    PickGuidesState.strategyItemsRenderKey = "";
    PickGuidesState.strategyBaselineHero = "";
    PickGuidesState.strategyBaselineTitle = "";
    PickGuidesState.strategyBaselineItems = [];
    PickGuidesState.previewGuideId = null;
    PickGuidesState.previewGuide = null;
    PickGuidesState.previewPendingGuideId = null;
    PickGuidesState.previewCache = {};

    SetPickGuidesPickerOpen(false);
    RenderPickGuidesState();
    RenderPickGuidesPicker();
    RenderPickGuidesPreview();

    SchedulePickGuidesStrategyBaselineCapture();
    SchedulePickGuidesAutoOpen(heroScriptName);

    GameEvents.SendCustomGameEventToServer("guides_request_list", {
        hero_script_name: heroScriptName,
    });
}

function SelectPickGuide(guideId) {
    const numericGuideId = Number(guideId);
    if (!Number.isFinite(numericGuideId) || numericGuideId < 0) {
        return;
    }

    if (numericGuideId === PickGuidesState.selectedGuideId) {
        SetPickGuidesPickerOpen(false);
        return;
    }

    if (ShouldShowPickGuidesStrategySync()) {
        EnsurePickGuidesStrategyBaselineCaptured();
    }

    PickGuidesState.selectedGuideId = numericGuideId;
    PickGuidesState.guide = null;
    PickGuidesState.strategyItemsRenderKey = "";
    SetPickGuidesPickerOpen(false);
    RenderPickGuidesState();
    RenderPickGuidesPicker();

    GameEvents.SendCustomGameEventToServer("guides_select_guide", {
        guide_id: numericGuideId,
        hero_script_name: PickGuidesState.heroScriptName,
    });
}

function OnPickGuidesListResponse(event) {
    const heroScriptName = String(event?.hero_script_name || "");
    if (heroScriptName !== PickGuidesState.heroScriptName) {
        return;
    }

    PickGuidesState.list = MoveDefaultPickGuideToTop(PickGuidesToArray(event.guides));
    PickGuidesState.selectedGuideId = Number(event.selected_guide_id || 0);

    if (!FindPickGuideById(PickGuidesState.selectedGuideId) && PickGuidesState.list.length > 0) {
        PickGuidesState.selectedGuideId = Number(PickGuidesState.list[0].id || 0);
    }

    PickGuidesState.loading = false;
    RenderPickGuidesState();
    RenderPickGuidesPicker();
    SchedulePickGuidesStrategyBaselineCapture();
}

function OnPickGuideResponse(event) {
    const guide = event?.guide;
    const heroScriptName = NormalizePickHeroName(guide?.hero_script_name || "");
    if (!guide || heroScriptName !== PickGuidesState.heroScriptName) {
        return;
    }

    CachePickGuidePreview(guide);
    PickGuidesState.guide = guide;
    PickGuidesState.selectedGuideId = Number(guide.id || 0);
    PickGuidesState.strategyItemsRenderKey = "";
    RenderPickGuidesState();
    RenderPickGuidesPicker();
    if (AreSamePickGuideIds(PickGuidesState.previewGuideId, guide.id)) {
        PickGuidesState.previewGuide = guide;
        PickGuidesState.previewPendingGuideId = null;
        RenderPickGuidesPreview();
    }
    SchedulePickGuidesStrategySync();
}

function OnPickGuidePreviewResponse(event) {
    const guide = event?.guide;
    const heroScriptName = NormalizePickHeroName(guide?.hero_script_name || "");
    if (!guide || heroScriptName !== PickGuidesState.heroScriptName) {
        return;
    }

    CachePickGuidePreview(guide);
    if (AreSamePickGuideIds(PickGuidesState.previewGuideId, guide.id)) {
        PickGuidesState.previewGuide = guide;
        PickGuidesState.previewPendingGuideId = null;
        RenderPickGuidesPreview();
    }
}

function OnPickGuidesError() {
    PickGuidesState.loading = false;
    RenderPickGuidesState();
    RenderPickGuidesPicker();
}

function UpdatePickGuidesVisibility() {
    UpdatePickGuidesRootDock();

    if (!EnsurePickGuidesPanels()) {
        $.Schedule(0.1, UpdatePickGuidesVisibility);
        return;
    }

    const heroScriptName = GetLocalPickHeroScriptName();
    const shouldShow = IsPickGuidesGameState() && !!heroScriptName;

    PickGuidesFrame.SetHasClass("Visible", shouldShow);
    PickGuidesFrame.visible = shouldShow;

    if (!shouldShow) {
        InvalidatePickGuidesStrategySync();
        InvalidatePickGuidesAutoOpen();
        PickGuidesFrame.style.height = "0px";
        SetPickGuidesPickerHeightPx(0);
        PickGuidesState.heroScriptName = heroScriptName;
        PickGuidesState.requestedHero = "";
        PickGuidesState.list = [];
        PickGuidesState.selectedGuideId = 0;
        PickGuidesState.guide = null;
        PickGuidesState.loading = false;
        PickGuidesState.pickerPage = 1;
        PickGuidesState.pickerSearchText = "";
        PickGuidesState.pickerFavoritesOnly = false;
        PickGuidesState.pickerSearchFocused = false;
        PickGuidesState.strategyItemsRenderKey = "";
        PickGuidesState.strategyBaselineHero = "";
        PickGuidesState.strategyBaselineTitle = "";
        PickGuidesState.strategyBaselineItems = [];
        PickGuidesState.previewGuideId = null;
        PickGuidesState.previewGuide = null;
        PickGuidesState.previewPendingGuideId = null;
        PickGuidesState.previewCache = {};
        SetPickGuidesPickerOpen(false);
        RenderPickGuidesPreview();
        $.Schedule(0.1, UpdatePickGuidesVisibility);
        return;
    }

    if (PickGuidesState.heroScriptName !== heroScriptName) {
        InvalidatePickGuidesStrategySync();
        PickGuidesState.heroScriptName = heroScriptName;
        PickGuidesState.requestedHero = "";
    }

    if (PickGuidesState.requestedHero !== heroScriptName) {
        RequestPickGuidesForHero(heroScriptName);
    }

    $.Schedule(0.1, UpdatePickGuidesVisibility);
}

(function () {
    GameEvents.Subscribe("guides_list_response", OnPickGuidesListResponse);
    GameEvents.Subscribe("guides_guide_response", OnPickGuideResponse);
    GameEvents.Subscribe("guides_preview_response", OnPickGuidePreviewResponse);
    GameEvents.Subscribe("guides_error_response", OnPickGuidesError);

    $.Schedule(0.0, () => {
        if (!EnsurePickGuidesPanels()) {
            return;
        }

        RenderPickGuidesState();
        RenderPickGuidesPicker();
        RenderPickGuidesPreview();
        UpdatePickGuidesVisibility();
    });
})();
