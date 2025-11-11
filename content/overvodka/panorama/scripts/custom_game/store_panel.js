"use strict";

var Store = {};
const StoreBody = $("#StoreBody");
(function() {
    const coinBalanceLabel = $("#CoinBalanceLabel");
    const categories = {
        skins: { button: $("#StoreTab_Skins"), panel: $("#StoreItems_Skins") },
        effects: { button: $("#StoreTab_Effects"), panel: $("#StoreItems_Effects") },
        pets: { button: $("#StoreTab_Pets"), panel: $("#StoreItems_Pets") },
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
    let primeAutoApplied = false;

    Store.Initialize = function() {
        if (isInitialized) return;
        StoreBody.SetHasClass("Visible", true);
        
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
    function UpdateCoinBalance() {
        coinBalanceLabel.text = playerCoins;
        UpdateAllItemButtons();
    }
    function BuildStoreUI() {
        for (const cat of Object.values(categories)) {
            cat.panel.RemoveAndDeleteChildren();
        }

        for (const item of Object.values(allItems)) {
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
    function UpdateCoinBalance() {
        coinBalanceLabel.text = playerCoins;
        UpdateAllItemButtons();
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
    };

})();
