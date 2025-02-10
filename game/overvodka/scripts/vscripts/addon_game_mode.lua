--[[
Overthrow Game Mode
]]

_G.nNEUTRAL_TEAM = 4
_G.nCOUNTDOWNTIMER = 1501

---------------------------------------------------------------------------
-- COverthrowGameMode class
---------------------------------------------------------------------------
if COverthrowGameMode == nil then
	_G.COverthrowGameMode = class({}) -- put COverthrowGameMode in the global scope
	--refer to: http://stackoverflow.com/questions/6586145/lua-require-with-global-local
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
		PrecacheUnitByNameSync( "npc_dota_creature_basic_zombie", context )
        PrecacheUnitByNameSync( "npc_dota_creature_berserk_zombie", context )
        PrecacheUnitByNameSync( "npc_dota_treasure_courier", context )
        PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_monkey_king.vsndevts", context)
    	PrecacheResource("soundfile", "soundevents/armature.vsndevts", context)
    	PrecacheResource("soundfile", "soundevents/armature_crit.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/5opka_start.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/magic_crit.vsndevts", context)
    	PrecacheResource("particle", "particles/armature_strike.vpcf", context)
    	PrecacheResource("particle", "particles/armature_cast.vpcf", context)
		PrecacheResource("particle", "particles/sans_base_attack.vpcf", context)
    --Cache new particles
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
		PrecacheResource( "particle", "particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", context)
		PrecacheResource( "particle", "particles/bloodseeker_rupture_new.vpcf", context)
		PrecacheResource( "particle", "particles/primal_beast_onslaught_range_finder_new.vpcf", context)
		PrecacheResource( "particle", "particles/dark_willow_willowisp_ambient_new.vpcf", context)
		PrecacheResource( "particle", "particles/dark_willow_wisp_aoe_cast_new.vpcf", context)
		PrecacheResource( "particle", "particles/dark_willow_wisp_aoe_new.vpcf", context)
		PrecacheResource( "particle", "particles/dark_willow_willowisp_base_attack_new.vpcf", context)
		PrecacheResource( "particle", "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf", context)
		PrecacheResource( "particle", "particles/axe_ti9_call_ring_new_1.vpcf", context )
		PrecacheResource( "particle", "particles/ember_spirit_hit_shockwave_new.vpcf", context )
		PrecacheResource( "particle", "particles/dark_seer_punch_glove_attack_new.vpcf", context )
		PrecacheResource( "particle", "particles/generic_gameplay/generic_sleep.vpcf", context )
		PrecacheResource( "particle", "particles/underlord_firestorm_pre_new.vpcf", context )
		PrecacheResource( "particle", "particles/abyssal_underlord_firestorm_wave_new.vpcf", context )
		PrecacheResource( "particle", "particles/duel/legion_duel_ring_arcana.vpcf", context )
		PrecacheResource( "particle", "particles/doom_bringer_doom_new.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_root_beam.vpcf", context )
		PrecacheResource( "particle", "particles/earthshaker_arcana_echoslam_start_v2_new.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf", context )
		PrecacheResource( "particle", "particles/neutral_fx/ogre_bruiser_smash.vpcf", context )
		PrecacheResource( "particle", "particles/items2_fx/vindicators_axe_armor.vpcf", context )
		PrecacheResource( "particle", "particles/faceless_void_arcana_deny_symbol_question_new.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_marci/marci_unleash_buff.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/drow/drow_arcana/drow_arcana_silenced_v2.vpcf", context )
		PrecacheResource( "particle", "particles/ogre_magi_arcana_egg_run_new.vpcf", context )
		PrecacheResource( "particle", "particles/earthshaker_arcana_totem_cast_clouds_new.vpcf", context )
		PrecacheResource( "particle", "particles/events/muerta_ofrenda/muerta_death_reckoning_flames_green.vpcf", context )
		PrecacheResource( "particle", "particles/econ/events/fall_2021/blink_dagger_fall_2021_start_lvl2.vpcf", context )
		PrecacheResource( "particle", "particles/econ/events/fall_2021/blink_dagger_fall_2021_end_lvl2.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start_bolt_parent.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_disarm_ti6_debuff.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/skywrath_mage/skywrath_arcana/skywrath_arcana_rod_of_atos_projectile.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_dialate_v2_debuff.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_crimson_missile_explosion.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_dialate_combined.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/juggernaut/jugg_fall20_immortal/jugg_fall20_immortal_healing_ward.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_rattletrap/clock_overclock_buff_stun.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/shadow_shaman/ti8_ss_mushroomer_belt/ti8_ss_mushroomer_belt_ambient_shimmer.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/lifestealer/lifestealer_immortal_backbone/lifestealer_immortal_backbone_rage.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/razor/razor_arcana/razor_arcana_static_link.vpcf", context )
		PrecacheResource( "particle", "particles/centaur_ti6_warstomp_gold_new.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/troll_warlord/troll_ti10_shoulder/troll_ti10_whirling_axe_ranged.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf", context )
		PrecacheResource( "particle", "particles/ti9_jungle_axe_attack_blur_counterhelix_new.vpcf", context )
		PrecacheResource( "particle", "particles/econ/events/fall_2022/radiance_target_fall2022.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_start_ti7_golden.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/antimage/antimage_ti7_golden/antimage_blink_ti7_golden_end.vpcf", context )
		PrecacheResource( "particle", "particles/radiance_owner_fall2022_new.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_antimage/antimage_manabreak_slow.vpcf", context )
		PrecacheResource( "particle", "particles/antimage_manavoid_basher_cast_gold_new.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", context )
		PrecacheResource( "particle", "particles/bloodseeker_bloodrage_eztzhok_new.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_trail.vpcf", context )
		PrecacheResource( "particle", "particles/zuus_base_attack_new.vpcf", context )
		PrecacheResource( "particle", "particles/c4_explosion.vpcf", context )
		PrecacheResource( "particle", "particles/doom_bringer_doom_ring_bomb.vpcf", context )
		PrecacheResource( "particle", "particles/econ/events/summer_2021/summer_2021_emblem_effect.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf", context )
		PrecacheResource( "particle", "particles/rubick_faceless_void_chronosphere_new.vpcf", context )
		PrecacheResource( "particle", "particles/marci_unleash_stack_number_two.vpcf", context )
		PrecacheResource( "particle", "particles/marci_unleash_stack_number_one.vpcf", context )
		PrecacheResource( "particle", "particles/marci_unleash_stack_number_three.vpcf", context )
		PrecacheResource( "particle", "particles/dev/library/base_dust_hit_smoke.vpcf", context )
		PrecacheResource( "particle", "particles/slark_ti6_pounce_trail_new.vpcf", context)
		PrecacheResource( "particle", "particles/slark_ti6_pounce_start_new.vpcf", context)
		PrecacheResource( "particle", "particles/slark_ti6_pounce_ground_new.vpcf", context)
		PrecacheResource( "particle", "particles/slark_ti6_pounce_leash_new.vpcf", context)
		PrecacheResource( "particle", "particles/pa_persona_shard_fan_of_knives_blades_new.vpcf", context)
		PrecacheResource( "particle", "particles/pangolier_shard_rollup_magic_immune_nix.vpcf", context )
		PrecacheResource( "particle", "particles/rain_fx/econ_snow.vpcf", context )
		PrecacheResource( "particle", "particles/viper_base_attack_frozen.vpcf", context )
		PrecacheResource( "particle", "particles/rostik_attack.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_snow_arcana1_shard.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/vengeful/vengeful_arcana/vengeful_arcana_nether_swap_v3_explosion.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_rage.vpcf", context )
		PrecacheResource( "particle", "particles/econ/courier/courier_greevil_black/courier_greevil_black_ambient_3.vpcf", context)
		PrecacheResource( "particle", "particles/kotl_ti10_blinding_light_groundring_new.vpcf", context)
		PrecacheResource( "particle", "particles/econ/items/disruptor/disruptor_2022_immortal/disruptor_2022_immortal_static_storm_lightning_start.vpcf", context )
		PrecacheResource("particle_folder",  "particles/units/heroes/hero_alchemist", context )
	--Cache particles for traps
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_dragon_knight", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_venomancer", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_axe", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_life_stealer", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_dark_willow", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_lion", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_medusa", context )
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
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_dark_willow", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_lone_druid", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_centaur", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_troll_warlord", context )
		PrecacheResource( "particle_folder", "particles/units/heroes/hero_keeper_of_the_light", context )
		PrecacheResource( "particle_folder", "particles/econ/events/ti11/balloon", context )
		PrecacheResource( "model", "bmw/models/heroes/bm/bmwe90.vmdl", context )
		PrecacheResource( "model", "peterka/girlv2.vmdl", context )
		PrecacheResource( "model", "peterka/5opka.vmdl", context )
		PrecacheResource( "model", "pvz/peashooter.vmdl", context )
		PrecacheResource( "model", "pvz/dave.vmdl", context )
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
		PrecacheResource( "model", "models/items/axe/ti9_jungle_axe/axe_bare.vmdl", context )
		PrecacheResource( "model", "models/heroes/tidehunter/tidehunter.vmdl", context )
		PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_harpy_a/n_creep_harpy_a.vmdl", context )
		PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_harpy_b/n_creep_harpy_b.vmdl", context )
		PrecacheResource( "model", "models/items/warlock/golem/hellsworn_golem/hellsworn_golem.vmdl", context )
		PrecacheResource( "model", "models/items/courier/hamster_courier/hamster_courier_lv4.vmdl", context )
		PrecacheResource( "model", "models/heroes/troll_warlord/troll_warlord.vmdl", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf", context )
		PrecacheResource( "particle", "particles/neutral_fx/black_dragon_fireball_lava_a.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_slark/slark_essence_shift.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_hand_of_midas.vpcf", context )
		PrecacheResource( "model", "bmw/models/heroes/bm/tofab.vmdl", context )
		PrecacheResource( "model", "models/items/hex/sheep_hex/sheep_hex.vmdl", context )
		PrecacheResource( "model", "models/items/lycan/wolves/watchdog_lycan_summons/watchdog_lycan_summons.vmdl", context )
		PrecacheResource( "model", "models/items/beastmaster/hawk/fotw_eagle/fotw_eagle.vmdl", context )
		PrecacheResource( "model", "models/creeps/mega_greevil/mega_greevil.vmdl", context )
		PrecacheResource( "model", "models/items/courier/carty_dire/carty_dire_flying.vmdl", context )
		PrecacheResource( "model", "cheater/models/heroes/cheat/c4_1.vmdl", context )
		PrecacheResource( "model", "nix/model.vmdl", context )
		PrecacheResource( "model", "sans/sans_rig.vmdl", context )
		PrecacheResource( "model", "sans/blaster.vmdl", context )

		PrecacheResource( "model", "sasavot/model.vmdl", context )
		PrecacheResource( "model", "arthas/untitled_1.vmdl", context )
		PrecacheResource( "model", "nix/pc_nightmare_mushroom.vmdl", context )
		PrecacheResource( "model", "arthas/jet.vmdl", context )
		PrecacheResource( "model", "arthas/papich_maniac.vmdl", context )
		PrecacheResource( "model", "golovach/golovach.vmdl", context )
		PrecacheResource( "model", "ebanko/ebanko.vmdl", context )
		PrecacheResource( "model", "rostik/rostik.vmdl", context )
		
	--Cache sounds for traps
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/soundevents_conquest.vsndevts", context )
		PrecacheResource( "soundfile", "sounds/weapons/hero/zuus/lightning_bolt.vsnd", context )

	-- Cache overthrow-specific sounds
		PrecacheResource( "soundfile", "soundevents/game_sounds_overthrow.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ui_sounds.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/vpis.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/peterka_shard.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/babulka.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/sans_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/arsen_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/bablokrad.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/bablokrad_mellstroy.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/pirat_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/rostik_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/vpiska_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/nix_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/vova_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/ilin_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/dima_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/lit_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/artem_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/dave_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/arseni_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/vovchik.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/orlov_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/step_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/sega_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/ivnv_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/tamaev_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/kirill_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/mru_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/laban_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/dmb_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/lev_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/ailesh.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/drunk.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/razbil.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/unitazik.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/uberi.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/tsts.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ejovik.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/serega.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/zizi.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/vkusno.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/legend.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/shish.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/fof.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ebi_menya.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ya_tebya.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/kakao.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ebanul_moroz.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zima_holoda.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/tyaga.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/parit.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/nepar.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ivn.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zveni.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/dvoika.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/polic.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/yeban.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/baran.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/suii.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sho.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/freak.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/smeh.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/otec.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/redbull.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/peremena.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/segasuka.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/star.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/gribochki.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/opasvo.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/opasvo_1.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/gniii.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chapman.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/gennadiy_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/gennadiy.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/penal.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/blue.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/kipil.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/rotik.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/hehe.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/dimon.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/pubg.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ebalo.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/suda.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasi.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/prov.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chto.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/blya.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/komp.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/stavka.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/stopan.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/siga.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/cheza.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/lvinoe.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zavod.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ezda.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/bandoleros.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/glox.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/med.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ulei.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/kirik.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/govor.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sdvg.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/gimn.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sobaka.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/razgrom.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/knight.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/skyli.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/tetris.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/baron.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/secret.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/murloc.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/orlov.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/fruits.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/nomoney.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/amamam.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/jackpot.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/normalwin.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/lose.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/shavel.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/biznes.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/mell_start.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/cond.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/bledina.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zhishi.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zhishi_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/subo.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/litenergy.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/kittymeow.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sigmastaff.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/stariy_ult.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/stariy_ult_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/old_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ptichki.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/kitaec.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/veter.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/borsh.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/muha.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/yo.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/stariy_bred.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/byebye_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/byebye.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/dogon.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ashab_oi.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/slushay.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/rocket.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/rocket_hit.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ashab_car.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ashab_train.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/konchai.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/testosteron.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/tgk.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/baza.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/semya.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/gunnar.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/skiter.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/hamster_announce.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/nix_rus.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/serega_blink.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/serega_stop.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/serega_sven.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/jump.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/jump_2.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/jump_3.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zolo_zver.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zolo_home.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zolo_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zolo_zver_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/raif.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/snadom.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/nizkaya.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/mayas.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/stopapupa.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sharik.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zolo_tabletki.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/scar.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/scout.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/privik.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/zanovo.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/brat.vsndevts", context )
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
		PrecacheResource( "soundfile", "soundevents/c4_activate.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/c4.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/c4_defused.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/bomb_defusing.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/bomb_planted.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/oboyudno.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/oboyudno_2.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/vibes.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/klonk.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chillguy_music.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chillguy_photo.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chillguy_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chillguy_r.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/chillzone.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_q.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_e.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_r.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_shard.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/sasavot_q_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_q.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_w.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_e_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_e.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_e_fail.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_r.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_punch.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_innate.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_r_hit.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/smok2.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/mohito_1.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/mohito_2.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/question1.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/question2.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/question3.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_w.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_q_clone.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_q_clone_success.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_e_fly.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_e_plane.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_e_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_e_end.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_r_spawn.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_r_appear.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_e_plane_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_r_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_r_end.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_innate_1.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_innate_2.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_innate_3.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_w_clone.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_e_clone_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_e_clone_exp.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/papich_e_clone_success.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/golovach_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/onehp.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/ebanko_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/dave_ambient_1.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/dave_ambient_2.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/dave_loonboon.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/vihor_e.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/vihor_w.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/vihor_start.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_troll_warlord.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_marci.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lycan.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_keeper_of_the_light.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spirit_breaker.vsndevts", context )
		PrecacheResource( "particle", "particles/econ/items/huskar/huskar_ti8/huskar_ti8_shoulder_heal.vpcf", context )
		PrecacheResource( "particle", "particles/invoker_chaos_meteor_dave.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_viper/viper_base_attack.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/crystal_maiden/ti7_immortal_shoulder/cm_ti7_immortal_frostbite.vpcf", context )
		PrecacheResource( "particle", "particles/ti9_banner_fireworksrockets_b_new.vpcf", context )
		PrecacheResource( "particle", "particles/viper_base_attack_new.vpcf", context )
		PrecacheResource( "particle", "particles/ancient_apparition_ice_blast_initial_ti5_new.vpcf", context )
		PrecacheResource( "particle", "particles/shredder_whirling_death_new.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_crownfall_immortal/bloodseeker_crownfall_immortal_rupture.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/dark_willow/dark_willow_immortal_2021/dw_2021_willow_wisp_spell_impact_filler_smoke.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/sven/sven_ti10_helmet/sven_ti10_helmet_gods_strength.vpcf", context )
		PrecacheResource( "particle", "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", context )
		PrecacheResource( "particle", "particles/econ/items/omniknight/omni_crimson_witness_2021/omniknight_crimson_witness_2021_degen_aura_debuff.vpcf", context )
		PrecacheResource( "soundfile", "soundevents/myak.vsndevts", context )
end

function Activate()
	-- Create our game mode and initialize it
	COverthrowGameMode:InitGameMode()
	-- Custom Spawn
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
    3940, -- 7	 
    4600, -- 8
    5280, -- 9
    6080, -- 10
	6900,  --- 11
	7740,  --- 12
	8640,  --- 13
	9865,  --- 14
	11115, --- 15
	12390, --- 16
	13690, --- 17
	15015, --- 18
	16415, --- 19
	17905, --- 20
	19405, --- 21
	21155, --- 22
	23155, --- 23
	25405, --- 24
	27905, --- 25
	30655, --- 26
	33655, --- 27
	36905, --- 28
	40405, --- 29
	44405, --- 30
	48655, --- 31
	52155, --- 32
	56905, --- 33
	58905, --- 34
	62905, --- 35
  }
  
  	require( "scripts/vscripts/filters" )
  	FilterManager:Init()
  	MusicZoneTrigger:Init()
	DebugPanel:Init()

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 35 )
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
	GameRules:GetGameModeEntity():SetTPScrollSlotItemOverride("item_lesh")
