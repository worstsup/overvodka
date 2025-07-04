"use strict";

var Store = {};
const StoreBody = $("#StoreBody");
(function() {
    const coinBalanceLabel = $("#CoinBalanceLabel");
    const categories = {
        skins: { button: $("#StoreTab_Skins"), panel: $("#StoreItems_Skins") },
        effects: { button: $("#StoreTab_Effects"), panel: $("#StoreItems_Effects") },
        pets: { button: $("#StoreTab_Pets"), panel: $("#StoreItems_Pets") },
    };

    let isInitialized = false;
    let currentCategory = null;
    let allItems = {};
    let playerInventory = [];
    let playerCoins = 0;
    const localPlayerID64 = Players.GetLocalPlayer();
    const localSteamID = GetSteamID32(localPlayerID64).toString();
    Store.Initialize = function() {
        if (isInitialized) return;
        StoreBody.SetHasClass("Visible", true);
        
        $.Msg("[Store] Initializing for SteamID:", localSteamID);
        
        // Listen for NetTable changes
        CustomNetTables.SubscribeNetTableListener("store", OnStoreNetTableChange);
        CustomNetTables.SubscribeNetTableListener("player_data", OnPlayerDataChange);

        // Get initial data
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

    function OnStoreNetTableChange(table_name, key, data) {
        if (key === "items") {
            allItems = data;
            BuildStoreUI();
        }
    }

    function OnPlayerDataChange(table_name, key, data) {
        if (key === localSteamID) {
            $.Msg("[Store] Player data updated from NetTable: ", data);
            
            if (data) {
                if (typeof data.coins === "number") {
                    playerCoins = data.coins;
                    coinBalanceLabel.text = playerCoins;
                }
                playerInventory = data.inventory || {};
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
        itemPanel.FindChildTraverse("ItemPrice").text = itemData.price;

        const button = itemPanel.FindChildTraverse("ItemButton");
        const buttonLabel = itemPanel.FindChildTraverse("ItemButtonLabel");

        UpdateItemButtonState(button, buttonLabel, itemData);

        button.SetPanelEvent("onactivate", () => {
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

        if (playerInventory[itemData.id]) {
            button.AddClass("Owned");
            label.text = $.Localize("#Store_Equip_Item");
        } else {
            if (playerCoins < itemData.price) {
                button.AddClass("NotEnoughCoins");
                button.enabled = true;
            }
            label.text = $.Localize("#Store_Buy_Item");
        }
    }

    function OnItemButtonClick(itemId) {
        if (playerInventory[itemId]) {
            $.Msg(`Equip item: ${itemId}`);
            // TODO: Handle equipping logic
        } else {
            GameEvents.SendCustomGameEventToServer("store_buy_item", { item_id: itemId });
        }
    }

    GameEvents.Subscribe("store_buy_response", (data) => {
        if (data.success) {
            Game.EmitSound("General.Buy");
            if (data.new_balance !== undefined) {
                playerCoins = data.new_balance;
                coinBalanceLabel.text = playerCoins;
                UpdateAllItemButtons();
            }
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
