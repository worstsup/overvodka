"use strict";

let QUESTS = {};
let QUEST_CONFIG = [];
let PLAYER_DATA = null;
let INITIALIZED = false;

function OpenQuests() {
    const questRoot = $("#QuestRoot");
    if (!questRoot) return;
    questRoot.AddClass("Show");
}

function CloseQuests() {
    const questRoot = $("#QuestRoot");
    if (!questRoot) return;
    questRoot.RemoveClass("Show");
}

function InitializeQuests() {
    if (INITIALIZED) return;
    if (QUEST_CONFIG.length === 0 || !PLAYER_DATA || !PLAYER_DATA.activeQuests) return;
    
    const questList = $("#QuestList");
    if (!questList) return;
    
    questList.RemoveAndDeleteChildren();
    QUESTS = {};
    
    const activeQuests = PLAYER_DATA.activeQuests;
    const progressData = PLAYER_DATA.progress;
    const claimedData = PLAYER_DATA.claimed || {};

    for (const questId in activeQuests) {
        if (!activeQuests[questId]) continue;
        
        const quest = QUEST_CONFIG.find(q => q.id === questId);
        if (!quest) continue;
        
        const progress = progressData[questId] || 0;
        const isClaimed = claimedData[questId] || false;
        
        const panel = $.CreatePanel('Panel', questList, quest.id);
        panel.AddClass("QuestRow");
        
        const questInfo = $.CreatePanel('Panel', panel, '');
        questInfo.AddClass("QuestInfo");
        const title = $.CreatePanel('Label', questInfo, '');
        title.AddClass("QuestTitle");
        title.text = $.Localize(quest.name);
        const desc = $.CreatePanel('Label', questInfo, '');
        desc.AddClass("QuestDescription");
        desc.text = $.Localize(quest.description);
        
        const questProgress = $.CreatePanel('Panel', panel, '');
        questProgress.AddClass("QuestProgress");
        const progressBar = $.CreatePanel('ProgressBar', questProgress, '');
        progressBar.AddClass("QuestProgressBar");
        const progressLabel = $.CreatePanel('Label', progressBar, '');
        progressLabel.AddClass("QuestProgressLabel");
        
        const questReward = $.CreatePanel('Panel', panel, '');
        questReward.AddClass("QuestReward");
        const rewardLabel = $.CreatePanel('Label', questReward, '');
        rewardLabel.AddClass("QuestRewardLabel");
        rewardLabel.text = `+${quest.reward || 15}`;
        const rewardIcon = $.CreatePanel('Panel', questReward, '');
        rewardIcon.AddClass("QuestRewardIcon");
        
        QUESTS[quest.id] = {
            panel: panel,
            progressBar: progressBar,
            progressLabel: progressLabel,
            maxValue: quest.max
        };
        
        // Set initial state
        progressBar.max = quest.max;
        progressBar.value = progress;
        progressLabel.text = `${progress} / ${quest.max}`;
        
        if (progress >= quest.max) {
            panel.AddClass("Completed");
        }
        if (isClaimed) {
            panel.AddClass("Claimed");
        }
    }
    
    INITIALIZED = true;
}

function UpdateQuestProgress(questId, value, isClaimed) {
    if (!INITIALIZED) return;
    
    const quest = QUESTS[questId];
    if (!quest) return;
    
    const cappedValue = Math.min(value, quest.maxValue);
    quest.progressBar.value = cappedValue;
    quest.progressLabel.text = `${cappedValue} / ${quest.maxValue}`;
    
    if (cappedValue >= quest.maxValue) {
        quest.panel.AddClass("Completed");
    } else {
        quest.panel.RemoveClass("Completed");
    }

    quest.panel.SetHasClass("Claimed", isClaimed);
}

function HandleConfigUpdate(value) {
    if (value && value.questTypes) {
        if (Array.isArray(value.questTypes)) {
            QUEST_CONFIG = value.questTypes;
        } else {
            QUEST_CONFIG = Object.keys(value.questTypes).map(key => value.questTypes[key]);
        }
        
        $.Msg("[Quests] Updated quest config: ", QUEST_CONFIG);
        InitializeQuests();
    }
}

function HandlePlayerUpdate(playerID, value) {
    const localPlayerID = Game.GetLocalPlayerID().toString();
    
    if (playerID === localPlayerID) {
        PLAYER_DATA = value;
        
        if (!INITIALIZED) {
            InitializeQuests();
        } else {
            if (value.progress) {
                for (const questId in value.progress) {
                    const isClaimed = (value.claimed && value.claimed[questId]) || false;
                    UpdateQuestProgress(questId, value.progress[questId], isClaimed);
                }
            }
        }
    }
}

(function() {
    const configTable = CustomNetTables.GetTableValue("quests", "config");
    if (configTable) {
        HandleConfigUpdate(configTable);
    }
    const localPlayerID = Game.GetLocalPlayerID().toString();
    const playerDataTable = CustomNetTables.GetTableValue("quests", "player_" + localPlayerID);
    if (playerDataTable) {
        HandlePlayerUpdate(localPlayerID, playerDataTable);
    }
    CustomNetTables.SubscribeNetTableListener("quests", (tableName, key, value) => {
        $.Msg(`[Quests] NetTable update: ${key}`);
        
        if (key === "config") {
            HandleConfigUpdate(value);
        }
        else if (key.startsWith("player_")) {
            const playerID = key.substring(7);
            HandlePlayerUpdate(playerID, value);
        }
    });
    $.Schedule(3.0, () => {
        if (!INITIALIZED) {
            $.Msg("[Quests] Fallback initialization after timeout");
            const configTable = CustomNetTables.GetTableValue("quests", "config");
            if (configTable) {
                HandleConfigUpdate(configTable);
            }
            const localPlayerID = Game.GetLocalPlayerID().toString();
            const playerDataTable = CustomNetTables.GetTableValue("quests", "player_" + localPlayerID);
            if (playerDataTable) {
                HandlePlayerUpdate(localPlayerID, playerDataTable);
            }
            InitializeQuests();
        }
    });
    
    $.Msg("[Quests] Quest UI Initialized with Net Tables.");
})();