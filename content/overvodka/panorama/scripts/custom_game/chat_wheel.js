const LocalPID = Players.GetLocalPlayer()

const MAIN_PANEL = $.GetContextPanel()

const SettingsBody = $("#SettingsBody")
const ItemsText = $("#ItemsText")
const ItemsSounds = $("#ItemsSounds")
const SettingsVariantsTable = $("#SettingsVariantsTable")
const CallBody = $("#CallBody")
const ChatWheelCursor = $("#ChatWheelCursor")
const WheelPointer = $("#WheelPointer")
const Arrow = $("#Arrow")
let DotaHUD = GetDotaHud();

const Menus = {
    text: {
        button: "TextMenuButton",
        menu: "ItemsText"
    },
    sound: {
        button: "SoundsMenuButton",
        menu: "ItemsSounds"
    },
}

const RegionSize = 45

const CallRegions = [
    {
        center: 0,
        line_id: 3,
    },
    {
        center: 45,
        line_id: 4,
    },
    {
        center: 90,
        line_id: 5,
    },
    {
        center: 135,
        line_id: 6,
    },
    {
        center: 180,
        line_id: 7,
    },
    {
        center: 225,
        line_id: 8,
    },
    {
        center: 270,
        line_id: 1,
    },
    {
        center: 315,
        line_id: 2,
    },
]

const CallKeyBind = {
    Default: "G",
    Dota: DOTAKeybindCommand_t.DOTA_KEYBIND_CONTROL_GROUP8,
    Current: "",
    Slot: "CallKeyBind"
}

const CHAT_WHEEL_TYPES = {
    TEXT: 1,
    SOUND: 2
}

let ItemsList = {}

let CurrentOpenedPage = undefined
let CurrentSelectLine = 0
let bCallBodyIsActive = false
let CurrentSelectedCallLine = 0

let UISCALE_X = 1;
let UISCALE_Y = 1;

function OpenMenuPage(page){
    if(CurrentOpenedPage == page){
        return
    }

    CurrentOpenedPage = page

    DeselectMenusExceptOf(page)
}

function DeselectMenusExceptOf(page){
    for (const page_name in Menus) {
        let bIsThis = page == page_name
        let Info = Menus[page_name]
        let Button = $(`#${Info.button}`)
        let Menu = $(`#${Info.menu}`)
        if(Button && Menu){
            Button.SetHasClass("Selected", bIsThis)
            Menu.SetHasClass("Selected", bIsThis)
        }
    }
}

function StartSelectItem(LineNum){
    if(CurrentSelectLine == LineNum || LineNum == 0){
        SettingsVariantsTable.RemoveClass("SelectingTime")
        CurrentSelectLine = 0
        DeselectLinesExceptOf(CurrentSelectLine)
        return
    }

    CurrentSelectLine = LineNum

    SettingsVariantsTable.AddClass("SelectingTime")
    DeselectLinesExceptOf(LineNum)
}

function SelectItem(ItemID){
    if(CurrentSelectLine == 0){
        return
    }

    GameEvents.SendCustomGameEventToServer("chat_wheel_item_selected", {line_id:CurrentSelectLine, item_id: ItemID})

    StartSelectItem(0)
}

function ToggleChatWheelSettings(){
    Game.EmitSound("UUI_SOUNDS.ChatWheelOpen");
    SettingsBody.SetHasClass("Show", !SettingsBody.BHasClass("Show"))
}

function CloseChatWheelSettings(){
    Game.EmitSound("UUI_SOUNDS.ChatWheelClose");
    SettingsBody.RemoveClass("Show")
}

function DeselectLinesExceptOf(LineNum){
    for (let i = 1; i < 9; i++) {
        let LinePanel = $(`#LineButton${i}`)
        if(LinePanel){
            LinePanel.SetHasClass("SelectingTime", i == LineNum)
        }
    }
}

