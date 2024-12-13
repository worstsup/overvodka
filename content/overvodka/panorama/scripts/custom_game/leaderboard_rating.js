const LeaderboardMain = $("#LeaderboardMain")
const Buttons = $("#Buttons")
const ContainerAll = $("#PlayerContainer")
const Container = $("#LineSelf")

let LocalPlayerID = Players.GetLocalPlayer()
let SelectedCategory = -1

// Обозначения категорий:
// 1 - Соло
// 2 - Дуо

function ToggleLeaderboard(){
    LeaderboardMain.SetHasClass("Show", !LeaderboardMain.BHasClass("Show"))

    if(SelectedCategory == -1){
        SelectCategory(1)
    }
}

function SelectCategory(CategoryID){
    if(SelectedCategory == CategoryID){
        return
    }

    SelectedCategory = CategoryID
    DeselectAllExceptOf(Buttons, CategoryID)

    UpdateRating()
}

function UpdateRating(){
    if(SelectedCategory == -1){
        return
    }

    let Table = CustomNetTables.GetTableValue("globals", `leaderboard_category_${SelectedCategory}`);
    if(!Table){
        GameEvents.SendCustomGameEventToServer( "server_get_leaderboard_info", {category: SelectedCategory} )
    }else{
        LoadLeaderboardRating(SelectedCategory)
    }
}

function LoadLeaderboardRating(CategoryID){
    let Table = CustomNetTables.GetTableValue("globals", `leaderboard_category_${SelectedCategory}`);
    DeleteAllChildren(ContainerAll)
    DeleteAllChildren(Container)
    if(Table.records){
        for(let i=1; i<=100; i++){
            let Player = Table.records[i]
            if(Player){
                CreatePlayer(i, ContainerAll, Player.steamid, Player.value)
            }
        }
    }
    let SteamID32 = GetSteamID32(LocalPlayerID)
    if(Table.players && Table.players[SteamID32]){
        let Rank = Table.players[SteamID32].ranking ? Table.players[SteamID32].ranking : 0
        let Value = Table.players[SteamID32].value ? Table.players[SteamID32].value : 0
        CreatePlayer(Rank, Container, SteamID32, Value)
    }
}

function CreatePlayer(Rank, Container, SteamID, Value){
    let PlayerPanel = $.CreatePanel('Panel', Container, '')
    PlayerPanel.BLoadLayoutSnippet("Player");
    PlayerPanel.SetDialogVariableInt("Rank", parseInt(Rank))

    let RankIconClass = GetRankClassName(Value)
    
    PlayerPanel.AddClass(RankIconClass)
    
    PlayerPanel.SetHasClass("odd", Rank%2 != 0)

    PlayerPanel.SetDialogVariable("rating", Value+"")

    let PlayerImage = PlayerPanel.FindChildrenWithClassTraverse("PlayerImage")[0]
    if(PlayerImage){
        PlayerImage.accountid = SteamID
    }
    let PlayerNickname = PlayerPanel.FindChildrenWithClassTraverse("PlayerNickname")[0]
    if(PlayerNickname){
        PlayerNickname.accountid = SteamID
    }
}

function DeselectAllExceptOf(p, CategoryID){
    let Childs = p.GetChildCount()
    for (let i = 0; i < Childs; i++) {
        const Child = p.GetChild(i)
        if(Child){
            if(Child.id != "Category"+CategoryID){
                Child.RemoveClass("Selected")
            }else{
                Child.AddClass("Selected")
            }
        }
    }
}

(function(){
    GameEvents.Subscribe("server_leaderboard_update", function(data){
        LoadLeaderboardRating(data.category)
    });
})();