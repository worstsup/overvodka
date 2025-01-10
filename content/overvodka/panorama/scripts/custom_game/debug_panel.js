var Utils = GameUI.CustomUIConfig().Utils;
var Constants = GameUI.CustomUIConfig().Constants;
var DebugPanelWindow = {};
const LocalPID = Players.GetLocalPlayer()
$.Msg("Initialize debug panel")

function Init()
{
	let contextPanel = $.GetContextPanel();
	let parent = contextPanel.GetParent();
	let customRoot = parent.GetParent();
	let hudRoot = customRoot.GetParent().FindChild( 'HUDElements' );
	let menuButtons = hudRoot.FindChild( 'MenuButtons' );
	menuButtons.AddClass( "HeroDemo" );

	$.RegisterEventHandler( 'DOTAUIHeroPickerHeroSelected', $( '#SelectHeroContainer' ), SwitchToNewHero );
	let combatLog = menuButtons.FindChildTraverse("ToggleCombatLogButton");
	combatLog.style.visibility = "collapse";

	$.RegisterEventHandler( 'DOTAUIHeroPickerHeroSelected', $( '#SelectBotContainer' ), SwitchToNewBot);

	RMBInterctions();
}

Init();

function RMBInterctions()
{
	let contextPanel = $.GetContextPanel();
	let parent = contextPanel.GetParent();
	let customRoot = parent.GetParent();
	let hudRoot = customRoot.GetParent().FindChild( 'HUDElements' );

	// RMB scepter interactions
	let aghanimScepter = hudRoot.FindChildTraverse("AghsStatusScepterContainer")
	if (aghanimScepter) {aghanimScepter.SetPanelEvent('oncontextmenu', AddScepterToHero)}
	let aghanimShard = hudRoot.FindChildTraverse("AghsStatusShard")
	if (aghanimShard) {aghanimShard.SetPanelEvent('oncontextmenu', AddShardToHero)}


}

function ToggleHeroPicker( bMainHero )
{
	let heroPickerOpen = $( '#SelectHeroContainer' ).BHasClass("HeroPickerVisible")
	HideAllAdditionalPanels();
	$( '#SelectHeroContainer' ).SetHasClass( 'PickMainHero', bMainHero );
	$( '#SelectHeroContainer' ).SetHasClass('HeroPickerVisible', !heroPickerOpen);
	if(!heroPickerOpen == true) {
		$( "#SelectHeroContainer" ).FindChildTraverse( "HeroSearchTextEntry" ).text = "";
		$( "#SelectHeroContainer" ).FindChildTraverse( "HeroSearchTextEntry" ).SetFocus();
	}
	Game.EmitSound( "UI.Button.Pressed" );
}

function ToggleBotPicker(){
	let heroPickerOpen = $( '#SelectBotContainer' ).BHasClass("HeroPickerVisible")
	HideAllAdditionalPanels();
	$( '#SelectBotContainer' ).SetHasClass( 'PickMainHero', false );
	$( '#SelectBotContainer' ).SetHasClass('HeroPickerVisible', !heroPickerOpen);
	if(!heroPickerOpen == true) {
		$( "#SelectBotContainer" ).FindChildTraverse( "HeroSearchTextEntry" ).text = "";
		$( "#SelectBotContainer" ).FindChildTraverse( "HeroSearchTextEntry" ).SetFocus();
	}
	Game.EmitSound( "UI.Button.Pressed" );
}

function EscapeHeroPickerSearch()
{
	$( '#SelectHeroContainer' ).SetHasClass('HeroPickerVisible', !$( '#SelectHeroContainer' ).BHasClass("HeroPickerVisible"));
}

function CloseHeroPicker()
{
	$( '#SelectHeroContainer' ).RemoveClass("HeroPickerVisible");
}

function CloseBotPicker()
{
	$( '#SelectBotContainer' ).RemoveClass("HeroPickerVisible");
}

function SwitchToNewBot(nHeroID)
{
	Game.EmitSound( "UI.Button.Pressed" );

	$.Msg( 'Hero = ' + nHeroID );

	GameEvents.SendCustomGameEventToServer("debug_panel_set_bot", { id: nHeroID});

	$( '#SelectBotContainer' ).RemoveClass( 'PickMainHero' );
	CloseBotPicker();
}

