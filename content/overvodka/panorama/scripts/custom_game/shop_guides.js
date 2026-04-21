const ShopGuidesRoot = $.GetContextPanel();
let ShopGuidesFrame = null;
let ShopGuidesPicker = null;
let ShopGuidesPickerButtonText = null;
let ShopGuidesSelectedTitle = null;
let ShopGuidesSelectedMeta = null;
let ShopGuidesSummary = null;
let ShopGuidesVoteRow = null;
let ShopGuidesVoteLikeButton = null;
let ShopGuidesVoteLikeCount = null;
let ShopGuidesVoteDislikeButton = null;
let ShopGuidesVoteDislikeCount = null;
let ShopGuidesFavoriteButton = null;
let ShopGuidesSections = null;
let ShopGuidesSkillsBlock = null;
let ShopGuidesSkillsList = null;
let ShopGuidesTalentsWrap = null;
let ShopGuidesTalentsList = null;
let ShopGuidesEmpty = null;
let ShopGuidesPickerList = null;
let ShopGuidesPickerSearchEntry = null;
let ShopGuidesPickerPagination = null;
let ShopGuidesPickerFavoritesButton = null;
let ShopGuidesPickerCloseButton = null;
let ShopGuidesPickerCloseButtonText = null;

const SHOP_GUIDE_SECTION_TITLES = {
    starting: "#SHOP_GUIDES_SECTION_STARTING",
    early: "#SHOP_GUIDES_SECTION_EARLY",
    core: "#SHOP_GUIDES_SECTION_CORE",
    luxury: "#SHOP_GUIDES_SECTION_LUXURY",
    situational: "#SHOP_GUIDES_SECTION_SITUATIONAL",
};
const SHOP_GUIDES_ABILITY_NAME_REMAP = {
    vihor_r: "vihor_ultimate",
    frisk_r: "frisk_ultimate",
    bikov_r: "bikov_ultimate",
    amor_r: "amor_ultimate",
    epstein_q: "epstein_r", acer: "sahur_ultimate", redak: "sahur_e", abuse: "sahur_w", koleso: "sahur_q",
    materka: "dvoreckov_q", alko: "dvoreckov_w", wakas: "dvoreckov_e",
    adod: "kachok_pure_protein", tasty: "kachok_big_tasty", nosex: "kachok_abstention", churban: "kachok_trenbolone", soska: "kachok_test",
    vovacho: "ebanko_q", fofan: "ebanko_w", parit: "ebanko_e", minis: "ebanko_r",
    fei: "eldzhey_q", novape: "eldzhey_w", qmar: "eldzhey_e", srsr: "eldzhey_r",
    shkolota: "shkolnik_peremena", zvonk: "shkolnik_e", or: "shkolnik_r", chef_q: "chef_shout",
    peashooter: "dave_peashooter", sunflower: "dave_sunflower", shield: "dave_e",
    futbik: "speed_penalty", bleval: "speed_bark", twenty: "speed_cr7", gena: "speed_shake",
    stop: "worstsup_q", nerf: "worstsup_w", bigwin: "worstsup_e", code: "rubick_spell_steal",
    pchela: "macan_q", razg: "macan_w", baidul: "macan_e", largus: "macan_r",
    shavel: "mellstroy_shavel", fruits: "mellstroy_meteors", biznes: "mellstroy_business", amamam: "mellstroy_amam",
    bledina: "litvin_bledina", cond: "litvin_conditions", subo: "litvin_subo", zhishi: "litvin_zhishi",
    zveri: "stariy_zveri", yu: "stariy_bolt", lasers: "stariy_lasers",
    dogon: "ashab_dogon", slushay: "ashab_slushay", car: "ashab_car", rocket: "Ashab_rocket",
    konchai: "arsen_konchai", testosteron: "arsen_testosteron", baza: "arsen_baza", tgk: "arsen_tg",
    semya: "nix_semya", gunnar: "gunnar_bash", stopapupa: "zolo_stopapupa",
    awp: "custom_critical_strike", granade: "cheater_granades", antiaim: "custom_passive_evasion", wallhack: "custom_vision_aura", aimlock: "cheater_rage",
};
const SHOP_GUIDES_ITEM_NAME_REMAP = {
    item_octarine_core: "item_octarine_vodka",
    item_heart: "item_heart_vodka",
    item_bloodstone: "item_bloodstone_vodka",
};

const SHOP_GUIDES_NATIVE_HEIGHT_DEFAULT = 148;
const SHOP_GUIDES_NATIVE_HEIGHT_EMPTY = 148;
const SHOP_GUIDES_NATIVE_HEIGHT_MIN = 148;
const SHOP_GUIDES_NATIVE_HEIGHT_MAX = 284;
const SHOP_GUIDES_NATIVE_SUMMARY_BOTTOM_SPACING = 16;
const SHOP_GUIDES_NATIVE_VOTE_ROW_HEIGHT = 46;
const SHOP_GUIDES_MAX_SUMMARY_CHARS = 200;
const SHOP_GUIDES_PICKER_PAGE_SIZE = 5;

const ShopGuidesState = {
    heroScriptName: "",
    requestedHero: "",
    list: [],
    selectedGuideId: 0,
    guide: null,
    loading: false,
    pickerOpen: false,
    pickerPage: 1,
    pickerSearchText: "",
    hiddenStandardPanels: [],
    dockReady: false,
    nativeBuildHeightPx: SHOP_GUIDES_NATIVE_HEIGHT_DEFAULT,
    nativeGuideOverrideActive: false,
    defaultNativeSections: null,
    votePending: false,
    favoritePending: false,
    pickerFavoritesOnly: false,
};

function EnsureShopGuidesMainPanels() {
    if (
        ShopGuidesFrame && ShopGuidesFrame.IsValid && ShopGuidesFrame.IsValid() &&
        ShopGuidesSelectedTitle && ShopGuidesSelectedTitle.IsValid && ShopGuidesSelectedTitle.IsValid() &&
        ShopGuidesPickerButtonText && ShopGuidesPickerButtonText.IsValid && ShopGuidesPickerButtonText.IsValid() &&
        ShopGuidesFavoriteButton && ShopGuidesFavoriteButton.IsValid && ShopGuidesFavoriteButton.IsValid()
    ) {
        return true;
    }

    ShopGuidesFrame = ShopGuidesRoot.FindChildTraverse("ShopGuidesFrame");
    ShopGuidesPickerButtonText = ShopGuidesRoot.FindChildTraverse("ShopGuidesPickerButtonText");
    if (!ShopGuidesPickerButtonText && ShopGuidesFrame && ShopGuidesFrame.IsValid && ShopGuidesFrame.IsValid()) {
        ShopGuidesPickerButtonText = ShopGuidesFrame.FindChildTraverse("ShopGuidesPickerButtonText");
    }
    ShopGuidesSelectedTitle = ShopGuidesRoot.FindChildTraverse("ShopGuidesSelectedTitle");
    ShopGuidesSelectedMeta = ShopGuidesRoot.FindChildTraverse("ShopGuidesSelectedMeta");
    ShopGuidesSummary = ShopGuidesRoot.FindChildTraverse("ShopGuidesSummary");
    ShopGuidesVoteRow = ShopGuidesRoot.FindChildTraverse("ShopGuidesVoteRow");
    ShopGuidesVoteLikeButton = ShopGuidesRoot.FindChildTraverse("ShopGuidesVoteLikeButton");
    ShopGuidesVoteLikeCount = ShopGuidesRoot.FindChildTraverse("ShopGuidesVoteLikeCount");
    ShopGuidesVoteDislikeButton = ShopGuidesRoot.FindChildTraverse("ShopGuidesVoteDislikeButton");
    ShopGuidesVoteDislikeCount = ShopGuidesRoot.FindChildTraverse("ShopGuidesVoteDislikeCount");
    ShopGuidesFavoriteButton = ShopGuidesRoot.FindChildTraverse("ShopGuidesFavoriteButton");
    ShopGuidesSections = ShopGuidesRoot.FindChildTraverse("ShopGuidesSections");
    ShopGuidesSkillsBlock = ShopGuidesRoot.FindChildTraverse("ShopGuidesSkillsBlock");
    ShopGuidesSkillsList = ShopGuidesRoot.FindChildTraverse("ShopGuidesSkillsList");
    ShopGuidesTalentsWrap = ShopGuidesRoot.FindChildTraverse("ShopGuidesTalentsWrap");
    ShopGuidesTalentsList = ShopGuidesRoot.FindChildTraverse("ShopGuidesTalentsList");
    ShopGuidesEmpty = ShopGuidesRoot.FindChildTraverse("ShopGuidesEmpty");

    if (ShopGuidesVoteLikeButton) {
        ShopGuidesVoteLikeButton.SetPanelEvent("onactivate", () => VoteCurrentShopGuide(1));
    }

    if (ShopGuidesVoteDislikeButton) {
        ShopGuidesVoteDislikeButton.SetPanelEvent("onactivate", () => VoteCurrentShopGuide(-1));
    }

    if (ShopGuidesFavoriteButton) {
        ShopGuidesFavoriteButton.SetPanelEvent("onactivate", ToggleCurrentShopGuideFavorite);
    }

    return !!(
        ShopGuidesFrame &&
        ShopGuidesPickerButtonText &&
        ShopGuidesSelectedTitle &&
        ShopGuidesSelectedMeta &&
        ShopGuidesSummary &&
        ShopGuidesVoteRow &&
        ShopGuidesVoteLikeButton &&
        ShopGuidesVoteLikeCount &&
        ShopGuidesVoteDislikeButton &&
        ShopGuidesVoteDislikeCount &&
        ShopGuidesFavoriteButton &&
        ShopGuidesSections &&
        ShopGuidesSkillsBlock &&
        ShopGuidesSkillsList &&
        ShopGuidesTalentsWrap &&
        ShopGuidesTalentsList &&
        ShopGuidesEmpty
    );
}

