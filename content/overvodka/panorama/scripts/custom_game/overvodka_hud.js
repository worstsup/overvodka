(function () {
    GameEvents.Subscribe("hero_selection", HeroSelection )    
    GameEvents.Subscribe("pre_game", RemovePickBg )
})();

function RemovePickBg() {
    $.Schedule(1, RemovePickBg)
    
    remove = 1  
}

remove = 0

bgid = 0


    var BackgroundImages = FillBackgroundImageArray()

    let ScanImage = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("RadarIcon")
    let RightMapContainers = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("GlyphScanContainer")
    RightMapContainers.style.marginTop = "50px"
    RightMapContainers.style.marginLeft = "244px"
    RightMapContainers.style.marginBottom = "0px"
    let RoshanTimer = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("RoshanTimerContainer")
    RoshanTimer.style.visibility = "collapse"
    let Minimap = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("minimap")
    let heropanel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("center_bg")
    heropanel.style.width = "100%";
    let InventoryBackgroundBot = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("inventory_items")
    InventoryBackgroundBot.style.backgroundColor = "transparent"
    let InventoryBackgroundTop = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("InventoryBG")
    InventoryBackgroundTop.style.backgroundColor = "transparent"
    InventoryBackgroundTop.style.marginBottom = "1000px"
    let InventoryTop = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("inventory")
    let Talents = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("StatBranchBG")
    let RightFlare = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("right_flare")
    RightFlare.style.height = "160px"
    let NeutralSlot = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("inventory_neutral_craft_holder")
    let LeftFlare = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("left_flare")
    LeftFlare.style.height = "138px";
    LeftFlare.style.width = "52px";
    let LevelLabel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("LevelLabel")
    LevelLabel.style.textShadow = "0px 0px 0px transparent"
    let LevelProgressBg = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CircularXPProgress_BG")
    LevelProgressBg.style.border = "0px solid transparent"
    LevelProgressBg.style.borderRadius = "50%"
    let LevelProgressFg = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CircularXPProgress_FG")
    LevelProgressFg.style.borderRadius = "50%"
    let LevelBG = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("LevelBackground")
    LevelBG.style.visibility = "collapse"
    LevelBG.style.borderRadius = "50%";
    let LevelBlur = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CircularXPProgressBlur_BG")
    LevelBlur.style.visibility = "visible"
    let LevelBlur2 = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CircularXPProgressBlur_FG")
    LevelBlur2.style.visibility = "collapse"
    LevelProgressBg.style.backgroundColor = "black"
    let HeroOverlay = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("PortraitGroup")
    let ShopBg = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("shop_launcher_bg")
    ShopBg.style.width = "290px"
    ShopBg.style.height = "73px"
    let QuicbuyBg = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("QuickBuyRows")
    QuicbuyBg.style.marginLeft = "32px"
    QuicbuyBg.style.paddingLeft = "2px"
    QuicbuyBg.style.marginBottom = "65px"
    let ShopButtonBg = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("ShopButton")
    ShopButtonBg.style.width = "94px"
    ShopButtonBg.style.padding = "0px -0px 0px 0px"
    ShopButtonBg.style.marginLeft = "10px"
    let ShopContainer = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("ShopCourierControls")
    ShopContainer.style.marginLeft = "25px"
    let ShopGold = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GoldIcon")

    let CourIcon = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectCourierButton")
    let CourBust = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CourierBurstButton")
    let CourProtect = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CourierShieldButton")
    let CourGiveButton = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("DeliverItemsButton")
    let CourDeliverSpinner = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Spinner")
    let StashBg = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("stash_bg")
    StashBg.style.backgroundImage               = "url('file://{images}/custom_game/stash_bg.png')"
    let GameInfoButton = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GameInfoButton")
    GameInfoButton.style.backgroundColor    = "black"
    let GameInfoIcon = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GameInfoIcon")
    let GameInfoOpenClose = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GameInfoOpenClose")

    let SearchBox = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("SearchBox")
    let GiudeFlyoutContainer = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GuideFlyoutContainer")
    let ShopSearchIcon = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopSearchIcon")
    let PlaceholderText = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("PlaceholderText")
    let SearchContainter = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("SearchContainer")
    let ToggleMinimapShop = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ToggleMinimalShop")
    let ShopItems_basics = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_basics").FindChildTraverse("ShopItemsHeader")
    let ShopItems_support = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_support").FindChildTraverse("ShopItemsHeader")
    let ShopItems_magics = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_magics").FindChildTraverse("ShopItemsHeader")
    let ShopItems_defense = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_defense").FindChildTraverse("ShopItemsHeader")
    let ShopItems_weapons = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_weapons").FindChildTraverse("ShopItemsHeader")
    let ShopItems_artifacts = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_artifacts").FindChildTraverse("ShopItemsHeader")
    let ShopItems_consumables = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_consumables").FindChildTraverse("ShopItemsHeader")
    let ShopItems_atributeslabel = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_attributes").FindChildTraverse("ShopItemsHeader")
    let ShopItems_weapons_armor = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_weapons_armor").FindChildTraverse("ShopItemsHeader")
    let ShopItems_misc = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_misc").FindChildTraverse("ShopItemsHeader")
    let ShopItems_secretshop = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_secretshop").FindChildTraverse("ShopItemsHeader")
    let GridBasicsTab = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GridBasicsTab")
    let GridUpgradesTab = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GridUpgradesTab")
    let GridNeutralsTab = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GridNeutralsTab")

    //let newUI = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("center_block")
    //$.Msg(newUI)

    //newUI.FindChildrenWithClassTraverse("TertiaryAbilityContainer")[0].style.visibility = "visible";
    /*let AbilityLvl = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Ability0")
    let AbilityLvl1 = AbilityLvl.FindChildTraverse("ButtonAndLevel")
    let AbilityLvl12 = AbilityLvl.FindChildTraverse("LevelUpTab").FindChildTraverse("LevelUpButton")
    AbilityLvl12.style.visibility   = "visible";
    AbilityLvl12.style.backgroundImage              = "url('file://{images}/custom_game/gold_small.png')";
    */