--	CustomNetTables:SetTableValue( "test", "value 1", {} );
--	CustomNetTables:SetTableValue( "test", "value 2", { a = 1, b = 2 } );

	self.m_bFillWithBots = GlobalSys:CommandLineCheck( "-addon_bots" )
	self.m_bFastPlay = GlobalSys:CommandLineCheck( "-addon_fastplay" )

	self.m_TeamColors = {}
	self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }	--		Teal
	self.m_TeamColors[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }		--		Yellow
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
	self.KILLS_TO_WIN_TRIOS = 35
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
	if GetMapName() == "desert_quintet" then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 5 )
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

	-- GameRules:SetCustomGameTeamMaxPlayers( 1, 5 )

	--GameRules:SetCustomGameSetupTimeout( 3 )--Убрать когда нужно будет убрать зрителей

	-- Show the ending scoreboard immediately
	GameRules:SetCustomGameEndDelay( 0 )
	GameRules:SetCustomVictoryMessageDuration( 10 )
	if GetMapName() == "desert_duo" then
		GameRules:SetCustomGameSetupTimeout( 3 )
	else
		GameRules:SetCustomGameSetupTimeout( 0 )
	end
	GameRules:SetPreGameTime( 10.0 )
	GameRules:SetStrategyTime( 20.0 )
	if self.m_bFastPlay then
		GameRules:SetStrategyTime( 1.0 )
	end
	GameRules:SetHeroSelectPenaltyTime( 0.0 )
	GameRules:SetShowcaseTime( 0.0 )
	GameRules:SetIgnoreLobbyTeamsInCustomGame( false )
	--GameRules:SetHideKillMessageHeaders( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:SetHideKillMessageHeaders( true )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetSuggestAbilitiesEnabled( true )
	GameRules:SetSuggestItemsEnabled( true )
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_DOUBLEDAMAGE , true ) --Double Damage
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_HASTE, true ) --Haste
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ILLUSION, true ) --Illusion
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_INVISIBILITY, true ) --Invis
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_REGENERATION, false ) --Regen
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_ARCANE, true ) --Arcane
	GameRules:GetGameModeEntity():SetRuneEnabled( DOTA_RUNE_BOUNTY, false ) --Bounty
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	GameRules:GetGameModeEntity():SetFountainPercentageHealthRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainPercentageManaRegen( 0 )
	GameRules:GetGameModeEntity():SetFountainConstantManaRegen( 0 )
	GameRules:GetGameModeEntity():SetGiveFreeTPOnDeath( false )
	GameRules:GetGameModeEntity():SetDefaultStickyItem( "item_byebye" )
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter( Dynamic_Wrap( COverthrowGameMode, "BountyRunePickupFilter" ), self )
	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( COverthrowGameMode, "ExecuteOrderFilter" ), self )


	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled( true )
	GameRules:GetGameModeEntity():SetUseTurboCouriers( true )
	GameRules:GetGameModeEntity():SetCanSellAnywhere( true )

	local nTeamSize = GameRules:GetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS )
	--print( '^^^Setting BANS PER TEAM to Team Size = ' .. nTeamSize )
	GameRules:SetCustomGameBansPerTeam( 1 )
	GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 0.0 )
	if self.m_bFastPlay then
		GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 1.0 )
	end
	GameRules:GetGameModeEntity():SetDraftingHeroPickSelectTimeOverride( 40.0 )

	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( COverthrowGameMode, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( COverthrowGameMode, "OnNPCSpawned" ), self )
	ListenToGameEvent( "dota_on_hero_finish_spawn", Dynamic_Wrap( COverthrowGameMode, "OnHeroFinishSpawn" ), self )
	ListenToGameEvent( "dota_team_kill_credit", Dynamic_Wrap( COverthrowGameMode, 'OnTeamKillCredit' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( COverthrowGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( COverthrowGameMode, "OnItemPickUp"), self )
	ListenToGameEvent( "dota_npc_goal_reached", Dynamic_Wrap( COverthrowGameMode, "OnNpcGoalReached" ), self )
	ListenToGameEvent("player_disconnect", Dynamic_Wrap( COverthrowGameMode, "OnPlayerDisconnected" ), self )

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
		--print("fountain unit " .. tostring( fountainEnt ) )
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

	Server:OnGameEnded(sortedTeams)

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
	--print("Leader = " .. leader)
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
		if entity:GetTeamNumber() == leader and sortedTeams[1].teamScore ~= sortedTeams[2].teamScore then
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
	-- Stop thinking if game is paused
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
			--Check to see if there's a tie
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
		--Spawn Gold Bags
		COverthrowGameMode:ThinkGoldDrop()
		COverthrowGameMode:ThinkSpecialItemDrop()
	end

	return 1
end

---------------------------------------------------------------------------
-- Scan the map to see which teams have spawn points
---------------------------------------------------------------------------
function COverthrowGameMode:GatherAndRegisterValidTeams()
--	print( "GatherValidTeams:" )

	local foundTeams = {}
	for _, playerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
		foundTeams[  playerStart:GetTeam() ] = true
	end

	local numTeams = TableCount(foundTeams)
	print( "GatherValidTeams - Found spawns for a total of " .. numTeams .. " teams" )
	
	local foundTeamsList = {}
	for t, _ in pairs( foundTeams ) do
		table.insert( foundTeamsList, t )	
	end

	if numTeams == 0 then
		print( "GatherValidTeams - NO team spawns detected, defaulting to GOOD/BAD" )
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

-- Spawning individual camps
function COverthrowGameMode:spawncamp(campname)
	spawnunits(campname)
end

-- Simple Custom Spawn
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
	--print(r)
    for i = 1, NumberToSpawn do
        local creature = CreateUnitByName( "npc_dota_creature_" ..r , SpawnLocation:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_NEUTRALS )
        --print ("Spawning Camps")
        creature:SetInitialGoalEntity( waypointlocation )
    end
end

--------------------------------------------------------------------------------
-- Event: Filter for inventory full
--------------------------------------------------------------------------------
function COverthrowGameMode:ExecuteOrderFilter( filterTable )
	--[[
	for k, v in pairs( filterTable ) do
		print("EO: " .. k .. " " .. tostring(v) )
	end
	]]

	local orderType = filterTable["order_type"]
	if ( orderType ~= DOTA_UNIT_ORDER_PICKUP_ITEM or filterTable["issuer_player_id_const"] == -1 ) then
		return true
	else
		local item = EntIndexToHScript( filterTable["entindex_target"] )
		if item == nil then
			return true
		end
		local pickedItem = item:GetContainedItem()

		--print(pickedItem:GetAbilityName())
		if pickedItem == nil then
			return true
		end
		if pickedItem:GetAbilityName() == "item_treasure_chest" then
			local player = PlayerResource:GetPlayer(filterTable["issuer_player_id_const"])
			local hero = player:GetAssignedHero()

			-- determine if we can scoop the neutral or not
			-- we need either a free backpack slot or a free neutral item slot
			local bAllowPickup = false
			local hNeutralItem = hero:GetItemInSlot( DOTA_ITEM_NEUTRAL_SLOT )
			if hNeutralItem == nil then
				bAllowPickup = true
				--print( '^^^Empty neutral slot!' )
			else
				local numBackpackItems = 0
				for nItemSlot = 0,DOTA_ITEM_INVENTORY_SIZE - 1 do 
					local hItem = hero:GetItemInSlot( nItemSlot )
					if hItem and hItem:IsInBackpack() then
						numBackpackItems = numBackpackItems + 1
					end
				end
				--print( '^^^Backpack slots = ' .. numBackpackItems )
				if numBackpackItems < 3 then
					bAllowPickup = true
				end
			end		

			if bAllowPickup then
				--print("inventory has space")
				return true
			else
				--print("Moving to target instead")
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
	--print( "Assigning teams" )
	local vecTeamValid = {}
	local vecTeamNeededPlayers = {}
	for nTeam = 0, (DOTA_TEAM_COUNT-1) do
		local nMax = GameRules:GetCustomGameTeamMaxPlayers( nTeam )
		if nMax > 0 then
			--print( "Found team " .. nTeam .. " with max players " .. nMax )
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