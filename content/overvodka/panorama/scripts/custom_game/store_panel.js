"use strict";

var Store = {};
const StoreBody = $("#StoreBody");
(function() {
    const coinBalanceLabel = $("#CoinBalanceLabel");
    const coinBalanceTooltip = $("#CoinBalanceTooltip");
    const categories = {
        skins: { button: $("#StoreTab_Skins"), panel: $("#StoreItems_Skins") },
        effects: { button: $("#StoreTab_Effects"), panel: $("#StoreItems_Effects") },
        pets: { button: $("#StoreTab_Pets"), panel: $("#StoreItems_Pets") },
        cases:  { button: $("#StoreTab_Cases"),  panel: $("#StoreItems_Cases") },
        prime: { button: $("#StoreTab_Prime"), panel: $("#StoreItems_Prime") },
    };

    let isInitialized = false;
    let currentCategory = null;
    let allItems = {};
    let playerInventory = {};
    let playerEquipped = {
        effect: null,
        skin: null,
        pet: null
    };
    let playerCoins = 0;
    const claimedPrime = Object.create(null);
    let lastClickedItemId = null;
    const localPlayerID64 = Players.GetLocalPlayer();
    const localSteamID = GetSteamID32(localPlayerID64).toString();

    const PRIME_AUTO_SKINS = {
        "npc_dota_hero_morphling": "sans_arcana",
        "npc_dota_hero_void_spirit": "invincible_arcana",
    };
    const STORE_ITEM_ORDER = [
        "prime_day",
        "prime_week",
        "pet_8",
        "pet_7",
        "pet_6",
        "pet_5",
        "pet_4",
        "pet_3",
        "pet_2",
        "pet_1",
        "effect_4",
        "effect_3",
        "effect_2",
        "effect_1",
        "skin_8",
        "skin_7",
        "skin_6",
        "skin_4",
        "invincible_arcana",
        "sans_arcana",
        "skin_9",
        "skin_12",
        "skin_5",
        "skin_3",
        "skin_2",
        "skin_1",
    ];
    const STORE_ITEM_ORDER_INDEX = {};
    let primeAutoApplied = false;

    for (let i = 0; i < STORE_ITEM_ORDER.length; i++) {
        STORE_ITEM_ORDER_INDEX[STORE_ITEM_ORDER[i]] = i;
    }

    Store.ShowCoinsTooltip = function() {
        if (coinBalanceTooltip) {
            coinBalanceTooltip.SetHasClass("Visible", true);
        }
    };

    Store.HideCoinsTooltip = function() {
        if (coinBalanceTooltip) {
            coinBalanceTooltip.SetHasClass("Visible", false);
        }
    };

    Store.Initialize = function() {
        if (isInitialized) return;
        StoreBody.SetHasClass("Visible", true);
        Store.HideCoinsTooltip();
        
        $.Msg("[Store] Initializing for SteamID:", localSteamID);
        
        CustomNetTables.SubscribeNetTableListener("store", OnStoreNetTableChange);
        CustomNetTables.SubscribeNetTableListener("player_data", OnPlayerDataChange);

        const itemsData = CustomNetTables.GetTableValue("store", "items");
        if (itemsData) {
            $.Msg("[Store] Found store items in NetTable");
            OnStoreNetTableChange("store", "items", itemsData);
        }

        const playerData = CustomNetTables.GetTableValue("player_data", localSteamID);
        if (playerData) {
            $.Msg("[Store] Found player data in NetTable:", playerData);
            OnPlayerDataChange("player_data", localSteamID, playerData);
        } else {
            $.Msg("[Store] No player data found in NetTable");
        }
        
        isInitialized = true;
    };

    function hasPrime() {
        try {
            if (typeof IsPlayerSubscribed === "function") {
                return !!IsPlayerSubscribed(Players.GetLocalPlayer());
            }
        } catch (e) {
            $.Msg("IsPlayerSubscribed error:", e);
        }
        return false;
    }

    function TryAutoEquipPrimeSkin() {
        if (primeAutoApplied) return;

        if (!hasPrime()) {
            return;
        }

        const playerID = Players.GetLocalPlayer();
        const heroEnt = Players.GetPlayerHeroEntityIndex(playerID);

        if (heroEnt === -1) {
            $.Schedule(1.0, TryAutoEquipPrimeSkin);
            return;
        }

        const heroName = Entities.GetUnitName(heroEnt);
        const itemId = PRIME_AUTO_SKINS[heroName];

        if (!itemId) {
            return;
        }

        if (playerEquipped.skin && playerEquipped.skin !== itemId) {
            return;
        }

        primeAutoApplied = true;

        GameEvents.SendCustomGameEventToServer("store_equip_item", {
            item_id: itemId,
            item_type: "skins"
        });
    }

    $.Schedule(1.0, TryAutoEquipPrimeSkin);

    function OnStoreNetTableChange(table_name, key, data) {
        if (key === "items") {
            allItems = data;
            BuildStoreUI();
        }
    }

    function OnPlayerDataChange(table_name, key, data) {
        if (key === localSteamID) {
            if (data) {
                playerCoins = data.coins || 0;
                playerInventory = data.inventory || {};
                playerEquipped.effect = data.equipped_effect;
                playerEquipped.skin = data.equipped_skin;
                playerEquipped.pet = data.equipped_pet;
                const primeClaims = data.prime_claims ? (Array.isArray(data.prime_claims) ? data.prime_claims : Object.values(data.prime_claims)) : [];
                for (const code of primeClaims) {
                    claimedPrime[code] = true;
                }
                coinBalanceLabel.text = playerCoins;
                UpdateAllItemButtons();
            }
        }
    }

    function GetSortedStoreItems() {
        return Object.values(allItems).sort((a, b) => {
            const aOrder = Object.prototype.hasOwnProperty.call(STORE_ITEM_ORDER_INDEX, a.id)
                ? STORE_ITEM_ORDER_INDEX[a.id]
                : Number.MAX_SAFE_INTEGER;
            const bOrder = Object.prototype.hasOwnProperty.call(STORE_ITEM_ORDER_INDEX, b.id)
                ? STORE_ITEM_ORDER_INDEX[b.id]
                : Number.MAX_SAFE_INTEGER;

            if (aOrder !== bOrder) {
                return aOrder - bOrder;
            }

            return (a.id || "").localeCompare(b.id || "");
        });
    }

    function BuildStoreUI() {
        for (const cat of Object.values(categories)) {
            cat.panel.RemoveAndDeleteChildren();
        }

        for (const item of GetSortedStoreItems()) {
            const parentPanel = categories[item.type] ? categories[item.type].panel : null;
            if (parentPanel) {
                CreateItemPanel(item, parentPanel);
            }
        }
        
        if (currentCategory) {
            Store.SwitchCategory(currentCategory);
        } else {
            Store.SwitchCategory('skins');
        }
    }
    function CreateItemPanel(itemData, parent) {
        const itemPanel = $.CreatePanel("Panel", parent, `StoreItem_${itemData.id}`);
        itemPanel.BLoadLayoutSnippet("StoreItem");

        itemPanel.FindChildTraverse("ItemImage").SetImage(itemData.image);
        itemPanel.FindChildTraverse("ItemName").text = $.Localize(itemData.name);

        const priceLabel = itemPanel.FindChildTraverse("ItemPrice");

        if (itemData.prime_only) {
            priceLabel.text = $.Localize("#Store_Need_Prime");
        } else if (Number(itemData.price) === 0) {
            priceLabel.text = $.Localize("#Store_Free");
        } else {
            priceLabel.text = itemData.price;
        }

        const button = itemPanel.FindChildTraverse("ItemButton");
        const buttonLabel = itemPanel.FindChildTraverse("ItemButtonLabel");

        UpdateItemButtonState(button, buttonLabel, itemData);

        button.SetPanelEvent("onactivate", () => {
            lastClickedItemId = itemData.id;
            OnItemButtonClick(itemData.id);
        });
    }
    
    function UpdateAllItemButtons() {
        for (const item of Object.values(allItems)) {
            const itemPanel = $(`#StoreItem_${item.id}`);
            if (itemPanel) {
                const button = itemPanel.FindChildTraverse("ItemButton");
                const buttonLabel = itemPanel.FindChildTraverse("ItemButtonLabel");
                UpdateItemButtonState(button, buttonLabel, item);
            }
        }
    }

    function UpdateItemButtonState(button, label, itemData) {
        button.RemoveClass("Owned");
        button.RemoveClass("Equipped");
        button.RemoveClass("NotEnoughCoins");
        button.enabled = true;

        if (itemData.prime_only) {
            const hasPrimeSub = hasPrime();

            if (!hasPrimeSub) {
                button.enabled = true;
                label.text = $.Localize("#Store_Need_Prime_Button");
                return;
            }

            let isEquipped = false;
            if (itemData.type === "effects") {
                isEquipped = (playerEquipped.effect === itemData.id);
            } else if (itemData.type === "skins") {
                isEquipped = (playerEquipped.skin === itemData.id);
            } else if (itemData.type === "pets") {
                isEquipped = (playerEquipped.pet === itemData.id);
            }

            if (isEquipped) {
                button.AddClass("Equipped");
                label.text = $.Localize("#Store_Unequip_Item");
            } else {
                button.AddClass("Owned");
                label.text = $.Localize("#Store_Equip_Item");
            }
            return;
        }

        if (itemData.type === "prime") {
            const isFree = Number(itemData.price) === 0;
            const alreadyClaimed = !!claimedPrime[itemData.id] || !!playerInventory[itemData.id];

            if (alreadyClaimed) {
                button.enabled = false;
                label.text = $.Localize("#Store_Claimed");
                return;
            }

            if (isFree) {
                label.text = $.Localize("#Store_Claim");
            }
            else {
                if (playerCoins < Number(itemData.price)) {
                    button.AddClass("NotEnoughCoins");
                }
                label.text = $.Localize("#Store_Buy_Item");
            }
            return;
        }

        if (playerInventory[itemData.id]) {
            let isEquipped = false;
            if (itemData.type === 'effects') {
                isEquipped = (playerEquipped.effect === itemData.id);
            } else if (itemData.type === 'skins') {
                isEquipped = (playerEquipped.skin === itemData.id);
            } else if (itemData.type === 'pets') {
                isEquipped = (playerEquipped.pet === itemData.id);
            }
            
            if (isEquipped) {
                button.AddClass("Equipped");
                label.text = $.Localize("#Store_Unequip_Item");
            } else {
                button.AddClass("Owned");
                label.text = $.Localize("#Store_Equip_Item");
            }
        }
        else {
            if (Number(itemData.price) === 0) {
                label.text = $.Localize("#Store_Claim");
            } 
            else {
                if (playerCoins < Number(itemData.price)) {
                    button.AddClass("NotEnoughCoins");
                }
                label.text = $.Localize("#Store_Buy_Item");
            }
        }
    }

    function OnItemButtonClick(itemId) {
        const item = allItems[itemId];
        if (!item) return;

        if (item.prime_only) {
            const hasPrimeSub = hasPrime();

            if (!hasPrimeSub) {
                Menu.SwitchTab('Prime');
                return;
            }

            let isEquipped = false;
            if (item.type === 'effects') {
                isEquipped = (playerEquipped.effect === itemId);
            } else if (item.type === 'skins') {
                isEquipped = (playerEquipped.skin === itemId);
            } else if (item.type === 'pets') {
                isEquipped = (playerEquipped.pet === itemId);
            }

            if (isEquipped) {
                Game.EmitSound("UI.Unequip");
                GameEvents.SendCustomGameEventToServer("store_unequip_item", {
                    item_type: item.type
                });
            } else {
                Game.EmitSound("UI.Equip");
                GameEvents.SendCustomGameEventToServer("store_equip_item", { 
                    item_id: itemId,
                    item_type: item.type 
                });
            }
            return;
        }

        if (item.type === 'prime') {
            GameEvents.SendCustomGameEventToServer("store_buy_item", {item_id: item.id});
            return;
        }

        if (playerInventory[itemId]) {
            let isEquipped = false;
            if (item.type === 'effects') {
                isEquipped = (playerEquipped.effect === itemId);
            } else if (item.type === 'skins') {
                isEquipped = (playerEquipped.skin === itemId);
            } else if (item.type === 'pets') {
                isEquipped = (playerEquipped.pet === itemId);
            }

            if (isEquipped) {
                Game.EmitSound("UI.Unequip");
                GameEvents.SendCustomGameEventToServer("store_unequip_item", {
                    item_type: item.type
                });
            } else {
                Game.EmitSound("UI.Equip");
                GameEvents.SendCustomGameEventToServer("store_equip_item", { 
                    item_id: itemId,
                    item_type: item.type 
                });
            }
        } else {
            GameEvents.SendCustomGameEventToServer("store_buy_item", { item_id: itemId });
        }
    }

    GameEvents.Subscribe("store_buy_response", (data) => {
        const itemId = data.item_id || lastClickedItemId;
        const item =
        itemId && allItems[itemId] ? allItems[itemId] : null;

        if (data.success) {
            Game.EmitSound("General.Buy");
            if (typeof data.new_balance !== "undefined") {
                playerCoins = data.new_balance;
                coinBalanceLabel.text = playerCoins;
            }
            if (item && item.type === "prime") {
                claimedPrime[itemId] = true;
            }

            UpdateAllItemButtons();
        }
        else {
            Game.EmitSound("UUI_SOUNDS.NoMoney");
            $.Msg(`Failed to buy item: ${data.error}`);
        }
    });

    Store.SwitchCategory = function(categoryName) {
        currentCategory = categoryName;
        for (const [name, cat] of Object.entries(categories)) {
            const isSelected = name === categoryName;
            cat.button.SetHasClass("Selected", isSelected);
            cat.panel.SetHasClass("Visible", isSelected);
        }

        if (categoryName === "cases" && Store.Cases) {
            Store.Cases.EnsureLoaded();
        }
    };
    Store.Cases = (function () {
        const casesPanel = $("#StoreItems_Cases");

        let casesList = [];
        let isLoaded = false;
        let isOpening = false;

        let previewCase = null;

        GameEvents.Subscribe("cases_info", function (data) {
            const raw = data && data.cases ? data.cases : [];

            if (Array.isArray(raw)) {
                casesList = raw;
            } else {
                casesList = Object.values(raw);
            }

            $.Msg("[Cases] received cases:", casesList.length);
            BuildCasesUI();
            isLoaded = true;
        });

        GameEvents.Subscribe("cases_open_result", function (data) {
            isOpening = false;

            if (!data || !data.success) {
                Game.EmitSound("UUI_SOUNDS.NoMoney");
                $.Msg("[Cases] failed to open case:", data && data.error);
                return;
            }

            if (typeof data.new_balance !== "undefined") {
                playerCoins = data.new_balance;
                coinBalanceLabel.text = playerCoins;
            }

            if (data.inventory) {
                playerInventory = {};
                const invArray = Array.isArray(data.inventory) ? data.inventory : Object.values(data.inventory);
                for (const id of invArray) {
                    playerInventory[id] = true;
                }
                UpdateAllItemButtons();
            }

            if (data.items && data.drop_id) {
                CasesChestAnimation.StartRoll(data.items, data.drop_id);
            }
        });

        function RequestCasesInfo() {
            if (isLoaded) return;
            GameEvents.SendCustomGameEventToServer("cases_request_info", {});
        }

        function BuildCasesUI() {
            if (!casesPanel) return;
            casesPanel.RemoveAndDeleteChildren();

            const list = Array.isArray(casesList) ? casesList : Object.values(casesList || {});
            if (!list.length) {
                const label = $.CreatePanel("Label", casesPanel, "");
                label.text = $.Localize("#Store_Cases_Empty") || "Нет доступных кейсов";
                label.style.color = "#f0e0b4";
                label.style.fontSize = "20px";
                label.style.horizontalAlign = "center";
                label.style.verticalAlign = "center";
                return;
            }

            for (const caseInfo of list) {
                CreateCaseCard(caseInfo);
            }
        }

        function ShowPreview(caseInfo) {
            previewCase = caseInfo || null;
            if (!previewCase) return;

            CasesChestAnimation.OpenChestHudForPreview(previewCase.name, previewCase.items);
        }

        function OpenCurrentCase() {
            if (!previewCase) return;
            if (isOpening) return;

            isOpening = true;

            GameEvents.SendCustomGameEventToServer("cases_open_case", {
                case_id: previewCase.case_id,
            });
        }

        function CreateCaseCard(caseInfo) {
            const card = $.CreatePanel("Panel", casesPanel, `Case_${caseInfo.case_id}`);
            card.BLoadLayoutSnippet("StoreItem");

            const imgPanel = card.FindChildTraverse("ItemImage");
            const nameLabel = card.FindChildTraverse("ItemName");
            const priceLabel = card.FindChildTraverse("ItemPrice");
            const button = card.FindChildTraverse("ItemButton");
            const buttonLabel = card.FindChildTraverse("ItemButtonLabel");

            if (imgPanel && caseInfo.icon) {
                imgPanel.SetImage(caseInfo.icon);
            }
            if (nameLabel) {
                nameLabel.text = $.Localize(caseInfo.name || "") || caseInfo.name || "Case";
            }
            if (priceLabel) {
                priceLabel.text = caseInfo.cost || 0;
            }
            if (buttonLabel) {
                buttonLabel.text = $.Localize("#Store_Case_View") || "ПОСМОТРЕТЬ";
            }

            button.SetPanelEvent("onactivate", function () {
                ShowPreview(caseInfo);
            });
        }

        return {
            EnsureLoaded: function () {
                RequestCasesInfo();
            },
            ShowPreview: ShowPreview,
            OpenCurrentCase: OpenCurrentCase,
        };
    })();


})();