function HeroSelection() {

    // if game state is not hero pick or stategy time   
    if ((!Game.GameStateIs(4)) && (!Game.GameStateIs(5))) 
    {
        return
    }
    

    let SceneLoaded = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("PregameBG")
    SceneLoaded.style.width = "0%"
    SceneLoaded.style.height = "0%"
    SceneLoaded.style.visibility = "visible"


    let selectionBg = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("PregameBGStatic")
    selectionBg.BLoadLayout( "file://{resources}/layout/custom_game/heropick_bg.xml", false, false );
    
    selectionBg.style.visibility = "visible"
    selectionBg.style.width = "100%"
    selectionBg.style.height = "100%"
    selectionBg.style.backgroundColor = "transparent"
    selectionBg.style.backgroundRepeat = "no-repeat"

    let CustomBackground = selectionBg.FindChild( "HeroPickBg" );
    CustomBackground.style.backgroundImage = "url('file://{images}/custom_game/overvodka_pick.png')";
    CustomBackground.style.backgroundSize = "100% 100%"
    
    // hero selection UI
    let Minimap = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("PreMinimapContainer")
    if (Game.GetMapInfo().map_display_name == "overvodka_5x5"){
        Minimap.style.visibility = "visible"
    }
    else{
        Minimap.style.visibility = "collapse"
    }
    Minimap.style.width = "100%"
    Minimap.style.marginBottom = "15px"
    let removeMinimap = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPickMinimap")
    removeMinimap.style.visibility = "visible"
    removeMinimap.style.marginRight = "-5%"
    removeMinimap.style.border = "2px solid #FFD700" // Gold border
    removeMinimap.style.boxShadow = "0 0 15px rgba(255, 215, 0, 0.1)" // Gold glow effect
    removeMinimap.style.transform = "rotateX(0deg)"
    let removeFooter = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Footer") // footer выбор сетки героев
    removeFooter.style.visibility = "collapse"
    let pickFooter = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("ViewModeControls") // footer выбор сетки героев
    pickFooter.style.visibility = "collapse"
    let removeFilters = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Filters") // footer фильтр героев сложности и роли
    removeFilters.style.visibility = "collapse"
    //let MItems = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("AvailableItemsContainer")
    //MItems.style.visibility = "collapse"
    //MItems.enabled = false
    let Mmap = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("StrategyMap")
    Mmap.style.visibility = "collapse"
    Mmap.style.width = "300px"
    Mmap.enabled = false
    let Mmap1 = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("StrategyMapControls")
    Mmap1.style.visibility = "collapse"
    let Minimap_true = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("StrategyMinimap")
    Minimap_true.style.visibility = "visible"
    let Mplus = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("StrategyFriendsAndFoes")
    Mplus.style.visibility = "collapse"
    Mplus.enabled = false
    let Mlist = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("HeroLockedNav")
    Mlist.style.visibility = "collapse"
    Mlist.enabled = false
    let StrategyTimeLabel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeaderSubtitle")
    StrategyTimeLabel.style.marginTop = "0.45%"
    
 
    

    // select hero panel
    let BotomPanel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("BottomPanels")
    let PlusPaned = BotomPanel.FindChildTraverse("FriendsAndFoes")
    PlusPaned.style.visibility = "collapse"
    let HeroBlock = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPickRightColumn")
    let SimilarHero1 = HeroBlock.FindChildTraverse("HeroInspect").FindChildTraverse("HeroSimpleDescription").FindChildTraverse("SimilarHero1")
    let SimilarHero2 = HeroBlock.FindChildTraverse("HeroInspect").FindChildTraverse("HeroSimpleDescription").FindChildTraverse("SimilarHero2")
    let SimilarHero3 = HeroBlock.FindChildTraverse("HeroInspect").FindChildTraverse("HeroSimpleDescription").FindChildTraverse("SimilarHero3")
    SimilarHero1.style.visibility = "visible"
    SimilarHero2.style.visibility = "visible"
    SimilarHero3.style.visibility = "visible"
    // select hero buttons (ban, pick, random)
    
    HeroBlock.style.visibility = "visible"
    HeroBlock.style.margin = "-10px 22px 0px 0px";
    HeroBlock.style.boxShadow = "0px 0px 10px 0px yellow"
    HeroBlock.style.backgroundColor = "gradient( linear, 0% -30%, 0% 100%, from(rgb(255, 255, 0) ), to( black ) )";
    let PickButton = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("LockInButton")
    PickButton.style.visibility = "visible"
    PickButton.style.borderTop = "3px solid yellow"
    PickButton.style.borderRight = "3px solid yellow"
    PickButton.style.backgroundColor = "black"
    let RandomButton = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("RandomButton")
    RandomButton.style.visibility = "visible"
    RandomButton.style.borderTop = "3px solid yellow"
    RandomButton.style.borderLeft = "2px solid yellow"
    RandomButton.style.marginLeft = "-1px"
    RandomButton.style.backgroundColor = "black"
    let PickBottom = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPickControls")
    PickBottom.style.visibility = "visible"
    PickBottom.style.backgroundColor = "black"
    PickBottom.style.height = "75px"


    // strategy hero panel
    let PregameRelicues = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroRelicsContainer")
    PregameRelicues.style.visibility = "collapse"
    let PlusHeroLevel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("StrategyHeroBadge")
    PlusHeroLevel.style.visibility = "collapse"
    let RelicsStategy1 = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("StrategyHeroRelicsThumbnail")
    RelicsStategy1.style.visibility = "collapse"
    let RelicsStategy = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("StrategyHeroRelicsThumbnailTooltips")
    RelicsStategy.style.visibility = "collapse"
    let SelectedHeroAbilitiesHitTargets = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHeroAbilitiesHitTargets")
    SelectedHeroAbilitiesHitTargets.style.visibility = "visible"
    SelectedHeroAbilitiesHitTargets.style.marginLeft = "0%"
    SelectedHeroAbilitiesHitTargets.style.marginTop = "0%"
    SelectedHeroAbilitiesHitTargets.style.height = "100px"
    SelectedHeroAbilitiesHitTargets.style.position = "58.3% 26.5% 0px"
    let HeroSkill1 = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHeroAbilities")
    HeroSkill1.style.visibility = "visible"
    let SelectedHeroDetails = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHeroDetails")
    SelectedHeroDetails.style.visibility = "visible"
    SelectedHeroDetails.style.marginLeft = "0%"
    SelectedHeroDetails.style.marginTop = "0%"
    SelectedHeroDetails.style.position = "58.4% 25% 0px"
    let SelectedHeroName = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHeroName")
    SelectedHeroName.style.marginLeft = "0.1%"
    SelectedHeroName.style.marginTop = "-5px"
    SelectedHeroName.style.height = "70px"



    // pregame shop
    let RightContainer = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("RightContainer")
    RightContainer.style.visibility = "visible"
    RightContainer.style.paddingRight = "0%"
    RightContainer.style.position = "5% 30% 0px"
    let RightContainerMain = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("RightContainerMain")
    RightContainerMain.style.visibility = "visible"
    RightContainerMain.style.position = "0% 0% 0px"

    let PregameFastBuy = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("StartingItems")
    PregameFastBuy.style.visibility = "visible"
    PregameFastBuy.enabled = true
    let PregabeBuytextgoldLabel = PregameFastBuy.FindChildrenWithClassTraverse("StrategyControlTitle")
    //$.Msg(PregabeBuytextgoldLabel)
    for (let k in PregabeBuytextgoldLabel)
    {
        PregabeBuytextgoldLabel[k].style.color = "gold";
        PregabeBuytextgoldLabel[k].style.fontWeight = "lighter";
        PregabeBuytextgoldLabel[k].style.textShadow = "5px 5px 5px 5px black";

    }
    PregameFastBuy.style.visibility = "visible" //==========
    PregameFastBuy.style.backgroundColor = "transparent";
    PregameFastBuy.style.margin = "-20px 0px 0px 180px";
    //PregameFastBuy.style.margin = "250px 300px 0px 270px";
    PregameFastBuy.style.width = "1000px";
    PregameFastBuy.style.marginRight = "-10px";
    PregameFastBuy.style.boxShadow = "0px 0px 10px 0px rgba(0,0,0, 0.7)";

    let PregameInventory = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("StartingItemsInventory")
    PregameInventory.style.visibility = "visible"
    PregameInventory.style.backgroundColor = "transparent";
    let Cmonitems = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("TeamSharedItemsStrategyControl")
    Cmonitems.style.visibility = "collapse"
    Cmonitems.enabled = false
    let TeamItems = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("StartingItemsRightColumnRow")
    TeamItems.style.visibility = "visible"

    // selected hero panel
    let SelectedHeroModel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("EconSetPreview2")
    SelectedHeroModel.style.marginLeft = "15%"
    SelectedHeroModel.style.marginTop = "15%"
    SelectedHeroModel.style.height = "100%"
    SelectedHeroModel.style.width = "100%"
    let HeroModel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroModel")
    HeroModel.style.height = "1000px"
    HeroModel.style.width = "100%"
    let HeroModelOverlay = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroModelOverlay")
    HeroModelOverlay.style.height = "1000px"
    HeroModelOverlay.style.width = "100%"
    
    let StatBranchPick = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHeroAbilitiesHitTargets");
    StatBranchPick.style.visibility = "collapse"

    let sceptershard = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("AghsStatusShard")
    let scepterscepter = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("AghsStatusScepter")
    sceptershard.style.visibility = "visible"
    scepterscepter.style.visibility = "visible"
    
    $.Schedule(0.25, PickIconsStyles)
    $.Schedule(1, PickIconsStyles)
    $.Schedule(1.25, PickIconsStyles)

    
    
    // hero pick  похожие
    

    // GAME INFO BLOCK
    //let InfoBlockBg = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GameInfoPanel")
    //InfoBlockBg.style.backgroundColor = "transparent"
    //InfoBlockBg.style.backgroundImage     = "url('file://{images}/custom_game/game_info/infoblock.png')";
    //InfoBlockBg.style.width   = "534px"
    //InfoBlockBg.style.height = "800px"
    //InfoBlockBg.style.transitionDuration = "0.4s";
    //InfoBlockBg.style.marginTop = "5%";
    GameInfoButton.style.transitionDelay = "0s";
    GameInfoButton.style.transitionDuration = "0.1s";
    GameInfoButton.style.marginTop  = "8%"
    /*InfoBlockBg.style.backgroundColor = "transparent"
    
    InfoBlockBg.style.backgroundRepeat = "no-repeat"
    InfoBlockBg.style.marginBottom = "-100px"
    InfoBlockBg.style.width = "40%"
    InfoBlockBg.style.height = "100%"
    InfoBlockBg.style.borderRadius = "0px 1% 1% 0px"
    InfoBlockBg.style.textAlign = "center"
    InfoBlockBg.style.boxShadow = "0px 0px 0px 0px transparent"
    InfoBlockBg.style.marginTop = "0px"
    */
    let InfoBlockArea = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GameInfoPanelScrollArea")
    InfoBlockArea.style.height = "100%"
    let PickChat = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("Chat")
    PickChat.style.visibility = "visible"   
    
    //let Shop = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("shop")
    //Shop.style.height = "100%" 
    
    let InfoBlockTop = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GameInfoGradientOverlayTop")
    InfoBlockTop.style.visibility   = "collapse"
    let InfoBlockBot = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GameInfoGradientOverlayBottom")
    InfoBlockBot.style.visibility   = "collapse"

    let SimpleShopIcon = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ToggleAdvancedShop")
    SimpleShopIcon.style.visibility = "collapse"
    

    let CommonItems = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("CommonItems")
    CommonItems.style.visibility = "collapse"

    let Weapons = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ShopItems_weapons")
    Weapons.style.height = "500px"

    let GridUpgradeItems = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GridUpgradeItems")
    GridUpgradeItems.style.height = "1000px"

    let GridUpgradesCategory = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GridUpgradesCategory")
    GridUpgradesCategory.style.height = "1000px"

    let GridMainShop = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GridMainShop")
    GridMainShop.style.height = "1000px"

    let GridMainStopContent = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("GridMainShopContents")
    GridMainStopContent.style.height = "1000px"

    let Main = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("Main")
    Main.style.height = "100%"

    let HeightLimiter = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("HeightLimiter")
    HeightLimiter.style.height = "100%"

    let BuildTitleContainer = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("BuildTitleContainer")
    BuildTitleContainer.style.visibility = "collapse"

    let RequestSuggestion = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("RequestSuggestion")
    RequestSuggestion.style.visibility = "collapse"
    let PopularItems = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("PopularItems")
    PopularItems.style.visibility = "collapse"

    // PROZRACHNOST SHOPA

    let ItemCombines = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("ItemCombines")
    ItemCombines.style.marginBottom = "10px"
    ItemCombines.style.backgroundColor = "transparent"

    let HeightLimiterContainer = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("HeightLimiterContainer")
    HeightLimiterContainer.style.height = "1000px"
    



    GridUpgradeItems.style.backgroundColor = "transparent"
    GridUpgradesCategory.style.backgroundColor = "transparent"
    GridMainShop.style.backgroundColor = "transparent"
    GridMainStopContent.style.backgroundColor = "transparent"
    Main.style.backgroundColor = "transparent"
    HeightLimiter.style.backgroundColor = "transparent"
    HeightLimiterContainer.style.backgroundColor = "transparent"
    SearchBox.style.backgroundColor = "transparent"



    SearchContainter.style.width = "315px"
    ToggleMinimapShop.style.paddingLeft = "8px"
    ToggleMinimapShop.style.marginLeft = "2px"


    // basic shop lables color
    


    // upgrade shop lables colors
    

    
    let Categories = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("Categories")
    Categories.style.paddingBottom = "0px"
    Categories.style.paddingTop = "-0px"
    GridBasicsTab.style.borderRadius = "1%"
    GridUpgradesTab.style.borderRadius = "1%"
    GridNeutralsTab.style.borderRadius = "1%"
    let PreGameHeroIcons = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("PreGame").FindChildTraverse("MainContents").FindChildTraverse("StrategyScreen")
    let PregameHeroicon = PreGameHeroIcons.FindChildTraverse("SelectedHeroDetails")
    PregameHeroicon.style.width = "800px"
    let HeroAbilities = PregameHeroicon.FindChildTraverse("SelectedAbilitiesContainer")
    let PersonaSelector = PregameHeroicon.FindChildTraverse("PersonaSelector")
    PersonaSelector.style.visibility = "collapse"
    HeroAbilities.style.marginTop = "0px"
    let InnateHolder = HeroAbilities.FindChildTraverse("InnateAbilityContainer")
    let AbilityIcons = HeroAbilities.FindChildrenWithClassTraverse("AbilityIconContainer")
    let selectors = [
        "#SelectedHeroAbilities > .AbilityIconContainer",
        "#SelectedHeroAbilities > .StatBranch", 
        "#SelectedHeroAbilities > .ScepterDetails",
        "#SelectedHeroAbilities > .InnateAbility",
        "#SelectedHeroAbilitiesHitTargets > Panel"
    ]
    for (let i = 0; i < AbilityIcons.length; i++) {
        AbilityIcons[i].style.width = "64px";
        AbilityIcons[i].style.height = "64px";
    }
    for (let selector of selectors) {
        let elements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildrenWithClassTraverse(selector);
        for (let element of elements) {
            element.style.width = "64px";
            element.style.height = "64px";
        }
    }
    let EnterBattleLabel = PregameHeroicon.FindChildTraverse("EnterBattle")
    if (EnterBattleLabel) {
        EnterBattleLabel.style.fontSize = "30px"
        EnterBattleLabel.style.marginTop = "-15px"
    }
    let PanelAttribute = PregameHeroicon.FindChildTraverse("PrimaryAttribute")
    if (PanelAttribute) {
        PanelAttribute.style.width = "50px"
        PanelAttribute.style.height = "50px"
    }
    //PregameHeroicon.style.width = "100%"
    //PregameHeroicon.style.marginTop = "-30px"
    //talenttable.style.backgroundImage = "url('file://{images}/custom_game/int_pink/shop_button.png')";

    // НАЧАЛО ИГРЫ

    

          // $.Msg("works");
         //  $.Msg(InterfaceID);
    }
    /*let PreGameHeroIcons = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("PreGame").FindChildTraverse("MainContents").FindChildTraverse("HeroList")
    let PregameHeroicon = PreGameHeroIcons.FindChildrenWithClassTraverse("HeroCard")
    for (let i=0; i<=20; i++)
    {
       PregameHeroicon[i].style.washColor = "transparent"
       PregameHeroicon[i].style.width = "51px"
       PregameHeroicon[i].style.height = "83px"
    }*/

