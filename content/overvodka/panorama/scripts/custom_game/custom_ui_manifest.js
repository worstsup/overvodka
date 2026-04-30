GameUI.CustomUIConfig().multiteam_top_scoreboard =
{
 reorder_team_scores: true,
 LeftInjectXMLFile: "file://{resources}/layout/custom_game/overthrow_scoreboard_left.xml",
 TeamOverlayXMLFile: "file://{resources}/layout/custom_game/overthrow_scoreboard_team_overlay.xml"
};
if (Game.GetMapInfo().map_display_name == "overvodka_5x5"){
  GameUI.CustomUIConfig().multiteam_top_scoreboard =
    {
    reorder_team_scores: false,
    LeftInjectXMLFile: "",
    TeamOverlayXMLFile: "file://{resources}/layout/custom_game/overthrow_scoreboard_team_overlay.xml"
    };
}
GameUI.CustomUIConfig().team_select = 
{
    "bShowSpectatorTeam" : false
}

let PICK_SCREEN_HIDDEN = false;

function HidePregameUntilTeamSelection()
{
    let pregameRoot = null;
    try {
        pregameRoot = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("PreGame");
    } catch (e) {}

    if (!pregameRoot) {
        $.Schedule(0.1, HidePregameUntilTeamSelection);
        return;
    }

    if (Game.GameStateIsBefore(DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP)) {
        if (!PICK_SCREEN_HIDDEN) {
            PICK_SCREEN_HIDDEN = true;
            pregameRoot.style.opacity = "0";
        }

        $.Schedule(0.1, HidePregameUntilTeamSelection);
        return;
    }

    pregameRoot.style.opacity = "1";
    PICK_SCREEN_HIDDEN = false;
}

function UpdateHeroSelection() {
    if (Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_STRATEGY_TIME)) {
        UnmuteAll()
    }

    if (!Game.GameStateIsBefore(DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME)) {
        ClearLocalHeroSkinSelectionOverrides()
        StopSansPickMusic()
    }
}

(function () {
    GameEvents.Subscribe('game_rules_state_change', UpdateHeroSelection);
    GameEvents.Subscribe("sans_pick_music_start", OnSansPickMusicStart);
    GameEvents.Subscribe("sans_pick_music_stop", OnSansPickMusicStop);
})();

HidePregameUntilTeamSelection();

function RemoveMute() 
{
    let scoreboard = FindDotaHudElement("scoreboard")
    if (scoreboard) {
        scoreboard.FindChildrenWithClassTraverse("ReportColumn")?.forEach(element => {
            element.style.visibility = "collapse"
        })
    }
    $.Schedule(0, RemoveMute)
}

$.Schedule(0, RemoveMute)

let updateMuteSchedule = null;
let updateMuteInterval = 0.1;

function UnmuteAll()
{
    for (let nPlayerID = 0; nPlayerID < Players.GetMaxPlayers(); nPlayerID++) {
        if (nPlayerID != Players.GetLocalPlayer()) {
            Game.SetPlayerMuted( nPlayerID, false )
            Game.SetPlayerMuted( nPlayerID, false )
            Game.SetPlayerMuted( nPlayerID, false )
        }
    }
}

function GetLocalHeroName() {
    let localPlayer = Players.GetLocalPlayer();
    let heroIndex = Players.GetPlayerHeroEntityIndex(localPlayer);
    if (heroIndex != -1) {
        return Entities.GetUnitName(heroIndex);
    }
    if (Players.IsSpectator( localPlayer )) {
        return "spectator";
    }
    return null;
}

