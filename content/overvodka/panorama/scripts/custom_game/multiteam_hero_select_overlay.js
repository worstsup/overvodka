"use strict";
let heroModelPanel
function OnUpdateHeroSelection()
{
	for ( var teamId of Game.GetAllTeamIDs() )
	{
		UpdateTeam( teamId );
	}
}

function UpdateTeam( teamId )
{
	var teamPanelName = "team_" + teamId;
	var teamPanel = $( "#"+teamPanelName );
	var teamPlayers = Game.GetPlayerIDsOnTeam( teamId );
	teamPanel.SetHasClass( "no_players", ( teamPlayers.length == 0 ) );
	for ( var playerId of teamPlayers )
	{
		UpdatePlayer( teamPanel, playerId );
	}
}

function UpdateCustomHeroModel(hero_name)
{
	let HeroModelLoadout = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroModelLoadout")
	HeroModelLoadout.style.visibility = "collapse";
	if (heroModelPanel) {
		return
	}

	if (!heroModelPanel) 
	{
		let panel = FindDotaHudElement("StrategyScreen")
		heroModelPanel = $.CreatePanel("DOTAScenePanel", $.GetContextPanel(), "", { class: "hero_model_strategy", style: "width:48%;height:80%;", drawbackground: false, unit: "sans_arcana_loadout", particleonly:"false", renderdeferred:"false", antialias:"true", renderwaterreflections:"true", allowrotation: "false"});
		heroModelPanel.SetParent(panel);
	}
}

