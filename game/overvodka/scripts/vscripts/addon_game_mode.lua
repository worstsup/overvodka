--[[
Overvodka Game Mode
]]

_G.nNEUTRAL_TEAM = 4
_G.nCOUNTDOWNTIMER = 1501

---------------------------------------------------------------------------
-- COverthrowGameMode class
---------------------------------------------------------------------------
if COverthrowGameMode == nil then
	_G.COverthrowGameMode = class({}) -- put COverthrowGameMode in the global scope
end

---------------------------------------------------------------------------
-- Required .lua files
---------------------------------------------------------------------------
require( "events" )
require( "items" )
require( "utility_functions" )
require('timers')
require('utils')
require('server/debug_panel')
require('chat_wheel/chat_wheel')
require('server/server')
require('music_zone_trigger')
require('util/vector_targeting')
require('util/functions')
---------------------------------------------------------------------------
-- Precache
---------------------------------------------------------------------------
function Precache( context )
	--Cache the gold bags
		PrecacheItemByNameSync( "item_bag_of_gold", context )
		PrecacheItemByNameSync( "item_bag_of_gold_2", context )
		PrecacheItemByNameSync( "item_bag_of_gold_bablokrad", context )
		PrecacheResource( "particle", "particles/items2_fx/veil_of_discord.vpcf", context )	

		PrecacheItemByNameSync( "item_treasure_chest", context )

	--Cache the creature models

		if GetMapName() == "overvodka_5x5" then
			PrecacheResource("particle", "particles/base_attacks/ranged_goodguy.vpcf", context)
			PrecacheResource("particle", "particles/base_attacks/ranged_siege_good.vpcf", context)
			PrecacheResource("particle", "particles/base_attacks/ranged_siege_bad.vpcf", context)
			PrecacheResource("particle", "particles/overboss_chalice_splash.vpcf", context)
			PrecacheResource("particle", "particles/sasavot_tower_proj.vpcf", context)
			PrecacheResource("particle", "particles/units/heroes/hero_witchdoctor/witchdoctor_base_attack.vpcf", context)
			PrecacheResource("particle", "particles/sasavot_tower_dest.vpcf", context)
			PrecacheResource("particle", "particles/evelone_tower_dest.vpcf", context)
			PrecacheResource("particle", "particles/evelone_tower_proj.vpcf", context)
			PrecacheResource("particle", "particles/evelone_barracks_dest.vpcf", context)
			PrecacheResource("particle", "particles/econ/items/effigies/status_fx_effigies/base_statue_destruction_gold.vpcf", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_mega.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_flagbearer_mega.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged_mega.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee_mega.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_ranged/lane_dire_ranged_mega.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_melee/creep_bad_flagbearer_mega.vmdl", context)
			PrecacheResource("model", "models/heroes/attachto_ghost/attachto_ghost.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_froglet/n_creep_froglet.vmdl", context)
			PrecacheResource("model", "models/props_gameplay/aegis.vmdl", context)
			PrecacheResource("model", "models/toilet/toilet.vmdl", context)
			PrecacheResource("model", "models/props_gameplay/divine_sentinel/divine_sentinel_cube.vmdl", context)
			PrecacheResource("model", "models/slots/safe/safe.vmdl", context)
			PrecacheResource("model", "models/slots/roulete_table.vmdl", context)
			PrecacheResource("model", "models/slots/tower_slot.vmdl", context)
			PrecacheResource("model", "models/hydrant/cap.vmdl", context)
			PrecacheResource("model", "models/pozhar/pozhar.vmdl", context)
			PrecacheResource("model", "models/hydrant/hydrant.vmdl", context)
			PrecacheResource("model", "models/props_gameplay/rune_water.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ancient_frog/n_creep_ancient_frog_mage.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_ranged/lane_dire_ranged.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_kobold/kobold_c/n_creep_kobold_c.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_thunder_lizard/n_creep_thunder_lizard_small.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_satyr_b/n_creep_satyr_b.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ogre_med/n_creep_ogre_med.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_satyr_spawn_a/n_creep_satyr_spawn_b.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_tadpole/n_creep_tadpole_ranged_v2.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_worg_small/n_creep_worg_small.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_tadpole_c/n_creep_tadpole_c.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_troll_dark_a/n_creep_troll_dark_a.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_beast/n_creep_beast.vmdl", context)
			PrecacheResource("model", "models/creeps/pine_cone/pine_cone.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_forest_trolls/n_creep_forest_troll_berserker.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_tadpole/n_creep_tadpole_v2.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_satyr_c/n_creep_satyr_c.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_kobold/kobold_b/n_creep_kobold_b.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_thunder_lizard/n_creep_thunder_lizard_big.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ogre_lrg/n_creep_ogre_lrg.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_worg_large/n_creep_worg_large.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_kobold/kobold_a/n_creep_kobold_a.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_centaur_med/n_creep_centaur_med.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_vulture_b/n_creep_vulture_b.vmdl", context)
			PrecacheResource("model", "models/creeps/ice_biome/frostbitten/n_creep_frostbitten_swollen01.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_golem_b/n_creep_golem_b.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_centaur_lrg/n_creep_centaur_lrg.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_vulture_a/n_creep_vulture_a.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_troll_dark_b/n_creep_troll_dark_b.vmdl", context)
			PrecacheResource("model", "models/creeps/ice_biome/giant/ice_giant01.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_forest_trolls/n_creep_forest_troll_high_priest.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_black_drake/n_creep_black_drake.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_satyr_spawn_a/n_creep_satyr_spawn_a.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_black_dragon/n_creep_black_dragon.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_furbolg/n_creep_furbolg_disrupter.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_satyr_a/n_creep_satyr_a.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_gnoll/n_creep_gnoll.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_ghost_a/n_creep_ghost_a.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_melee/creep_bad_flagbearer.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_radiant_melee/radiant_flagbearer.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_good_siege/creep_good_siege.vmdl", context)
			PrecacheResource("model", "models/creeps/lane_creeps/creep_bad_siege/creep_bad_siege.vmdl", context)
			PrecacheResource("model", "models/creeps/neutral_creeps/n_creep_froglet/n_creep_froglet_mage.vmdl", context)
		end
		PrecacheResource( "model", "models/props_gameplay/rune_goldxp.vmdl", context)
		PrecacheResource( "soundfile", "soundevents/golden_rain.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golden_rain_announce.vsndevts", context )
		PrecacheResource( "particle", "particles/golden_rain_start.vpcf", context )
		PrecacheResource( "particle", "particles/golden_rain_wave.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/monkey_king/mk_ti9_immortal/mk_ti9_immortal_army_radius.vpcf", context )
		PrecacheResource( "particle", "particles/mk_ti9_immortal_army_radius_b_new.vpcf", context )

		PrecacheUnitByNameSync( "npc_dota_creature_basic_zombie", context )
        PrecacheUnitByNameSync( "npc_dota_creature_berserk_zombie", context )
        PrecacheUnitByNameSync( "npc_dota_treasure_courier", context )
        PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_monkey_king.vsndevts", context)
    	PrecacheResource("soundfile", "soundevents/armature.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/bombardiro.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/bombardiro_plane_sound.vsndevts", context)
		PrecacheResource("particle", "particles/bombardiro_bombs_marker.vpcf", context)
    	PrecacheResource("particle", "particles/units/heroes/hero_gyrocopter/gyro_calldown_first.vpcf", context)
    	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)
    	PrecacheResource("soundfile", "soundevents/armature_crit.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/5opka_start.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/magic_crit.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/elixir_collector.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/elixir_collector_place.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/rocket_launcher.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/udar_sahur.vsndevts", context)
    	PrecacheResource("particle", "particles/armature_strike.vpcf", context)
    	PrecacheResource("particle", "particles/armature_cast.vpcf", context)
		PrecacheResource("particle", "particles/quadrobe_buff.vpcf", context)
		PrecacheResource("particle", "particles/sans_base_attack.vpcf", context)
		PrecacheResource("particle", "particles/econ/events/ti11/duel/dueling_glove_projectile.vpcf", context)
		PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_pugna.vsndevts", context)
    --Cache new particles
		PrecacheResource( "particle", "particles/minion_generator_aura.vpcf", context )
		PrecacheResource( "particle", "soundevents/minion_generator_minion.vsndevts", context )
		PrecacheResource("soundfile", "soundevents/minion_generator_spawn.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/elixir_collector_place.vsndevts", context)
		PrecacheResource( "particle", "particles/units/heroes/hero_vengeful/vengeful_projection_attack.vpcf", context )
		PrecacheResource( "particle", "particles/ui_mouseactions/range_finder_cone.vpcf", context )
       	PrecacheResource( "particle", "particles/econ/events/nexon_hero_compendium_2014/teleport_end_nexon_hero_cp_2014.vpcf", context )
       	PrecacheResource( "particle", "particles/leader/leader_overhead.vpcf", context )
       	PrecacheResource( "particle", "particles/last_hit/last_hit.vpcf", context )
       	PrecacheResource( "particle", "particles/units/heroes/hero_zuus/zeus_taunt_coin.vpcf", context )
       	PrecacheResource( "particle", "particles/addons_gameplay/player_deferred_light.vpcf", context )
       	PrecacheResource( "particle", "particles/items_fx/black_king_bar_avatar.vpcf", context )
       	PrecacheResource( "particle", "particles/treasure_courier_death.vpcf", context )
       	PrecacheResource( "particle", "particles/econ/wards/f2p/f2p_ward/f2p_ward_true_sight_ambient.vpcf", context )
       	PrecacheResource( "particle", "particles/econ/items/lone_druid/lone_druid_cauldron/lone_druid_bear_entangle_dust_cauldron.vpcf", context )
       	PrecacheResource( "particle", "particles/newplayer_fx/npx_landslide_debris.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_queenofpain/queen_scream_of_pain.vpcf", context )
       	PrecacheResource( "particle", "particles/units/heroes/hero_lion/lion_mana_drain.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", context )
		PrecacheResource( "particle", "particles/bloodseeker_rupture_new.vpcf", context)
		PrecacheResource( "particle", "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf", context)
		PrecacheResource( "particle", "particles/ember_spirit_hit_shockwave_new.vpcf", context )
		PrecacheResource( "particle", "particles/dark_seer_punch_glove_attack_new.vpcf", context )
		PrecacheResource( "particle", "particles/generic_gameplay/generic_sleep.vpcf", context )
		PrecacheResource( "particle", "particles/duel/legion_duel_ring_arcana.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root_beam.vpcf", context )
		PrecacheResource( "particle", "particles/earthshaker_arcana_echoslam_start_v2_new.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf", context )
		PrecacheResource( "particle", "particles/neutral_fx/ogre_bruiser_smash.vpcf", context )
		PrecacheResource( "particle", "particles/items2_fx/vindicators_axe_armor.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/drow/drow_arcana/drow_arcana_silenced_v2.vpcf", context )
		PrecacheResource( "particle", "particles/econ/events/fall_2021/blink_dagger_fall_2021_start_lvl2.vpcf", context )
		PrecacheResource( "particle", "particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", context )
		PrecacheResource("particle", "particles/creatures/aghanim/aghanim_blink_warmup.vpcf", context)
   		PrecacheResource("particle", "particles/creatures/aghanim/aghanim_blink_arrival.vpcf", context)
		PrecacheResource( "particle", "particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start_bolt_parent.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/skywrath_mage/skywrath_arcana/skywrath_arcana_rod_of_atos_projectile.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_dialate_v2_debuff.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/juggernaut/jugg_fall20_immortal/jugg_fall20_immortal_healing_ward.vpcf", context )
		PrecacheResource( "particle", "particles/elixir_collector_ambient.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/pugna/pugna_ti10_immortal/pugna_ti10_immortal_life_drain_shard.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_rattletrap/clock_overclock_buff_stun.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/shadow_shaman/ti8_ss_mushroomer_belt/ti8_ss_mushroomer_belt_ambient_shimmer.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/lifestealer/lifestealer_immortal_backbone/lifestealer_immortal_backbone_rage.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_trail.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/zeus/lightning_weapon_fx/zuus_base_attack_immortal_lightning.vpcf", context )
		PrecacheResource( "particle", "particles/overvodka_prime_effect.vpcf", context )
		PrecacheResource( "particle", "particles/rubick_faceless_void_chronosphere_new.vpcf", context )
		PrecacheResource( "particle", "particles/marci_unleash_stack_number_two.vpcf", context )
		PrecacheResource( "particle", "particles/marci_unleash_stack_number_one.vpcf", context )
		PrecacheResource( "particle", "particles/marci_unleash_stack_number_three.vpcf", context )
		PrecacheResource( "particle", "particles/econ/events/compendium_2024/compendium_2024_teleport_endcap_smoke.vpcf", context )
		PrecacheResource( "particle", "particles/rain_fx/econ_snow.vpcf", context )
		PrecacheResource( "particle", "particles/viper_base_attack_frozen.vpcf", context )
		PrecacheResource( "particle", "particles/rostik_attack.vpcf", context )
		PrecacheResource( "particle", "particles/rocket_launcher.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf", context )
		PrecacheResource( "particle", "pparticles/econ/events/ti10/aegis_lvl_1000_ambient_ti10.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_rage.vpcf", context )
		PrecacheResource( "particle", "particles/kotl_ti10_blinding_light_groundring_new.vpcf", context)
		PrecacheResource( "particle", "particles/econ/items/disruptor/disruptor_2022_immortal/disruptor_2022_immortal_static_storm_lightning_start.vpcf", context )
		PrecacheResource( "particle", "particles/base_attacks/ranged_badguy.vpcf", context )
		PrecacheResource( "particle_folder", "particles/neutral_fx", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_alchemist", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_dragon_knight", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_venomancer", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_axe", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_life_stealer", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_dark_willow", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_lion", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_pudge", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_leshrac", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_undying", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_dawnbreaker", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_invoker", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_earthshaker", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_rubick", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_sandking", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_techies", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_silencer", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_faceless_void", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_primal_beast", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_centaur", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_troll_warlord", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_keeper_of_the_light", context )
		PrecacheResource( "particle_folder", "particles/econ/events/ti11/balloon", context )
		PrecacheResource( "model", "models/creeps/item_creeps/i_creep_necro_warrior/necro_warrior.vmdl", context )
		PrecacheResource( "model", "models/creeps/item_creeps/i_creep_necro_archer/necro_archer.vmdl", context )
		PrecacheResource( "model", "models/tung_sahur/tung_tung_tung_sahur.vmdl", context )
		PrecacheResource( "model", "models/bombardiro/bombardiro.vmdl", context )
		PrecacheResource( "model", "models/shrek/shrek.vmdl", context)
		PrecacheResource( "model", "models/speed/ishowspeed.vmdl", context)
		PrecacheResource( "model", "models/griffins/peter.vmdl", context )
		PrecacheResource( "model", "models/griffins/chris.vmdl", context )
		PrecacheResource( "model", "models/coin.vmdl", context )
		PrecacheResource( "model", "models/kachok/kachok.vmdl", context )
		PrecacheResource( "model", "models/stray/stray.vmdl", context )
		PrecacheResource( "model", "models/azazin/azazin.vmdl", context )
		PrecacheResource( "model", "models/bratishkin/bratishkin.vmdl", context )
		PrecacheResource( "model", "tamaev/1_tamaev_normal_normal_1024_lod1.vmdl", context )
		PrecacheResource( "model", "models/evelone/evelone.vmdl", context )
		PrecacheResource( "model", "models/elixir_collector.vmdl", context )
		PrecacheResource( "model", "models/god.vmdl", context )
		PrecacheResource( "model", "bmw/models/heroes/bm/bmwe90.vmdl", context )
		PrecacheResource( "model", "peterka/girlv2.vmdl", context )
		PrecacheResource( "model", "models/dvoreckov/dvoreckov.vmdl", context )
		PrecacheResource( "model", "models/dvoreckov/cigarette.vmdl", context )
		PrecacheResource( "model", "peterka/5opka.vmdl", context )
		PrecacheResource( "model", "pvz/peashooter.vmdl", context )
		PrecacheResource( "model", "pvz/dave.vmdl", context )
		PrecacheResource("particle", "particles/dave_missile.vpcf", context)
    	PrecacheResource("soundfile", "soundevents/dave_scepter.vsndevts", context)
		PrecacheResource( "model", "models/arsen/arsen.vmdl", context )
		PrecacheResource( "model", "models/arsen/arsen_arena.vmdl", context )
		PrecacheResource( "model", "models/props_gameplay/rune_haste01.vmdl", context )
		PrecacheResource( "model", "models/props_gameplay/rune_arcane.vmdl", context )
		PrecacheResource( "model", "models/props_gameplay/rune_doubledamage01.vmdl", context )
		PrecacheResource( "model", "models/props_gameplay/rune_illusion01.vmdl", context )
		PrecacheResource( "model", "models/props_gameplay/rune_invisibility01.vmdl", context )
		PrecacheResource( "model", "models/props_gameplay/rune_regeneration01.vmdl", context )
		PrecacheResource( "model", "models/props_gameplay/rune_shield01.vmdl", context )
		PrecacheResource( "model", "models/props_gameplay/rune_water.vmdl", context )
		PrecacheResource( "model", "models/props_gameplay/dummy/dummy_large.vmdl", context )
		PrecacheResource( "model", "models/props_consumables/balloons/donkey_2022/donkey_2022.vmdl", context )
		PrecacheResource( "model", "models/props_consumables/balloons/donkey_2022/donkey_2022_fx.vmdl", context )
		PrecacheResource( "model", "models/props_consumables/balloons/donkey_dire_2022/donkey_dire_2022.vmdl", context )
		PrecacheResource( "model", "models/props_consumables/balloons/donkey_dire_2022/donkey_dire_2022_fx.vmdl", context )
		PrecacheResource( "model", "vihor/igor_vikhorkov.vmdl", context )
		PrecacheResource( "model", "pvz/peashooter_freeze.vmdl", context )
		PrecacheResource( "model", "pvz/sunflower_defaultflower_mesh.vmdl", context )
		PrecacheResource( "model", "zolo/models/heroes/zol/old_man_to_sk.vmdl", context )
		PrecacheResource( "model", "mellstroy/models/heroes/mell/mellstroy.vmdl", context )
		PrecacheResource( "model", "stariy/models/heroes/stariy/stariy.vmdl", context )
		PrecacheResource( "model", "zolo/models/heroes/zol/model.vmdl", context )
		PrecacheResource( "model", "models/items/alchemist/twin_blades_aurelian/twin_blades_aurelian.vmdl", context )
		PrecacheResource( "model", "macan/macan.vmdl", context )
		PrecacheResource( "model", "models/minion/minion.vmdl", context )
		PrecacheResource( "model", "models/minion/minon_purple.vmdl", context )
		PrecacheResource( "model", "models/items/warlock/golem/hellsworn_golem/hellsworn_golem.vmdl", context )
		PrecacheResource( "model", "models/items/courier/hamster_courier/hamster_courier_lv7.vmdl", context )
		PrecacheResource( "model", "models/heroes/troll_warlord/troll_warlord.vmdl", context )
		PrecacheResource( "particle", "particles/neutral_fx/black_dragon_fireball_lava_a.vpcf", context )
		PrecacheResource( "particle", "particles/chef_base_attack.vpcf", context )
		PrecacheResource( "particle", "particles/minion_base_attack.vpcf", context )
		PrecacheResource( "particle", "particles/minion_base_attack_purple.vpcf", context )
		PrecacheResource( "particle", "particles/skeletonking_hellfireblast_debuff_new.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_monkey_king/monkey_king_taunt_bananas.vpcf", context)
    	PrecacheResource( "soundfile", "soundevents/minion_laugh.vsndevts", context)
		PrecacheResource("particle", "particles/minion_purple_blob.vpcf", context)
    	PrecacheResource("soundfile", "soundevents/minion_purple_blob.vsndevts", context)
		PrecacheResource("particle", "particles/minion_banana.vpcf", context)
    	PrecacheResource("particle", "particles/minion_banana_root.vpcf", context)
    	PrecacheResource("soundfile", "soundevents/minion_banana.vsndevts", context)
    	PrecacheResource("soundfile", "soundevents/minion_banana_hello.vsndevts", context)
		PrecacheResource("particle", "particles/minion_generator_spawn.vpcf", context)

		PrecacheResource( "particle", "particles/units/heroes/hero_slark/slark_essence_shift.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_hand_of_midas.vpcf", context )
		PrecacheResource( "model", "bmw/models/heroes/bm/tofab.vmdl", context )
		PrecacheResource( "model", "models/items/hex/sheep_hex/sheep_hex.vmdl", context )
		PrecacheResource( "model", "models/items/lycan/wolves/watchdog_lycan_summons/watchdog_lycan_summons.vmdl", context )
		PrecacheResource( "model", "models/items/beastmaster/hawk/fotw_eagle/fotw_eagle.vmdl", context )
		PrecacheResource( "model", "models/creeps/mega_greevil/mega_greevil.vmdl", context )
		PrecacheResource( "model", "models/items/courier/carty_dire/carty_dire_flying.vmdl", context )
		PrecacheResource( "model", "nix/model.vmdl", context )
		PrecacheResource( "model", "sans/sans_rig.vmdl", context )
		PrecacheResource( "model", "sans/blaster.vmdl", context )
		PrecacheResource( "model", "models/heroes/mars/mars_soldier.vmdl", context )
		PrecacheResource( "model", "sasavot/model.vmdl", context )
		PrecacheResource( "model", "arthas/untitled_1.vmdl", context )
		PrecacheResource( "model", "nix/pc_nightmare_mushroom.vmdl", context )
		PrecacheResource( "model", "arthas/jet.vmdl", context )
		PrecacheResource( "model", "arthas/papich_maniac.vmdl", context )
		PrecacheResource( "model", "golovach/golovach.vmdl", context )
		PrecacheResource( "model", "ebanko/ebanko.vmdl", context )
		PrecacheResource( "model", "rostik/rostik.vmdl", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/soundevents_conquest.vsndevts", context )
		PrecacheResource( "soundfile", "sounds/weapons/hero/zuus/lightning_bolt.vsnd", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_overthrow.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ui_sounds.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/peterka_shard.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/overvodka_song.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sahur_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/stray_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/azazin_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/bratishkin_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/evelone_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sans_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/arsen_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/bablokrad.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/bablokrad_mellstroy.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/pirat_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/rostik_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/vpiska_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/vihor_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ebanko_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chillguy_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zolo_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/nix_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/vova_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/ilin_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/dima_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/lit_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/artem_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/dave_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/arseni_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/orlov_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/step_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/ivnv_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/tamaev_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/kirill_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/dmb_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/lev_start.vsndevts", context )

		PrecacheResource( "soundfile", "soundevents/ailesh.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zveni.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sho.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/smeh.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/redbull.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/peremena.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/gribochki.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/gniii.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chapman.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/stopan.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/lvinoe.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/gimn.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sobaka.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/razgrom.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/knight.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/skyli.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/baron.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/secret.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/murloc.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/orlov.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/nomoney.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/amamam.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/jackpot.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/normalwin.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/lose.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/shavel.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/mell_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/cond.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/bledina.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zhishi.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zhishi_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/subo.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/litenergy.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/kittymeow.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sigmastaff.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ptichki.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/kitaec.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/veter.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/borsh.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/muha.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/byebye_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/byebye.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/gunnar.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/hamster_announce.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/jump.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/jump_2.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/jump_3.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zolo_zver.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zolo_home.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zolo_zver_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/raif.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/snadom.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/nizkaya.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/mayas.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/stopapupa.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/kachok_duel.vsndevts", context ) -- dont delete
		PrecacheResource( "soundfile", "soundevents/trenbolone.vsndevts", context) -- dont delete
		PrecacheResource( "soundfile", "soundevents/sharik.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zolo_tabletki.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/scar.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/scout.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/smoke_throw.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/molotov_throw.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/grenade_throw.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/grenade_explosion.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/smoke_explosion.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/scar_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/wallhack.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/molotov_fire.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/molotov_burn.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/awp.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/awp_draw.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/tazer.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/oboyudno.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/oboyudno_2.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/vibes.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/klonk.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chillguy_music.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chillguy_photo.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chillguy_r.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chillzone.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_q.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_e.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_r.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_shard.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_q_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_q.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_w.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_r.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_punch.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_innate.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_r_hit.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/smok2.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/mohito_1.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/mohito_2.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_q_clone.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_q_clone_success.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/onehp.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_troll_warlord.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_marci.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lycan.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_primal_beast.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_keeper_of_the_light.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spirit_breaker.vsndevts", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_viper/viper_base_attack.vpcf", context )
		PrecacheResource( "particle", "particles/ti9_banner_fireworksrockets_b_new.vpcf", context )
		PrecacheResource( "particle", "particles/viper_base_attack_new.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", context )
end

function Activate()
	COverthrowGameMode:InitGameMode()
	COverthrowGameMode:CustomSpawnCamps()
end

function COverthrowGameMode:CustomSpawnCamps()
	for name,_ in pairs(spawncamps) do
	spawnunits(name)
	end
end


---------------------------------------------------------------------------
-- Initializer
---------------------------------------------------------------------------
function COverthrowGameMode:InitGameMode()
	print( "Overthrow is loaded." )
	XP_PER_LEVEL_TABLE = {
	0, -- 1
	200, -- 2
	600, -- 3
	1080, -- 4
	1680, -- 5
	2300, -- 6
	2940, -- 7
	3600, -- 8
	4280, -- 9
	5080, -- 10
	5900,  --- 11
	6740,  --- 12
	7640,  --- 13
	8865,  --- 14
	10115, --- 15
	11390, --- 16
	12690, --- 17
	14015, --- 18
	15415, --- 19
	16905, --- 20
	18405, --- 21
	20155, --- 22
	22155, --- 23
	24405, --- 24
	26905, --- 25
	29655, --- 26
	32655, --- 27
	35905, --- 28
	39405, --- 29
	43405, --- 30
	47655, --- 31
	51155, --- 32
	55905, --- 33
	57905, --- 34
	61905, --- 35
	}
  
  	require( "scripts/vscripts/filters" )
  	FilterManager:Init()
	if GetMapName() ~= "overvodka_5x5" then
  		MusicZoneTrigger:Init()
	end
	DebugPanel:Init()

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 35 )
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)

	self.m_bFillWithBots = GlobalSys:CommandLineCheck( "-addon_bots" )
	self.m_bFastPlay = GlobalSys:CommandLineCheck( "-addon_fastplay" )

	self.m_TeamColors = {}
	if GetMapName() ~= "overvodka_5x5" then
		self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }	--		Teal
		self.m_TeamColors[DOTA_TEAM_BADGUYS]  = { 136, 8, 8 }
	end
	self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }	--      Pink
	self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }		--		Orange
	self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }		--		Blue
	self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }	--		Green
	self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }		--		Brown
	self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }	--		Cyan
	self.m_TeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }	--		Olive
	self.m_TeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }	--		Purple

	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end

	self.m_VictoryMessages = {}
	self.m_VictoryMessages[DOTA_TEAM_GOODGUYS] = "#VictoryMessage_GoodGuys"
	self.m_VictoryMessages[DOTA_TEAM_BADGUYS]  = "#VictoryMessage_BadGuys"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_1] = "#VictoryMessage_Custom1"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_2] = "#VictoryMessage_Custom2"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_3] = "#VictoryMessage_Custom3"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_4] = "#VictoryMessage_Custom4"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_5] = "#VictoryMessage_Custom5"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_6] = "#VictoryMessage_Custom6"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_7] = "#VictoryMessage_Custom7"
	self.m_VictoryMessages[DOTA_TEAM_CUSTOM_8] = "#VictoryMessage_Custom8"

	self.m_GatheredShuffledTeams = {}
	self.numSpawnCamps = 6
	self.specialItem = ""
	self.spawnTime = 60
	self.warnTime = 7
	self.nNextSpawnItemNumber = 1
	self.nMaxItemSpawns = 30
	self.hasWarnedSpawn = false
	self.allSpawned = false
	self.leadingTeam = -1
	self.runnerupTeam = -1
	self.leadingTeamScore = 0
	self.runnerupTeamScore = 0
	self.isGameTied = true
	self.countdownEnabled = false
	self.itemSpawnIndex = 1
	self.itemSpawnLocation = Entities:FindByName( nil, "greevil" )
	self.tier1ItemBucket = {}
	self.tier2ItemBucket = {}
	self.tier3ItemBucket = {}
	self.tier4ItemBucket = {}
	self.tier5ItemBucket = {}

	self.itemSpawnLocations = nil
	self.KILLS_TO_WIN_SINGLES = 50
	self.KILLS_TO_WIN_DUOS = 50
	self.KILLS_TO_WIN_TRIOS = 200
	self.KILLS_TO_WIN_QUADS = 50
	self.KILLS_TO_WIN_QUINTS = 50

	self.TEAM_KILLS_TO_WIN = self.KILLS_TO_WIN_SINGLES
	self.CLOSE_TO_VICTORY_THRESHOLD = 5

	self.TEAMS_MISSING = 0
	self.GoldBonusPerTeam = 2
	self.XpBonusPerTeam = 4
	self.MIN_COUNTDOWN_TIME = 900
	self.SOLO_TIME_PER_TEAM = 120
	self.DUO_TIME_PER_TEAM = 300

	self.LeaveTeamEncounterDuration = 5

	self.bFirstBlooded = false

	self.bShowsComeback = false

	self.TeamKills = {}

	---------------------------------------------------------------------------
	
	self:GatherAndRegisterValidTeams()

	GameRules:GetGameModeEntity().COverthrowGameMode = self

	-- Adding Many Players
	if GetMapName() == "overvodka_5x5" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
		self.m_GoldRadiusMin = 300
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 8
	elseif GetMapName() == "temple_quartet" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 4 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 4 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 4 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 4 )
		self.m_GoldRadiusMin = 300
		self.m_GoldRadiusMax = 1400
		self.m_GoldDropPercent = 10
	else
		self.m_GoldRadiusMin = 250
		self.m_GoldRadiusMax = 650
		self.m_GoldDropPercent = 15
	end

	--GameRules:SetCustomGameTeamMaxPlayers( 1, 5 )
	--GameRules:SetCustomGameSetupTimeout( 3 )--Убрать когда нужно будет убрать зрителей

	-- Show the ending scoreboard immediately
	--GameRules:SetCustomGameEndDelay( 0 )
	--GameRules:SetCustomVictoryMessageDuration( 10 )
	if GetMapName() == "overvodka_duo" then
		GameRules:SetCustomGameSetupTimeout( 3 )
	else
		GameRules:SetCustomGameSetupTimeout( 0 )
	end
	if GetMapName() == "overvodka_5x5" then
		GameRules:SetPreGameTime( 90.0 )
		GameRules:SetCustomGameSetupTimeout( 3 )
	else
		GameRules:SetPreGameTime( 10.0 )
	end
	if self.m_bFastPlay then
		GameRules:SetStrategyTime( 1.0 )
	end
	GameRules:SetHeroSelectPenaltyTime( 0.0 )
	GameRules:SetShowcaseTime( 0.0 )
	GameRules:SetIgnoreLobbyTeamsInCustomGame( false )
	GameRules:SetSafeToLeave(true)
	--GameRules:SetHideKillMessageHeaders( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetSuggestAbilitiesEnabled( true )
	GameRules:SetSuggestItemsEnabled( true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_DOUBLEDAMAGE , true ) --Double Damage
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_HASTE, true ) --Haste
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ILLUSION, true ) --Illusion
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_INVISIBILITY, true ) --Invis
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ARCANE, true ) --Arcane
	if GetMapName() == "overvodka_5x5" then
		GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_BOUNTY, true ) --Bounty
		GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_REGENERATION, true ) --Regen
		GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_WATER, true ) -- Water
		GameRules:GetGameModeEntity():SetLoseGoldOnDeath( true )
		GameRules:GetGameModeEntity():SetDefaultStickyItem( "item_tpscroll" )
		GameRules:GetGameModeEntity():SetGiveFreeTPOnDeath( true )
		GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )
		GameRules:GetGameModeEntity():SetDaynightCycleDisabled( false )
		GameRules:GetGameModeEntity():SetDaynightCycleAdvanceRate( 1.0 )
		GameRules:GetGameModeEntity():SetUseDefaultDOTARuneSpawnLogic(true)
		GameRules:SetHideKillMessageHeaders( false )
		GameRules:SetUseUniversalShopMode( false )
		GameRules:SetTimeOfDay( 0.25 )
		GameRules:SetStrategyTime( 20.0 )
	else
		GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_BOUNTY, false ) --Bounty
		GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_REGENERATION, false ) --Regen
		GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride("item_lesh")
		GameRules:GetGameModeEntity():SetDefaultStickyItem( "item_byebye" )
		GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
		GameRules:GetGameModeEntity():SetGiveFreeTPOnDeath( false )
		GameRules:SetHideKillMessageHeaders( true )
		GameRules:SetUseUniversalShopMode( true )
		GameRules:SetStrategyTime( 15.0 )
	end
	GameRules:GetGameModeEntity():SetFountainPercentageHealthRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainPercentageManaRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainConstantManaRegen( 0 )
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter( Dynamic_Wrap( COverthrowGameMode, "BountyRunePickupFilter" ), self )
	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( COverthrowGameMode, "ExecuteOrderFilter" ), self )

	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled( true )
	GameRules:GetGameModeEntity():SetUseTurboCouriers( true )
	GameRules:GetGameModeEntity():SetCanSellAnywhere( true )

	local nTeamSize = GameRules:GetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS )
	GameRules:SetCustomGameBansPerTeam( 1 )
	GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 0.0 )
	if self.m_bFastPlay then
		GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 1.0 )
	end
	GameRules:GetGameModeEntity():SetDraftingHeroPickSelectTimeOverride( 60.0 )

	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( COverthrowGameMode, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( COverthrowGameMode, "OnNPCSpawned" ), self )
	ListenToGameEvent( "dota_on_hero_finish_spawn", Dynamic_Wrap( COverthrowGameMode, "OnHeroFinishSpawn" ), self )
	ListenToGameEvent( "dota_team_kill_credit", Dynamic_Wrap( COverthrowGameMode, 'OnTeamKillCredit' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( COverthrowGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( COverthrowGameMode, "OnItemPickUp"), self )
	ListenToGameEvent( "dota_npc_goal_reached", Dynamic_Wrap( COverthrowGameMode, "OnNpcGoalReached" ), self )
	ListenToGameEvent( "player_disconnect", Dynamic_Wrap( COverthrowGameMode, "OnPlayerDisconnected" ), self )
		Convars:RegisterCommand( "overthrow_force_item_drop", function(...) self:ForceSpawnItem() end, "Force an item drop.", FCVAR_CHEAT )
		Convars:RegisterCommand( "overthrow_force_gold_drop", function(...) self:ForceSpawnGold() end, "Force gold drop.", FCVAR_CHEAT )
		Convars:RegisterCommand( "overthrow_set_timer", function(...) return SetTimer( ... ) end, "Set the timer.", FCVAR_CHEAT )
		Convars:RegisterCommand( "overthrow_force_end_game", function(...) return self:EndGame( DOTA_TEAM_GOODGUYS ) end, "Force the game to end.", FCVAR_CHEAT )
		Convars:RegisterCommand( "overthrow_team_leaved", function(...) 
				local Data = {
					team = 2,
					last_time = GameRules:GetGameTime()+self.LeaveTeamEncounterDuration,
					bonus_gold = self.GoldBonusPerTeam,
					bonus_xp = self.XpBonusPerTeam,
					time_reduce = IsSolo() and self.SOLO_TIME_PER_TEAM or self.DUO_TIME_PER_TEAM,
					missing_teams = self.TEAMS_MISSING
				}
				return CustomGameEventManager:Send_ServerToAllClients( "on_team_leaved", Data ) 
			end, "Show team leave encounter", FCVAR_CHEAT )
		Convars:RegisterCommand( "overthrow_chat_wheel_say", function(...) 
				return CustomGameEventManager:Send_ServerToAllClients("chat_wheel_say_line", {caller_player = 1, item_id = 1})
			end, "Show team leave encounter", FCVAR_CHEAT )
		Convars:SetInt( "dota_server_side_animation_heroesonly", 0 )

	COverthrowGameMode:SetUpFountains()
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 ) 

	-- Spawning monsters
	spawncamps = {}
	for i = 1, self.numSpawnCamps do
		local campname = "camp"..i.."_path_customspawn"
		spawncamps[campname] =
		{
			NumberToSpawn = RandomInt(3,5),
			WaypointName = "camp"..i.."_path_wp1"
		}
	end

	GameRules:SetPostGameLayout( DOTA_POST_GAME_LAYOUT_SINGLE_COLUMN )
	GameRules:SetPostGameColumns( {
		DOTA_POST_GAME_COLUMN_LEVEL,
		DOTA_POST_GAME_COLUMN_ITEMS,
		DOTA_POST_GAME_COLUMN_KILLS,
		DOTA_POST_GAME_COLUMN_DEATHS,
		DOTA_POST_GAME_COLUMN_ASSISTS,
		DOTA_POST_GAME_COLUMN_NET_WORTH,
		DOTA_POST_GAME_COLUMN_DAMAGE,
		DOTA_POST_GAME_COLUMN_HEALING,
	} )
end

function COverthrowGameMode:IncrementTeamHeroKills(TeamID, value)
	if self.TeamKills[TeamID] == nil then
		self.TeamKills[TeamID] = 0
	end

	self.TeamKills[TeamID] = self.TeamKills[TeamID] + value

	CustomNetTables:SetTableValue("globals", "team_".. TeamID .."_kills", {kills=self.TeamKills[TeamID]})
end

function COverthrowGameMode:GetTeamHeroKills(TeamID)
	return self.TeamKills[TeamID] or 0
end

---------------------------------------------------------------------------
-- Set up fountain regen
---------------------------------------------------------------------------
function COverthrowGameMode:SetUpFountains()

	LinkLuaModifier( "modifier_fountain_aura_lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_fountain_aura_effect_lua", LUA_MODIFIER_MOTION_NONE )

	local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
	for _,fountainEnt in pairs( fountainEntities ) do
		fountainEnt:AddNewModifier( fountainEnt, fountainEnt, "modifier_fountain_aura_lua", {} )
	end
end

---------------------------------------------------------------------------
-- Get the color associated with a given teamID
---------------------------------------------------------------------------
function COverthrowGameMode:ColorForTeam( teamID )
	local color = self.m_TeamColors[ teamID ]
	if color == nil then
		color = { 255, 255, 255 } -- default to white
	end
	return color
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function COverthrowGameMode:EndGame( victoryTeam )
	local overBoss = Entities:FindByName( nil, "@overboss" )
	if overBoss then
		local celebrate = overBoss:FindAbilityByName( 'dota_ability_celebrate' )
		if celebrate then
			overBoss:CastAbilityNoTarget( celebrate, -1 )
		end
	end
	local tTeamScores = {}
	for team = DOTA_TEAM_FIRST, (DOTA_TEAM_COUNT-1) do
		tTeamScores[team] = self:GetTeamHeroKills(team)
	end
	GameRules:SetPostGameTeamScores( tTeamScores )
	local sortedTeams = self:GetSortedValidTeams()
	Server:OnGameEnded(sortedTeams, victoryTeam)
	GameRules:SetGameWinner( victoryTeam )
end

function COverthrowGameMode:GetSortedValidTeams()
	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		if PlayerResource:GetNthPlayerIDOnTeam(team, 1) ~= -1 then
			table.insert( sortedTeams, { teamID = team, teamScore = self:GetTeamHeroKills( team ) } )
		end
	end

	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	return sortedTeams
end

function COverthrowGameMode:GetSortedValidActiveTeams()
	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		if PlayerResource:GetNthPlayerIDOnTeam(team, 1) ~= -1 then
			for i = 1, PlayerResource:GetPlayerCountForTeam(team) do
				local PlayerID = PlayerResource:GetNthPlayerIDOnTeam(team, i)
				if PlayerID ~= -1 then
					local Connection = PlayerResource:GetConnectionState(PlayerID)
					local FakeClient = PlayerResource:IsFakeClient(PlayerID)
					local Check = DOTA_CONNECTION_STATE_ABANDONED
					if FakeClient then
						Check = DOTA_CONNECTION_STATE_NOT_YET_CONNECTED
					end
					if Connection ~= Check and Connection ~= DOTA_CONNECTION_STATE_UNKNOWN then
						table.insert( sortedTeams, { teamID = team, teamScore = self:GetTeamHeroKills( team ) } )
						break
					end
				end
			end
		end
	end

	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	return sortedTeams
end

function COverthrowGameMode:GetCountMissingTeams()
	local MaxTeamsCount = #self.m_GatheredShuffledTeams
	local CurrentActiveTeams = #self:GetSortedValidActiveTeams()
	local Diff = MaxTeamsCount - CurrentActiveTeams
	return Diff
end

function COverthrowGameMode:GetValidTeamPlayers()
	local Teams = {}

	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		if PlayerResource:GetNthPlayerIDOnTeam(team, 1) ~= -1 then
			Teams[team] = {}
			for i = 1, PlayerResource:GetPlayerCountForTeam(team) do
				local PlayerID = PlayerResource:GetNthPlayerIDOnTeam(team, i)
				if PlayerID ~= -1 then
					table.insert(Teams[team], PlayerID)
				end
			end
		end
	end

	return Teams
end

function COverthrowGameMode:IsFirstBlooded()
	return self.bFirstBlooded
end

function COverthrowGameMode:OnPlayerDisconnected(event)
	local PlayerID = event.PlayerID
	local Team = PlayerResource:GetTeam(PlayerID)
	local ActiveTeams = self:GetSortedValidActiveTeams()
	local bTeamActive = false
	for _, TeamInfo in ipairs(ActiveTeams) do
		if TeamInfo.teamID == Team then
			bTeamActive = true
			break
		end
	end
	if bTeamActive == true then return end
	print("Team Disconnected: "..Team)
	self.TEAMS_MISSING = self:GetCountMissingTeams()
	local MinusTime = IsSolo() and self.SOLO_TIME_PER_TEAM or self.DUO_TIME_PER_TEAM
	self:ReduceCountdownTimer(1)

	CustomGameEventManager:Send_ServerToAllClients( "on_team_leaved", {
		team = Team, 
		last_time = GameRules:GetGameTime()+self.LeaveTeamEncounterDuration,
		bonus_gold = self.GoldBonusPerTeam,
		bonus_xp = self.XpBonusPerTeam,
		time_reduce = MinusTime,
		missing_teams = self.TEAMS_MISSING
	} )
end

function COverthrowGameMode:ReduceCountdownTimer(nTimes)
	local MinusTime = IsSolo() and self.SOLO_TIME_PER_TEAM or self.DUO_TIME_PER_TEAM
	if _G.nCOUNTDOWNTIMER > self.MIN_COUNTDOWN_TIME then
		_G.nCOUNTDOWNTIMER = math.max(self.MIN_COUNTDOWN_TIME, _G.nCOUNTDOWNTIMER-(MinusTime*nTimes))
	end
end

---------------------------------------------------------------------------
-- Put a label over a player's hero so people know who is on what team
---------------------------------------------------------------------------
function COverthrowGameMode:UpdatePlayerColor( nPlayerID )
	if not PlayerResource:HasSelectedHero( nPlayerID ) then
		return
	end

	local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
	if hero == nil then
		return
	end

	local teamID = PlayerResource:GetTeam( nPlayerID )
	local color = self:ColorForTeam( teamID )
	PlayerResource:SetCustomPlayerColor( nPlayerID, color[1], color[2], color[3] )
end


---------------------------------------------------------------------------
-- Simple scoreboard using debug text
---------------------------------------------------------------------------
function COverthrowGameMode:UpdateScoreboard()
	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		table.insert( sortedTeams, { teamID = team, teamScore = self:GetTeamHeroKills( team ) } )
	end
	
	-- reverse-sort by score
	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	for _, t in pairs( sortedTeams ) do
		local clr = self:ColorForTeam( t.teamID )

		-- Scaleform UI Scoreboard
		local score = 
		{
			team_id = t.teamID,
			team_score = t.teamScore
		}
		FireGameEvent( "score_board", score )
	end
	-- Leader effects (moved from OnTeamKillCredit)
	local leader = sortedTeams[1].teamID
	self.leadingTeam = leader
	self.runnerupTeam = sortedTeams[2].teamID
	self.leadingTeamScore = sortedTeams[1].teamScore
	self.runnerupTeamScore = sortedTeams[2].teamScore
	if sortedTeams[1].teamScore == sortedTeams[2].teamScore then
		self.isGameTied = true
	else
		self.isGameTied = false
	end
	local allHeroes = HeroList:GetAllHeroes()
	for _,entity in pairs( allHeroes) do
		if entity:GetTeamNumber() == leader and sortedTeams[1].teamScore ~= sortedTeams[2].teamScore and GetMapName() ~= "overvodka_5x5" then
			if entity:IsAlive() == true then
				-- Attaching a particle to the leading team heroes
				local existingParticle = entity:Attribute_GetIntValue( "particleID", -1 )
       			if existingParticle == -1 then
       				local particleLeader = ParticleManager:CreateParticle( "particles/leader/leader_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, entity )
					ParticleManager:SetParticleControlEnt( particleLeader, PATTACH_OVERHEAD_FOLLOW, entity, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", entity:GetAbsOrigin(), true )
					entity:Attribute_SetIntValue( "particleID", particleLeader )
				end
			else
				local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
				if particleLeader ~= -1 then
					ParticleManager:DestroyParticle( particleLeader, true )
					entity:DeleteAttribute( "particleID" )
				end
			end
		else
			local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
			if particleLeader ~= -1 then
				ParticleManager:DestroyParticle( particleLeader, true )
				entity:DeleteAttribute( "particleID" )
			end
		end
	end
end

---------------------------------------------------------------------------
-- Update player labels and the scoreboard
---------------------------------------------------------------------------
function COverthrowGameMode:OnThink()
	for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
		self:UpdatePlayerColor( nPlayerID )
	end
	self:UpdateScoreboard()
	if GameRules:IsGamePaused() == true then
        return 1
    end

	if self.countdownEnabled == true then
		CountdownTimer()

		if nCOUNTDOWNTIMER <= 900 and self.bShowsComeback == false then
			self.bShowsComeback = true

			local SortedTeams = self:GetSortedValidActiveTeams()

			CustomNetTables:SetTableValue("globals", "teams_top", SortedTeams)
		end

		if nCOUNTDOWNTIMER == 30 then
			CustomGameEventManager:Send_ServerToAllClients( "timer_alert", {} )
		end
		if nCOUNTDOWNTIMER <= 0 then
			if self.isGameTied == false then
				GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[self.leadingTeam] )
				COverthrowGameMode:EndGame( self.leadingTeam )
				self.countdownEnabled = false
			else
				self.TEAM_KILLS_TO_WIN = self.leadingTeamScore + 1
				local broadcast_killcount = 
				{
					killcount = self.TEAM_KILLS_TO_WIN
				}
				CustomGameEventManager:Send_ServerToAllClients( "overtime_alert", broadcast_killcount )
			end
       	end
	end
	
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		COverthrowGameMode:ThinkGoldDrop()
		COverthrowGameMode:ThinkSpecialItemDrop()
	end

	return 1
end

---------------------------------------------------------------------------
-- Scan the map to see which teams have spawn points
---------------------------------------------------------------------------
function COverthrowGameMode:GatherAndRegisterValidTeams()
	local foundTeams = {}
	local foundTeamsList = {}
	local numTeams
	if GetMapName() ~= "overvodka_5x5" then
		for _, playerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
			foundTeams[  playerStart:GetTeam() ] = true
		end

		numTeams = TableCount(foundTeams)
		print( "GatherValidTeams - Found spawns for a total of " .. numTeams .. " teams" )
		
		for t, _ in pairs( foundTeams ) do
			table.insert( foundTeamsList, t )	
		end

		if numTeams == 0 then
			print( "GatherValidTeams - NO team spawns detected, defaulting to GOOD/BAD" )
			table.insert( foundTeamsList, DOTA_TEAM_GOODGUYS )
			table.insert( foundTeamsList, DOTA_TEAM_BADGUYS )
			numTeams = 2
		end
	else
		table.insert( foundTeamsList, DOTA_TEAM_GOODGUYS )
		table.insert( foundTeamsList, DOTA_TEAM_BADGUYS )
		numTeams = 2
	end


	local maxPlayersPerValidTeam = math.floor( 10 / numTeams )

	self.m_GatheredShuffledTeams = ShuffledList( foundTeamsList )

	print( "Final shuffled team list:" )
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		print( " - " .. team .. " ( " .. GetTeamName( team ) .. " )" )
	end

	print( "Setting up teams:" )
	for team = 0, (DOTA_TEAM_COUNT-1) do
		local maxPlayers = 0
		if ( nil ~= TableFindKey( foundTeamsList, team ) ) then
			maxPlayers = maxPlayersPerValidTeam
		end
		print( " - " .. team .. " ( " .. GetTeamName( team ) .. " ) -> max players = " .. tostring(maxPlayers) )
		GameRules:SetCustomGameTeamMaxPlayers( team, maxPlayers )
	end
end

function COverthrowGameMode:spawncamp(campname)
	spawnunits(campname)
end

function spawnunits(campname)
	local spawndata = spawncamps[campname]
	local NumberToSpawn = spawndata.NumberToSpawn --How many to spawn
    local SpawnLocation = Entities:FindByName( nil, campname )
    local waypointlocation = Entities:FindByName ( nil, spawndata.WaypointName )
	if SpawnLocation == nil then
		return
	end

    local randomCreature = 
    	{
			"basic_zombie",
			"berserk_zombie"
	    }
	local r = randomCreature[RandomInt(1,#randomCreature)]
    for i = 1, NumberToSpawn do
        local creature = CreateUnitByName( "npc_dota_creature_" ..r , SpawnLocation:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_NEUTRALS )
        creature:SetInitialGoalEntity( waypointlocation )
    end
end

--------------------------------------------------------------------------------
-- Event: Filter for inventory full
--------------------------------------------------------------------------------
function COverthrowGameMode:ExecuteOrderFilter( filterTable )
	local orderType = filterTable["order_type"]
	if ( orderType ~= DOTA_UNIT_ORDER_PICKUP_ITEM or filterTable["issuer_player_id_const"] == -1 ) then
		return true
	else
		local item = EntIndexToHScript( filterTable["entindex_target"] )
		if item == nil then
			return true
		end
		local pickedItem = item:GetContainedItem()

		if pickedItem == nil then
			return true
		end
		if pickedItem:GetAbilityName() == "item_treasure_chest" then
			local player = PlayerResource:GetPlayer(filterTable["issuer_player_id_const"])
			local hero = player:GetAssignedHero()

			-- determine if we can scoop the neutral or not
			-- we need either a free backpack slot or a free neutral item slot
			local bAllowPickup = false
			local numBackpackItems = 0
			for nItemSlot = 0,DOTA_ITEM_INVENTORY_SIZE - 1 do 
				local hItem = hero:GetItemInSlot( nItemSlot )
				if hItem and hItem:IsInBackpack() then
					numBackpackItems = numBackpackItems + 1
				end
			end
			if numBackpackItems < 3 then
				bAllowPickup = true
			end

			if bAllowPickup then
				return true
			else
				local position = item:GetAbsOrigin()
				filterTable["position_x"] = position.x
				filterTable["position_y"] = position.y
				filterTable["position_z"] = position.z
				filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
				return true
			end
		end
	end
	return true
end

--------------------------------------------------------------------------------
function COverthrowGameMode:AssignTeams()
	local vecTeamValid = {}
	local vecTeamNeededPlayers = {}
	for nTeam = 0, (DOTA_TEAM_COUNT-1) do
		local nMax = GameRules:GetCustomGameTeamMaxPlayers( nTeam )
		if nMax > 0 then
			vecTeamNeededPlayers[ nTeam ] = nMax
			vecTeamValid[ nTeam ] = true
		else
			vecTeamValid[ nTeam ] = false
		end
	end

	-- loop 1: count up players on each team
	local hPlayers = {}
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:IsValidPlayerID( nPlayerID ) then
			local nTeam = PlayerResource:GetTeam( nPlayerID )
			if vecTeamValid[ nTeam ] == false then
				nTeam = PlayerResource:GetCustomTeamAssignment( nPlayerID )
			end
			--print( "Found player " .. nPlayerID .. " on team " .. nTeam )
			if vecTeamValid[ nTeam ] then
				vecTeamNeededPlayers[ nTeam ] = vecTeamNeededPlayers[ nTeam ] - 1
			else
				table.insert( hPlayers, nPlayerID )
			end
		end
	end

	-- loop 2: assign players. For each player who is on an invalid team,
	-- find the team that has the highest number of needed players
	-- and assign the player to that team
	for _,nPlayerID in pairs( hPlayers ) do
		--print( "Finding team for player " .. nPlayerID )
		local nTeamNumber = -1
		local nHighest = 0
		for nTeam = 0, (DOTA_TEAM_COUNT-1) do
			if vecTeamValid[ nTeam ] then
				local nVal = vecTeamNeededPlayers[ nTeam ]
				if nVal > nHighest then
					--print( "found team " .. nTeam .. " with needed " .. nVal .. " but highest was only " .. nHighest )
					nHighest = nVal
					nTeamNumber = nTeam
				end
			end
		end
		if nTeamNumber > 0 then
			PlayerResource:SetCustomTeamAssignment( nPlayerID, nTeamNumber )
			vecTeamNeededPlayers[ nTeamNumber ] = vecTeamNeededPlayers[ nTeamNumber ] - 1
		end
	end
	if self.m_bFillWithBots == true then
		GameRules:BotPopulate()
	end
end