function ApplyMuteFromNetTable() {
    let localHeroName = GetLocalHeroName();
    let muteData = null;
    
    if (localHeroName) {
        muteData = CustomNetTables.GetTableValue("mute_data", localHeroName);
    }
    if (!muteData && localHeroName == "spectator") {
        muteData = CustomNetTables.GetTableValue("mute_data", "npc_dota_hero_abaddon");
    }
    if (!muteData) {
        muteData = CustomNetTables.GetTableValue("mute_data", "all");
    }
    if (muteData) {
        for (let nPlayerID = 0; nPlayerID < Players.GetMaxPlayers(); nPlayerID++) {
            if (nPlayerID != Players.GetLocalPlayer()) {
                let hero = Players.GetPlayerHeroEntityIndex(nPlayerID);
                if (hero != -1) {
                    let heroName = Entities.GetUnitName(hero);
                    if (muteData.hasOwnProperty(heroName)) {
                        Game.SetPlayerMutedVoice(nPlayerID, muteData[heroName] == 1);
                    }
                }
            }
        }
    }
}

function StartMuteLoop() {
    ApplyMuteFromNetTable();
    updateMuteSchedule = $.Schedule(updateMuteInterval, StartMuteLoop);
}

StartMuteLoop();

function OnSansPickMusicStart(event) {
    const soundName = event && event.sound_name;
    if (!soundName) {
        return;
    }

    StartSansPickMusicByName(soundName);
}

function OnSansPickMusicStop() {
    StopSansPickMusic();
}


GameEvents.Subscribe("PrintMuted", PrintMuted);

function PrintMuted()
{
    for (let nPlayerID = 0; nPlayerID < Players.GetMaxPlayers(); nPlayerID++) {
        if (Players.GetPlayerHeroEntityIndex( nPlayerID ) != -1) {
            print(Entities.GetUnitName(Players.GetPlayerHeroEntityIndex( nPlayerID )))
            print(
                "all " + Game.IsPlayerMuted( nPlayerID ) + " " +
                "voice " + Game.IsPlayerMutedVoice( nPlayerID ) + " " +
                "text " + Game.IsPlayerMutedText( nPlayerID )
            )
        }
    }
}

GameUI.CustomUIConfig().team_logo_xml = "file://{resources}/layout/custom_game/overthrow_team_icon.xml";
GameUI.CustomUIConfig().team_logo_large_xml = "file://{resources}/layout/custom_game/overthrow_team_icon_large.xml";

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FIGHT_RECAP, false );

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false);

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_GAME_NAME, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_CLOCK, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_HEADER, false );

if (Game.GetMapInfo().map_display_name == "overvodka_5x5"){
  GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, true );
}

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false );

GameUI.CustomUIConfig().team_colors = {}
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "#3455FF"; // { 61, 210, 150 }	--		Teal
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_BADGUYS ] = "#D2042D;"; // { 243, 201, 9 }		--		Yellow
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "#c54da8;"; // { 197, 77, 168 }	--		Pink
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "#FF6C00;"; // { 255, 108, 0 }		--		Orange
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "#3455FF;"; // { 52, 85, 255 }		--		Blue
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "#65d413;"; // { 101, 212, 19 }	--		Green
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = "#815336;"; // { 129, 83, 54 }		--		Brown
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = "#1bc0d8;"; // { 27, 192, 216 }	--		Cyan
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = "#c7e40d;"; // { 199, 228, 13 }	--		Olive
GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = "#8c2af4;"; // { 140, 42, 244 }	--		Purple

GameUI.CustomUIConfig().team_icons = {}
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "file://{images}/custom_game/team_icons/team_icon_evelone.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_BADGUYS ] = "file://{images}/custom_game/team_icons/team_icon_sasavot.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "file://{images}/custom_game/team_icons/team_icon_dragon_01.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "file://{images}/custom_game/team_icons/team_icon_dog_01.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "file://{images}/custom_game/team_icons/team_icon_rooster_01.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "file://{images}/custom_game/team_icons/team_icon_ram_01.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = "file://{images}/custom_game/team_icons/team_icon_rat_01.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = "file://{images}/custom_game/team_icons/team_icon_boar_01.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = "file://{images}/custom_game/team_icons/team_icon_snake_01.png";
GameUI.CustomUIConfig().team_icons[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = "file://{images}/custom_game/team_icons/team_icon_horse_01.png";
