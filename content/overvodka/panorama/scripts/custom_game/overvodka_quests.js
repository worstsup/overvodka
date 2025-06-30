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
    
    // Check for required data
    if (QUEST_CONFIG.length === 0) {
        $.Msg("[Quests] Not ready to initialize: missing quest config");
        return;
    }
    
    if (!PLAYER_DATA || !PLAYER_DATA.activeQuests || !PLAYER_DATA.progress) {
        $.Msg("[Quests] Not ready to initialize: missing or incomplete player data");
        return;
    }
    
    const questList = $("#QuestList");
    if (!questList) return;
    
    questList.RemoveAndDeleteChildren();
    QUESTS = {};
    
    // Create UI for active quests
    const activeQuests = PLAYER_DATA.activeQuests;
    const progressData = PLAYER_DATA.progress;
    
    for (const questId in activeQuests) {
        if (!activeQuests[questId]) continue;
        
        const quest = QUEST_CONFIG.find(q => q.id === questId);
        if (!quest) {
            $.Msg(`[Quests] Quest config not found for: ${questId}`);
            continue;
        }
        
        const progress = progressData[questId] || 0;
        
        // Create UI elements
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
        progressBar.min = 0;
        progressBar.max = quest.max;
        progressBar.value = progress;
        
        const progressLabel = $.CreatePanel('Label', progressBar, '');
        progressLabel.AddClass("QuestProgressLabel");
        progressLabel.text = `${progress} / ${quest.max}`;
        
        QUESTS[quest.id] = {
            panel: panel,
            progressBar: progressBar,
            progressLabel: progressLabel,
            maxValue: quest.max
        };
        
        if (progress >= quest.max) {
            panel.AddClass("Completed");
        }
    }
    
    INITIALIZED = true;
    $.Msg("[Quests] UI fully initialized");
}

function UpdateQuestProgress(questId, value) {
    if (!INITIALIZED) {
        $.Msg("[Quests] Tried to update before initialization");
        return;
    }
    
    const quest = QUESTS[questId];
    if (!quest) {
        $.Msg(`[Quests] UpdateQuestProgress: Unknown quest ${questId}`);
        return;
    }
    
    const cappedValue = Math.min(value, quest.maxValue);
    quest.progressBar.value = cappedValue;
    quest.progressLabel.text = `${cappedValue} / ${quest.maxValue}`;
    
    if (cappedValue >= quest.maxValue) {
        quest.panel.AddClass("Completed");
    } else {
        quest.panel.RemoveClass("Completed");
    }
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
        $.Msg("[Quests] Updated player quest data");
        
        InitializeQuests();
        
        if (INITIALIZED && value.progress) {
            for (const questId in value.progress) {
                UpdateQuestProgress(questId, value.progress[questId]);
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