HeroSelection()
//var iter = 0
RemoveWearablesFromDotaScenePanel()



function PickIconsStyles()
{
    let PreGame = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("PreGame").FindChildTraverse("MainContents").FindChildTraverse("GridCategories");
    let PickIconArray = PreGame.FindChildrenWithClassTraverse("HeroCard")
    //$.Msg(PreGame)
    for (let key in PickIconArray)
    {
        PickIconArray[key].style.height = "104px"
        PickIconArray[key].style.width = "63px" 
        PickIconArray[key].style.borderRadius = "0%"
        PickIconArray[key].style.margin = "5px"
        PickIconArray[key].style.border = "1px solid #FFD700" // Gold border
        PickIconArray[key].style.boxShadow = "0 0 5px rgba(255, 215, 0, 0.5)" // Gold glow effect
        
        
        let dotaplus_level = PickIconArray[key].FindChildrenWithClassTraverse("HeroCardContents")[0].FindChildTraverse("HeroBadgeStatus")
        dotaplus_level.style.visibility = "collapse"
    }
    
    let HeroGrid = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroGrid")
    HeroGrid.style.height = "900px";
    HeroGrid.style.width = "100%"; // Increased width
    HeroGrid.style.marginTop = "-0px";
    HeroGrid.style.marginLeft = "-20px";

    let GridCategories = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("GridCategories")
    GridCategories.style.flowChildren = "down";
    GridCategories.style.width = "1000px"; // Added width to match HeroGrid

    let HeroCategories = GridCategories.FindChildrenWithClassTraverse("HeroCategory")
        
    for (let key in HeroCategories)
    {
        HeroCategories[key].style.width = "100%"
        HeroCategories[key].style.height = "22%"
    }

    $.Schedule(1, PickIconsStyles)
    
}