function EnsureShopGuidesPickerPanels() {
    if (
        ShopGuidesPicker && ShopGuidesPicker.IsValid && ShopGuidesPicker.IsValid() &&
        ShopGuidesPickerButtonText && ShopGuidesPickerButtonText.IsValid && ShopGuidesPickerButtonText.IsValid() &&
        ShopGuidesPickerList && ShopGuidesPickerList.IsValid && ShopGuidesPickerList.IsValid() &&
        ShopGuidesPickerFavoritesButton && ShopGuidesPickerFavoritesButton.IsValid && ShopGuidesPickerFavoritesButton.IsValid()
    ) {
        return true;
    }

    ShopGuidesPicker = ShopGuidesPicker && ShopGuidesPicker.IsValid && ShopGuidesPicker.IsValid()
        ? ShopGuidesPicker
        : ShopGuidesRoot.FindChildTraverse("ShopGuidesPicker");
    ShopGuidesPickerButtonText = ShopGuidesRoot.FindChildTraverse("ShopGuidesPickerButtonText");
    if (!ShopGuidesPickerButtonText && ShopGuidesFrame && ShopGuidesFrame.IsValid && ShopGuidesFrame.IsValid()) {
        ShopGuidesPickerButtonText = ShopGuidesFrame.FindChildTraverse("ShopGuidesPickerButtonText");
    }
    ShopGuidesPickerList = ShopGuidesPicker && ShopGuidesPicker.IsValid && ShopGuidesPicker.IsValid()
        ? ShopGuidesPicker.FindChildTraverse("ShopGuidesPickerList") || ShopGuidesPickerList
        : ShopGuidesRoot.FindChildTraverse("ShopGuidesPickerList");
    ShopGuidesPickerSearchEntry = ShopGuidesPicker && ShopGuidesPicker.IsValid && ShopGuidesPicker.IsValid()
        ? ShopGuidesPicker.FindChildTraverse("ShopGuidesPickerSearchEntry") || ShopGuidesPickerSearchEntry
        : ShopGuidesRoot.FindChildTraverse("ShopGuidesPickerSearchEntry");
    ShopGuidesPickerPagination = ShopGuidesPicker && ShopGuidesPicker.IsValid && ShopGuidesPicker.IsValid()
        ? ShopGuidesPicker.FindChildTraverse("ShopGuidesPickerPagination") || ShopGuidesPickerPagination
        : ShopGuidesRoot.FindChildTraverse("ShopGuidesPickerPagination");
    ShopGuidesPickerFavoritesButton = ShopGuidesPicker && ShopGuidesPicker.IsValid && ShopGuidesPicker.IsValid()
        ? ShopGuidesPicker.FindChildTraverse("ShopGuidesPickerFavoritesButton") || ShopGuidesPickerFavoritesButton
        : ShopGuidesRoot.FindChildTraverse("ShopGuidesPickerFavoritesButton");
    ShopGuidesPickerCloseButton = ShopGuidesPicker && ShopGuidesPicker.IsValid && ShopGuidesPicker.IsValid()
        ? ShopGuidesPicker.FindChildTraverse("ShopGuidesPickerCloseButton") || ShopGuidesPickerCloseButton
        : ShopGuidesRoot.FindChildTraverse("ShopGuidesPickerCloseButton");
    ShopGuidesPickerCloseButtonText = ShopGuidesPicker && ShopGuidesPicker.IsValid && ShopGuidesPicker.IsValid()
        ? ShopGuidesPicker.FindChildTraverse("ShopGuidesPickerCloseButtonText") || ShopGuidesPickerCloseButtonText
        : ShopGuidesRoot.FindChildTraverse("ShopGuidesPickerCloseButtonText");

    if (ShopGuidesPickerCloseButton && ShopGuidesPickerCloseButton.style) {
        ShopGuidesPickerCloseButton.style.flowChildren = "none";
    }

    if (ShopGuidesPickerCloseButtonText && ShopGuidesPickerCloseButtonText.style) {
        ShopGuidesPickerCloseButtonText.style.width = "100%";
        ShopGuidesPickerCloseButtonText.style.height = "100%";
        ShopGuidesPickerCloseButtonText.style.textAlign = "center";
        ShopGuidesPickerCloseButtonText.style.position = "0px 0px 0px";
    }

    return !!(
        ShopGuidesPicker &&
        ShopGuidesPickerButtonText &&
        ShopGuidesPickerList &&
        ShopGuidesPickerSearchEntry &&
        ShopGuidesPickerFavoritesButton &&
        ShopGuidesPickerPagination
    );
}

function ShopGuidesToArray(value) {
    if (!value || typeof value !== "object") {
        return [];
    }

    return toArray(value);
}

function TrimShopGuidesSummaryText(value) {
    const text = String(value || "").replace(/\r/g, "").trim();
    if (!text) {
        return "";
    }

    if (text.length <= SHOP_GUIDES_MAX_SUMMARY_CHARS) {
        return text;
    }

    return `${text.slice(0, Math.max(0, SHOP_GUIDES_MAX_SUMMARY_CHARS - 3)).trimEnd()}...`;
}

function IsDefaultShopGuide(guide) {
    return !!guide && (Number(guide.id) === 0 || Number(guide.is_default_guide || 0) === 1);
}

function GetGuideDisplayTitle(guide) {
    if (IsDefaultShopGuide(guide)) {
        return $.Localize("#SHOP_GUIDES_DEFAULT_TITLE");
    }

    return guide?.title || $.Localize("#SHOP_GUIDES_UNTITLED");
}

function GetGuideSummaryText(guide) {
    if (IsDefaultShopGuide(guide)) {
        return $.Localize("#SHOP_GUIDES_DEFAULT_SUMMARY");
    }

    return TrimShopGuidesSummaryText(guide?.summary || "");
}

function GetGuidePickerMetaText(guide) {
    if (!guide) {
        return "";
    }

    if (IsDefaultShopGuide(guide)) {
        return $.Localize("#SHOP_GUIDES_DEFAULT_PICKER_META");
    }

    const author = guide.author_display_name || guide.author?.display_name || "";
    return `${author} | ${$.Localize("#SHOP_GUIDES_RATING")} ${Number(guide.rating || 0)}`;
}

