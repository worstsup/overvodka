"use strict";

const LOCAL_PLAYER_ID = typeof Game.GetLocalPlayerID === "function" ? Game.GetLocalPlayerID() : -1;
const MAP_DISPLAY_NAME = (typeof Game.GetMapInfo === "function" && Game.GetMapInfo() && Game.GetMapInfo().map_display_name) || "";

const HUD = {
    CONTEXT: $.GetContextPanel(),
    TEAMS_ROOT: $("#TS_TeamsRoot"),
    UNASSIGNED_ROOT: $("#UnassignedPlayersContainer"),
};

const AUTO_LAUNCH_DELAY_SECONDS = 30;

let team_panels = [];
let players_panels = [];
let previousTeamsLocked = false;

function IsUnknownPlayerName(player_name) {
    const normalized_name = String(player_name || "").trim().toLowerCase();
    return (
        normalized_name === "" ||
        normalized_name === "unknown" ||
        normalized_name === "[unknown]" ||
        normalized_name === "неизвестно" ||
        normalized_name === "[неизвестно]"
    );
}

function GetKnownPlayerInfo(player_id) {
    const player_info = Game.GetPlayerInfo(player_id);
    if (!player_info) {
        return null;
    }

    const connection_state = player_info.player_connection_state;
    if (typeof DOTAConnectionState_t !== "undefined") {
        if (
            connection_state === DOTAConnectionState_t.DOTA_CONNECTION_STATE_UNKNOWN
        ) {
            return null;
        }
    }

    const steam_id = String(player_info.player_steamid || "");
    const player_name = String(player_info.player_name || "");
    const has_known_identity =
        (steam_id !== "" && steam_id !== "0") ||
        !IsUnknownPlayerName(player_name);

    return has_known_identity ? player_info : null;
}

function GetKnownLobbyPlayerIDs() {
    const player_ids = [];
    const max_players = (typeof DOTALimits_t !== "undefined" && DOTALimits_t.DOTA_MAX_TEAM_PLAYERS) || 24;

    for (let player_id = 0; player_id < max_players; player_id++) {
        if (GetKnownPlayerInfo(player_id)) {
            player_ids.push(player_id);
        }
    }

    return player_ids;
}

function GetKnownLobbyPlayerIDSet() {
    return new Set(GetKnownLobbyPlayerIDs());
}

function GetValidUnassignedPlayerIDs() {
    const known_lobby_players = GetKnownLobbyPlayerIDSet();
    return (Game.GetUnassignedPlayerIDs() || []).filter((player_id) => known_lobby_players.has(player_id));
}

function CleanupStalePlayerPanels(known_lobby_players) {
    Object.keys(players_panels).forEach((player_id) => {
        const numeric_player_id = Number(player_id);
        if (known_lobby_players.has(numeric_player_id)) {
            return;
        }

        const player_panel = players_panels[numeric_player_id];
        if (player_panel) {
            player_panel.DeleteAsync(0);
        }
        delete players_panels[numeric_player_id];
    });
}

