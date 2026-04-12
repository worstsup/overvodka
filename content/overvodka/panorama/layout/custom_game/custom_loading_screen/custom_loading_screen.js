(function () {
    const CONNECTION_CLASS_BY_STATE = {
        [DOTAConnectionState_t.DOTA_CONNECTION_STATE_CONNECTED]: "BState_Loaded",
        [DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED]: "BState_Failed",
        [DOTAConnectionState_t.DOTA_CONNECTION_STATE_FAILED]: "BState_Failed",
    };

    const LS = {
        CONTEXT: $.GetContextPanel(),
        PLAYERS_LIST: $("#LoadingPlayersList"),
        PLAYERS_HEADER: $("#LoadingPlayersHeader"),
        PLAYERS_ROOT: $("#LoadingPlayersRoot"),
    };

    const playerPanels = {};
    let playerSignature = "";

    function FindFirstChatTipBox() {
        return dotaLoadingScreen && dotaLoadingScreen.FindChildrenWithClassTraverse
            ? (dotaLoadingScreen.FindChildrenWithClassTraverse("ChatTipBox") || [])[0]
            : null;
    }

    function UpdateLoadingChatPosition() {
        const loadingChat = FindDotaHudElementInLS("LoadingScreenChat");
        const chatTipBox = FindFirstChatTipBox();
        const target = chatTipBox || (loadingChat ? loadingChat.GetParent() : null) || loadingChat;

        if (target) {
            target.style.horizontalAlign = "right";
            target.style.marginRight = "36px";
            target.style.marginTop = "54px";
        }

        if (loadingChat) {
            loadingChat.style.width = "660px";
            loadingChat.style.horizontalAlign = "center";
        }

        $.Schedule(0.2, UpdateLoadingChatPosition);
    }

    function HideDefaultLoadingSidebar() {
        const sidebar = FindDotaHudElementInLS("SidebarAndBattleCupLayoutContainer");
        if (sidebar) {
            sidebar.style.visibility = "collapse";
            sidebar.hittest = false;
            sidebar.hittestchildren = false;
        }
    }

    function IsLocalPlayerReady() {
        if (typeof Game.GetLocalPlayerID !== "function") {
            return false;
        }

        const localPlayerId = Game.GetLocalPlayerID();
        if (localPlayerId < 0) {
            return false;
        }

        const playerInfo = Game.GetPlayerInfo(localPlayerId);
        return !!playerInfo && playerInfo.player_connection_state === DOTAConnectionState_t.DOTA_CONNECTION_STATE_CONNECTED;
    }

    function GetLobbyPlayerIds() {
        const ids = [];
        const maxPlayers = (typeof DOTALimits_t !== "undefined" && DOTALimits_t.DOTA_MAX_TEAM_PLAYERS) || 24;

        for (let playerId = 0; playerId < maxPlayers; playerId++) {
            if (Game.GetPlayerInfo(playerId)) {
                ids.push(playerId);
            }
        }

        return ids;
    }

    function RebuildPlayersListIfNeeded() {
        if (!LS.PLAYERS_LIST) {
            return [];
        }

        const playerIds = GetLobbyPlayerIds();
        const nextSignature = playerIds.join(",");
        const hasAllPanels = playerIds.every((playerId) => !!playerPanels[playerId]);

        if (nextSignature === playerSignature && hasAllPanels) {
            return playerIds;
        }

        playerSignature = nextSignature;
        LS.PLAYERS_LIST.RemoveAndDeleteChildren();

        Object.keys(playerPanels).forEach((playerId) => {
            delete playerPanels[playerId];
        });

        playerIds.forEach((playerId) => {
            const playerInfo = Game.GetPlayerInfo(playerId);
            const panel = $.CreatePanel("Panel", LS.PLAYERS_LIST, `LS_Player_${playerId}`);
            panel.BLoadLayoutSnippet("LoadingPlayer");
            panel.SetHasClass("BLocalPlayer", playerId === Game.GetLocalPlayerID());

            const playerInfoRoot = panel.FindChildTraverse("LS_PlayerInfo");
            if (playerInfoRoot && playerInfoRoot.GetChildCount() >= 2 && playerInfo) {
                playerInfoRoot.GetChild(0).steamid = playerInfo.player_steamid;
                playerInfoRoot.GetChild(1).steamid = playerInfo.player_steamid;
            }

            playerPanels[playerId] = panel;
        });

        return playerIds;
    }

    function UpdatePlayersLoadState() {
        const playerIds = RebuildPlayersListIfNeeded();
        let loadedPlayers = 0;

        playerIds.forEach((playerId) => {
            const playerInfo = Game.GetPlayerInfo(playerId);
            const panel = playerPanels[playerId];
            if (!panel) {
                return;
            }

            if (playerInfo) {
                const playerInfoRoot = panel.FindChildTraverse("LS_PlayerInfo");
                if (playerInfoRoot && playerInfoRoot.GetChildCount() >= 2) {
                    playerInfoRoot.GetChild(0).steamid = playerInfo.player_steamid;
                    playerInfoRoot.GetChild(1).steamid = playerInfo.player_steamid;
                }
            }

            const stateClass = playerInfo
                ? (CONNECTION_CLASS_BY_STATE[playerInfo.player_connection_state] || "BState_Pending")
                : "BState_Pending";
            panel.SwitchClass("loading_state", stateClass);

            if (playerInfo && playerInfo.player_connection_state === DOTAConnectionState_t.DOTA_CONNECTION_STATE_CONNECTED) {
                loadedPlayers += 1;
            }
        });

        const totalPlayers = playerIds.length;
        LS.CONTEXT.SetDialogVariableInt("players_loaded", loadedPlayers);
        LS.CONTEXT.SetDialogVariableInt("players_total", totalPlayers);

        if (LS.PLAYERS_HEADER) {
            LS.PLAYERS_HEADER.text = `${$.Localize("#OVERVODKA_LOADING_PLAYERS")} ${loadedPlayers} ${$.Localize("#OVERVODKA_LOADING_OF")} ${totalPlayers}`;
        }

        LS.CONTEXT.SetHasClass("BAllPlayersLoaded", totalPlayers > 0 && loadedPlayers === totalPlayers);
    }

    function TickLoadingPlayers() {
        if (!IsLocalPlayerReady()) {
            if (LS.PLAYERS_ROOT) {
                LS.PLAYERS_ROOT.visible = false;
            }
            $.Schedule(0.1, TickLoadingPlayers);
            return;
        }

        if (LS.PLAYERS_ROOT) {
            LS.PLAYERS_ROOT.visible = true;
        }
        UpdatePlayersLoadState();
        $.Schedule(0.1, TickLoadingPlayers);
    }

    HideDefaultLoadingSidebar();
    TickLoadingPlayers();
    UpdateLoadingChatPosition();
})();