function NormalizeShopGuidesSearchText(value) {
    return String(value || "").trim().toLowerCase();
}

function GetFilteredShopGuidesList() {
    const query = NormalizeShopGuidesSearchText(ShopGuidesState.pickerSearchText);
    return ShopGuidesState.list.filter((guide) => {
        if (ShopGuidesState.pickerFavoritesOnly && !guide?.is_favorite) {
            return false;
        }

        if (!query) {
            return true;
        }

        const title = String(GetGuideDisplayTitle(guide) || "").toLowerCase();
        return title.includes(query);
    });
}

function MoveDefaultGuideToTop(list) {
    const guides = list && typeof list.length === "number" ? list.slice() : [];
    const defaultGuides = guides.filter((guide) => IsDefaultShopGuide(guide));
    const otherGuides = guides.filter((guide) => !IsDefaultShopGuide(guide));
    return defaultGuides.concat(otherGuides);
}

function ClampShopGuidesPickerPage(page, totalPages) {
    return Math.max(1, Math.min(totalPages, Number(page) || 1));
}

function FindShopGuidesParent() {
    return FindDotaHudElement("HudShop") ||
        FindDotaHudElement("ShopMain") ||
        FindDotaHudElement("shop");
}

function FindShopGuidesOverlayParent() {
    return FindDotaHudElement("HUDElements") ||
        FindDotaHudElement("Hud") ||
        ShopGuidesRoot.GetParent();
}

function RestoreStandardGuidePanel() {
    for (const panel of ShopGuidesState.hiddenStandardPanels) {
        if (panel && panel.IsValid && panel.IsValid()) {
            panel.visible = true;
        }
    }

    ShopGuidesState.hiddenStandardPanels = [];
}

function UpdateShopGuidesPickerDock() {
    if (!EnsureShopGuidesMainPanels() || !EnsureShopGuidesPickerPanels() || !ShopGuidesFrame || !ShopGuidesPicker) {
        return;
    }

    const overlayParent = FindShopGuidesOverlayParent();
    if (!overlayParent || !overlayParent.GetPositionWithinWindow || !ShopGuidesFrame.GetPositionWithinWindow) {
        return;
    }

    if (ShopGuidesPicker.GetParent() !== overlayParent) {
        ShopGuidesPicker.SetParent(overlayParent);
    }

    const overlayPos = overlayParent.GetPositionWithinWindow();
    const framePos = ShopGuidesFrame.GetPositionWithinWindow();
    const overlayX = NormalizeShopGuidesMetric(overlayPos.x);
    const overlayY = NormalizeShopGuidesMetric(overlayPos.y);
    const frameX = NormalizeShopGuidesMetric(framePos.x);
    const frameY = NormalizeShopGuidesMetric(framePos.y);
    const pickerWidth = NormalizeShopGuidesMetric(ShopGuidesPicker.actuallayoutwidth, 238);
    if (overlayX == null || overlayY == null || frameX == null || frameY == null || pickerWidth == null) {
        return;
    }

    const pickerX = Math.round(frameX - overlayX - Math.max(238, pickerWidth) - 14);
    const pickerY = Math.round(frameY - overlayY + 4);

    ShopGuidesPicker.style.position = `${pickerX}px ${pickerY}px 0px`;
}

function NormalizeShopGuidesMetric(value, fallback = null) {
    const numeric = Number(value);
    if (!Number.isFinite(numeric)) {
        return fallback;
    }

    if (Math.abs(numeric) >= 1000000) {
        return fallback;
    }

    return numeric;
}

function ClampShopGuidesNativeHeight(value) {
    const numeric = Math.round(Number(value) || SHOP_GUIDES_NATIVE_HEIGHT_DEFAULT);
    return Math.max(SHOP_GUIDES_NATIVE_HEIGHT_MIN, Math.min(SHOP_GUIDES_NATIVE_HEIGHT_MAX, numeric));
}

function NormalizeGuideItemName(itemName) {
    const normalized = String(itemName || "");
    return SHOP_GUIDES_ITEM_NAME_REMAP[normalized] || normalized;
}

function CountApproxGuideLines(text, charsPerLine) {
    if (!text) {
        return 0;
    }

    const normalized = String(text).replace(/\r/g, "");
    const lines = normalized.split("\n");
    let total = 0;

    for (const line of lines) {
        const trimmedLength = line.trim().length;
        if (trimmedLength === 0) {
            total += 1;
            continue;
        }

        total += Math.max(1, Math.ceil(trimmedLength / charsPerLine));
    }

    return total;
}

function CalculateShopGuidesNativeBuildHeight(guide) {
    if (!guide) {
        return SHOP_GUIDES_NATIVE_HEIGHT_EMPTY;
    }

    const titleLines = Math.max(1, CountApproxGuideLines(GetGuideDisplayTitle(guide), 22));
    const metaLines = Math.max(1, CountApproxGuideLines(FormatGuideMeta(guide), 42));
    const summaryLines = CountApproxGuideLines(GetGuideSummaryText(guide), 30);
    const summaryBottomSpacing = IsDefaultShopGuide(guide) ? 0 : SHOP_GUIDES_NATIVE_SUMMARY_BOTTOM_SPACING;
    const voteRowHeight = IsDefaultShopGuide(guide) ? 0 : SHOP_GUIDES_NATIVE_VOTE_ROW_HEIGHT;

    const calculatedHeight =
        28 +                  // header row
        18 +                  // header padding/border
        (titleLines * 17) +
        (metaLines * 12) +
        (summaryLines > 0 ? 16 + (summaryLines * 15) + summaryBottomSpacing : 0) +
        voteRowHeight +
        18;                   // content padding

    return ClampShopGuidesNativeHeight(calculatedHeight);
}

function ApplyShopGuidesNativeBuildHeight(heightPx) {
    ShopGuidesState.nativeBuildHeightPx = ClampShopGuidesNativeHeight(heightPx);
}

function FindShopGuidesDockData(shopPanel) {
    const nativeItemBuild = FindDotaHudElement("ItemBuild");
    const nativeCategories = FindDotaHudElement("Categories");
    const nativeBuildTitleContainer = FindDotaHudElement("BuildTitleContainer");
    if (nativeItemBuild && nativeCategories) {
        return {
            parent: nativeItemBuild,
            hiddenPanels: nativeBuildTitleContainer ? [nativeBuildTitleContainer] : [],
            mode: "native_build",
        };
    }

    const itemsArea = FindDotaHudElement("ItemsArea");
    const itemBuildContainer = FindDotaHudElement("ItemBuildContainer");
    if (itemsArea && itemBuildContainer) {
        return {
            parent: itemsArea,
            hiddenPanels: [itemBuildContainer],
            mode: "fill",
        };
    }

    const mainPanel = FindDotaHudElement("Main") || shopPanel;
    const itemsPanel = FindDotaHudElement("ItemCombinesAndBasicItemsContainer");
    const titlesPanel = FindDotaHudElement("titles");

    if (!mainPanel || !itemsPanel || !titlesPanel ||
        !itemsPanel.GetPositionWithinWindow || !titlesPanel.GetPositionWithinWindow || !mainPanel.GetPositionWithinWindow) {
        return null;
    }

    const mainPos = mainPanel.GetPositionWithinWindow();
    const itemsPos = itemsPanel.GetPositionWithinWindow();
    const titlesPos = titlesPanel.GetPositionWithinWindow();

    const mainX = NormalizeShopGuidesMetric(mainPos.x);
    const mainY = NormalizeShopGuidesMetric(mainPos.y);
    const itemsX = NormalizeShopGuidesMetric(itemsPos.x);
    const itemsY = NormalizeShopGuidesMetric(itemsPos.y);
    const titlesX = NormalizeShopGuidesMetric(titlesPos.x);
    const titlesY = NormalizeShopGuidesMetric(titlesPos.y);
    const itemsWidth = NormalizeShopGuidesMetric(itemsPanel.actuallayoutwidth);
    const itemsHeight = NormalizeShopGuidesMetric(itemsPanel.actuallayoutheight);
    const titlesWidth = NormalizeShopGuidesMetric(titlesPanel.actuallayoutwidth);
    const titlesHeight = NormalizeShopGuidesMetric(titlesPanel.actuallayoutheight);

    if (
        mainX == null || mainY == null ||
        itemsX == null || itemsY == null ||
        titlesX == null || titlesY == null ||
        itemsWidth == null || itemsHeight == null ||
        titlesWidth == null || titlesHeight == null
    ) {
        return null;
    }

    const minX = Math.min(itemsX, titlesX);
    const minY = Math.min(itemsY, titlesY);
    const maxX = Math.max(itemsX + itemsWidth, titlesX + titlesWidth);
    const maxY = Math.max(itemsY + itemsHeight, titlesY + titlesHeight);

    if (maxX <= minX || maxY <= minY) {
        return null;
    }

    const width = Math.round(maxX - minX);
    const height = Math.round(maxY - minY);
    if (width <= 0 || height <= 0 || width > 5000 || height > 5000) {
        return null;
    }

    return {
        parent: mainPanel,
        hiddenPanels: [itemsPanel, titlesPanel],
        mode: "absolute",
        x: Math.max(0, Math.round(minX - mainX)),
        y: Math.max(0, Math.round(minY - mainY)),
        width: Math.max(1, width),
        height: Math.max(1, height),
    };
}

