"use strict";

var ChatWheel = {};
const SettingsBody = $("#SettingsBody");
const ItemsText = $("#ItemsText");
const ItemsSounds = $("#ItemsSounds");
const SettingsVariantsTable = $("#SettingsVariantsTable");
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

let ItemsList = {}

let CurrentOpenedPage = undefined
let CurrentSelectLine = 0
let bCallBodyIsActive = false
let CurrentSelectedCallLine = 0

let UISCALE_X = 1;
let UISCALE_Y = 1;
(function() {
    DeleteAllChildren(ItemsText)
    DeleteAllChildren(ItemsSounds)
    const LocalPID = Players.GetLocalPlayer()
    OpenMenuPage("text")

    $.Schedule(0.1, function(){
        SubscribeAndFireNetTableByKey("globals", "chat_wheel_items_list", function(v){
            ItemsList = v
            UpdateItemsList(v)
        })
    })
    $.Schedule(0.1, function(){
        SubscribeAndFireNetTableByKey("players", `player_${LocalPID}_chat_wheel`, function(v){
            UpdateChatWheel(v)
        })
    })
    ChatWheel.Initialize = function() {
        Game.EmitSound("UUI_SOUNDS.ChatWheelOpen");
        SettingsBody.SetHasClass("Show", true)
    }
})();

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