function UpdatePlayer( teamPanel, playerId )
{
	var playerContainer = teamPanel.FindChildInLayoutFile( "PlayersContainer" );
	var playerPanelName = "player_" + playerId;
	var playerPanel = playerContainer.FindChild( playerPanelName );
	if ( playerPanel === null )
	{
		playerPanel = $.CreatePanel( "Image", playerContainer, playerPanelName );
		playerPanel.BLoadLayout( "file://{resources}/layout/custom_game/multiteam_hero_select_overlay_player.xml", false, false );
		playerPanel.AddClass( "PlayerPanel" );
	}

	var playerInfo = Game.GetPlayerInfo( playerId );
	if ( !playerInfo )
		return;

	var localPlayerInfo = Game.GetLocalPlayerInfo();
	if ( !localPlayerInfo )
		return;

	var localPlayerTeamId = localPlayerInfo.player_team_id;
	var playerPortrait = playerPanel.FindChildInLayoutFile( "PlayerPortrait" );
	
	if ( playerId == localPlayerInfo.player_id )
	{
		playerPanel.AddClass( "is_local_player" );
	}

	if ( playerInfo.player_selected_hero !== "" )
	{
		const heroImages = {
			"npc_dota_hero_ursa": "file://{images}/heroes/npc_dota_hero_litvin.png",
			"npc_dota_hero_bounty_hunter": "file://{images}/heroes/npc_dota_hero_mellstroy.png",
			"npc_dota_hero_tinker": "file://{images}/heroes/npc_dota_hero_ilin.png",
			"npc_dota_hero_brewmaster": "file://{images}/heroes/npc_dota_hero_golmy.png",
			"npc_dota_hero_invoker": "file://{images}/heroes/npc_dota_hero_zombill.png",
			"npc_dota_hero_rubick": "file://{images}/heroes/npc_dota_hero_mrus.png",
			"npc_dota_hero_terrorblade": "file://{images}/heroes/npc_dota_hero_senya.png",
			"npc_dota_hero_riki": "file://{images}/heroes/npc_dota_hero_stray.png",
			"npc_dota_hero_lion": "file://{images}/heroes/npc_dota_hero_lev.png",
			"npc_dota_hero_kunkka": "file://{images}/heroes/npc_dota_hero_vova.png",
			"npc_dota_hero_pudge": "file://{images}/heroes/npc_dota_hero_step.png",
			"npc_dota_hero_sniper": "file://{images}/heroes/npc_dota_hero_ivanov.png",
			"npc_dota_hero_meepo": "file://{images}/heroes/npc_dota_hero_kirill.png",
			"npc_dota_hero_undying": "file://{images}/heroes/npc_dota_hero_dmb.png",
			"npc_dota_hero_axe": "file://{images}/heroes/npc_dota_hero_dima.png",
			"npc_dota_hero_phoenix": "file://{images}/heroes/npc_dota_hero_orlov.png",
			"npc_dota_hero_zuus": "file://{images}/heroes/npc_dota_hero_stariy.png",
			"npc_dota_hero_tidehunter": "file://{images}/heroes/npc_dota_hero_tamaev.png",
			"npc_dota_hero_earthshaker": "file://{images}/heroes/npc_dota_hero_arsen.png",
			"npc_dota_hero_furion": "file://{images}/heroes/npc_dota_hero_nix.png",
			"npc_dota_hero_antimage": "file://{images}/heroes/npc_dota_hero_pirat.png",
			"npc_dota_hero_ogre_magi": "file://{images}/heroes/npc_dota_hero_zolo.png",
			"npc_dota_hero_clinkz": "file://{images}/heroes/npc_dota_hero_cheater.png",
			"npc_dota_hero_ancient_apparition": "file://{images}/heroes/npc_dota_hero_chill.png",
			"npc_dota_hero_bloodseeker": "file://{images}/heroes/npc_dota_hero_sasavot.png",
			"npc_dota_hero_juggernaut": "file://{images}/heroes/npc_dota_hero_golovach.png",
			"npc_dota_hero_skeleton_king": "file://{images}/heroes/npc_dota_hero_papich.png",
			"npc_dota_hero_rattletrap": "file://{images}/heroes/npc_dota_hero_vihorkov.png",
			"npc_dota_hero_storm_spirit": "file://{images}/heroes/npc_dota_hero_rostik.png",
			"npc_dota_hero_necrolyte": "file://{images}/heroes/npc_dota_hero_5opka.png",
			"npc_dota_hero_morphling": "file://{images}/heroes/npc_dota_hero_sans.png",
			"npc_dota_hero_faceless_void": "file://{images}/heroes/npc_dota_hero_evelone.png",
			"npc_dota_hero_slark": "file://{images}/heroes/npc_dota_hero_bratishkin.png",
			"npc_dota_hero_weaver": "file://{images}/heroes/npc_dota_hero_azazin.png",
			"npc_dota_hero_omniknight": "file://{images}/heroes/npc_dota_hero_stint.png",
			"npc_dota_hero_void_spirit": "file://{images}/heroes/npc_dota_hero_invincible.png",
			"npc_dota_hero_mars":	"file://{images}/heroes/npc_dota_hero_zhenya.png",
		};

		if (heroImages[playerInfo.player_selected_hero]) {
			if (playerInfo.player_selected_hero == "npc_dota_hero_morphling" && IsPlayerSubscribed(playerId)) {
				playerPortrait.SetImage("file://{images}/heroes/npc_dota_hero_underfell_sans.png");
				UpdateCustomHeroModel(playerInfo.player_selected_hero)
			}
			else {
				playerPortrait.SetImage(heroImages[playerInfo.player_selected_hero]);
			}
		} else {
			playerPortrait.SetImage("file://{images}/heroes/" + playerInfo.player_selected_hero + ".png");
		}
		playerPanel.SetHasClass("hero_selected", true);
		playerPanel.SetHasClass("hero_highlighted", false);
	}
	else if ( playerInfo.possible_hero_selection !== "" && ( playerInfo.player_team_id == localPlayerTeamId ) )
	{
		const possibleHeroImages = {
			"ursa": "file://{images}/heroes/npc_dota_hero_litvin.png",
			"bounty_hunter": "file://{images}/heroes/npc_dota_hero_mellstroy.png",
			"tinker": "file://{images}/heroes/npc_dota_hero_ilin.png",
			"brewmaster": "file://{images}/heroes/npc_dota_hero_golmy.png",
			"invoker": "file://{images}/heroes/npc_dota_hero_zombill.png",
			"rubick": "file://{images}/heroes/npc_dota_hero_mrus.png",
			"terrorblade": "file://{images}/heroes/npc_dota_hero_senya.png",
			"riki": "file://{images}/heroes/npc_dota_hero_stray.png",
			"lion": "file://{images}/heroes/npc_dota_hero_lev.png",
			"kunkka": "file://{images}/heroes/npc_dota_hero_vova.png",
			"pudge": "file://{images}/heroes/npc_dota_hero_step.png",
			"sniper": "file://{images}/heroes/npc_dota_hero_ivanov.png",
			"meepo": "file://{images}/heroes/npc_dota_hero_kirill.png",
			"undying": "file://{images}/heroes/npc_dota_hero_dmb.png",
			"axe": "file://{images}/heroes/npc_dota_hero_dima.png",
			"phoenix": "file://{images}/heroes/npc_dota_hero_orlov.png",
			"zuus": "file://{images}/heroes/npc_dota_hero_stariy.png",
			"tidehunter": "file://{images}/heroes/npc_dota_hero_tamaev.png",
			"earthshaker": "file://{images}/heroes/npc_dota_hero_arsen.png",
			"furion": "file://{images}/heroes/npc_dota_hero_nix.png",
			"antimage": "file://{images}/heroes/npc_dota_hero_pirat.png",
			"ogre_magi": "file://{images}/heroes/npc_dota_hero_zolo.png",
			"clinkz": "file://{images}/heroes/npc_dota_hero_cheater.png",
			"ancient_apparition": "file://{images}/heroes/npc_dota_hero_chill.png",
			"bloodseeker": "file://{images}/heroes/npc_dota_hero_sasavot.png",
			"juggernaut": "file://{images}/heroes/npc_dota_hero_golovach.png",
			"skeleton_king": "file://{images}/heroes/npc_dota_hero_papich.png",
			"rattletrap": "file://{images}/heroes/npc_dota_hero_vihorkov.png",
			"storm_spirit": "file://{images}/heroes/npc_dota_hero_rostik.png",
			"necrolyte": "file://{images}/heroes/npc_dota_hero_5opka.png",
			"morphling": "file://{images}/heroes/npc_dota_hero_sans.png",
			"faceless_void": "file://{images}/heroes/npc_dota_hero_evelone.png",
			"slark": "file://{images}/heroes/npc_dota_hero_bratishkin.png",
			"weaver": "file://{images}/heroes/npc_dota_hero_azazin.png",
			"omniknight": "file://{images}/heroes/npc_dota_hero_stint.png",
			"void_spirit": "file://{images}/heroes/npc_dota_hero_invincible.png",
			"mars": "file://{images}/heroes/npc_dota_hero_zhenya.png",
		};

		if (possibleHeroImages[playerInfo.possible_hero_selection]) {
			if (playerInfo.possible_hero_selection == "morphling" && IsPlayerSubscribed(playerId)) 
			{
				playerPortrait.SetImage("file://{images}/heroes/npc_dota_hero_underfell_sans.png");
			}
			else
			{
				playerPortrait.SetImage(possibleHeroImages[playerInfo.possible_hero_selection]);
			}
		}
		else
		{
			playerPortrait.SetImage("file://{images}/heroes/npc_dota_hero_" + playerInfo.possible_hero_selection + ".png");
		}
		playerPanel.SetHasClass("hero_selected", false);
		playerPanel.SetHasClass("hero_highlighted", true);
	}
	else
	{
		playerPortrait.SetImage( "file://{images}/custom_game/unassigned.png" );
	}
	
	var playerName = playerPanel.FindChildInLayoutFile( "PlayerName" );
	playerName.text = playerInfo.player_name;

	playerPanel.SetHasClass( "is_local_player", ( playerId == Game.GetLocalPlayerID() ) );
}

