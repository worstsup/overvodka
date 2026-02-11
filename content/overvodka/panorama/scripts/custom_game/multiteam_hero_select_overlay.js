"use strict";
var heroModelPanel = heroModelPanel || null;
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

function UpdateCustomHeroModel(hero_name, playerId)
{
	if (playerId != Game.GetLocalPlayerID()) {
		return;
	}
	let strategyScreen = FindDotaHudElement("StrategyScreen");
    if (!strategyScreen) {
        return;
    }
	let existing = strategyScreen.FindChildTraverse("custom_hero_model_panel");
    if (existing) {
        heroModelPanel = existing;
        heroModelPanel.style.visibility = "visible";
        return;
    }

	let HeroModelLoadout = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroModelLoadout")
	HeroModelLoadout.style.visibility = "collapse";
	if (heroModelPanel) {
		return
	}

	if (!heroModelPanel && hero_name === "npc_dota_hero_morphling") 
	{
		let panel = FindDotaHudElement("StrategyScreen")
		heroModelPanel = $.CreatePanel("DOTAScenePanel", strategyScreen, "custom_hero_model_panel", { class: "hero_model_strategy", style: "width:46.5%;height:90%;margin-top:-40px;", drawbackground: true, unit: "sans_arcana_loadout", particleonly:"false", renderdeferred:"false", antialias:"true", renderwaterreflections:"true", allowrotation: "true"});
		heroModelPanel.SetParent(panel);
	}
	if (!heroModelPanel && hero_name === "npc_dota_hero_void_spirit") 
	{
		let panel = FindDotaHudElement("StrategyScreen")
		heroModelPanel = $.CreatePanel("DOTAScenePanel", strategyScreen, "custom_hero_model_panel", { class: "hero_model_strategy", style: "width:46.5%;height:90%;margin-top:-40px;", drawbackground: true, unit: "invincible_arcana_loadout", particleonly:"false", renderdeferred:"false", antialias:"true", renderwaterreflections:"true", allowrotation: "true"});
		heroModelPanel.SetParent(panel);
	}
	try {
        let firstChild = strategyScreen.GetChild(0);
        if (firstChild && strategyScreen.MoveChildBefore) {
            strategyScreen.MoveChildBefore(heroModelPanel, firstChild);
        }
    } catch (e) {
    }
}
function ToggleLockInNotice(heroPickPanel, showNotice) {
    if (!heroPickPanel) return;

    const controls = heroPickPanel.FindChildTraverse("HeroPickControls") || heroPickPanel.FindChildTraverse("HeroControls");
    if (!controls) return;

    let lockBtn = controls.FindChildTraverse("LockInButton");
    if (!lockBtn) {
        const btns = (typeof controls.Children === "function") ? controls.Children() : null;
        if (btns) {
            for (let i = 0; i < btns.length; i++) {
                if (btns[i] && btns[i].BHasClass && btns[i].BHasClass("lock-in-button")) { lockBtn = btns[i]; break; }
            }
        }
    }

    const noticeId = "OvervodkaPrimeNotice";

    if (showNotice) {
        if (lockBtn) lockBtn.style.visibility = "collapse";

        let notice = controls.FindChildTraverse(noticeId);
        if (!notice) {
			notice = $.CreatePanel("Panel", controls, noticeId);
			notice.AddClass("OvervodkaPrimeNotice");
			notice.style.width = "100%";
			notice.style.height = "100%";
			notice.style.backgroundColor = "rgba(0,0,0,0.8)";

			const textId = noticeId + "_text";
			const text = $.CreatePanel("Label", notice, textId);
			text.text = $.Localize("#DOTA_Tooltip_overvodka_prime_notice") || "Доступно с Overvodka Prime";

			text.style.width = "100%";
			text.style.height = "100%";
			text.style.margin = "20px 0px 0px 0px";
			text.style.textAlign = "center";
			text.style.fontSize = "24px";
			text.style.fontWeight = "bold";
			text.style.color = "white";

		} else {
			let text = notice.FindChildTraverse(noticeId + "_text");
			if (!text) {
				text = $.CreatePanel("Label", notice, noticeId + "_text");
			}
			text.text = $.Localize("#DOTA_Tooltip_overvodka_prime_notice") || "Доступно с Overvodka Prime";
			text.style.width = "100%";
			text.style.height = "100%";
			text.style.textAlign = "center";
			text.style.margin = "20px 0px 0px 0px"; 
			text.style.fontSize = "24px";
			text.style.fontWeight = "bold";
			text.style.color = "white";
		}

        try {
            const firstChild = (typeof controls.GetChild === "function") ? controls.GetChild(0) : null;
            if (firstChild && typeof controls.MoveChildBefore === "function") {
                controls.MoveChildBefore(notice, firstChild);
            } else {
                if (firstChild && typeof firstChild.MoveChildAfter === "function") {
                    firstChild.MoveChildAfter(firstChild, notice);
                } else {
                    $.Msg("ToggleLockInNotice: MoveChildBefore / MoveChildAfter not available; notice kept at end.");
                }
            }
        } catch (err) {
            $.Msg("ToggleLockInNotice: error while moving notice to start:", err);
        }

    } else {
        if (lockBtn) lockBtn.style.visibility = "visible";

        const old = controls.FindChildTraverse(noticeId);
        if (old) old.DeleteAsync(0);
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
			"npc_dota_hero_lion": "file://{images}/heroes/npc_dota_hero_chef.png",
			"npc_dota_hero_puck": "file://{images}/heroes/npc_dota_hero_lev.png",
			"npc_dota_hero_kunkka": "file://{images}/heroes/npc_dota_hero_vova.png",
			"npc_dota_hero_pudge": "file://{images}/heroes/npc_dota_hero_step.png",
			"npc_dota_hero_sniper": "file://{images}/heroes/npc_dota_hero_ivanov.png",
			"npc_dota_hero_meepo": "file://{images}/heroes/npc_dota_hero_kirill.png",
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
			"npc_dota_hero_phantom_lancer": "file://{images}/heroes/npc_dota_hero_kolyan.png",
			"npc_dota_hero_primal_beast": "file://{images}/heroes/npc_dota_hero_t2x2.png",
			"npc_dota_hero_ringmaster": "file://{images}/heroes/npc_dota_hero_mazellov.png",
			"npc_dota_hero_warlock": "file://{images}/heroes/npc_dota_hero_king.png",
			"npc_dota_hero_spirit_breaker": "file://{images}/heroes/npc_dota_hero_flash.png",
			"npc_dota_hero_winter_wyvern": "file://{images}/heroes/npc_dota_hero_bikov.png",
			"npc_dota_hero_spectre": "file://{images}/heroes/npc_dota_hero_chara.png",
			"npc_dota_hero_templar_assassin": "file://{images}/heroes/npc_dota_hero_frisk.png",
			"npc_dota_hero_abaddon": "file://{images}/heroes/npc_dota_hero_prince.png",
			"npc_dota_hero_tusk": "file://{images}/heroes/npc_dota_hero_seregga.png",
			"npc_dota_hero_undying": "file://{images}/heroes/npc_dota_hero_visitor.png",
			"npc_dota_hero_ember_spirit": "file://{images}/heroes/npc_dota_hero_peacemaker.png",
			"npc_dota_hero_nyx_assassin": "file://{images}/heroes/npc_dota_hero_kolibri.png",
			"npc_dota_hero_hoodwink": "file://{images}/heroes/npc_dota_hero_leon.png",
			"npc_dota_hero_slardar": "file://{images}/heroes/npc_dota_hero_pistol.png",
			"npc_dota_hero_bristleback": "file://{images}/heroes/npc_dota_hero_amor.png",
			"npc_dota_hero_beastmaster": "file://{images}/heroes/npc_dota_hero_epstein.png",
		};

		if (heroImages[playerInfo.player_selected_hero]) {
			if (playerInfo.player_selected_hero == "npc_dota_hero_morphling" && IsPlayerSubscribed(playerId)) {
				playerPortrait.SetImage("file://{images}/heroes/npc_dota_hero_underfell_sans.png");
				UpdateCustomHeroModel(playerInfo.player_selected_hero, playerId);
			}
			else if (playerInfo.player_selected_hero == "npc_dota_hero_void_spirit" && IsPlayerSubscribed(playerId)) {
				playerPortrait.SetImage("file://{images}/heroes/npc_dota_hero_invincible_arcana.png");
				UpdateCustomHeroModel(playerInfo.player_selected_hero, playerId);
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
			"lion": "file://{images}/heroes/npc_dota_hero_chef.png",
			"puck": "file://{images}/heroes/npc_dota_hero_lev.png",
			"kunkka": "file://{images}/heroes/npc_dota_hero_vova.png",
			"pudge": "file://{images}/heroes/npc_dota_hero_step.png",
			"sniper": "file://{images}/heroes/npc_dota_hero_ivanov.png",
			"meepo": "file://{images}/heroes/npc_dota_hero_kirill.png",
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
			"phantom_lancer": "file://{images}/heroes/npc_dota_hero_kolyan.png",
			"primal_beast": "file://{images}/heroes/npc_dota_hero_t2x2.png",
			"ringmaster": "file://{images}/heroes/npc_dota_hero_mazellov.png",
			"warlock": "file://{images}/heroes/npc_dota_hero_king.png",
			"spirit_breaker": "file://{images}/heroes/npc_dota_hero_flash.png",
			"winter_wyvern": "file://{images}/heroes/npc_dota_hero_bikov.png",
			"spectre": "file://{images}/heroes/npc_dota_hero_chara.png",
			"templar_assassin": "file://{images}/heroes/npc_dota_hero_frisk.png",
			"abaddon": "file://{images}/heroes/npc_dota_hero_prince.png",
			"tusk": "file://{images}/heroes/npc_dota_hero_seregga.png",
			"undying": "file://{images}/heroes/npc_dota_hero_visitor.png",
			"ember_spirit": "file://{images}/heroes/npc_dota_hero_peacemaker.png",
			"nyx_assassin": "file://{images}/heroes/npc_dota_hero_kolibri.png",
			"hoodwink": "file://{images}/heroes/npc_dota_hero_leon.png",
			"slardar": "file://{images}/heroes/npc_dota_hero_pistol.png",
			"bristleback": "file://{images}/heroes/npc_dota_hero_amor.png",
			"beastmaster": "file://{images}/heroes/npc_dota_hero_epstein.png",
		};

		if (possibleHeroImages[playerInfo.possible_hero_selection]) {
			let HeroPick = FindDotaHudElement("HeroPickRightColumn");
			HeroPick.style.visibility = "visible";
			if (playerInfo.possible_hero_selection == "morphling" && IsPlayerSubscribed(playerId)) 
			{
				ToggleLockInNotice(HeroPick, false);
				playerPortrait.SetImage("file://{images}/heroes/npc_dota_hero_underfell_sans.png");
				
			}
			else if (playerInfo.possible_hero_selection == "void_spirit" && IsPlayerSubscribed(playerId))
			{
				ToggleLockInNotice(HeroPick, false);
				playerPortrait.SetImage("file://{images}/heroes/npc_dota_hero_invincible_arcana.png");
			}
			else if (playerInfo.possible_hero_selection == "puck" && !IsPlayerSubscribed(playerId))
			{
				ToggleLockInNotice(HeroPick, true);
			}
			else
			{
				ToggleLockInNotice(HeroPick, false);
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

	$.Schedule( 0.05, UpdateTimer );
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