function IsShopGuidesPanelVisible(panel) {
    if (!panel) {
        return false;
    }

    return panel.visible !== false &&
        panel.style.visibility !== "collapse" &&
        panel.actuallayoutwidth > 0 &&
        panel.actuallayoutheight > 0;
}

function IsShopGuidesOpen() {
    if (GameUI && typeof GameUI.IsShopOpen === "function") {
        return GameUI.IsShopOpen();
    }

    if (Game && typeof Game.IsShopOpen === "function") {
        return Game.IsShopOpen();
    }

    return IsShopGuidesPanelVisible(FindShopGuidesParent());
}

function EnsureShopGuidesParent() {
    const shopPanel = FindShopGuidesParent();
    if (!shopPanel) {
        return null;
    }

    const dockData = FindShopGuidesDockData(shopPanel);
    ShopGuidesState.dockReady = !!dockData;
    const targetParent = dockData && dockData.parent ? dockData.parent : shopPanel;

    if (!dockData && ShopGuidesState.hiddenStandardPanels.length > 0) {
        RestoreStandardGuidePanel();
    }

    if (ShopGuidesRoot.GetParent() !== targetParent) {
        ShopGuidesRoot.SetParent(targetParent);
    }

    if (dockData) {
        if (dockData.mode === "native_build") {
            const nativeHeightPx = ShopGuidesState.nativeBuildHeightPx || SHOP_GUIDES_NATIVE_HEIGHT_DEFAULT;
            ShopGuidesRoot.style.width = "100%";
            ShopGuidesRoot.style.height = `${nativeHeightPx}px`;
            ShopGuidesRoot.style.position = "0px 0px 0px";

            const nativeCategories = FindDotaHudElement("Categories");
            if (nativeCategories) {
                nativeCategories.style.position = `0px ${nativeHeightPx}px 0px`;
                nativeCategories.style.paddingTop = "0px";
            }
        } else if (dockData.mode === "fill") {
            ShopGuidesRoot.style.width = "100%";
            ShopGuidesRoot.style.height = "100%";
            ShopGuidesRoot.style.position = "0px 0px 0px";
        } else {
            ShopGuidesRoot.style.width = `${dockData.width}px`;
            ShopGuidesRoot.style.height = `${dockData.height}px`;
            ShopGuidesRoot.style.position = `${dockData.x}px ${dockData.y}px 0px`;
        }

        if (ShopGuidesState.hiddenStandardPanels.length === 0) {
            for (const panel of dockData.hiddenPanels) {
                panel.visible = false;
            }
            ShopGuidesState.hiddenStandardPanels = dockData.hiddenPanels;
        }
    } else {
        ShopGuidesRoot.style.width = "0px";
        ShopGuidesRoot.style.height = "0px";
        ShopGuidesRoot.style.position = "0px 0px 0px";
    }

    UpdateShopGuidesPickerDock();

    return shopPanel;
}

function GetLocalGuideHeroScriptName() {
    const localPlayerID = Players.GetLocalPlayer();
    if (localPlayerID == null || localPlayerID < 0) {
        return "";
    }

    const heroEnt = Players.GetPlayerHeroEntityIndex(localPlayerID);
    if (heroEnt == null || heroEnt === -1) {
        return "";
    }

    return Entities.GetUnitName(heroEnt) || "";
}

function NormalizeGuideAbilityName(abilityScriptName) {
    const normalized = typeof abilityScriptName === "string" ? abilityScriptName : "";
    return SHOP_GUIDES_ABILITY_NAME_REMAP[normalized] || normalized;
}

function GetGuideAbilityDisplayName(abilityScriptName) {
    abilityScriptName = NormalizeGuideAbilityName(abilityScriptName);
    const token = `#DOTA_Tooltip_ability_${abilityScriptName}`;
    const localized = $.Localize(token);
    if (localized === token) {
        return abilityScriptName;
    }

    return localized;
}

function GetGuideSectionTitle(sectionKey, customTitle) {
    if (customTitle && customTitle.length > 0) {
        return customTitle.startsWith("#") ? $.Localize(customTitle) : customTitle;
    }

    const token = SHOP_GUIDE_SECTION_TITLES[sectionKey];
    return token ? $.Localize(token) : sectionKey;
}

function FormatGuideMeta(guide) {
    if (!guide) {
        return "";
    }

    if (IsDefaultShopGuide(guide)) {
        return `${$.Localize("#SHOP_GUIDES_BY")} worstsup`;
    }

    const author = guide.author?.display_name || guide.author_display_name || "";
    const rating = Number(guide.rating || 0);
    const views = Number(guide.views_count || 0);
    const updated = guide.updated_msk_date || "";
    const chunks = [];

    if (author) {
        chunks.push(`${$.Localize("#SHOP_GUIDES_BY")} ${author}`);
    }

    chunks.push(`${$.Localize("#SHOP_GUIDES_RATING")} ${rating}`);
    chunks.push(`${$.Localize("#SHOP_GUIDES_VIEWS")} ${views}`);

    if (updated) {
        chunks.push(`${$.Localize("#SHOP_GUIDES_UPDATED")} ${updated}`);
    }

    return chunks.join("  |  ");
}

function IsGuideVoteAvailable(guide) {
    return !!guide && !IsDefaultShopGuide(guide) && Number(guide.id || 0) > 0;
}

function IsGuideFavoriteAvailable(guide) {
    return !!guide && !IsDefaultShopGuide(guide) && Number(guide.id || 0) > 0;
}

function GetGuideViewerVote(guide) {
    return Number(guide?.viewer_vote || 0);
}

function IsGuideFavorite(guide) {
    return guide?.is_favorite === true || Number(guide?.is_favorite || 0) === 1;
}

function SetShopGuideVoteButtonsEnabled(enabled) {
    const isEnabled = !!enabled;
    if (ShopGuidesVoteLikeButton) {
        ShopGuidesVoteLikeButton.SetHasClass("Disabled", !isEnabled);
        ShopGuidesVoteLikeButton.hittest = isEnabled;
    }

    if (ShopGuidesVoteDislikeButton) {
        ShopGuidesVoteDislikeButton.SetHasClass("Disabled", !isEnabled);
        ShopGuidesVoteDislikeButton.hittest = isEnabled;
    }
}

function SetShopGuideFavoriteButtonEnabled(enabled) {
    const isEnabled = !!enabled;
    if (!ShopGuidesFavoriteButton) {
        return;
    }

    ShopGuidesFavoriteButton.SetHasClass("Disabled", !isEnabled);
    ShopGuidesFavoriteButton.hittest = isEnabled;
}

