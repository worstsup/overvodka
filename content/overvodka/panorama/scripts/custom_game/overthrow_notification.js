"use strict";
// Notifications for Overthrow

function OnItemWillSpawn( msg )
{
//	$.Msg( "OnItemWillSpawn: ", msg );
	$.GetContextPanel().SetHasClass( "item_will_spawn", true );
	$.GetContextPanel().SetHasClass( "item_has_spawned", false );
	GameUI.PingMinimapAtLocation( msg.spawn_location );
	$( "#AlertMessage_Chest" ).html = true;
	$( "#AlertMessage_Delivery" ).html = true;
	$( "#AlertMessage_Chest" ).text = $.Localize( "#Chest" );
	$( "#AlertMessage_Delivery" ).text = $.Localize( "#ItemWillSpawn" );

	$.Schedule( 3, ClearItemSpawnMessage );
}

function OnItemHasSpawned( msg )
{
//	$.Msg( "OnItemHasSpawned: ", msg );
	$.GetContextPanel().SetHasClass( "item_will_spawn", false );
	$.GetContextPanel().SetHasClass( "item_has_spawned", true );
	$( "#AlertMessage_Chest" ).html = true;
	$( "#AlertMessage_Delivery" ).html = true;
	$( "#AlertMessage_Chest" ).text = $.Localize( "#HamsterWillSpawn" );
	$( "#AlertMessage_Delivery" ).text = $.Localize( "#ItemHasSpawned" );
				
	$.Schedule( 5, ClearItemSpawnMessage );
}

function OnHamsterSpawn( msg ) {
	$.GetContextPanel().SetHasClass( "item_will_spawn", false );
	$.GetContextPanel().SetHasClass( "item_has_spawned", true );
	$( "#AlertMessage_Chest" ).html = true;
	$( "#AlertMessage_Delivery" ).html = true;
	$( "#AlertMessage_Chest" ).text = $.Localize( "#HamsterSpawnAnnounce" );
	$( "#AlertMessage_Delivery" ).text = $.Localize( "#HamsterSpawn" );

	$.Schedule( 10, ClearItemSpawnMessage );
}
		
function ClearItemSpawnMessage()
{
	$.GetContextPanel().SetHasClass( "item_will_spawn", false );
	$.GetContextPanel().SetHasClass( "item_has_spawned", false );
	$( "#AlertMessage" ).text = "";
}

//==============================================================
//==============================================================
function OnItemDrop( msg )
{
//	$.Msg( "recent_item_drop: ", msg );
//	$.Msg( msg.hero_id )
	$.GetContextPanel().SetHasClass( "recent_item_drop", true );

	$( "#PickupMessage_Hero_Text" ).SetDialogVariable( "hero_id", GameUI.GetUnitNameLocalized( msg.hero_id ) );
	$( "#PickupMessage_Item_Text" ).SetDialogVariable( "item_id", $.Localize( "#DOTA_Tooltip_Ability_"+msg.dropped_item ) );
	let hero = "unassigned"
	if (msg.hero_id == "npc_dota_hero_sniper")
	{
		hero = "npc_dota_hero_ivanov"
	}
	if (msg.hero_id == "npc_dota_hero_bounty_hunter")
	{
		hero = "npc_dota_hero_mellstroy"
	}
	if (msg.hero_id == "npc_dota_hero_meepo")
	{
		hero = "npc_dota_hero_kirill"
	}
	if (msg.hero_id == "npc_dota_hero_lion")
	{
		hero = "npc_dota_hero_lev"
	}
	if (msg.hero_id == "npc_dota_hero_ursa")
	{
		hero = "npc_dota_hero_litvin"
	}
	if (msg.hero_id == "npc_dota_hero_riki")
	{
		hero = "npc_dota_hero_sega"
	}
	if (msg.hero_id == "npc_dota_hero_terrorblade")
	{
		hero = "npc_dota_hero_senya"
	}	
	if (msg.hero_id == "npc_dota_hero_tinker")
	{
		hero = "npc_dota_hero_ilin"
	}	
	if (msg.hero_id == "npc_dota_hero_pudge")
	{
		hero = "npc_dota_hero_step"
	}	
	if (msg.hero_id == "npc_dota_hero_brewmaster")
	{
		hero = "npc_dota_hero_golmy"
	}	
	if (msg.hero_id == "npc_dota_hero_phoenix")
	{
		hero = "npc_dota_hero_orlov"
	}	
	if (msg.hero_id == "npc_dota_hero_axe")
	{
		hero = "npc_dota_hero_dima"
	}	
	if (msg.hero_id == "npc_dota_hero_undying")
	{
		hero = "npc_dota_hero_dmb"
	}	
	if (msg.hero_id == "npc_dota_hero_invoker")
	{
		hero = "npc_dota_hero_zombill"
	}	
	if (msg.hero_id == "npc_dota_hero_kunkka")
	{
		hero = "npc_dota_hero_vova"
	}	
	if (msg.hero_id == "npc_dota_hero_rubick")
	{
		hero = "npc_dota_hero_mrus"
	}	
	if (msg.hero_id == "npc_dota_hero_monkey_king")
	{
		hero = "npc_dota_hero_loban"
	}
	if (msg.hero_id == "npc_dota_hero_zuus")
	{
		hero = "npc_dota_hero_stariy"
	}
	if (msg.hero_id == "npc_dota_hero_tidehunter")
	{
		hero = "npc_dota_hero_tamaev"
	}
	if (msg.hero_id == "npc_dota_hero_earthshaker")
	{
		hero = "npc_dota_hero_arsen"
	}
	if (msg.hero_id == "npc_dota_hero_furion")
	{
		hero = "npc_dota_hero_nix"
	}
	if (msg.hero_id == "npc_dota_hero_antimage")
	{
		hero = "npc_dota_hero_pirat"
	}
	if (msg.hero_id == "npc_dota_hero_ogre_magi")
	{
		hero = "npc_dota_hero_zolo"
	}
	var hero_image_name = "file://{images}/heroes/" + hero + ".png";
	$( "#PickupMessage_Hero" ).SetImage( hero_image_name );

	var chest_image_name = "file://{images}/econ/tools/gift_lockless_luckbox.png";
	$( "#PickupMessage_Chest" ).SetImage( chest_image_name );
			
	var item_image_name = "file://{images}/items/" + msg.dropped_item.replace( "item_", "" ) + ".png"
	$( "#PickupMessage_Item" ).SetImage( item_image_name );

	$.Schedule( 5, ClearDropMessage );
}
		
