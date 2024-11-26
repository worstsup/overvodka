"use strict";

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
		if (playerInfo.player_selected_hero == "npc_dota_hero_ursa"){
			playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_litvin.png" );
			playerPanel.SetHasClass( "hero_selected", true );
			playerPanel.SetHasClass( "hero_highlighted", false );
		}
		else{
			if (playerInfo.player_selected_hero == "npc_dota_hero_bounty_hunter"){
				playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_mellstroy.png" );
				playerPanel.SetHasClass( "hero_selected", true );
				playerPanel.SetHasClass( "hero_highlighted", false );
			}
			else{
				if (playerInfo.player_selected_hero == "npc_dota_hero_tinker"){
					playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_ilin.png" );
					playerPanel.SetHasClass( "hero_selected", true );
					playerPanel.SetHasClass( "hero_highlighted", false );
				}
				else{
					if (playerInfo.player_selected_hero == "npc_dota_hero_brewmaster"){
						playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_golmy.png" );
						playerPanel.SetHasClass( "hero_selected", true );
						playerPanel.SetHasClass( "hero_highlighted", false );
					}
					else{
						if (playerInfo.player_selected_hero == "npc_dota_hero_invoker"){
							playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_zombill.png" );
							playerPanel.SetHasClass( "hero_selected", true );
							playerPanel.SetHasClass( "hero_highlighted", false );
						}
						else{
							if (playerInfo.player_selected_hero == "npc_dota_hero_rubick"){
								playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_mrus.png" );
								playerPanel.SetHasClass( "hero_selected", true );
								playerPanel.SetHasClass( "hero_highlighted", false );
							}
							else{
								if (playerInfo.player_selected_hero == "npc_dota_hero_terrorblade"){
									playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_senya.png" );
									playerPanel.SetHasClass( "hero_selected", true );
									playerPanel.SetHasClass( "hero_highlighted", false );
								}
								else{
									if (playerInfo.player_selected_hero == "npc_dota_hero_riki"){
										playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_sega.png" );
										playerPanel.SetHasClass( "hero_selected", true );
										playerPanel.SetHasClass( "hero_highlighted", false );
									}
									else{
										if (playerInfo.player_selected_hero == "npc_dota_hero_lion"){
											playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_lev.png" );
											playerPanel.SetHasClass( "hero_selected", true );
											playerPanel.SetHasClass( "hero_highlighted", false );
										}
										else{
											if (playerInfo.player_selected_hero == "npc_dota_hero_kunkka"){
												playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_vova.png" );
												playerPanel.SetHasClass( "hero_selected", true );
												playerPanel.SetHasClass( "hero_highlighted", false );
											}
											else{
												if (playerInfo.player_selected_hero == "npc_dota_hero_pudge"){
													playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_step.png" );
													playerPanel.SetHasClass( "hero_selected", true );
													playerPanel.SetHasClass( "hero_highlighted", false );
												}
												else{
													if (playerInfo.player_selected_hero == "npc_dota_hero_sniper"){
														playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_ivanov.png" );
														playerPanel.SetHasClass( "hero_selected", true );
														playerPanel.SetHasClass( "hero_highlighted", false );
													}
													else{
														if (playerInfo.player_selected_hero == "npc_dota_hero_meepo"){
															playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_kirill.png" );
															playerPanel.SetHasClass( "hero_selected", true );
															playerPanel.SetHasClass( "hero_highlighted", false );
														}
														else{
															if (playerInfo.player_selected_hero == "npc_dota_hero_undying"){
																playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_dmb.png" );
																playerPanel.SetHasClass( "hero_selected", true );
																playerPanel.SetHasClass( "hero_highlighted", false );
															}
															else{
																if (playerInfo.player_selected_hero == "npc_dota_hero_axe"){
																	playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_dima.png" );
																	playerPanel.SetHasClass( "hero_selected", true );
																	playerPanel.SetHasClass( "hero_highlighted", false );
																}
																else{
																	if (playerInfo.player_selected_hero == "npc_dota_hero_phoenix"){
																		playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_orlov.png" );
																		playerPanel.SetHasClass( "hero_selected", true );
																		playerPanel.SetHasClass( "hero_highlighted", false );
																	}
																	else{
																		if (playerInfo.player_selected_hero == "npc_dota_hero_monkey_king"){
																			playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_loban.png" );
																			playerPanel.SetHasClass( "hero_selected", true );
																			playerPanel.SetHasClass( "hero_highlighted", false );
																		}
																		else{
																			if (playerInfo.player_selected_hero == "npc_dota_hero_zuus"){
																				playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_stariy.png" );
																				playerPanel.SetHasClass( "hero_selected", true );
																				playerPanel.SetHasClass( "hero_highlighted", false );
																			}
																			else{
																				if (playerInfo.player_selected_hero == "npc_dota_hero_tidehunter"){
																					playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_tamaev.png" );
																					playerPanel.SetHasClass( "hero_selected", true );
																					playerPanel.SetHasClass( "hero_highlighted", false );
																				}
																				else{
																					if (playerInfo.player_selected_hero == "npc_dota_hero_earthshaker"){
																						playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_arsen.png" );
																						playerPanel.SetHasClass( "hero_selected", true );
																						playerPanel.SetHasClass( "hero_highlighted", false );
																					}
																					else{
																						if (playerInfo.player_selected_hero == "npc_dota_hero_furion"){
																							playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_nix.png" );
																							playerPanel.SetHasClass( "hero_selected", true );
																							playerPanel.SetHasClass( "hero_highlighted", false );
																						}
																						else{
																							if (playerInfo.player_selected_hero == "npc_dota_hero_antimage"){
																								playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_pirat.png" );
																								playerPanel.SetHasClass( "hero_selected", true );
																								playerPanel.SetHasClass( "hero_highlighted", false );
																							}
																							else{
																								if (playerInfo.player_selected_hero == "npc_dota_hero_ogre_magi"){
																									playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_zolo.png" );
																									playerPanel.SetHasClass( "hero_selected", true );
																									playerPanel.SetHasClass( "hero_highlighted", false );
																								}
																								else{
																									playerPortrait.SetImage( "file://{images}/heroes/" + playerInfo.player_selected_hero + ".png" );
																									playerPanel.SetHasClass( "hero_selected", true );
																									playerPanel.SetHasClass( "hero_highlighted", false );
																								}
																							}
																						}
																					}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	else if ( playerInfo.possible_hero_selection !== "" && ( playerInfo.player_team_id == localPlayerTeamId ) )
	{
		if (playerInfo.possible_hero_selection == "ursa"){
			playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_litvin.png" );
			playerPanel.SetHasClass( "hero_selected", false );
			playerPanel.SetHasClass( "hero_highlighted", true );
		}
		else{
			if (playerInfo.possible_hero_selection == "bounty_hunter"){
				playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_mellstroy.png" );
				playerPanel.SetHasClass( "hero_selected", false );
				playerPanel.SetHasClass( "hero_highlighted", true );
			}
			else{
				if (playerInfo.possible_hero_selection == "tinker"){
					playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_ilin.png" );
					playerPanel.SetHasClass( "hero_selected", false );
					playerPanel.SetHasClass( "hero_highlighted", true );
				}
				else{
					if (playerInfo.possible_hero_selection == "brewmaster"){
						playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_golmy.png" );
						playerPanel.SetHasClass( "hero_selected", false );
						playerPanel.SetHasClass( "hero_highlighted", true );
					}
					else{
						if (playerInfo.possible_hero_selection == "invoker"){
							playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_zombill.png" );
							playerPanel.SetHasClass( "hero_selected", false );
							playerPanel.SetHasClass( "hero_highlighted", true );
						}
						else{
							if (playerInfo.possible_hero_selection == "rubick"){
								playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_mrus.png" );
								playerPanel.SetHasClass( "hero_selected", false );
								playerPanel.SetHasClass( "hero_highlighted", true );
							}
							else{
								if (playerInfo.possible_hero_selection == "terrorblade"){
									playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_senya.png" );
									playerPanel.SetHasClass( "hero_selected", false );
									playerPanel.SetHasClass( "hero_highlighted", true );
								}
								else{
									if (playerInfo.possible_hero_selection == "riki"){
										playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_sega.png" );
										playerPanel.SetHasClass( "hero_selected", false );
										playerPanel.SetHasClass( "hero_highlighted", true );
									}
									else{
										if (playerInfo.possible_hero_selection == "lion"){
											playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_lev.png" );
											playerPanel.SetHasClass( "hero_selected", false );
											playerPanel.SetHasClass( "hero_highlighted", true );
										}
										else{
											if (playerInfo.possible_hero_selection == "kunkka"){
												playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_vova.png" );
												playerPanel.SetHasClass( "hero_selected", false );
												playerPanel.SetHasClass( "hero_highlighted", true );
											}
											else{
												if (playerInfo.possible_hero_selection == "pudge"){
													playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_step.png" );
													playerPanel.SetHasClass( "hero_selected", false );
													playerPanel.SetHasClass( "hero_highlighted", true );
												}
												else{
													if (playerInfo.possible_hero_selection == "sniper"){
														playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_ivanov.png" );
														playerPanel.SetHasClass( "hero_selected", false );
														playerPanel.SetHasClass( "hero_highlighted", true );
													}
													else{
														if (playerInfo.possible_hero_selection == "meepo"){
															playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_kirill.png" );
															playerPanel.SetHasClass( "hero_selected", false );
															playerPanel.SetHasClass( "hero_highlighted", true );
														}
														else{
															if (playerInfo.possible_hero_selection == "undying"){
																playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_dmb.png" );
																playerPanel.SetHasClass( "hero_selected", false );
																playerPanel.SetHasClass( "hero_highlighted", true );
															}
															else{
																if (playerInfo.possible_hero_selection == "axe"){
																	playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_dima.png" );
																	playerPanel.SetHasClass( "hero_selected", false );
																	playerPanel.SetHasClass( "hero_highlighted", true );
																}
																else{
																	if (playerInfo.possible_hero_selection == "phoenix"){
																		playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_orlov.png" );
																		playerPanel.SetHasClass( "hero_selected", false );
																		playerPanel.SetHasClass( "hero_highlighted", true );
																	}
																	else{
																		if (playerInfo.possible_hero_selection == "monkey_king"){
																			playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_loban.png" );
																			playerPanel.SetHasClass( "hero_selected", false );
																			playerPanel.SetHasClass( "hero_highlighted", true );
																		}
																		else{
																			if (playerInfo.possible_hero_selection == "zuus"){
																				playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_stariy.png" );
																				playerPanel.SetHasClass( "hero_selected", false );
																				playerPanel.SetHasClass( "hero_highlighted", true );
																			}
																			else{
																				if (playerInfo.possible_hero_selection == "tidehunter"){
																					playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_tamaev.png" );
																					playerPanel.SetHasClass( "hero_selected", false );
																					playerPanel.SetHasClass( "hero_highlighted", true );
																				}
																				else{
																					if (playerInfo.possible_hero_selection == "earthshaker"){
																						playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_arsen.png" );
																						playerPanel.SetHasClass( "hero_selected", false );
																						playerPanel.SetHasClass( "hero_highlighted", true );
																					}
																					else{
																						if (playerInfo.possible_hero_selection == "furion"){
																							playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_nix.png" );
																							playerPanel.SetHasClass( "hero_selected", false );
																							playerPanel.SetHasClass( "hero_highlighted", true );
																						}
																						else{
																							if (playerInfo.possible_hero_selection == "antimage"){
																								playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_pirat.png" );
																								playerPanel.SetHasClass( "hero_selected", false );
																								playerPanel.SetHasClass( "hero_highlighted", true );
																							}
																							else{
																								if (playerInfo.possible_hero_selection == "ogre_magi"){
																									playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_zolo.png" );
																									playerPanel.SetHasClass( "hero_selected", false );
																									playerPanel.SetHasClass( "hero_highlighted", true );
																								}
																								else{
																									playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_" + playerInfo.possible_hero_selection + ".png" );
																									playerPanel.SetHasClass( "hero_selected", false );
																									playerPanel.SetHasClass( "hero_highlighted", true );
																								}
																							}
																						}
																					}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
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