function UpdateChatWheel(PlayerInfo){
    for (const LineID in PlayerInfo) {
        let ItemID = PlayerInfo[LineID]
        if(ItemID != 0){
            let ItemInfo = ItemsList[ItemID]
            if(ItemInfo){
                let LinePanel = $(`#LineButton${LineID}`)
                if(LinePanel){
                    let MainText = $.Localize(`#CUSTOM_CHAT_WHEEL_Item_${ItemInfo.Name}`)
                    let Prefix = ItemInfo.ForAll == 1 ? $.Localize(`#CUSTOM_CHAT_WHEEL_Prefix`)+" " : ""
                    LinePanel.SetDialogVariable("linetext", `${Prefix}${MainText}`)
                }
                let LinePanel2 = $(`#CallLine${LineID}`)
                if(LinePanel2){
                    let MainText = $.Localize(`#CUSTOM_CHAT_WHEEL_Item_${ItemInfo.Name}`)
                    let Prefix = ItemInfo.ForAll == 1 ? $.Localize(`#CUSTOM_CHAT_WHEEL_Prefix`)+" " : ""
                    LinePanel2.SetDialogVariable("calllinetext", `${Prefix}${MainText}`)

                    LinePanel2.SetHasClass("TypeSound", ItemInfo.Type == CHAT_WHEEL_TYPES.SOUND)
                }
            }
        }
    }
}

function UpdateItemsList(List){
    let TextI = 0
    let SoundI = 0
    for (const ItemID in List) {
        let ItemInfo = List[ItemID]

        let ItemName = ItemInfo.Name
        let Container = ItemInfo.Type == CHAT_WHEEL_TYPES.TEXT ? ItemsText : ItemsSounds
        let panel = GetOrCreateItem(Container, ItemID)
        panel.SetHasClass("TypeText", ItemInfo.Type == CHAT_WHEEL_TYPES.TEXT)
        panel.SetHasClass("TypeSound", ItemInfo.Type == CHAT_WHEEL_TYPES.SOUND)

        panel.style.zIndex = -999999

        if(ItemInfo.Type == CHAT_WHEEL_TYPES.TEXT){
            TextI++;
            
            panel.SetHasClass("Odd", TextI%2==0)
        }else{
            SoundI++;

            panel.SetHasClass("Odd", SoundI%2==0)
        }

        panel.SetDialogVariable("itemtext", $.Localize(`#CUSTOM_CHAT_WHEEL_Item_${ItemName}`))

        if(ItemInfo.Type == CHAT_WHEEL_TYPES.SOUND){
            let SoundIcon = panel.FindChildTraverse("SoundIcon")
            if(SoundIcon){
                SoundIcon.SetPanelEvent("onactivate", function(){
                    Game.EmitSound(ItemInfo.Sound)
                })
            }
        }

        panel.SetPanelEvent("onactivate", function(){
            SelectItem(ItemID)
        })
    }
}

function GetOrCreateItem(Container, ItemID){
    let f = Container.FindChildTraverse(`chat_wheel_item_${ItemID}`)
    if(f){
        return f
    }else{
        let panel = $.CreatePanel("Panel", Container, `chat_wheel_item_${ItemID}`, {})
        panel.BLoadLayoutSnippet("Item")
        return panel
    }
}

function OpenCallBody(){
    //if(!IsPlayerSubscribed(LocalPID)){return}
    bCallBodyIsActive = true
    MAIN_PANEL.AddClass("ShowCall")

    // SetCursorToCenter()

    // GameEvents.SendEventClientSide( "chat_wheel_console_command", { command : "dota_hide_cursor 1"} )
}
function CloseCallBody(){
    bCallBodyIsActive = false
    MAIN_PANEL.RemoveClass("ShowCall")

    if(CurrentSelectedCallLine == 0){return}

    GameEvents.SendCustomGameEventToServer("chat_wheel_line_selected", {line_id:CurrentSelectedCallLine})

    CurrentSelectedCallLine = 0

    // GameEvents.SendEventClientSide( "chat_wheel_console_command", { command : "dota_hide_cursor 0"} )
}

