"use strict";

(function () {
    const LOCAL_PLAYER_ID = Players.GetLocalPlayer();

    function GetRoot() {
        return $.GetContextPanel().FindChildTraverse("ZhenyaNotificationsContainer");
    }

    function GetPluralIndexRu(amount) {
        let n = Math.abs(Number(amount) || 0);
        n = n % 100;
        const n1 = n % 10;

        if (n > 10 && n < 20) return 5;
        if (n1 === 1) return 1;
        if (n1 >= 2 && n1 <= 4) return 2;
        return 5;
    }

    function BuildRewardText(data) {
        const youGot = $.Localize("#zhenya_notif_you_got");

        if (data.kind === "coins" && data.amount) {
            const amount = Number(data.amount) || 0;
            const idx    = GetPluralIndexRu(amount);
            const noun   = $.Localize("#zhenya_notif_coins_" + idx);
            return youGot + " " + amount + " " + noun;

        } else if (data.kind === "prime" && data.hours) {
            const hours = Number(data.hours) || 0;
            const idx   = GetPluralIndexRu(hours);
            const noun  = $.Localize("#zhenya_notif_prime_" + idx);
            return youGot + " " + hours + " " + noun;

        } else if (data.kind === "gold" && data.gold) {
            const gold = Number(data.gold) || 0;
            const idx  = GetPluralIndexRu(gold);
            const noun = $.Localize("#zhenya_notif_gold_" + idx);
            return youGot + " " + gold + " " + noun;
        }

        return $.Localize("#zhenya_notif_reward_generic");
    }

    function OnNotificationTableChanged(tableName, key, data) {
        if (tableName !== "overvodka_notifications") return;
        if (!data) return;

        const playerID = parseInt(key);
        if (playerID !== LOCAL_PLAYER_ID) return;

        CreateNotification(data);
    }

    function CreateNotification(data) {
        const container = GetRoot();
        if (!container) return;

        Game.EmitSound("ui.treasure_03");

        const panel = $.CreatePanel("Panel", container, "");
        panel.BLoadLayoutSnippet("ZhenyaNotification");

        const icon = panel.FindChildTraverse("ZN_Icon");
        const textLabel = panel.FindChildTraverse("ZN_Text");

        if (icon) {
            icon.SetImage("file://{images}/custom_game/zhenya_present.png");
        }

        const text = BuildRewardText(data);

        if (textLabel) {
            textLabel.text = text;
        }

        const firstChild = container.GetChild(0);
        if (firstChild) {
            container.MoveChildBefore(panel, firstChild);
        }

        if (container.GetChildCount() > 3) {
            const lastIndex = container.GetChildCount() - 1;
            const last = container.GetChild(lastIndex);
            if (last && last.IsValid()) {
                SafeDeleteAsync(last);
            }
        }

        panel.AddClass("ZN_Show");

        $.Schedule(4.0, function () {
            if (!panel || !panel.IsValid()) return;
            panel.RemoveClass("ZN_Show");
            panel.AddClass("ZN_Hide");
            $.Schedule(0.25, function () {
                SafeDeleteAsync(panel);
            });
        });
    }

    (function Init() {
        $.RegisterEventHandler("DOTAScenePanelSceneLoaded", $.GetContextPanel(), function () {});

        CustomNetTables.SubscribeNetTableListener("overvodka_notifications", OnNotificationTableChanged);

        const all = CustomNetTables.GetAllTableValues("overvodka_notifications") || [];
        for (let i = 0; i < all.length; i++) {
            const entry = all[i];
            const key = entry.key;
            const value = entry.value;
            OnNotificationTableChanged("overvodka_notifications", key, value);
        }
    })();
})();