function SwitchToNewHero( nHeroID )
{
	Game.EmitSound( "UI.Button.Pressed" );

	$.Msg( 'Hero = ' + nHeroID );

	GameEvents.SendCustomGameEventToServer("debug_panel_set_hero", { id: nHeroID});

	$( '#SelectHeroContainer' ).RemoveClass( 'PickMainHero' );
	CloseHeroPicker();
}


function OnSetSpawnHeroID( event_data )
{
	$.Msg( "OnSetSpawnHeroID: ", event_data );
	var HeroPickerImage = $( '#HeroPickerImage' );
	if ( HeroPickerImage != null )
	{
		HeroPickerImage.SetImage( "file://{images}/heroes/" + GetOvervodkaHeroName(event_data.hero_name) + ".png" );
	}

	var SpawnHeroButton = $( '#SpawnHeroButton' );
	if ( SpawnHeroButton != null )
	{
		$.Msg( 'HERO NAME = ' + event_data.hero_name );
		SpawnHeroButton.SetDialogVariable( "hero_name", $.Localize( '#'+event_data.hero_name ) );
	}
}
GameEvents.Subscribe( "debug_panel_set_hero_response", OnSetSpawnHeroID );

function OnSetSpawnBotID( event_data )
{
	$.Msg( "OnSetSpawnBotID: ", event_data );
	var HeroPickerImage = $( '#BotPickerImage' );
	if ( HeroPickerImage != null )
	{
		HeroPickerImage.SetImage( "file://{images}/heroes/" + GetOvervodkaHeroName(event_data.hero_name) + ".png" );
	}

	var SpawnHeroButton = $( '#SpawnBotButton' );
	if ( SpawnHeroButton != null )
	{
		$.Msg( 'HERO NAME = ' + event_data.hero_name );
		SpawnHeroButton.SetDialogVariable( "hero_name", $.Localize( '#'+event_data.hero_name ) );
	}
}
GameEvents.Subscribe( "debug_panel_set_bot_response", OnSetSpawnBotID );

function SpawnBot(){
	let selectedTeam = $("#BotSpawnerTeam").GetSelected();
	let team = DOTATeam_t[selectedTeam.text];
	if(team == null) {
		team = DOTATeam_t.DOTA_TEAM_GOODGUYS
	}

	GameEvents.SendCustomGameEventToServer("debug_panel_create_bot", {team:team});
	Game.EmitSound( "UI.Button.Pressed" );
}

function CreateDummy()
{
	GameEvents.SendCustomGameEventToServer("debug_panel_create_dummy", {});
	Game.EmitSound( "UI.Button.Pressed" );
}

function DestroyDummy()
{
	GameEvents.SendCustomGameEventToServer("debug_panel_destroy_dummy", {});
	Game.EmitSound( "UI.Button.Pressed" );
}

function SwitchRunesDisplay()
{
	let displayOpen = $( '#RunesContainer' ).BHasClass("RunesListVisible")
	HideAllAdditionalPanels();
	$( '#RunesContainer' ).SetHasClass( 'RunesListVisible', !displayOpen);
	Game.EmitSound( "UI.Button.Pressed" );
}

function CloseRunesDisplay()
{
	$( '#RunesContainer' ).RemoveClass( 'RunesListVisible' );
	Game.EmitSound( "UI.Button.Pressed" );
}

function AdjustHeroLevel(lvl, increase) {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_adjust_hero_level", {
			unit: SelectedUnit,
			lvl : lvl,
			increase : increase
		});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function AdjustHeroStats(type, value) {
	let convertedType = Attributes[type]
	if(convertedType == null) {
		return;
	}
	GameEvents.SendCustomGameEventToServer("debug_panel_adjust_hero_stats", {
		type : convertedType,
		value : value
	});
	Game.EmitSound( "UI.Button.Pressed" );
}

function AddScepterToHero() {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_add_scepter_to_hero", {unit:SelectedUnit});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function AddShardToHero() {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_add_shard_to_hero", {unit:SelectedUnit});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function SwitchInvulOnHero() {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_switch_invul_on_hero", {unit:SelectedUnit});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function SwitchFlyMode() {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_switch_fly_on_hero", {unit:SelectedUnit});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function SwitchGraveOnHero() {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_switch_grave_on_hero", {unit:SelectedUnit});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function SwitchVisionOnTeam() {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_switch_vision_on_hero", {unit:SelectedUnit});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function OnKickPlayerRequest() {
	GameEvents.SendCustomGameEventToServer("debug_panel_kick_player", {
		target : Players.GetLocalPlayerPortraitUnit()
	});
	Game.EmitSound( "UI.Button.Pressed" );
}