function ClearDropMessage()
{
	$.GetContextPanel().SetHasClass( "recent_item_drop", false );
}

//==============================================================
//==============================================================
function AlertTimer( data )
{
//	$.Msg( "AlertTimer: ", data );
	var remainingText = "";
	
	if ( ( data.timer_minute_01 == 2 ) && ( data.timer_second_10 == 0 ) && ( data.timer_second_01 == 0 ) )
	{
		remainingText = "2 MINUTES";
		$.GetContextPanel().SetHasClass( "time_notification", true );
		$( "#AlertTimer_Text" ).text = remainingText;
		Game.EmitSound("Tutorial.TaskProgress");
	}
	if ( ( data.timer_minute_01 == 1 ) && ( data.timer_second_10 == 0 ) && ( data.timer_second_01 == 0 ) )
	{
		remainingText = "60 SECONDS";
		$.GetContextPanel().SetHasClass( "time_notification", true );
		$( "#AlertTimer_Text" ).text = remainingText;
		Game.EmitSound("Tutorial.TaskProgress");
	}
	if ( ( data.timer_second_10 == 5 ) && ( data.timer_second_01 == 5 ) )
	{
		$.GetContextPanel().SetHasClass( "time_notification", false );
	}
	if ( ( data.timer_minute_01 == 0 ) && ( data.timer_second_10 == 3 ) && ( data.timer_second_01 == 0 ) )
	{
		remainingText = "30 SECONDS";
		$.GetContextPanel().SetHasClass( "time_notification", true );
		$( "#AlertTimer_Text" ).text = remainingText;
		Game.EmitSound("Tutorial.TaskProgress");
	}
	if ( ( data.timer_minute_01 == 0 ) && ( data.timer_second_10 == 2 ) && ( data.timer_second_01 == 5 ) )
	{
		$.GetContextPanel().SetHasClass( "time_notification", false );
	}
	if ( ( data.timer_minute_01 == 0 ) && ( data.timer_second_10 == 1 ) && ( data.timer_second_01 == 0 ) )
	{
		remainingText = "10";
		$.GetContextPanel().SetHasClass( "time_notification", true );
		$.GetContextPanel().SetHasClass( "time_countdown", true );
		$( "#AlertTimer_Text" ).text = remainingText;
		Game.EmitSound("Tutorial.TaskProgress");
	}
	if ( ( data.timer_minute_01 == 0 ) && ( data.timer_second_10 == 0 ) && ( data.timer_second_01 <= 9 ) )
	{
		remainingText += data.timer_second_01;
		$( "#AlertTimer_Text" ).text = remainingText;
		Game.EmitSound("Tutorial.TaskProgress");
	}
//	if ( ( data.timer_minute_01 == 0 ) && ( data.timer_second_10 == 0 ) && ( data.timer_second_01 <= 0 ) )
//	{
//		$( "#AlertTimer_Text" ).text = $.Localize( "#Overtime" );
//		Game.EmitSound("General.PingAttack");
//	}
}

//==============================================================
//==============================================================
function OnOvertimeStart( data )
{
//	$.Msg( "Overtime Goal: ", data );
	var new_score_to_win = data.killcount;
	var overtimeText = "";
	overtimeText += new_score_to_win
	$.GetContextPanel().SetHasClass( "overtime_visible", true );
	$( "#Overtime_Goal" ).text = overtimeText;
}

//==============================================================
//==============================================================
function OnLeaderKilled( msg )
{
//	$.Msg( "leader_has_been_killed: ", msg );

	$.GetContextPanel().SetHasClass( "leader_has_been_killed", true );

	$( "#KillMessage_Hero" ).SetDialogVariable( "hero_id", GameUI.GetUnitNameLocalized( msg.hero_id ) );

	$.Schedule( 5, ClearKillMessage );
}
		
function ClearKillMessage()
{
	$.GetContextPanel().SetHasClass( "leader_has_been_killed", false );
}

(function () {
	GameEvents.Subscribe( "item_will_spawn", OnItemWillSpawn );
	GameEvents.Subscribe( "item_has_spawned", OnItemHasSpawned );
	GameEvents.Subscribe( "hamster_spawn", OnHamsterSpawn );
	GameEvents.Subscribe( "overthrow_item_drop", OnItemDrop );
    GameEvents.Subscribe( "time_remaining", AlertTimer );
    GameEvents.Subscribe( "overtime_alert", OnOvertimeStart );
    GameEvents.Subscribe( "kill_alert", OnLeaderKilled );
})();

