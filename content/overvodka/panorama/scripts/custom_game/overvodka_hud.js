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

function HeroSelection() {

    // if game state is not hero pick or stategy time   
    if ((!Game.GameStateIs(0)) && (!Game.GameStateIs(1)) && (!Game.GameStateIs(4)) && (!Game.GameStateIs(5)))
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
    let Movie = $.CreatePanel("MoviePanel", CustomBackground, "Movie", { src: "file://{resources}/videos/overvodka_pick.webm", repeat: "true", autoplay: "onload" });
    Movie.style.width = "100%";
    Movie.style.height = "100%";
    let TitlesContainer = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("TitlesContainer")
    TitlesContainer.style.visibility = "collapse"
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
    removeMinimap.style.marginRight = "-15%"
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
    HeroBlock.style.boxShadow = "0px 0px 15px 0px yellow"
    HeroBlock.style.backgroundColor = "gradient( linear, 0% -30%, 0% 100%, from(rgb(255, 255, 0) ), to( black ) )";
    let PickButton = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("LockInButton")
    PickButton.style.visibility = "visible"
    PickButton.style.borderTop = "2px solid yellow"
    PickButton.style.borderRight = "3px solid yellow"
    PickButton.style.boxShadow = "0 0 10px rgba(255, 255, 0, 0.3)"
    let RandomButton = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("RandomButton")
    RandomButton.style.visibility = "visible"
    RandomButton.style.borderTop = "2px solid yellow"
    RandomButton.style.boxShadow = "0 0 10px rgba(255, 255, 0, 0.3)"
    RandomButton.style.marginLeft = "-1px"
    let PickBottom = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPickControls")
    PickBottom.style.visibility = "visible"
    PickBottom.style.backgroundColor = " #FFD700"
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
    SelectedHeroDetails.style.marginLeft = "-20%"
    SelectedHeroDetails.style.marginTop = "0%"
    SelectedHeroDetails.style.position = "58.4% 25% 0px"
    let SelectedHeroName = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHeroName")
    SelectedHeroName.style.marginLeft = "0.1%"
    SelectedHeroName.style.marginTop = "-15px"
    SelectedHeroName.style.height = "70px"
    let PreGameHeroIcons = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("PreGame").FindChildTraverse("MainContents").FindChildTraverse("StrategyScreen")
    let PregameHeroicon = PreGameHeroIcons.FindChildTraverse("SelectedHeroDetails")
    PregameHeroicon.style.width = "800px"

    let SelectedHeroFacets = PreGameHeroIcons.FindChildrenWithClassTraverse("SelectedHeroFacets")
    if (SelectedHeroFacets && SelectedHeroFacets.length > 0) {
        SelectedHeroFacets[0].style.marginLeft = "2%"
    }

    let HeroAbilities = PregameHeroicon.FindChildTraverse("SelectedAbilitiesContainer")
    let PersonaSelector = PregameHeroicon.FindChildTraverse("PersonaSelector")
    PersonaSelector.style.visibility = "collapse"
    HeroAbilities.style.marginTop = "0px"
    let InnateHolder = HeroAbilities.FindChildTraverse("InnateAbilityContainer")
    const PickAbilityIconMap = {
        gaster_blaster: { hero: "npc_dota_hero_morphling", base: "gaster_blaster", special: "gaster_blaster_arcana" },
        sans_w: { hero: "npc_dota_hero_morphling", base: "sans_w", special: "sans_w_arcana" },
        sans_e: { hero: "npc_dota_hero_morphling", base: "sans_e", special: "sans_e_arcana" },
        sans_shard: { hero: "npc_dota_hero_morphling", base: "sans_shard", special: "sans_shard_arcana" },
        sans_scepter: { hero: "npc_dota_hero_morphling", base: "sans_scepter", special: "sans_scepter_arcana" },
        sans_innate: { hero: "npc_dota_hero_morphling", base: "sans_innate", special: "sans_innate_arcana" },
        sans_r: { hero: "npc_dota_hero_morphling", base: "sans_r", special: "sans_r_arcana" },
        invincible_q: { hero: "npc_dota_hero_void_spirit", base: "invincible_q", special: "invincible_q_arcana" },
        invincible_w: { hero: "npc_dota_hero_void_spirit", base: "invincible_w", special: "invincible_w_arcana" },
        invincible_e: { hero: "npc_dota_hero_void_spirit", base: "invincible_e", special: "invincible_e_arcana" },
        invincible_innate: { hero: "npc_dota_hero_void_spirit", base: "invincible_innate", special: "invincible_innate_arcana" },
        invincible_r: { hero: "npc_dota_hero_void_spirit", base: "invincible_r", special: "invincible_r_arcana" },
        flash_q_facet_1: { hero: "npc_dota_hero_spirit_breaker", base: "flash_q_facet_1", special: "flash_q_facet_1_immortal" },
        flash_q_facet_2: { hero: "npc_dota_hero_spirit_breaker", base: "flash_q_facet_2", special: "flash_q_facet_2_immortal" },
        flash_w: { hero: "npc_dota_hero_spirit_breaker", base: "flash_w", special: "flash_w_immortal" },
        flash_e: { hero: "npc_dota_hero_spirit_breaker", base: "flash_e", special: "flash_e_immortal" },
        flash_shard: { hero: "npc_dota_hero_spirit_breaker", base: "flash_shard", special: "flash_shard_immortal" },
        flash_r: { hero: "npc_dota_hero_spirit_breaker", base: "flash_r", special: "flash_r_immortal" },
        mellstroy_shavel: { hero: "npc_dota_hero_bounty_hunter", base: "shavel", special: "shavel_arcana" },
        mellstroy_meteors: { hero: "npc_dota_hero_bounty_hunter", base: "fruits", special: "fruits_arcana" },
        mellstroy_business: { hero: "npc_dota_hero_bounty_hunter", base: "biznes", special: "biznes_arcana" },
        mellstroy_business_new: { hero: "npc_dota_hero_bounty_hunter", base: "biznes", special: "biznes_arcana" },
        mellstroy_casino: { hero: "npc_dota_hero_bounty_hunter", base: "casino", special: "casino_arcana" },
        mellstroy_scepter: { hero: "npc_dota_hero_bounty_hunter", base: "mellstroy_scepter", special: "mellstroy_scepter_arcana" },
        mellstroy_amam: { hero: "npc_dota_hero_bounty_hunter", base: "amamam", special: "amamam_arcana" },
        mellstroy_casino_allin: { hero: "npc_dota_hero_bounty_hunter", base: "casino_allin", special: "casino_allin_arcana" },
    };

    function GetSpellIconPath(iconName) {
        return "file://{images}/spellicons/" + iconName + ".png";
    }

    function CollectDotaAbilityImages(panel, result) {
        if (!panel) {
            return;
        }

        if (panel.paneltype === "DOTAAbilityImage") {
            result.push(panel);
        }

        const childCount = panel.GetChildCount ? panel.GetChildCount() : 0;
        for (let i = 0; i < childCount; i++) {
            CollectDotaAbilityImages(panel.GetChild(i), result);
        }
    }

    function PatchPregameAbilityIcons() {
        if (typeof IsSpecialHeroSkinEquippedForPlayer !== "function") {
            return;
        }

        const localPlayerId = (typeof GetOvervodkaLocalPlayerID === "function")
            ? GetOvervodkaLocalPlayerID()
            : Players.GetLocalPlayer();
        const abilityImages = [];

        if (HeroAbilities) {
            CollectDotaAbilityImages(HeroAbilities, abilityImages);
        }

        if (abilityImages.length <= 0) {
            return;
        }

        for (const abilityImage of abilityImages) {
            if (!abilityImage) {
                continue;
            }

            const abilityName = String(abilityImage.abilityname || abilityImage.GetAttributeString("abilityname", ""));
            const iconConfig = PickAbilityIconMap[abilityName];
            if (!iconConfig) {
                continue;
            }

            const useSpecialIcon = IsSpecialHeroSkinEquippedForPlayer(localPlayerId, iconConfig.hero);
            const iconName = useSpecialIcon ? iconConfig.special : iconConfig.base;
            const iconPath = GetSpellIconPath(iconName);

            if (abilityImage._overvodkaPatchedIconPath !== iconPath) {
                abilityImage.SetImage(iconPath);
                abilityImage._overvodkaPatchedIconPath = iconPath;
            }
        }
    }

    // Function to safely resize elements
    function resizeElements(elements) {
        if (elements && elements.length > 0) {
            for (let element of elements) {
                if (element) {
                    element.style.width = "64px";
                    element.style.height = "64px";
                }
            }
        }
    }

    function applyResizing() {
        let AbilityIcons = HeroAbilities.FindChildrenWithClassTraverse("AbilityIconContainer")
        // Get all ability icons and set their dimensions
        if (AbilityIcons && AbilityIcons.length > 0) {
            resizeElements(AbilityIcons);
        }

        // Find and resize talent tree
        let talents = HeroAbilities ? HeroAbilities.FindChildrenWithClassTraverse("StatBranch") : null;
        resizeElements(talents);

        // Find and resize scepter details
        let scepter = HeroAbilities ? HeroAbilities.FindChildrenWithClassTraverse("ScepterDetails") : null;
        resizeElements(scepter);

        // Find and resize innate abilities
        let innate = HeroAbilities ? HeroAbilities.FindChildrenWithClassTraverse("InnateAbility") : null;
        resizeElements(innate);

        // Find and resize hit target panels
        let hitTargets = HeroAbilities ? HeroAbilities.FindChildrenWithClassTraverse("Panel") : null;
        resizeElements(hitTargets);

        PatchPregameAbilityIcons();

        // Schedule next update
        $.Schedule(0.1, applyResizing);
    }

    // Start the resizing loop
    applyResizing();
    let EnterBattleLabel = PregameHeroicon.FindChildTraverse("EnterBattle")
    if (EnterBattleLabel) {
        EnterBattleLabel.style.fontSize = "30px"
        EnterBattleLabel.style.marginTop = "-25px"
    }
    let PanelAttribute = PregameHeroicon.FindChildTraverse("PrimaryAttribute")
    if (PanelAttribute) {
        PanelAttribute.style.width = "50px"
        PanelAttribute.style.height = "50px"
    }


    // pregame shop
    let RightContainer = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("RightContainer")
    RightContainer.style.visibility = "visible"
    RightContainer.style.paddingRight = "0%"
    const aspectRatio = RightContainer.actualLayoutWidth / RightContainer.actualLayoutHeight;
    RightContainer.style.position = aspectRatio < 1.7 ? "0% 30% 0px" : "-15% 30% 0px" // ДОДЕЛАЙ БЛЯ НЕ ЗАБУДЬ
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
    PregameFastBuy.style.marginRight = "-10px";
    PregameFastBuy.style.height = "360px"
    PregameFastBuy.style.boxShadow = "0px 0px 10px 0px rgba(0,0,0, 0.7)";
    
    let Chat = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Chat")
    Chat.style.marginRight = "23.5%"

    let PregameInventory = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("StartingItemsInventory")
    PregameInventory.style.visibility = "visible"
    PregameInventory.style.backgroundColor = "transparent";
    //let Cmonitems = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("TeamSharedItemsStrategyControl")
    //Cmonitems.style.visibility = "collapse"
    //Cmonitems.enabled = false
    //let TeamItems = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent().FindChildTraverse("StartingItemsRightColumnRow")
    //TeamItems.style.visibility = "visible"

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
    let HeroModelLoadout = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroModelLoadout")
    HeroModelLoadout.style.marginTop = "-8%"
    HeroModelLoadout.style.marginLeft = "-2%"
    
    let StatBranchPick = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHeroAbilitiesHitTargets");
    StatBranchPick.style.visibility = "collapse"

    let sceptershard = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("AghsStatusShard")
    let scepterscepter = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("AghsStatusScepter")
    sceptershard.style.visibility = "visible"
    scepterscepter.style.visibility = "visible"
    
    $.Schedule(0.25, PickIconsStyles)
    $.Schedule(1, PickIconsStyles)
    $.Schedule(1.25, PickIconsStyles)
    }

