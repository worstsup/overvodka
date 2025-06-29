"use strict";

const QUESTS = {
    kills: {
        panel: $("#Quest_Kills"),
        progressBar: $("#KillsProgressBar"),
        progressLabel: $("#KillsProgressLabel"),
        maxValue: 5
    },
    ults: {
        panel: $("#Quest_Ults"),
        progressBar: $("#UltsProgressBar"),
        progressLabel: $("#UltsProgressLabel"),
        maxValue: 3
    },
    magicDamage: {
        panel: $("#Quest_Damage"),
        progressBar: $("#DamageProgressBar"),
        progressLabel: $("#DamageProgressLabel"),
        maxValue: 15000
    },
    physDamage: {
        panel: $("#Quest_PhysDamage"),
        progressBar: $("#PhysDamageProgressBar"),
        progressLabel: $("#PhysDamageProgressLabel"),
        maxValue: 15000
    }
};

function OpenQuests() {
    const questRoot = $("#QuestRoot");
    if (!questRoot) {
        $.Msg("[Quests] Quest root not found.");
        return;
    }
    questRoot.AddClass("Show");
}

function CloseQuests() {
    const questRoot = $("#QuestRoot");
    if (!questRoot) {
        $.Msg("[Quests] Quest root not found.");
        return;
    }
    questRoot.RemoveClass("Show");
}

/**
 * Updates a quest's progress on the UI.
 * @param {string} questId
 * @param {number} currentValue
 */
function UpdateQuestProgress(questId, currentValue) {
    const quest = QUESTS[questId];
    if (!quest) {
        $.Msg(`[Quests] Received update for unknown quest: ${questId}`);
        return;
    }
    const value = Math.min(currentValue, quest.maxValue);
    quest.progressBar.value = value;
    quest.progressBar.max = quest.maxValue;
    quest.progressLabel.text = `${value} / ${quest.maxValue}`;
    if (value >= quest.maxValue) {
        quest.panel.AddClass("Completed");
    } else {
        quest.panel.RemoveClass("Completed");
    }
}

(function() {
    GameEvents.Subscribe("quests_update_progress", function(data) {
        $.Msg(`[Quests] Received event: `, data);
        if (data.questId && data.value !== undefined) {
            UpdateQuestProgress(data.questId, data.value);
        }
    });

    GameUI.CustomUIConfig().TestQuestUpdate = UpdateQuestProgress;
    UpdateQuestProgress("kills", 0);
    UpdateQuestProgress("ults", 0);
    UpdateQuestProgress("magicDamage", 0);
    UpdateQuestProgress("physDamage", 0);
    $.Msg("[Quests] Quest UI Initialized.");
})();