function CreateKeyBind(){
    $.Schedule(0.5, CreateKeyBind)

    let oldKey = CallKeyBind.Current;
    let DotaKey = Game.GetKeybindForCommand(CallKeyBind.Dota);
    if (CallKeyBind.Current == "") {
        CallKeyBind.Current = CallKeyBind.Default;
    }
    if (DotaKey != "") {
        CallKeyBind.Current = DotaKey;
    }
    if (oldKey != CallKeyBind.Current) {
        let PanelForBind = SettingsBody.FindChildTraverse(CallKeyBind.Slot);
        if (PanelForBind) {
            PanelForBind.SetDialogVariable("callkeybind", CallKeyBind.Current+"")
        }
        const cmd_name = "CastDFGMText" + Math.floor(Math.random() * 99999999);
        Game.CreateCustomKeyBind(CallKeyBind.Current, "+"+cmd_name);
        Game.AddCommand("+"+cmd_name, OpenCallBody, "", 0);
        Game.AddCommand("-"+cmd_name, CloseCallBody, "", 0);
    }
}

function SetCursorToCenter(){
    GameEvents.SendEventClientSide( "chat_wheel_console_command", { command : "dota_camera_allow_freecam 1"} )
    GameEvents.SendEventClientSide( "chat_wheel_console_command", { command : "dota_toggle_free_camera"} )
    GameEvents.SendEventClientSide( "chat_wheel_console_command", { command : "dota_toggle_free_camera"} )
    GameEvents.SendEventClientSide( "chat_wheel_console_command", { command : "dota_camera_allow_freecam 0"} )
}

function OnSayLine(event){
    if(IsPlayerMuted(event.caller_player)){return}
    
    let ItemInfo = ItemsList[event.item_id]
    if(ItemInfo){
        let Info = Game.GetPlayerInfo(event.caller_player)
        let HeroName = Info.player_selected_hero
        let playerColor = GetHEXPlayerColor(event.caller_player)
        let OvervodkaName = GetOvervodkaHeroName(HeroName)

        let SoundIcon = ``

        if(ItemInfo.Type == CHAT_WHEEL_TYPES.SOUND){
            Game.EmitSound(ItemInfo.Sound)
            SoundIcon = `<img class='SoundIconChat' src='s2r://panorama/images/hud/reborn/icon_scoreboard_mute_sound_psd.vtex'> `
        }else{
            SoundIcon = `<img class='SoundIconChat' src='s2r://panorama/images/control_icons/chat_wheel_icon_png.vtex'> `
        }

        let Text = `<font color='${playerColor}'>${Info.player_name}</font>: ${SoundIcon}${$.Localize(`#CUSTOM_CHAT_WHEEL_Item_${ItemInfo.Name}`)}`

        let ChatLines = DotaHUD.FindChildTraverse("ChatLinesPanel")
        if(ChatLines){
            let msgPanel = $.CreatePanel("Panel", ChatLines, "", {class:"ChatLine"})
            msgPanel.BLoadLayout("file://{resources}/layout/custom_game/custom_chat_line.xml", false, false)
            msgPanel.hittest = false
    
            let HeroImage = msgPanel.FindChildTraverse("HeroImage")
    
            HeroImage.SetImage( "file://{images}/heroes/" + OvervodkaName + ".png" );
    
            msgPanel.SetDialogVariable("text", Text)
            $.Schedule(5, function(){
                msgPanel.AddClass("ExpireThis")
            })
        }
    }
    // let InfoTipped = Game.GetPlayerInfo(event.tipped_player)
    // let playerColor = GetHEXPlayerColor(event.tips_player)
    // let TippedPlayerColor = GetHEXPlayerColor(event.tipped_player)
    // let OvervodkaName = GetOvervodkaHeroName(HeroName)
    // let Text = `<font color='${playerColor}'>${Info.player_name}</font> ${$.Localize('#PLAYER_HUD_TIPPED')} <font color='${TippedPlayerColor}'>${InfoTipped.player_name}</font>. ${$.Localize('#PLAYER_HUD_TIPPED_Text')}`
}