HeroSelection()
RemoveWearablesFromDotaScenePanel()

function EnsurePickHeroMovie(cardPanel, movieSrc)
{
    if (!cardPanel || !movieSrc) {
        return;
    }

    let moviePanel = cardPanel.FindChild("Movie");
    const currentMovieSrc = moviePanel ? moviePanel.GetAttributeString("overvodka_movie_src", "") : "";
    if (moviePanel && currentMovieSrc === movieSrc) {
        return;
    }

    if (moviePanel) {
        moviePanel.DeleteAsync(0);
    }

    moviePanel = $.CreatePanel("MoviePanel", cardPanel, "Movie", { src: movieSrc, repeat: "true", autoplay: "onload" });
    moviePanel.SetAttributeString("overvodka_movie_src", movieSrc);
    moviePanel.style.width = "100%";
    moviePanel.style.height = "100%";
}

function PickIconsStyles()
{
    let PreGame = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("PreGame").FindChildTraverse("MainContents").FindChildTraverse("GridCategories");
    // Get all player panels in the pick screen
    let PickIconArray = PreGame.FindChildrenWithClassTraverse("HeroCard")
    const playerID = Players.GetLocalPlayer();
    for (let key in PickIconArray)
    {
        PickIconArray[key].style.height = "104px"
        PickIconArray[key].style.width = "63px"
        PickIconArray[key].style.borderRadius = "0%"
        PickIconArray[key].style.margin = "5px"
        const heroId = PickIconArray[key].GetAttributeInt("heroid", -1);
        const moviePanel = PickIconArray[key].FindChild("Movie");
        if (IsSpecialHeroSkinEquippedForPlayer(playerID, "npc_dota_hero_morphling") && heroId == 10) {
            PickIconArray[key].style.border = "1px solid #FF4500"
            PickIconArray[key].style.boxShadow = "0 0 25px rgba(255, 69, 0, 0.8), inset 0 0 8px rgba(255, 0, 0, 0.5)"
            EnsurePickHeroMovie(PickIconArray[key], "file://{resources}/videos/heroes/underfell_sans.webm");
        }
        else if (IsSpecialHeroSkinEquippedForPlayer(playerID, "npc_dota_hero_void_spirit") && heroId == 126) {
            EnsurePickHeroMovie(PickIconArray[key], "file://{resources}/videos/heroes/invincible_arcana.webm");
            PickIconArray[key].style.border = "1px solid #00FF00"  // Green border
            PickIconArray[key].style.boxShadow = "0 0 25px rgba(0, 255, 0, 0.8), inset 0 0 8px rgba(0, 255, 0, 0.5)" // Green glow
        }
        else {
            if (moviePanel) {
                moviePanel.DeleteAsync(0);
            }
            PickIconArray[key].style.border = "1px solid #FFD700" // Default gold border 
            PickIconArray[key].style.boxShadow = "0 0 10px rgba(255, 215, 0, 0.5)" // Default gold glow
        }
        let dotaplus_level = PickIconArray[key].FindChildrenWithClassTraverse("HeroCardContents")[0].FindChildTraverse("HeroBadgeStatus")
        dotaplus_level.style.visibility = "collapse"
    }
    let MainHeroPick = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("MainHeroPickScreenContents")
    MainHeroPick.style.marginTop = "50px"
    let HeroGrid = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroGrid")
    HeroGrid.style.height = "900px";
    HeroGrid.style.width = "100%";
    HeroGrid.style.marginTop = "0px";
    HeroGrid.style.marginLeft = "0%";

    let GridCategories = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("GridCategories")
    GridCategories.style.flowChildren = "down";
    GridCategories.style.width = "1200px";

    let HeroCategories = GridCategories.FindChildrenWithClassTraverse("HeroCategory")
        
    for (let key in HeroCategories)
    {
        HeroCategories[key].style.width = "100%"
        HeroCategories[key].style.height = "22%"
    }

    $.Schedule(1, PickIconsStyles)
    
}


function RemoveWearablesFromDotaScenePanel()
{
    if (Game.GameStateIsAfter(5))
    {
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
