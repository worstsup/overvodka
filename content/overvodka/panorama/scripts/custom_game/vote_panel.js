"use strict";

var Vote = {};

(function() {
    const candidatesContainer = $("#VoteCandidatesContainer");
    const resultsContainer    = $("#VoteResultsContainer");
    const histogramContainer  = $("#HistogramContainer");

    let isInitialized = false;
    let hasVoted       = false;
    let voteCounts     = {};

    Vote.Initialize = function() {
        if (isInitialized) return;
        isInitialized = true;
        GameEvents.SendCustomGameEventToServer("vote_get_info", {});
    };

    GameEvents.Subscribe("vote_info_response", OnVoteInfoReceived);

    function OnVoteInfoReceived(data) {
        if (!data.success) return;
        let candidates = data.candidates;
        if (!Array.isArray(candidates) && typeof candidates === "object") {
            candidates = Object.values(candidates);
        }
        hasVoted = (data.player_vote !== null && data.player_vote !== undefined);
        voteCounts = data.vote_counts || {};
        if (hasVoted) {
            ShowResults();
        } else {
            ShowCandidates(candidates);
        }
    }

    function ShowCandidates(candidates) {
        if (!Array.isArray(candidates)) {
            $.Msg("[Vote] ERROR: expected an array of candidates, got:", candidates);
            return;
        }
        candidatesContainer.RemoveAndDeleteChildren();
        candidatesContainer.style.visibility = "visible";
        resultsContainer.style.visibility = "collapse";

        for (const heroName of candidates) {
            const card = $.CreatePanel("Button", candidatesContainer, `VoteCard_${heroName}`);
            card.BLoadLayoutSnippet("HeroVoteCard");

            card.FindChildTraverse("HeroImage").SetImage(`file://{images}/custom_game/hero_vote/${heroName.replace("npc_dota_hero_", "")}.png`);
            card.FindChildTraverse("HeroName").text = $.Localize(`#${heroName}`);

            card.SetPanelEvent("onactivate", () => SubmitVote(heroName));
        }
    }

    function ShowResults() {
        
        resultsContainer.style.visibility = "visible";
        candidatesContainer.style.visibility = "collapse";
        histogramContainer.RemoveAndDeleteChildren();
        
        let total = Object.values(voteCounts).reduce((a,b) => a+b, 0);
        const sorted = Object.keys(voteCounts).sort((a,b) => voteCounts[b] - voteCounts[a]);
        for (const heroName of sorted) {
            const votes = voteCounts[heroName];
            const pct   = total > 0 ? ((votes/total)*100).toFixed(1) : "0.0";
            const bar = $.CreatePanel("Panel", histogramContainer, `ResultBar_${heroName}`);
            bar.BLoadLayoutSnippet("HistogramBar");
            bar.FindChildTraverse("BarHeroName").text   = $.Localize(`#${heroName}`);
            bar.FindChildTraverse("BarPercentage").text = `${pct}%`;
            $.Schedule(0.1, () => {
                bar.FindChildTraverse("BarFill").style.width = `${pct}%`;
            });
        }
    }


    function SubmitVote(heroName) {
        if (hasVoted) return ShowResults();
        Game.EmitSound("ui_generic_button_click");
        GameEvents.SendCustomGameEventToServer("vote_submit", { hero_name: heroName });
    }
})();