function OnRemoveUnitRequest() {
	$.Msg("Hero entityIndex =" + Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()) + "GetSelectedEntities = " + Players.GetSelectedEntities(Players.GetLocalPlayer()));

	GameEvents.SendCustomGameEventToServer("debug_panel_remove_unit", {
		target : Players.GetLocalPlayerPortraitUnit()
	});
	Game.EmitSound( "UI.Button.Pressed" );
}

function OnWTFTogglePressed() {
	let check = $( '#FreeSpellsButton' ).checked
	GameEvents.SendCustomGameEventToServer("debug_panel_wtf_toggle", {
		isActive : check
	});
	Game.EmitSound( "UI.Button.Pressed" );
}

function OnTitleStatusPressed() {
	let check = $( '#TitleStatusButton' ).checked
	GameEvents.SendCustomGameEventToServer("debug_panel_switch_title_status", {
		isActive : check
	});
	Game.EmitSound( "UI.Button.Pressed" );
}

function OnRefreshAbilitiesRequest() {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_refresh_abilities", {unit: SelectedUnit});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function OnHurtMeBadPressed() {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_hurt_me_bad", {
			unit : SelectedUnit
		});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function OnKillPressed(bForceKill) {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_kill", {unit: SelectedUnit, force: bForceKill});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function OnRemoveItemsOnGroundPressed() {
	GameEvents.SendCustomGameEventToServer("debug_panel_remove_items_on_ground", {});
	Game.EmitSound( "UI.Button.Pressed" );
}