function ChangeBackgroundImage(panel) {
    let randomIndex = Math.floor(Math.random() * BackgroundImages.length);
    let randomImage = BackgroundImages[randomIndex];
    panel.style.backgroundImage = "url('file://{images}/custom_game/pick_bacground/" + randomImage + ".png')";

    BackgroundImages.splice(randomIndex, 1);
    if (BackgroundImages.length === 0) {
        FillBackgroundImageArray();
    }
    
    panel.RemoveClass("FadeOut");
    panel.AddClass("FadeIn");
    
    
    
    $.Schedule(5, function() {      
        panel.RemoveClass("FadeIn");        
        panel.AddClass("FadeOut");
        $.Schedule(0.5, function() {
            ChangeBackgroundImage(panel);           
        });
    });
}

function FillBackgroundImageArray() {   
    let img_array = []; // список всіх невикористаних картинок // lebiga

    if (BackgroundImages) {
        //$.Msg("BackgroundImages existing")
        BackgroundImages = img_array;
        return;
    } else {
        //$.Msg("BackgroundImages not exist for now")
    }

    return img_array;
}


function RemoveWearablesFromDotaScenePanel()
{
    
    //iter = iter + 1
    //$.Msg(iter)
    if (Game.GameStateIsAfter(5))
    {
        //$.Msg("scene was fixed")
        return
    }
    
    $.Schedule(0.3, RemoveWearablesFromDotaScenePanel)
    
    let Dotascenepanel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Preview").FindChildInLayoutFile("Preview3DItems")
    if (Dotascenepanel) 
    {   
        Dotascenepanel.FireEntityInput(
            "*",
            "RunScriptCode",
            `
            local key = tostring(${Math.random()})
            if thisEntity:GetClassname() == 'portrait_world_unit' and (GetUnitKeyValuesByName(thisEntity:GetUnitName()) or {})['DisableWearables'] == 1 then
                _G['scene_'..key] = true
                thisEntity:SetContextThink('clear',function()_G['scene_'..key] = nil end,1)
            end
            if thisEntity:GetClassname() == 'dota_item_wearable' then
                thisEntity:SetContextThink('delete',function() if _G['scene_'..key] then UTIL_Remove(thisEntity) end end,0)
            end
        `
        );      
        //$.Msg("succes")
    }
    else
    {
        //$.Msg("fail")
    }   

    /*
    for ( var teamId of Game.GetAllTeamIDs() ) // все айди всех команд
    {
        var teamPlayers = Game.GetPlayerIDsOnTeam( teamId ); // масив со всеми айдишниками каждого игрока в тиме

        for ( var playerId of teamPlayers ) // перебор масива с айди игроков по каждому айди
        {
            var playerInfo = Game.GetPlayerInfo( playerId ); // инфа по текущему айдишнику
            if ( !playerInfo )
            {
                return;
            }
            else
            {
                $.Msg("get player info passed")
            }
            var localPlayerInfo = Game.GetLocalPlayerInfo();
            if ( !localPlayerInfo )
            {
                return; 
            }
            else
            {
                $.Msg("get local player info passed")
            }

            if ( playerInfo.player_selected_hero !== "" )
            {
                let disable_wearables = ["antimage", "arc_warden", "axe", "alchemist",
                "bounty_hunter", "chaos_knight", "rattletrap", "doom_bringer", "earth_spirit", "earthshaker", 
                "enigma", "invoker", "juggernaut", "kunkka", "lion", "ogre_magi", "omniknight", "night_stalker",
                "phantom_assassin", "pudge", "rubick", "slark", "sniper", "silencer", "shadow_demon", "shredder", 
                "undying", "ursa", "visage", "warlock", "witch_doctor", "skeleton_king", "marci"];

                //$.Msg(playerInfo.player_selected_hero)
                //$.Msg(playerInfo.player_selected_hero.replace("npc_dota_hero_",""))
                //
                if (disable_wearables.includes(playerInfo.player_selected_hero.replace("npc_dota_hero_","")))
                {

                    $.Msg("array includes hero name")
                    let Dotascenepanel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Preview").FindChildInLayoutFile("Preview3DItems")
                    if (Dotascenepanel) 
                    {       
                        Dotascenepanel.style.visibility = "visible"
                        Dotascenepanel.FireEntityInput("*","runscriptcode","if thisEntity:GetClassname()=='dota_item_wearable' then UTIL_Remove(thisEntity) end")
                        $.Msg("succes")
                    }
                    else
                    {
                        $.Msg("fail")
                    }                           
                }   
            }
        }
    }
    */
}