function UpdateShopGuideVoteButtons(guide) {
    if (!EnsureShopGuidesMainPanels()) {
        return;
    }

    const canShowVoteRow = IsGuideVoteAvailable(guide) || IsGuideFavoriteAvailable(guide);
    ShopGuidesVoteRow.visible = canShowVoteRow;

    if (!IsGuideVoteAvailable(guide)) {
        SetShopGuideVoteButtonsEnabled(false);
        ShopGuidesVoteLikeButton.SetHasClass("Active", false);
        ShopGuidesVoteDislikeButton.SetHasClass("Active", false);
        ShopGuidesVoteLikeCount.text = "0";
        ShopGuidesVoteDislikeCount.text = "0";
    } else {
        const viewerVote = GetGuideViewerVote(guide);
        const isOwnGuide = !!Number(guide.is_own_guide || 0) || guide.is_own_guide === true;
        const enabled = !ShopGuidesState.votePending && !isOwnGuide;

        ShopGuidesVoteLikeCount.text = `${Math.max(0, Number(guide.likes_count || 0))}`;
        ShopGuidesVoteDislikeCount.text = `${Math.max(0, Number(guide.dislikes_count || 0))}`;
        ShopGuidesVoteLikeButton.SetHasClass("Active", viewerVote === 1);
        ShopGuidesVoteDislikeButton.SetHasClass("Active", viewerVote === -1);
        SetShopGuideVoteButtonsEnabled(enabled);
    }

    if (!ShopGuidesFavoriteButton) {
        return;
    }

    if (!IsGuideFavoriteAvailable(guide)) {
        ShopGuidesFavoriteButton.SetHasClass("Active", false);
        SetShopGuideFavoriteButtonEnabled(false);
        return;
    }

    ShopGuidesFavoriteButton.SetHasClass("Active", IsGuideFavorite(guide));
    SetShopGuideFavoriteButtonEnabled(!ShopGuidesState.favoritePending);
}

function VoteCurrentShopGuide(voteValue) {
    const numericVoteValue = Number(voteValue);
    const guide = ShopGuidesState.guide;
    if (!IsGuideVoteAvailable(guide) || ShopGuidesState.votePending) {
        return;
    }

    if (!!Number(guide.is_own_guide || 0) || guide.is_own_guide === true) {
        return;
    }

    if (numericVoteValue !== 1 && numericVoteValue !== -1) {
        return;
    }

    ShopGuidesState.votePending = true;
    UpdateShopGuideVoteButtons(guide);

    GameEvents.SendCustomGameEventToServer("guides_vote_guide", {
        guide_id: Number(guide.id || 0),
        value: numericVoteValue,
    });
}

function ToggleCurrentShopGuideFavorite() {
    const guide = ShopGuidesState.guide;
    if (!IsGuideFavoriteAvailable(guide) || ShopGuidesState.favoritePending) {
        return;
    }

    ShopGuidesState.favoritePending = true;
    UpdateShopGuideVoteButtons(guide);

    GameEvents.SendCustomGameEventToServer("guides_toggle_favorite", {
        guide_id: Number(guide.id || 0),
    });
}

function EnsureShopGuidesNativeBuildPanels() {
    const itemBuild = FindDotaHudElement("ItemBuild");
    const categoriesRoot = FindDotaHudElement("Categories");
    if (!itemBuild || !categoriesRoot) {
        return null;
    }

    const categoryPanels = categoriesRoot.Children().filter((panel) => panel && panel.FindChildTraverse && panel.FindChildTraverse("ItemList"));
    if (!categoryPanels.length) {
        return null;
    }

    return {
        itemBuild,
        categoriesRoot,
        categoryPanels,
    };
}

function FindFirstGuideLabel(panel) {
    if (!panel || !panel.Children) {
        return null;
    }

    const children = panel.Children();
    for (const child of children) {
        if (!child) {
            continue;
        }

        if (child.id === "ItemList") {
            continue;
        }

        if (child.paneltype === "Label") {
            return child;
        }

        const nested = FindFirstGuideLabel(child);
        if (nested) {
            return nested;
        }
    }

    return null;
}