function OnRespawnPressed() {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_respawn_hero", {unit: SelectedUnit});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}


function OnHostTimeScaleSliderValueChanged()
{
	var sliderValue = $( '#HostTimescaleSlider' ).value;
	$( '#HostTimescaleLabel' ).text = "Скорость времени (" + sliderValue.toFixed(1) + ")";
	GameEvents.SendCustomGameEventToServer("debug_panel_set_time_scale", {value : sliderValue});
}

function OnReloadScriptsRequest() {
	GameEvents.SendCustomGameEventToServer("debug_panel_reload_scripts", {});
	Game.EmitSound( "UI.Button.Pressed" );
}

function OnRestartRequest(){
	GameEvents.SendCustomGameEventToServer("debug_panel_restart", {});
	Game.EmitSound( "UI.Button.Pressed" );
}

function OnTeleportRequest() {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		let point_x = GameUI.GetCameraLookAtPosition()[0]
		let point_y = GameUI.GetCameraLookAtPosition()[1]
		let point_z = GameUI.GetCameraLookAtPosition()[2]
		GameEvents.SendCustomGameEventToServer("debug_panel_teleport", {unit: SelectedUnit, point_x : point_x, point_y : point_y, point_z : point_z});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function OnSetGoldRequest(value) {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		GameEvents.SendCustomGameEventToServer("debug_panel_set_gold", {unit: SelectedUnit, gold: value});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

function OnChangeGoldRequest(bool) {
	let SelectedUnit = Players.GetLocalPlayerPortraitUnit()
	if(SelectedUnit != -1){
		let value = parseInt($("#GoldTextEntry").text);
		if (isNaN(value)) {
			value = 0
		}
		if (!bool) {
			value = value * -1
		}
		value = Math.floor(value)

		GameEvents.SendCustomGameEventToServer("debug_panel_change_gold", {unit: SelectedUnit, gold: value});
		Game.EmitSound( "UI.Button.Pressed" );
	}
}

const LOG_LEVEL_INFO = 0
const LOG_LEVEL_ERROR = 1
const LOG_LEVEL_SUCCESS = 2

//function OnTestsResultData(kv) {
//	for (const [_, error] of Object.entries(kv.data)) {
//		let panel = $.CreatePanel("Label", $("#TestsDataJournal"), "")
//		panel.BLoadLayoutSnippet("LabelWithHTML");
//        let preSymbol = "<font color='white'>* </font>";
//        if(error.level == LOG_LEVEL_ERROR) {
//            preSymbol = "<font color='red'>X </font>";
//        }
//        if(error.level == LOG_LEVEL_SUCCESS) {
//            preSymbol = "<font color='green'>V </font>";
//        }
//        panel.text = preSymbol + error.text;
//    }
//}

//GameEvents.Subscribe( "debug_panel_on_tests_data", OnTestsResultData );

function CloseTestsDataDisplay()
{
	$( '#TestsDataContainer' ).SetHasClass( 'TestsDataVisible', false);
	Game.EmitSound( "UI.Button.Pressed" );
}

function SwitchBossSpawnerDisplay() {
	let displayOpen = $( '#BossSpawnerContainer' ).BHasClass("BossSpawnerVisible")
	HideAllAdditionalPanels();
	$( '#BossSpawnerContainer' ).SetHasClass( 'BossSpawnerVisible', !displayOpen);
	Game.EmitSound( "UI.Button.Pressed" );
}

function CloseBossSpawnerContainer() {
	$( '#BossSpawnerContainer' ).SetHasClass( 'BossSpawnerVisible', false);
	Game.EmitSound( "UI.Button.Pressed" );
}

//function OnBossSpawnerData(kv) {
//    let parent = $("#BossSpawnerList");
//    parent.RemoveAndDeleteChildren();
//	for (const [waveIndex, waveData] of Object.entries(kv.boss_spawner)) {
//        for (const [waveBossNumber, waveBoss] of Object.entries(waveData)) {
//            let panel = $.CreatePanel("Panel", parent, "")
//            panel.BLoadLayoutSnippet("ButtonRowSnippet");
//            let buttonLabel = panel.FindChildTraverse("ButtonLabel")
//            buttonLabel.text = waveBoss["boss_name"] + " (" + waveIndex +  "-" + waveBossNumber + ")";
//            panel.SetPanelEvent('onactivate', function() {
//                GameEvents.SendCustomGameEventToServer("debug_panel_spawn_lane_boss", {
//                    waveNumber : waveIndex,
//                    index : waveBossNumber
//                })
//            })
//        }
//    }
//}

//GameEvents.Subscribe( "debug_panel_kv_data", OnBossSpawnerData );

function HideAllAdditionalPanels() {
	CloseHeroPicker();
	CloseBotPicker();
	CloseUnitSpawnerContainer();
	CloseItemSpawnerContainer();
	CloseAbilitiesSpawnerContainer();
	$.DispatchEvent("DropInputFocus");
}


function SwitchUnitSpawnerDisplay() {
	let displayOpen = $( '#UnitSpawnerContainer' ).BHasClass("UnitSpawnerVisible")
	HideAllAdditionalPanels();
	$( '#UnitSpawnerContainer' ).SetHasClass( 'UnitSpawnerVisible', !displayOpen);
	if (!displayOpen) {
		$('#UnitSpawnerContainer').FindChildTraverse("UnitSpawnerName").text = "";
		$('#UnitSpawnerContainer').FindChildTraverse("UnitSpawnerName").SetFocus();
	}
	else {
		$.DispatchEvent("DropInputFocus");
	}
	Game.EmitSound( "UI.Button.Pressed" );
}

function CloseUnitSpawnerContainer() {
	$( '#UnitSpawnerContainer' ).SetHasClass( 'UnitSpawnerVisible', false);
	Game.EmitSound( "UI.Button.Pressed" );
}

function SwitchItemSpawnerDisplay() {
	let displayOpen = $( '#ItemSpawnerContainer' ).BHasClass("ItemSpawnerVisible")
	HideAllAdditionalPanels();
	$( '#ItemSpawnerContainer' ).SetHasClass( 'ItemSpawnerVisible', !displayOpen);
	if (!displayOpen) {
		$('#ItemSpawnerContainer').FindChildTraverse("ItemSpawnerName").text = "";
		$('#ItemSpawnerContainer').FindChildTraverse("ItemSpawnerName").SetFocus();
	}
	else {
		$.DispatchEvent("DropInputFocus");
	}
	Game.EmitSound( "UI.Button.Pressed" );
}

function CloseItemSpawnerContainer() {
	$( '#ItemSpawnerContainer' ).SetHasClass( 'ItemSpawnerVisible', false);
	Game.EmitSound( "UI.Button.Pressed" );
}

function SwitchAbilitiesSpawnerDisplay() {
	let displayOpen = $('#AbilitiesSpawnerContainer').BHasClass("AbilitiesSpawnerVisible")
	HideAllAdditionalPanels();
	$('#AbilitiesSpawnerContainer').SetHasClass( 'AbilitiesSpawnerVisible', !displayOpen);
	if (!displayOpen) {
		$('#AbilitiesSpawnerContainer').FindChildTraverse("AbilitySpawnerName").text = "";
		$('#AbilitiesSpawnerContainer').FindChildTraverse("AbilitySpawnerName").SetFocus();
	}
	else {
		$.DispatchEvent("DropInputFocus");
	}
	Game.EmitSound( "UI.Button.Pressed" );
}

function CloseAbilitiesSpawnerContainer() {
	$( '#AbilitiesSpawnerContainer' ).SetHasClass( 'AbilitiesSpawnerVisible', false);
	Game.EmitSound( "UI.Button.Pressed" );
}

function HideUselessItems() {
	let checkbox = $("#HideUselessItemsButton").checked
	if (checkbox == false) return;
	let ItemSpawnerList = $("#ItemSpawnerList");
	for(var i = 0; i < ItemSpawnerList.GetChildCount(); i++) {
		Item = ItemSpawnerList.GetChild(i)
		if (Item.markedIsUseless) {
			Item.style.visibility = checkbox ? "collapse" : "visible";
		}
	}
}

function OnUnitSpawnerUnitNameFilterChanged() {
	let filter = $("#UnitSpawnerName");
	if(filter._oldInput == filter.text) {
		return;
	}
	filter._oldInput = filter.text;
	let list = $("#UnitSpawnerList");
	for(var i = 0; i < list.GetChildCount(); i++) {
		var spawnButton = list.GetChild(i)
		let unitName = spawnButton._name.toLowerCase()
		let localizedUnitName = $.Localize("#"+unitName).toLowerCase()

		let filterText = filter.text
	//	let searchWords = filterText.trim().toLowerCase().split(/\s+/)
	//	let regexPattern = new RegExp(searchWords.map(word => `(?=.*${word})`).join(''), 'i')
	//	let visible = regexPattern.test(spawnButton._name) || regexPattern.test($.Localize("#"+spawnButton._name))
		let visible = unitName.includes(filterText.toLowerCase()) || localizedUnitName.includes(filterText.toLowerCase())

		spawnButton.style.visibility = visible ? "visible" : "collapse";
	}
}

function OnItemSpawnerUnitNameFilterChanged() {
	let filter = $("#ItemSpawnerName");
	if(filter._oldInput == filter.text) {
		return;
	}
	filter._oldInput = filter.text;
	let list = $("#ItemSpawnerList");
	for(var i = 0; i < list.GetChildCount(); i++) {
		let Item = list.GetChild(i);
		let itemInfo = Item.FindChild("ItemNameInfo");
		let filterText = filter.text;
		let localizedItemName = itemInfo.FindChild("LocalizedItemName").text.toLowerCase();
		let codeItemName = itemInfo.FindChild("CodeItemName").text.toLowerCase();

	//	let searchWords = filterText.trim().toLowerCase().split(/\s+/)
	//	let regexPattern = new RegExp(searchWords.map(word => `(?=.*${word})`).join(''), 'i')
	//	let visible = regexPattern.test(localizedItemName) || regexPattern.test(codeItemName)
		let visible = codeItemName.includes(filterText.toLowerCase()) || localizedItemName.includes(filterText.toLowerCase())

		Item.style.visibility = visible ? "visible" : "collapse"
	}
	HideUselessItems();
}

function OnAbilitiesSpawnerUnitNameFilterChanged() {
	let filter = $("#AbilitySpawnerName");
	if(filter._oldInput == filter.text) {
		return;
	}
	filter._oldInput = filter.text;
	let list = $("#AbilitiesSpawnerList");
	for(let i = 0; i < list.GetChildCount(); i++) {
		let spawnButton = list.GetChild(i);
		let filterText = filter.text;
		let abilityName = spawnButton._AbilityName.toLowerCase()
		let localizedAbilityName = $.Localize("#DOTA_Tooltip_Ability_" + abilityName)

	//	let searchWords = filterText.trim().toLowerCase().split(/\s+/)
	//	let regexPattern = new RegExp(searchWords.map(word => `(?=.*${word})`).join(''), 'i')
	//	let visible = regexPattern.test(abilityName) || regexPattern.test(localizedAbilityName)
		let visible = abilityName.includes(filterText.toLowerCase()) || localizedAbilityName.includes(filterText.toLowerCase())

	//	spawnButton.style.visibility = visible ? "visible" : "collapse"
		spawnButton.style.visibility = (visible > 0) ? "visible" : "collapse"
	}
}

let awaitFunction = function() {
	OnUnitSpawnerUnitNameFilterChanged();
	OnItemSpawnerUnitNameFilterChanged();
	OnAbilitiesSpawnerUnitNameFilterChanged();
	$.Schedule(0.25, awaitFunction);
}
awaitFunction();

function SendUnitSpawnerRequest(unitName) {
	// $.Msg($("#UnitSpawnerTeam"))
	// $.Msg($("#UnitSpawnerTeam").GetSelected())
	let selectedTeam = $("#UnitSpawnerTeam").GetSelected();
	let team = DOTATeam_t[selectedTeam.text];
	if(team == null) {
		team = DOTATeam_t.DOTA_TEAM_GOODGUYS
	}
	let count = parseInt($("#UnitSpawnerCount").text);
	if(isNaN(count)) {
		count = 1;
	}
	// let selectedType = $("#UnitSpawnerType").GetSelected();
	// let creepType = ConvertCreepTypeToEnumValue(selectedType.id);
	GameEvents.SendCustomGameEventToServer("debug_panel_spawn_unit", {
		unitName : unitName,
		team : team,
		count : count,
		// type : creepType
	})
}

function OnKVData(kv) {
	let parent = $("#UnitSpawnerList");
	parent.RemoveAndDeleteChildren();
	for (const [_, unitName] of Object.entries(kv.units)) {
		let panel = $.CreatePanel("Panel", parent, "")
		panel.BLoadLayoutSnippet("ButtonRowSnippet");
		let buttonLabel = panel.FindChildTraverse("ButtonLabel")
		buttonLabel.text = $.Localize("#" + unitName);
		panel._name = buttonLabel.text + unitName;
		panel.SetPanelEvent('onactivate', function() {
			SendUnitSpawnerRequest(unitName);
		});
	}

	parent = $("#ItemSpawnerList");
	parent.RemoveAndDeleteChildren();
	for (const [_, itemName] of Object.entries(kv.items)) {

		let itemInList = $.CreatePanel("Panel", parent, ""); //Создание пустой панели
		itemInList.BLoadLayoutSnippet("ItemRow"); //Применение к ней сниппета

		let itemImagePanel = itemInList.FindChildTraverse("ItemImage") // Панель для иконки предмета
		let itemNameInfo = itemInList.FindChildTraverse("ItemNameInfo") // Панель с названиями предмета

		let localizedItemName = itemNameInfo.GetChild(0)
		let сodeItemName = itemNameInfo.GetChild(1)

		localizedItemName.text = $.Localize("#DOTA_Tooltip_Ability_" + itemName);
		if (localizedItemName.text.includes("item_recipe")) {
			let newItemName = localizedItemName.text.replace(/recipe_/g, "")
			localizedItemName.text = $.Localize(newItemName);
		}
		if (localizedItemName.text.includes("color")) {
			localizedItemName.text = localizedItemName.text.replace(/<[^>]+>/g, "");
		}

		сodeItemName.text = itemName;

		let ItemImage = $.CreatePanel("DOTAItemImage", itemImagePanel, "");
		ItemImage.itemname = itemName;
		if (ItemImage.itemname == "") {
			itemInList.markedIsUseless = true;
		}

		ItemImage.SetPanelEvent('onactivate', () => SendItemSpawnerRequest(itemName));
	}

	parent = $("#AbilitiesSpawnerList");
	parent.RemoveAndDeleteChildren();
	for (const [_, abilityName] of Object.entries(kv.abilities)) {

		let AbilityName = abilityName[1];
		if (AbilityName.includes("special_bonus_")) {
			continue;
		}
		let AbilityTextureName = abilityName[2];
		let abilityInList = $.CreatePanel("Panel", parent, "")
		abilityInList.BLoadLayoutSnippet("AbilityRow");
		abilityInList._AbilityName = AbilityName;

		let StandartIcon = abilityInList.FindChildTraverse("AbilityImageForAbility")
		StandartIcon.SetImage("file://{images}/spellicons/" + AbilityTextureName + ".png");

		let CustomIcon = abilityInList.FindChildTraverse("CustomAbilityImageForAbility")
		CustomIcon.SetImage("raw://resource/flash3/images/spellicons/"+ AbilityTextureName +".png")

		abilityInList.SetPanelEvent('onmouseover', function () {
			$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", abilityInList, AbilityName, Players.GetLocalPlayer());
		});
		abilityInList.SetPanelEvent('onmouseout', function () {
			$.DispatchEvent("DOTAHideAbilityTooltip", abilityInList);
		});

		abilityInList.SetPanelEvent('onactivate', function() {
			SendAbilitySpawnerRequest(AbilityName);
		});
		abilityInList.SetPanelEvent('oncontextmenu', () => {
			GameUI.SendCustomHUDError(AbilityName, 0)
		})
	}
}

function SendItemSpawnerRequest(itemName) {
	GameEvents.SendCustomGameEventToServer("debug_panel_give_item", {itemName : itemName});
}

function SendAbilitySpawnerRequest(abilityName) {
	GameEvents.SendCustomGameEventToServer("debug_panel_add_ability", {abilityName : abilityName});
}

GameEvents.Subscribe( "debug_panel_kv_data", OnKVData );

function AdjustTimescaleSlider(value, isSet)
{
	var slider = $( '#HostTimescaleSlider' );
	if(isSet == true) {
		slider.value = value;
		return;
	}
	slider.value = slider.value + value;
}

function FixHostTimeScaleSlider()
{
	var slider = $( '#HostTimescaleSlider' );
	slider.min = 0.1;
	slider.value = 1;
	slider.max = 10;
	slider.increment = 0.01;
}

FixHostTimeScaleSlider();

function OnDebugPanelStateResponse(kv)
{
	$("#DebugPanelRoot").style.visibility = (kv.disabled == 1) ? "collapse" : "visible";
	$("#DebugPanelButton").style.visibility = (kv.disabled == 1) ? "collapse" : "visible";
}

GameEvents.Subscribe("debug_panel_state_for_player_response", OnDebugPanelStateResponse);
GameEvents.SendCustomGameEventToServer("debug_panel_state_for_player", {});

OnDebugPanelStateResponse({disabled : 1});

function ConvertDifficultyValueToEnumValue(value) {
	value = parseInt(value);
	if(value == 0) {
		return Constants.GAME_DIFFICULTIES.GAME_DIFFICULTY_EXPLORATION;
	}
	if(value == 1) {
		return Constants.GAME_DIFFICULTIES.GAME_DIFFICULTY_EASY;
	}
	if(value == 2) {
		return Constants.GAME_DIFFICULTIES.GAME_DIFFICULTY_NORMAL;
	}
	if(value == 3) {
		return Constants.GAME_DIFFICULTIES.GAME_DIFFICULTY_HARD;
	}
	if(value == 4) {
		return Constants.GAME_DIFFICULTIES.GAME_DIFFICULTY_HARDCORE;
	}
	return Constants.GAME_DIFFICULTIES.GAME_DIFFICULTY_EXPLORATION
}

function OnSetDifficultyRequest(value) {
	GameEvents.SendCustomGameEventToServer("debug_panel_set_difficulty", {
		difficulty : ConvertDifficultyValueToEnumValue(value)
	});
	Game.EmitSound( "UI.Button.Pressed" );
}

function Toggle()
{
	var slideThumb = $("#DebugPanelRoot");
	var bMinimized = slideThumb.BHasClass( 'Minimized' );

	if ( bMinimized )
	{
		Game.EmitSound( "ui_settings_slide_out" );
	}
	else
	{
		Game.EmitSound( "ui_settings_slide_in" );
	}
	HideAllAdditionalPanels();
	slideThumb.SetHasClass( 'Minimized', !bMinimized);
}

DebugPanelWindow.Toggle = function() {
	Toggle();
};

let awaitDebugWindowInitFunction = function() {
	var rootPanel = $("#DebugPanelRoot");
	if(rootPanel.BReadyForDisplay()) {
		GameUI.CustomUIConfig().DebugPanelWindow = DebugPanelWindow;
	} else {
		$.Schedule(0.25, awaitDebugWindowInitFunction);
	}
}

awaitDebugWindowInitFunction();

let PlayerInfo = CustomNetTables.GetTableValue("players", `player_${LocalPID}_title_status`)
if(PlayerInfo && PlayerInfo.status == 1){
	$("#TitleStatusButton").SetSelected(true)
}