function UpdateTimer()
{
	if ( Game.IsInBanPhase() )
	{
		$("#TimerPanel").SetDialogVariable( "timer_text", $.Localize( "#BanPhase" ) );
	}
	else if ( Game.GameStateIs( DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION ) )
	{
		$("#TimerPanel").SetDialogVariable( "timer_text", $.Localize( "#HeroPickPhase" ) );
	}
	else
	{
		$("#TimerPanel").SetDialogVariable( "timer_text", $.Localize( "#StrategyPhase" ) );
	}

	var gameTime = Game.GetGameTime();
	var transitionTime = Game.GetStateTransitionTime();

	var timerValue = Math.max( 0, Math.floor( transitionTime - gameTime ) );	
	$("#TimerPanel").SetDialogVariableInt( "timer_seconds", timerValue );

	$.Schedule( 0.1, UpdateTimer );
}

(function()
{
	var localPlayerTeamId = -1;
	var localPlayerInfo = Game.GetLocalPlayerInfo();
	if ( localPlayerInfo != null )
	{
		localPlayerTeamId = localPlayerInfo.player_team_id;
	}
	var first = true;
	var teamsContainer = $("#HeroSelectTeamsContainer");
	$.CreatePanel( "Panel", teamsContainer, "EndSpacer" );
	
	var timerPanel = $.CreatePanel( "Panel", teamsContainer, "TimerPanel" );
	timerPanel.BLoadLayout( "file://{resources}/layout/custom_game/multiteam_hero_select_overlay_timer.xml", false, false );

	for ( var teamId of Game.GetAllTeamIDs() )
	{
		$.CreatePanel( "Panel", teamsContainer, "Spacer" );

		var teamPanelName = "team_" + teamId;
		var teamPanel = $.CreatePanel( "Panel", teamsContainer, teamPanelName );
		teamPanel.BLoadLayout( "file://{resources}/layout/custom_game/multiteam_hero_select_overlay_team.xml", false, false );
		var teamName = teamPanel.FindChildInLayoutFile( "TeamName" );
		if ( teamName )
		{
			teamName.text = $.Localize( Game.GetTeamDetails( teamId ).team_name );
		}

		var logo_xml = GameUI.CustomUIConfig().team_logo_xml;
		if ( logo_xml )
		{
			var teamLogoPanel = teamPanel.FindChildInLayoutFile( "TeamLogo" );
			teamLogoPanel.SetAttributeInt( "team_id", teamId );
			teamLogoPanel.BLoadLayout( logo_xml, false, false );
		}
		
		var teamGradient = teamPanel.FindChildInLayoutFile( "TeamGradient" );
		if ( teamGradient && GameUI.CustomUIConfig().team_colors )
		{
			var teamColor = GameUI.CustomUIConfig().team_colors[ teamId ];
			teamColor = teamColor.replace( ";", "" );
			var gradientText = 'gradient( linear, 0% 0%, 0% 100%, from( #00000000 ), to( ' + teamColor + '40 ) );';
//			$.Msg( gradientText );
			teamGradient.style.backgroundColor = gradientText;
		}

		if ( teamName )
		{
			teamName.text = $.Localize( Game.GetTeamDetails( teamId ).team_name );
		}
		teamPanel.AddClass( "TeamPanel" );

		if ( teamId === localPlayerTeamId )
		{
			teamPanel.AddClass( "local_player_team" );
		}
		else
		{
			teamPanel.AddClass( "not_local_player_team" );
		}
	}

	$.CreatePanel( "Panel", teamsContainer, "EndSpacer" );

	OnUpdateHeroSelection();
	GameEvents.Subscribe( "dota_player_hero_selection_dirty", OnUpdateHeroSelection );
	GameEvents.Subscribe( "dota_player_update_hero_selection", OnUpdateHeroSelection );

	UpdateTimer();
})();