function GetShopGuidesItemName(shopItem) {
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

function ApplyShopGuidesItemVisualState(shopItem) {
    if (!shopItem) {
        return;
    }

    shopItem.AddClass("MainShopItem");
    shopItem.AddClass("SideShopItem");
    shopItem.RemoveClass("CanPurchase");
    shopItem.RemoveClass("Popular");

    const panelsToHide = [
        "PopularOverlay",
        "Popular",
        "CanPurchaseOverlay",
        "CanPurchase",
    ];

    for (const panelId of panelsToHide) {
        const panel = shopItem.FindChildTraverse ? shopItem.FindChildTraverse(panelId) : null;
        if (!panel) {
            continue;
        }

        panel.visible = false;
        panel.hittest = false;
        panel.hittestchildren = false;
        if (panel.style) {
            panel.style.visibility = "collapse";
        }
    }
}

function CaptureDefaultNativeBuildSections(nativePanels) {
    if (!nativePanels || !nativePanels.categoryPanels) {
        return [];
    }

    const sections = [];

    for (const categoryPanel of nativePanels.categoryPanels) {
        const itemList = categoryPanel && categoryPanel.FindChildTraverse ? categoryPanel.FindChildTraverse("ItemList") : null;
        if (!itemList) {
            continue;
        }

        const items = [];
        for (const child of itemList.Children()) {
            const itemName = GetShopGuidesItemName(child);
            if (!itemName) {
                continue;
            }

            items.push({
                item_name: itemName,
                note: "",
            });
        }

        if (!items.length) {
            continue;
        }

        const titleLabel = FindFirstGuideLabel(categoryPanel);
        sections.push({
            key: titleLabel ? titleLabel.text : "",
            title: titleLabel ? titleLabel.text : "",
            items,
        });
    }

    return sections;
}

function SanitizeCurrentNativeBuildPanels(nativePanels) {
    if (!nativePanels || !nativePanels.categoryPanels) {
        return;
    }

    for (const categoryPanel of nativePanels.categoryPanels) {
        const itemList = categoryPanel && categoryPanel.FindChildTraverse ? categoryPanel.FindChildTraverse("ItemList") : null;
        if (!itemList) {
            continue;
        }

        for (const child of itemList.Children()) {
            ApplyShopGuidesItemVisualState(child);
        }
    }
}

function PopulateNativeGuideItemList(itemList, items) {
    itemList.RemoveAndDeleteChildren();

    for (let itemIndex = 0; itemIndex < items.length; itemIndex++) {
        const item = items[itemIndex];
        const shopItem = $.CreatePanel("DOTAShopItem", itemList, `GuideNativeItem_${itemIndex}`, {
            itemname: NormalizeGuideItemName(item.item_name),
            style: "width: 42px; height: width-percentage(72.7%); margin-bottom: 5px; margin-right: 6px;",
        });
        ApplyShopGuidesItemVisualState(shopItem);
    }
}

function RenderShopGuidesIntoNativeBuild(itemSections) {
    const nativePanels = EnsureShopGuidesNativeBuildPanels();
    if (!nativePanels) {
        return false;
    }

    const sectionsToRender = itemSections.filter((section) => ShopGuidesToArray(section.items).length > 0);

    for (let index = 0; index < nativePanels.categoryPanels.length; index++) {
        const categoryPanel = nativePanels.categoryPanels[index];
        const itemList = categoryPanel.FindChildTraverse("ItemList");
        if (!itemList) {
            continue;
        }

        const section = sectionsToRender[index];
        categoryPanel.visible = !!section;

        if (!section) {
            itemList.RemoveAndDeleteChildren();
            continue;
        }

        const titleLabel = FindFirstGuideLabel(categoryPanel);
        if (titleLabel) {
            titleLabel.text = GetGuideSectionTitle(section.key, section.title);
        }

        PopulateNativeGuideItemList(itemList, ShopGuidesToArray(section.items));
    }

    return true;
}

function SetShopGuidesPickerOpen(isOpen) {
    if (!EnsureShopGuidesPickerPanels()) {
        return;
    }

    ShopGuidesState.pickerOpen = !!isOpen && ShopGuidesState.list.length > 0;
    ShopGuidesPicker.SetHasClass("Open", ShopGuidesState.pickerOpen);

    if (ShopGuidesState.pickerOpen) {
        UpdateShopGuidesPickerDock();
        $.Schedule(0.0, UpdateShopGuidesPickerDock);
    }
}

function ToggleShopGuidePicker() {
    SetShopGuidesPickerOpen(!ShopGuidesState.pickerOpen);
}

function CloseShopGuidePicker() {
    SetShopGuidesPickerOpen(false);
}

function SetShopGuidesPickerPage(page) {
    const filteredGuides = GetFilteredShopGuidesList();
    const totalPages = Math.max(1, Math.ceil(filteredGuides.length / SHOP_GUIDES_PICKER_PAGE_SIZE));
    ShopGuidesState.pickerPage = ClampShopGuidesPickerPage(page, totalPages);
    RenderShopGuidesPicker();
}

function OnShopGuidesSearchChanged() {
    if (!EnsureShopGuidesPickerPanels() || !ShopGuidesPickerSearchEntry) {
        return;
    }

    ShopGuidesState.pickerSearchText = ShopGuidesPickerSearchEntry.text || "";
    ShopGuidesState.pickerPage = 1;
    RenderShopGuidesPicker();
}

function ToggleShopGuidesFavoritesOnly() {
    if (!EnsureShopGuidesPickerPanels()) {
        return;
    }

    ShopGuidesState.pickerFavoritesOnly = !ShopGuidesState.pickerFavoritesOnly;
    ShopGuidesState.pickerPage = 1;
    RenderShopGuidesPicker();
}

function CreateGuideWrappedItems(parent, items) {
    const perRow = 4;

    for (let index = 0; index < items.length; index += perRow) {
        const row = $.CreatePanel("Panel", parent, "");
        row.AddClass("ShopGuidesItemsRow");

        const rowItems = items.slice(index, index + perRow);
        for (let rowIndex = 0; rowIndex < rowItems.length; rowIndex++) {
            const item = rowItems[rowIndex];
            const shopItem = $.CreatePanel("DOTAShopItem", row, `GuideItem_${index + rowIndex}`, {
                itemname: NormalizeGuideItemName(item.item_name),
                style: "width: 42px; height: width-percentage(72.7%); margin-top: 3px; margin-bottom: 3px; margin-right: 6px; margin-left: 0px;",
            });
            shopItem.AddClass("ShopGuidesShopItem");
            ApplyShopGuidesItemVisualState(shopItem);
        }
    }
}

function RenderShopGuideDetails() {
    if (!EnsureShopGuidesMainPanels()) {
        return;
    }

    DeleteAllChildren(ShopGuidesSections);
    DeleteAllChildren(ShopGuidesSkillsList);
    DeleteAllChildren(ShopGuidesTalentsList);

    const guide = ShopGuidesState.guide;
    if (!guide) {
        ShopGuidesSummary.visible = false;
        UpdateShopGuideVoteButtons(null);
        if (ShopGuidesSkillsBlock) {
            ShopGuidesSkillsBlock.visible = false;
        }
        ShopGuidesTalentsWrap.visible = false;
        return;
    }

    const summaryText = GetGuideSummaryText(guide);
    ShopGuidesSummary.visible = !!summaryText;
    ShopGuidesSummary.text = summaryText;
    UpdateShopGuideVoteButtons(guide);

    const itemSections = ShopGuidesToArray(guide.item_sections);
    const nativePanels = EnsureShopGuidesNativeBuildPanels();
    if (nativePanels && !ShopGuidesState.defaultNativeSections) {
        const capturedSections = CaptureDefaultNativeBuildSections(nativePanels);
        if (capturedSections.length > 0) {
            ShopGuidesState.defaultNativeSections = capturedSections;
        }
    }

    const hasNativeItems = itemSections.some((section) => ShopGuidesToArray(section.items).length > 0);
    const shouldPreserveDefaultNativeBuild = IsDefaultShopGuide(guide) && !ShopGuidesState.nativeGuideOverrideActive;
    let usingNativeBuild = false;

    if (shouldPreserveDefaultNativeBuild) {
        usingNativeBuild = true;
        ShopGuidesState.nativeGuideOverrideActive = false;
        if (nativePanels) {
            SanitizeCurrentNativeBuildPanels(nativePanels);
        }
    } else {
        const defaultNativeSections = ShopGuidesState.defaultNativeSections && ShopGuidesState.defaultNativeSections.length > 0
            ? ShopGuidesState.defaultNativeSections
            : itemSections;
        usingNativeBuild = RenderShopGuidesIntoNativeBuild(IsDefaultShopGuide(guide) ? defaultNativeSections : itemSections);
        if (usingNativeBuild) {
            if (IsDefaultShopGuide(guide)) {
                ShopGuidesState.nativeGuideOverrideActive = false;
            } else if (hasNativeItems) {
                ShopGuidesState.nativeGuideOverrideActive = true;
            }
        }
    }

    ShopGuidesSections.visible = !usingNativeBuild;
    if (ShopGuidesSkillsBlock) {
        ShopGuidesSkillsBlock.visible = !usingNativeBuild;
    }

    if (!usingNativeBuild) {
        for (const section of itemSections) {
            const items = ShopGuidesToArray(section.items);
            if (!items.length) {
                continue;
            }

            const sectionPanel = $.CreatePanel("Panel", ShopGuidesSections, "");
            sectionPanel.AddClass("ShopGuidesSection");

            const title = $.CreatePanel("Label", sectionPanel, "");
            title.AddClass("ShopGuidesSectionTitle");
            title.text = GetGuideSectionTitle(section.key, section.title);

            const itemsWrap = $.CreatePanel("Panel", sectionPanel, "");
            itemsWrap.AddClass("ShopGuidesItemsWrap");

            CreateGuideWrappedItems(itemsWrap, items);
        }
    }

    const skillBuild = ShopGuidesToArray(guide.skill_build);
    for (const skillEntry of skillBuild) {
        const row = $.CreatePanel("Panel", ShopGuidesSkillsList, "");
        row.AddClass("ShopGuidesSkillRow");

        const level = $.CreatePanel("Label", row, "");
        level.AddClass("ShopGuidesSkillLevel");
        level.text = `${skillEntry.level}.`;

        const icon = $.CreatePanel("DOTAAbilityImage", row, "");
        icon.AddClass("ShopGuidesSkillIcon");
        icon.abilityname = NormalizeGuideAbilityName(skillEntry.ability_script_name);

        const name = $.CreatePanel("Label", row, "");
        name.AddClass("ShopGuidesSkillName");
        name.text = GetGuideAbilityDisplayName(skillEntry.ability_script_name);

        if (skillEntry.note) {
            row.SetPanelEvent("onmouseover", () => $.DispatchEvent("DOTAShowTextTooltip", row, skillEntry.note));
            row.SetPanelEvent("onmouseout", () => $.DispatchEvent("DOTAHideTextTooltip"));
        }
    }

    const talentChoices = ShopGuidesToArray(guide.talent_choices);
    ShopGuidesTalentsWrap.visible = talentChoices.length > 0;
    for (const talentChoice of talentChoices) {
        const chip = $.CreatePanel("Label", ShopGuidesTalentsList, "");
        chip.AddClass("ShopGuidesTalentChip");
        chip.text = `${talentChoice.level}${talentChoice.side === "left" ? "L" : "R"}`;
    }
}

function RenderShopGuidesPicker() {
    if (!EnsureShopGuidesPickerPanels()) {
        return;
    }

    DeleteAllChildren(ShopGuidesPickerList);
    DeleteAllChildren(ShopGuidesPickerPagination);

    if (ShopGuidesPickerSearchEntry && ShopGuidesPickerSearchEntry.text !== ShopGuidesState.pickerSearchText) {
        ShopGuidesPickerSearchEntry.text = ShopGuidesState.pickerSearchText;
    }

    if (ShopGuidesPickerFavoritesButton) {
        ShopGuidesPickerFavoritesButton.SetHasClass("Active", ShopGuidesState.pickerFavoritesOnly);
    }

    const filteredGuides = GetFilteredShopGuidesList();
    const totalPages = Math.max(1, Math.ceil(filteredGuides.length / SHOP_GUIDES_PICKER_PAGE_SIZE));
    ShopGuidesState.pickerPage = ClampShopGuidesPickerPage(ShopGuidesState.pickerPage, totalPages);

    if (!filteredGuides.length) {
        const empty = $.CreatePanel("Label", ShopGuidesPickerList, "");
        empty.AddClass("ShopGuidesPickerEmpty");
        empty.text = $.Localize("#SHOP_GUIDES_SEARCH_EMPTY");
    }

    const pageStart = (ShopGuidesState.pickerPage - 1) * SHOP_GUIDES_PICKER_PAGE_SIZE;
    const pageGuides = filteredGuides.slice(pageStart, pageStart + SHOP_GUIDES_PICKER_PAGE_SIZE);

    for (const guide of pageGuides) {
        const entry = $.CreatePanel("Panel", ShopGuidesPickerList, "");
        const isSelected = Number(guide.id) === ShopGuidesState.selectedGuideId;
        entry.AddClass("ShopGuidesPickerEntry");
        entry.hittest = true;
        entry.hittestchildren = false;
        entry.style.width = "100%";
        entry.style.height = "fit-children";
        entry.style.flowChildren = "down";
        entry.style.ignoreParentFlow = "false";
        entry.style.marginBottom = "6px";
        entry.style.padding = "7px 8px 7px 8px";
        entry.style.borderRadius = "9px";
        entry.style.backgroundColor = "#161c22d9";
        entry.style.border = isSelected ? "1px solid #8da7c4" : "1px solid #46505b88";
        entry.style.transitionProperty = "brightness, background-color, border";
        entry.style.transitionDuration = "0.12s";
        entry.SetHasClass("Selected", isSelected);
        entry.SetPanelEvent("onmouseover", () => {
            entry.style.brightness = "1.12";
            entry.style.backgroundColor = "#212831eb";
            entry.style.border = isSelected ? "1px solid #a5bfdc" : "1px solid #6d7a89cc";
        });
        entry.SetPanelEvent("onmouseout", () => {
            entry.style.brightness = "1";
            entry.style.backgroundColor = "#161c22d9";
            entry.style.border = isSelected ? "1px solid #8da7c4" : "1px solid #46505b88";
        });
        entry.SetPanelEvent("onactivate", () => {
            entry.style.brightness = "0.98";
            entry.style.backgroundColor = "#12171df0";
            $.Schedule(0.03, () => SelectShopGuide(guide.id));
        });

        const title = $.CreatePanel("Label", entry, "");
        title.AddClass("ShopGuidesPickerEntryTitle");
        title.style.width = "100%";
        title.style.height = "fit-children";
        title.style.whiteSpace = "normal";
        title.style.fontSize = "12px";
        title.style.fontWeight = "semi-bold";
        title.style.color = "#edf1f5";
        title.style.marginBottom = "2px";
        title.text = GetGuideDisplayTitle(guide);

        const meta = $.CreatePanel("Label", entry, "");
        meta.AddClass("ShopGuidesPickerEntryMeta");
        meta.style.width = "100%";
        meta.style.height = "fit-children";
        meta.style.whiteSpace = "normal";
        meta.style.fontSize = "10px";
        meta.style.color = "#97a4b2";
        meta.style.marginTop = "2px";
        meta.text = GetGuidePickerMetaText(guide);
    }

    if (filteredGuides.length > 0) {
        for (let page = 1; page <= totalPages; page++) {
            const button = $.CreatePanel("Button", ShopGuidesPickerPagination, "");
            button.AddClass("ShopGuidesPageButton");
            const isActive = page === ShopGuidesState.pickerPage;
            button.SetHasClass("Active", isActive);
            button.style.minWidth = "22px";
            button.style.height = "22px";
            button.style.marginRight = "4px";
            button.style.padding = "0px 6px 0px 6px";
            button.style.borderRadius = "2px";
            button.style.backgroundColor = isActive ? "#586575" : "#2f363f";
            button.style.border = isActive ? "1px solid #b2bfd0cc" : "1px solid #65707d88";
            button.style.transitionProperty = "brightness, background-color, border";
            button.style.transitionDuration = "0.12s";
            button.SetPanelEvent("onmouseover", () => {
                button.style.brightness = "1.12";
                if (!isActive) {
                    button.style.backgroundColor = "#414b56";
                    button.style.border = "1px solid #96a1aeaa";
                }
            });
            button.SetPanelEvent("onmouseout", () => {
                button.style.brightness = "1";
                button.style.backgroundColor = isActive ? "#586575" : "#2f363f";
                button.style.border = isActive ? "1px solid #b2bfd0cc" : "1px solid #65707d88";
            });
            button.SetPanelEvent("onactivate", () => SetShopGuidesPickerPage(page));

            const label = $.CreatePanel("Label", button, "");
            label.AddClass("ShopGuidesPageButtonLabel");
            label.style.horizontalAlign = "center";
            label.style.verticalAlign = "center";
            label.style.textAlign = "center";
            label.style.color = "#e7edf3";
            label.style.fontSize = "12px";
            label.style.fontWeight = "semi-bold";
            label.text = `${page}`;
        }
    }
}

function RenderShopGuidesState() {
    if (!EnsureShopGuidesMainPanels()) {
        return;
    }

    const hasGuides = ShopGuidesState.list.length > 0;
    const guide = ShopGuidesState.guide;

    ShopGuidesPickerButtonText.text = hasGuides
        ? $.Localize("#SHOP_GUIDES_SELECT")
        : $.Localize("#SHOP_GUIDES_EMPTY_SHORT");

    if (ShopGuidesState.loading) {
        ShopGuidesSelectedTitle.text = $.Localize("#SHOP_GUIDES_LOADING");
        ShopGuidesSelectedMeta.text = "";
        ShopGuidesSummary.visible = false;
        UpdateShopGuideVoteButtons(null);
        if (ShopGuidesSkillsBlock) {
            ShopGuidesSkillsBlock.visible = false;
        }
        ShopGuidesTalentsWrap.visible = false;
        DeleteAllChildren(ShopGuidesSections);
        DeleteAllChildren(ShopGuidesSkillsList);
        DeleteAllChildren(ShopGuidesTalentsList);
        ShopGuidesEmpty.visible = false;
        return;
    }

    if (!hasGuides) {
        ApplyShopGuidesNativeBuildHeight(SHOP_GUIDES_NATIVE_HEIGHT_EMPTY);
        ShopGuidesSelectedTitle.text = $.Localize("#SHOP_GUIDES_TITLE");
        ShopGuidesSelectedMeta.text = "";
        ShopGuidesSummary.visible = false;
        UpdateShopGuideVoteButtons(null);
        if (ShopGuidesSkillsBlock) {
            ShopGuidesSkillsBlock.visible = false;
        }
        ShopGuidesTalentsWrap.visible = false;
        DeleteAllChildren(ShopGuidesSections);
        DeleteAllChildren(ShopGuidesSkillsList);
        DeleteAllChildren(ShopGuidesTalentsList);
        ShopGuidesEmpty.visible = true;
        return;
    }

    ShopGuidesEmpty.visible = !guide;
    if (!guide) {
        ShopGuidesSelectedTitle.text = $.Localize("#SHOP_GUIDES_LOADING");
        ShopGuidesSelectedMeta.text = "";
        UpdateShopGuideVoteButtons(null);
        if (ShopGuidesSkillsBlock) {
            ShopGuidesSkillsBlock.visible = false;
        }
        return;
    }

    ShopGuidesSelectedTitle.text = GetGuideDisplayTitle(guide);
    ShopGuidesSelectedMeta.text = FormatGuideMeta(guide);
    ApplyShopGuidesNativeBuildHeight(CalculateShopGuidesNativeBuildHeight(guide));
    RenderShopGuideDetails();
}

function RequestShopGuidesForHero(heroScriptName) {
    ShopGuidesState.requestedHero = heroScriptName;
    ShopGuidesState.list = [];
    ShopGuidesState.guide = null;
    ShopGuidesState.selectedGuideId = 0;
    ShopGuidesState.loading = true;
    ShopGuidesState.votePending = false;
    ShopGuidesState.favoritePending = false;
    ShopGuidesState.pickerPage = 1;
    ShopGuidesState.pickerSearchText = "";
    ShopGuidesState.pickerFavoritesOnly = false;
    ShopGuidesState.nativeGuideOverrideActive = false;
    ShopGuidesState.defaultNativeSections = null;
    SetShopGuidesPickerOpen(false);
    RenderShopGuidesState();
    RenderShopGuidesPicker();

    GameEvents.SendCustomGameEventToServer("guides_request_list", {
        hero_script_name: heroScriptName,
    });
}

function SelectShopGuide(guideID) {
    const numericGuideID = Number(guideID);
    if (!Number.isFinite(numericGuideID) || numericGuideID < 0) {
        return;
    }

    if (numericGuideID === ShopGuidesState.selectedGuideId) {
        SetShopGuidesPickerOpen(false);
        return;
    }

    ShopGuidesState.selectedGuideId = numericGuideID;
    ShopGuidesState.loading = true;
    ShopGuidesState.votePending = false;
    SetShopGuidesPickerOpen(false);
    RenderShopGuidesState();
    RenderShopGuidesPicker();

    GameEvents.SendCustomGameEventToServer("guides_select_guide", {
        guide_id: numericGuideID,
        hero_script_name: ShopGuidesState.heroScriptName,
    });
}

function OnShopGuidesListResponse(event) {
    const heroScriptName = event?.hero_script_name || "";
    if (heroScriptName !== ShopGuidesState.heroScriptName) {
        return;
    }

    ShopGuidesState.list = MoveDefaultGuideToTop(ShopGuidesToArray(event.guides));
    ShopGuidesState.selectedGuideId = Number(event.selected_guide_id || 0);
    if (ShopGuidesState.selectedGuideId === 0) {
        ShopGuidesState.guide = ShopGuidesState.list.find((guide) => IsDefaultShopGuide(guide)) || null;
        ShopGuidesState.loading = false;
    } else {
        ShopGuidesState.loading = ShopGuidesState.list.length > 0;
    }
    ShopGuidesState.votePending = false;
    ShopGuidesState.favoritePending = false;
    RenderShopGuidesPicker();
    RenderShopGuidesState();
}

function OnShopGuideResponse(event) {
    const guide = event?.guide;
    if (!guide || (guide.hero_script_name || "") !== ShopGuidesState.heroScriptName) {
        return;
    }

    ShopGuidesState.guide = guide;
    ShopGuidesState.selectedGuideId = Number(guide.id || 0);
    ShopGuidesState.loading = false;
    ShopGuidesState.votePending = false;
    ShopGuidesState.favoritePending = false;
    RenderShopGuidesPicker();
    RenderShopGuidesState();
}

function OnShopGuideVoteResponse(event) {
    const guideID = Number(event?.guide_id || 0);
    if (!guideID || guideID <= 0) {
        ShopGuidesState.votePending = false;
        UpdateShopGuideVoteButtons(ShopGuidesState.guide);
        return;
    }

    ShopGuidesState.votePending = false;

    if (Number(event?.ok || 0) !== 1) {
        UpdateShopGuideVoteButtons(ShopGuidesState.guide);
        return;
    }

    const voteValue = Number(event.vote_value || 0);
    const likesCount = Math.max(0, Number(event.likes_count || 0));
    const dislikesCount = Math.max(0, Number(event.dislikes_count || 0));
    const rating = Number(event.rating || 0);

    ShopGuidesState.list = ShopGuidesState.list.map((guideEntry) => {
        if (Number(guideEntry?.id || 0) !== guideID) {
            return guideEntry;
        }

        return {
            ...guideEntry,
            likes_count: likesCount,
            dislikes_count: dislikesCount,
            rating,
            viewer_vote: voteValue,
        };
    });

    if (ShopGuidesState.guide && Number(ShopGuidesState.guide.id || 0) === guideID) {
        ShopGuidesState.guide = {
            ...ShopGuidesState.guide,
            likes_count: likesCount,
            dislikes_count: dislikesCount,
            rating,
            viewer_vote: voteValue,
        };
    }

    RenderShopGuidesPicker();
    RenderShopGuidesState();
}

function OnShopGuideFavoriteResponse(event) {
    const guideID = Number(event?.guide_id || 0);
    ShopGuidesState.favoritePending = false;

    if (!guideID || guideID <= 0 || Number(event?.ok || 0) !== 1) {
        UpdateShopGuideVoteButtons(ShopGuidesState.guide);
        return;
    }

    const isFavorite = event?.is_favorite === true || Number(event?.is_favorite || 0) === 1;

    ShopGuidesState.list = ShopGuidesState.list.map((guideEntry) => {
        if (Number(guideEntry?.id || 0) !== guideID) {
            return guideEntry;
        }

        return {
            ...guideEntry,
            is_favorite: isFavorite,
        };
    });

    if (ShopGuidesState.guide && Number(ShopGuidesState.guide.id || 0) === guideID) {
        ShopGuidesState.guide = {
            ...ShopGuidesState.guide,
            is_favorite: isFavorite,
        };
    }

    RenderShopGuidesPicker();
    RenderShopGuidesState();
}

function OnShopGuideError() {
    ShopGuidesState.loading = false;
    ShopGuidesState.votePending = false;
    ShopGuidesState.favoritePending = false;
    RenderShopGuidesState();
}

function UpdateShopGuidesVisibility() {
    const shopPanel = EnsureShopGuidesParent();
    const heroScriptName = GetLocalGuideHeroScriptName();
    const shouldShow = !!shopPanel && !!heroScriptName && IsShopGuidesOpen() && ShopGuidesState.dockReady;

    ShopGuidesRoot.SetHasClass("Visible", shouldShow);
    if (!shouldShow) {
        if (!ShopGuidesState.dockReady) {
            RestoreStandardGuidePanel();
        }
        SetShopGuidesPickerOpen(false);
        $.Schedule(0.03, UpdateShopGuidesVisibility);
        return;
    }

    if (ShopGuidesState.heroScriptName !== heroScriptName) {
        ShopGuidesState.heroScriptName = heroScriptName;
        ShopGuidesState.requestedHero = "";
        ShopGuidesState.list = [];
        ShopGuidesState.guide = null;
        ShopGuidesState.selectedGuideId = 0;
        ShopGuidesState.loading = false;
        ShopGuidesState.votePending = false;
        ShopGuidesState.favoritePending = false;
        ShopGuidesState.pickerPage = 1;
        ShopGuidesState.pickerSearchText = "";
        ShopGuidesState.pickerFavoritesOnly = false;
        ShopGuidesState.nativeGuideOverrideActive = false;
        ShopGuidesState.defaultNativeSections = null;
    }

    if (ShopGuidesState.requestedHero !== heroScriptName) {
        RequestShopGuidesForHero(heroScriptName);
    }

    $.Schedule(0.03, UpdateShopGuidesVisibility);
}

(function () {
    GameEvents.Subscribe("guides_list_response", OnShopGuidesListResponse);
    GameEvents.Subscribe("guides_guide_response", OnShopGuideResponse);
    GameEvents.Subscribe("guides_vote_response", OnShopGuideVoteResponse);
    GameEvents.Subscribe("guides_favorite_response", OnShopGuideFavoriteResponse);
    GameEvents.Subscribe("guides_error_response", OnShopGuideError);

    $.Schedule(0.0, () => {
        if (!EnsureShopGuidesMainPanels()) {
            return;
        }

        RenderShopGuidesState();
        UpdateShopGuidesVisibility();
    });
})();