function FormatSetupTime(totalSeconds) {
    totalSeconds = Math.max(0, Math.floor(totalSeconds));
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes}:${seconds < 10 ? "0" : ""}${seconds}`;
}

function GetTeamColor(team_id) {
    if (typeof GameUI !== "undefined" && typeof GameUI.GetTeamColor === "function") {
        const color = GameUI.GetTeamColor(team_id);
        if (color) {
            return String(color).slice(0, -1);
        }
    }

    if (
        typeof GameUI !== "undefined" &&
        GameUI.CustomUIConfig &&
        GameUI.CustomUIConfig() &&
        GameUI.CustomUIConfig().team_colors &&
        GameUI.CustomUIConfig().team_colors[team_id]
    ) {
        return String(GameUI.CustomUIConfig().team_colors[team_id]).replace(";", "");
    }

    return "#cda758";
}

function GetPlayerPanel(player_id) {
    const player_info = GetKnownPlayerInfo(player_id);
    if (!player_info) {
        return null;
    }

    if (!players_panels[player_id]) {
        const player_panel = $.CreatePanel("Panel", HUD.UNASSIGNED_ROOT, `TS_Player_${player_id}`);
        player_panel.BLoadLayoutSnippet("TS_Player");
        players_panels[player_id] = player_panel;
        player_panel.SetHasClass("BLocalPlayer", player_id === LOCAL_PLAYER_ID);

        const player_info_root = player_panel.FindChild("TS_PlayerInfo");
        if (player_info_root && player_info_root.GetChildCount() >= 2) {
            player_info_root.GetChild(0).steamid = player_info.player_steamid;
            player_info_root.GetChild(1).steamid = player_info.player_steamid;
        }
    }

    return players_panels[player_id];
}

function CreateEmptySlot(root) {
    const empty_slot = $.CreatePanel("Button", root, "");
    empty_slot.BLoadLayoutSnippet("TS_Player");
    empty_slot.AddClass("Empty");
}

function UpdateAutoLaunchState(force = false) {
    if (!force && Game.GetTeamSelectionLocked()) {
        return;
    }

    const hasUnassignedPlayers = GetValidUnassignedPlayerIDs().length > 0;
    Game.SetAutoLaunchEnabled(!hasUnassignedPlayers);

    if (hasUnassignedPlayers) {
        Game.SetRemainingSetupTime(-1);
    } else {
        Game.SetRemainingSetupTime(AUTO_LAUNCH_DELAY_SECONDS);
    }
}

function ScheduleAutoLaunchRefresh() {
    $.Schedule(0, () => UpdateAutoLaunchState(true));
    $.Schedule(0.03, () => UpdateAutoLaunchState(true));
}

function OnLeaveTeamPressed() {
    Game.PlayerJoinTeam(DOTATeam_t.DOTA_TEAM_NOTEAM);
}

function UpdateTeamPanel(team_panel) {
    const team_id = team_panel.GetAttributeInt("team_id", -1);
    const known_lobby_players = GetKnownLobbyPlayerIDSet();
    const team_players = (Game.GetPlayerIDsOnTeam(team_id) || []).filter((player_id) => known_lobby_players.has(player_id));
    team_panel.player_list.RemoveAndDeleteChildren();

    team_players.forEach((player_id) => {
        const player_panel = GetPlayerPanel(player_id);
        if (player_panel) {
            player_panel.SetParent(team_panel.player_list);
        }
    });

    const team_info = Game.GetTeamDetails(team_id);
    const team_max_players = team_info ? team_info.team_max_players : team_players.length;
    for (let empty_idx = team_players.length; empty_idx < team_max_players; ++empty_idx) {
        CreateEmptySlot(team_panel.player_list);
    }

    team_panel.SetHasClass("BTeamFull", team_players.length === team_max_players);
}

function OnTeamPlayerListChanged() {
    const known_lobby_players = GetKnownLobbyPlayerIDSet();
    CleanupStalePlayerPanels(known_lobby_players);

    players_panels.forEach((player_panel) => {
        if (player_panel) {
            player_panel.SetParent(HUD.UNASSIGNED_ROOT);
        }
    });

    const unassigned_players = (Game.GetUnassignedPlayerIDs() || []).filter((player_id) => known_lobby_players.has(player_id));
    unassigned_players.forEach((unassigned_player_id) => {
        GetPlayerPanel(unassigned_player_id);
    });

    team_panels.forEach((team_panel) => {
        UpdateTeamPanel(team_panel);
    });

    UpdateAutoLaunchState();
    CheckPrivileges();
}

function OnPlayerSelectedTeam(player_id, team_id, b_success) {
    if (player_id !== LOCAL_PLAYER_ID) {
        return;
    }

    Game.EmitSound(`ui_team_select_pick_team${b_success ? "" : "_failed"}`);
}

function CreateTeams() {
    const all_teams_ids = Game.GetAllTeamIDs() || [];
    const teams_line = $.CreatePanel("Panel", HUD.TEAMS_ROOT, "");
    teams_line.AddClass("TS_TeamLine");

    all_teams_ids.forEach((team_id) => {
        const team_root = $.CreatePanel("Panel", teams_line, `TS_Team_${team_id}`);
        team_root.BLoadLayoutSnippet("TS_Team");
        team_root.player_list = team_root.FindChildTraverse("TS_Team_Players_List");
        team_root.SetAttributeInt("team_id", team_id);

        const team_details = Game.GetTeamDetails(team_id);
        if (team_details) {
            team_root.SetDialogVariable("team_name", $.Localize(team_details.team_name).toUpperCase());
        }

        team_panels.push(team_root);

        team_root.SetPanelEvent("onactivate", () => {
            Game.PlayerJoinTeam(team_id);
        });
        team_root.AddClass(`Team_${team_id}`);

        const header_overlay = team_root.FindChildTraverse("TS_Team_Header_Overlay");
        if (header_overlay) {
            header_overlay.style.backgroundColor = `gradient(radial, 50% 100%, 0% 0%, 40% 75%, from(${GetTeamColor(team_id)}), to(transparent));`;
        }
    });
}

function ShuffleTeams() {
    if (Game.GetTeamSelectionLocked()) {
        return;
    }

    if (MAP_DISPLAY_NAME === "overvodka_solo") {
        const unassignedPlayers = GetValidUnassignedPlayerIDs();
        if (unassignedPlayers.length > 0) {
            Game.AutoAssignPlayersToTeams();
            $.Schedule(0.03, () => {
                if (!Game.GetTeamSelectionLocked()) {
                    Game.ShufflePlayerTeamAssignments();
                }
            });
            return;
        }

        Game.ShufflePlayerTeamAssignments();
        return;
    }

    GameEvents.SendCustomGameEventToServer("team_selection_shuffle_request", {});
}

function LockAndStart() {
    if (GetValidUnassignedPlayerIDs().length > 0) {
        return;
    }

    Game.SetTeamSelectionLocked(true);
    Game.SetAutoLaunchEnabled(false);
    Game.SetRemainingSetupTime(3);
}

function UnlockTeams() {
    Game.SetTeamSelectionLocked(false);
    Game.SetRemainingSetupTime(-1);
    ScheduleAutoLaunchRefresh();
}

function IsShowLobbyTools() {
    let players_in_lobby = 0;
    const max_players = (typeof DOTALimits_t !== "undefined" && DOTALimits_t.DOTA_MAX_TEAM_PLAYERS) || 24;
    for (let player_id = 0; player_id < max_players; player_id++) {
        const player_info = Game.GetPlayerInfo(player_id);
        if (!player_info) {
            continue;
        }
        players_in_lobby++;
    }

    let max_player_in_map = 0;
    const all_teams_ids = Game.GetAllTeamIDs() || [];
    all_teams_ids.forEach((team_id) => {
        const team_details = Game.GetTeamDetails(team_id);
        if (team_details) {
            max_player_in_map += team_details.team_max_players;
        }
    });

    const is_tools = typeof Game.IsInToolsMode === "function" && Game.IsInToolsMode();
    return players_in_lobby < max_player_in_map || is_tools;
}

function CheckPrivileges() {
    const player_info = Game.GetLocalPlayerInfo();
    if (!player_info) {
        return;
    }

    HUD.CONTEXT.SetHasClass("BShowUnassigned", true);
    HUD.CONTEXT.SetHasClass("BShowHostElements", player_info.player_has_host_privileges);
    HUD.CONTEXT.SetHasClass("BShowUnlock", player_info.player_has_host_privileges);
}

function UpdateSchedule() {
    const teamsLocked = Game.GetTeamSelectionLocked();
    HUD.CONTEXT.SetHasClass("BTeamsLocked", teamsLocked);

    if (previousTeamsLocked && !teamsLocked) {
        ScheduleAutoLaunchRefresh();
    }
    previousTeamsLocked = teamsLocked;

    const timerPanel = $("#TS_TimerPanel");
    const timerLabel = $("#TS_TimerLabel");
    if (timerPanel && timerLabel) {
        const remainingSetupTime = Game.GetStateTransitionTime() - Game.GetGameTime();
        timerPanel.visible = true;
        if (remainingSetupTime >= 0) {
            timerLabel.text = FormatSetupTime(remainingSetupTime);
        } else {
            timerLabel.text = "\u221e";
        }
    }

    CheckPrivileges();

    if (Game.GameStateIsAfter(DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP)) {
        return;
    }
    $.Schedule(0.1, UpdateSchedule);
}

(function Init() {
    if (HUD.CONTEXT.GetParent()) {
        HUD.CONTEXT.GetParent().style.margin = "0px";
    }
    if (MAP_DISPLAY_NAME === "overvodka_solo") {
        HUD.CONTEXT.AddClass("Map_OvervodkaSolo");
    }

    HUD.TEAMS_ROOT.RemoveAndDeleteChildren();
    HUD.UNASSIGNED_ROOT.RemoveAndDeleteChildren();

    CreateTeams();
    OnTeamPlayerListChanged();
    UpdateAutoLaunchState();
    CheckPrivileges();
    UpdateSchedule();

    $.RegisterForUnhandledEvent("DOTAGame_TeamPlayerListChanged", OnTeamPlayerListChanged);
    $.RegisterForUnhandledEvent("DOTAGame_PlayerSelectedCustomTeam", OnPlayerSelectedTeam);
    $.RegisterForUnhandledEvent("DOTAGame_PlayerDetailsChanged", CheckPrivileges);
})();