function Updater(){
    $.Schedule(0, Updater)

    UISCALE_X = DotaHUD.actualuiscale_x;
    UISCALE_Y = DotaHUD.actualuiscale_y;

    if(!bCallBodyIsActive){
        return
    }

    let ScreenWidth = Game.GetScreenWidth()
    let ScreenHeight = Game.GetScreenHeight()

    let CenterX = ScreenWidth / 2
    let CenterY = ScreenHeight / 2
    let CenterPos = [CenterX, CenterY, 0]

    let Cursor = GameUI.GetCursorPosition();
    let CursorPos = [Cursor[0], Cursor[1], 0]

    let CursorDistance = Game.Length2D(CursorPos, CenterPos)

    let Direction = VectorMin( CursorPos, CenterPos );
	Direction = Game.Normalized( Direction );

    let newPos = CursorPos

    if(CursorDistance > 33){
        newPos = VectorAdd(CenterPos, VectorScale(Direction, 33))
    }

    ChatWheelCursor.style.x = ToAbsPixelValueX(newPos[0])-23 + "px;"
    ChatWheelCursor.style.y = ToAbsPixelValueX(newPos[1])-23 + "px;"

    let CurrentAngle = angle(CursorPos[0], CursorPos[1], CenterPos[0], CenterPos[1])
    let SelectedOne = false
    for (const Region of CallRegions) {
        let Min = Region.center - RegionSize/2
        if(Min < 0){
            Min = Min + 360
        }
        let Max = Region.center + RegionSize/2
        if(Max > 360){
            Max = Max - 360
        }

        let Center2 = Region.center == 0 ? 360 : Region.center

        let bIsActiveRegion = CursorDistance > 25 && ((CurrentAngle > Min && CurrentAngle < Center2) || (CurrentAngle >= Region.center && CurrentAngle < Max))

        let LinePanel = $(`#CallLine${Region.line_id}`)
        if(LinePanel){
            LinePanel.SetHasClass("Selected", bIsActiveRegion)
        }

        if(bIsActiveRegion){
            SelectedOne = true

            WheelPointer.style.transform = `rotateZ(${Region.center+90}deg)`;

            Arrow.style.transform = `translateX(60px) translateY(0px) rotateZ(${Region.center}deg)`;

            CurrentSelectedCallLine = Region.line_id
        }
    }

    CallBody.SetHasClass("CallLineSelected", SelectedOne)

    if(!SelectedOne){
        CurrentSelectedCallLine = 0
    }
}

function getDistancePoints(x1, y1, x2, y2) {
    return Math.sqrt(Math.pow((x1 - x2), 2) + Math.pow((y1 - y2), 2));
}

function ToAbsPixelValueX(value) {
    return Math.floor((1 / UISCALE_X) * value);
}
function ToAbsPixelValueY(value) {
    return Math.floor((1 / UISCALE_Y) * value);
}

function VectorMin( v1, v2 ) {
	return [ v1[0]-v2[0], v1[1]-v2[1], 0 ];
}
function VectorAdd( v1, v2 ) {
	return [ v1[0]+v2[0], v1[1]+v2[1], 0 ];
}
function VectorScale( v1, c ) {
	return [ v1[0]*c, v1[1]*c, 0 ];
}

function angle(cx, cy, ex, ey) {
    var dy = ey - cy;
    var dx = ex - cx;
    var theta = Math.atan2(dy, dx)+ Math.PI;
    theta *= 180 / Math.PI;
    return theta;
}

(function(){
    DeleteAllChildren(ItemsText)
    DeleteAllChildren(ItemsSounds)

    OpenMenuPage("text")

    $.Schedule(0.1, function(){
        SubscribeAndFireNetTableByKey("globals", "chat_wheel_items_list", function(v){
            ItemsList = v
            UpdateItemsList(v)
        })
    })

    for (let i = 1; i < 9; i++) {
        let LinePanel = $(`#LineButton${i}`)
        if(LinePanel){
            LinePanel.SetDialogVariable("linetext", $.Localize("#CUSTOM_CHAT_WHEEL_Default"))
        }
        let LinePanel2 = $(`#CallLine${i}`)
        if(LinePanel2){
            LinePanel2.SetDialogVariable("calllinetext", $.Localize("#CUSTOM_CHAT_WHEEL_Default"))
        }
    }
    $.Schedule(0.1, function(){
        SubscribeAndFireNetTableByKey("players", `player_${LocalPID}_chat_wheel`, function(v){
            UpdateChatWheel(v)
        })
    })

    Updater()

    CreateKeyBind()

    GameEvents.Subscribe("chat_wheel_say_line", OnSayLine)
    MAIN_PANEL.SetHasClass("IsSubscribed", true)
})();