var CasesChestAnimation = (function () {
    let CURRENT_DROP_ID = null;

    const DELAY_SPAWN_ITEMS_ANIM = 0.07;
    const STARTING_SPEED = 6000;
    
    const DROP_SLOT_INDEX = 70;
    const ITEM_WIDTH = 132.5;
    let VIEWPORT_CENTER_X = 0;
    
    const rarity_color = {
        common:    "#b0c3d9",
        uncommon:  "#5e98d9",
        rare:      "#4b69ff",
        mythical:  "#8847ff",
        legendary: "#d32ce6",
        immortal:  "#e4ae39",
    };

    let isRolling = false;
    let sound_tick_width = ITEM_WIDTH; 
    let animProgress = 0;
    let lastSoundStep = -1; 


    function FillChestContents(items) {
        const container = $("#ItemsInChestBlock");
        const border = $("#BorderItemsChestBlock");

        if (!container) return;

        container.RemoveAndDeleteChildren();

        const hasItems = !!items && Object.keys(items).length > 0;
        if (border) {
            border.SetHasClass("HasItems", hasItems);
        }
        if (!hasItems) return;

        const list = Array.isArray(items) ? items : Object.values(items || {});

        const rarityOrder = {
            common: 1,
            uncommon: 2,
            rare: 3,
            mythical: 4,
            legendary: 5,
            immortal: 6
        };

        list.sort((a, b) => {
            const ra = rarityOrder[a.rare] || 999;
            const rb = rarityOrder[b.rare] || 999;
            if (ra !== rb) return ra - rb;

            const na = (a.item_name || "").toLowerCase();
            const nb = (b.item_name || "").toLowerCase();
            if (na < nb) return -1;
            if (na > nb) return 1;
            return 0;
        });

        for (const info of list) {
            const item_panel = $.CreatePanel("Panel", container, "");
            item_panel.AddClass("item_panel_content");
            item_panel.style.opacity = "1";

            const rareColor = rarity_color[info.rare] || "#ffffff";

            const item_icon = $.CreatePanel("Panel", item_panel, "");
            item_icon.AddClass("item_icon");
            if (info.item_icon) {
                item_icon.style.backgroundImage = 'url("' + info.item_icon + '")';
                item_icon.style.backgroundSize = "100%";
            }

            const item_panel_name = $.CreatePanel("Panel", item_panel, "");
            item_panel_name.AddClass("item_panel_name");
            item_panel_name.style.backgroundColor = rareColor;

            const item_name = $.CreatePanel("Label", item_panel_name, "");
            item_name.AddClass("item_name");
            item_name.text = $.Localize(info.item_name || "") || (info.item_name || "");

            const item_panel_border = $.CreatePanel("Panel", item_panel, "");
            item_panel_border.AddClass("item_panel_border");
            item_panel_border.style.borderBrush =
                'gradient( linear, 0% 100%, 0% 20%, from(' + rareColor + '), to( rgba(0,0,0,0.1) ) )';
        }
    }


    function StartRoll(items, dropItemId) {
        animProgress = 0;
        lastSoundStep = -1;
        const hud = $("#ChestHudMainPanel");
        const rollList = $("#RollItemsListMain");
        const rollContainer = $("#RollItemsList");

        if (!hud || !rollList || !rollContainer) {
            $.Msg("[CasesChestAnimation] Required panels not found, skipping animation");
            return;
        }

        if (!items) {
            $.Msg("[CasesChestAnimation] StartRoll called with no items");
            return;
        }

        if (isRolling) {
            $.Msg("[CasesChestAnimation] already rolling, skipping new roll");
            return;
        }

        CURRENT_DROP_ID = GetItemPositionInDropList(dropItemId, items);
        if (CURRENT_DROP_ID === null) {
            $.Msg("[CasesChestAnimation] drop item not found in items list, abort");
            return;
        }

        isRolling = true;

        hud.style.opacity = "1";
        hud.hittest = true;
        hud.style.visibility = "visible";
        hud.SetHasClass("ChestHudAnimClose", false);
        hud.SetHasClass("ChestHudAnimOpen", true);

        const dropPanel = $("#DropItemPanel");
        if (dropPanel) {
            dropPanel.SetHasClass("DropItemPanelVisible", false);
        }


        ClearOldChest();
        ChestInitItemsInRoll(items);
        FillChestContents(items);

        const openBtn = $("#ChestOpenButton");
        if (openBtn) {
            openBtn.enabled = false;
            openBtn.AddClass("Disabled");
        }

        VIEWPORT_CENTER_X = (rollContainer.actuallayoutwidth / rollContainer.actualuiscale_x) / 2;
        
        $.Schedule(0.25, function () {
            OpenChest(items);
        });
    }

    function ClearOldChest() {
        const rollList = $("#RollItemsListMain");
        if (rollList) {
            rollList.RemoveAndDeleteChildren();
            rollList.style.position = "0px 0px 0px";
        }
    }

    function ChestInitItemsInRoll(items) {
        const rollList = $("#RollItemsListMain");
        if (!rollList) return;

        rollList.RemoveAndDeleteChildren();

        const keys = Object.keys(items);
        const len = keys.length;
        if (!len) return;

        const drop_info = items[CURRENT_DROP_ID];

        for (let i = 0; i <= 160; i++) { 
            let item_data;
            let panel_id = "";
            let is_drop_slot = false;

            if (i === DROP_SLOT_INDEX) {
                item_data = drop_info;
                panel_id = "dropped_item";
                is_drop_slot = true;
            } else {
                const randomKey = keys[Math.floor(Math.random() * len)];
                item_data = items[randomKey];
            }

            CreateItemInfo(rollList, item_data, 0, true, is_drop_slot, panel_id);
        }

        rollList.style.position = "0px 0px 0px";
    }

    function CreateItemInfo(main_panel, item_info, delay_count, roll, drop_slot, panel_id) {
        if (!main_panel || !item_info) return;

        const item_panel = $.CreatePanel("Panel", main_panel, panel_id || "");

        if (roll) {
            item_panel.AddClass("item_panel_roll");
        } else {
            item_panel.AddClass("item_panel");
        }

        const item_icon = $.CreatePanel("Panel", item_panel, "item_icon");
        item_icon.AddClass("item_icon");
        if (item_info.item_icon) {
            item_icon.style.backgroundImage = 'url("' + item_info.item_icon + '")';
            item_icon.style.backgroundSize = "100%";
        }

        const item_panel_name = $.CreatePanel("Panel", item_panel, "item_panel_name");
        item_panel_name.AddClass("item_panel_name");
        const rareColor = rarity_color[item_info.rare] || "#ffffff";
        item_panel_name.style.backgroundColor = rareColor;

        const item_name = $.CreatePanel("Label", item_panel_name, "item_name");
        item_name.AddClass("item_name");
        item_name.text = $.Localize(item_info.item_name || "") || (item_info.item_name || "");

        const item_panel_border = $.CreatePanel("Panel", item_panel, "item_panel_border");
        item_panel_border.AddClass("item_panel_border");
        item_panel_border.style.borderBrush =
            'gradient( linear, 0% 100%, 0% 20%, from(' + rareColor + '), to( rgba(0,0,0,0.1) ) )';
            

        $.Schedule(DELAY_SPAWN_ITEMS_ANIM * delay_count, function() {
            if (item_panel && item_panel.IsValid()) {
                item_panel.style.opacity = "1";
            }
        });
    }


    function OpenChest(items) {
        const keys = Object.keys(items);
        if (!keys.length || CURRENT_DROP_ID === null) {
            isRolling = false;
            return;
        }

        Game.EmitSound("ui.treasure_count");

        let current = 0;

        const drop_info = items[CURRENT_DROP_ID];
        
        const slot_drop = $("#RollItemsListMain") && $("#RollItemsListMain").FindChildTraverse("dropped_item");
        if (slot_drop && drop_info) {
             const item_icon = slot_drop.FindChildTraverse("item_icon");
             if (item_icon && drop_info.item_icon) {
                 item_icon.style.backgroundImage = 'url("' + drop_info.item_icon + '")';
             }

             const item_panel_name = slot_drop.FindChildTraverse("item_panel_name");
             if (item_panel_name) {
                 item_panel_name.style.backgroundColor = rarity_color[drop_info.rare] || "#ffffff";
             }

             const item_name = slot_drop.FindChildTraverse("item_name");
             if (item_name) {
                 item_name.text = $.Localize(drop_info.item_name || "") || (drop_info.item_name || "");
             }

             const item_panel_border = slot_drop.FindChildTraverse("item_panel_border");
             if (item_panel_border) {
                 const rareColor = rarity_color[drop_info.rare] || "#ffffff";
                 item_panel_border.style.borderBrush =
                     'gradient( linear, 0% 100%, 0% 20%, from(' + rareColor + '), to( rgba(0,0,0,0.1) ) )';
             }
        }

        const targetCenterPos = (DROP_SLOT_INDEX * ITEM_WIDTH) + (ITEM_WIDTH / 2);
        const desiredStopPos = -(targetCenterPos) + VIEWPORT_CENTER_X;

        const stopRange = ITEM_WIDTH / 4; 
        const minPos = desiredStopPos - stopRange;
        const maxPos = desiredStopPos + stopRange;

        const drop_distance = Math.floor(Math.random() * (maxPos - minPos + 1) + minPos);

        ChestAnimate(current, drop_distance, STARTING_SPEED, ITEM_WIDTH, drop_info);
    }

    (function () {
        const closeIcon = $("#CloseChestHudIcon");
            if (closeIcon) {
                closeIcon.SetPanelEvent("onactivate", function () {
                CloseDropPanel();
            });
        }
    })();

    (function () {
        const hud = $("#ChestHudMainPanel");
        if (hud) {
            hud.style.opacity = "0";
            hud.style.visibility = "collapse";
        }
        const openBtn = $("#ChestOpenButton");
        if (openBtn) {
            openBtn.SetPanelEvent("onactivate", function () {
                if (Store && Store.Cases && Store.Cases.OpenCurrentCase) {
                    Game.EmitSound("ui_generic_button_click");
                    Store.Cases.OpenCurrentCase();
                }
            });
        }
    })();

    function OpenChestHudForPreview(caseName, items) {
        const hud = $("#ChestHudMainPanel");
        if (!hud) return;

        const dropPanel = $("#DropItemPanel");
        if (dropPanel) {
            dropPanel.SetHasClass("DropItemPanelVisible", false);
        }

        const rollList = $("#RollItemsListMain");
        if (rollList) {
            rollList.RemoveAndDeleteChildren();
            rollList.style.position = "0px 0px 0px";
        }

        const chestNameLabel = $("#ChestName");
        if (chestNameLabel) {
            chestNameLabel.text = $.Localize(caseName || "") || (caseName || "");
        }

        FillChestContents(items);

        hud.style.opacity = "1";
        hud.hittest = true;
        hud.style.visibility = "visible";
        hud.SetHasClass("ChestHudAnimClose", false);
        hud.SetHasClass("ChestHudAnimOpen", true);

        isRolling = false;
        CURRENT_DROP_ID = null;
    }


    function ChestAnimate(current, drop_distance, speed_unused, sound_tick_unused, item_drop_info) {
        const hud = $("#ChestHudMainPanel");
        if (!hud) {
            isRolling = false;
            CURRENT_DROP_ID = null;
            CloseDropPanel();
            return;
        }

        if (hud.BHasClass("ChestHudAnimClose")) {
            isRolling = false;
            CURRENT_DROP_ID = null;
            CloseDropPanel();
            return;
        }

        const rollList = $("#RollItemsListMain");
        if (!rollList) {
            isRolling = false;
            CURRENT_DROP_ID = null;
            CloseDropPanel();
            return;
        }

        const dt = Game.GetGameFrameTime();
        const ANIM_DURATION = 3.0;

        animProgress += dt / ANIM_DURATION;
        if (animProgress > 1) animProgress = 1;

        const t = animProgress;
        const eased = 1 - Math.pow(1 - t, 3);

        const pos = 0 + (drop_distance - 0) * eased;
        rollList.style.position = pos + "px 0px 0px";

        const step = Math.floor(Math.abs(pos) / ITEM_WIDTH);
        if (step !== lastSoundStep) {
            lastSoundStep = step;
            Game.EmitSound("UUI_SOUNDS.CaseRoll");
        }

        if (animProgress >= 1) {
            rollList.style.position = drop_distance + "px 0px 0px";
            $.Schedule(0.1, function () {
                GiveItemDrop(item_drop_info);
            });
            return;
        }
        $.Schedule(dt, function () {
            ChestAnimate(pos, drop_distance, 0, 0, item_drop_info);
        });
    }

    function GiveItemDrop(item_drop_info) {
        isRolling = false;

        const dropPanel = $("#DropItemPanel");
        if (!dropPanel) return;

        dropPanel.SetHasClass("DropItemPanelVisible", true);

        const nameLabel = $("#ItemDropName");
        if (nameLabel) {
            nameLabel.text = $.Localize(item_drop_info.item_name || "") || (item_drop_info.item_name || "");
        }

        const iconPanel = $("#ItemDropIcon");
        if (iconPanel) {
            if (item_drop_info.item_icon) {
                iconPanel.style.backgroundImage = 'url("' + item_drop_info.item_icon + '")';
                iconPanel.style.backgroundSize = "100%";
            }
        }

        const rareColor = rarity_color[item_drop_info.rare] || "#ffffff";

        const hud = $("#ChestHudMainPanel");
        if (hud) {
            const item_drop_effect = $.CreatePanel("DOTAParticleScenePanel", hud, "", {
                particleName: "particles/ui/ui_generic_treasure_impact.vpcf",
                renderdeferred: "true",
                particleonly: "false",
                startActive: "true",
                cameraOrigin: "0 0 300",
                lookAt: "0 0 0",
                fov: "60"
            });
            item_drop_effect.AddClass("item_drop_effect");
            item_drop_effect.hittest = false;
            item_drop_effect.DeleteAsync(3);
        }

        Game.EmitSound("ui.treasure_01");

        const claimBtn = $("#ItemDropClaimButton");
        if (claimBtn) {
            claimBtn.SetPanelEvent("onactivate", function () {
                CloseDropPanel();
            });
        }

        const openBtn = $("#ChestOpenButton");
        if (openBtn) {
            openBtn.enabled = true;
            openBtn.RemoveClass("Disabled");
        }

        CURRENT_DROP_ID = null;
    }

    function CloseDropPanel() {
        const rollList = $("#RollItemsListMain");
        if (rollList) {
            rollList.style.position = "0px 0px 0px";
        }

        const dropPanel = $("#DropItemPanel");
        if (dropPanel) {
            dropPanel.SetHasClass("DropItemPanelVisible", false);
        }

        const hud = $("#ChestHudMainPanel");
        if (hud) {
            hud.SetHasClass("ChestHudAnimOpen", false);
            hud.SetHasClass("ChestHudAnimClose", true);
            hud.hittest = false;
            $.Schedule(0.05, function () {
                if (hud && hud.IsValid() && hud.BHasClass("ChestHudAnimClose")) {
                    hud.style.opacity = "0";
                    hud.style.visibility = "collapse";
                }
            });
        }
        const openBtn = $("#ChestOpenButton");
        if (openBtn) {
            openBtn.enabled = true;
            openBtn.RemoveClass("Disabled");
        }
    }

    function GetItemPositionInDropList(id, items) {
        const keys = Object.keys(items);
        for (let i = 0; i < keys.length; i++) {
            const k = keys[i];
            const info = items[k];
            if (info && info.item_id == id) {
                return k;
            }
        }
        return null;
    }

    return {
        StartRoll: StartRoll,
        OpenChestHudForPreview: OpenChestHudForPreview,
    };
})();
