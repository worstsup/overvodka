"use strict";

var Leaderboard = {};

(function() {
    const Buttons = $("#Buttons");
    const ContainerAll = $("#PlayerContainer");
    const Container = $("#LineSelf");
    const ProfilePanel = $("#ProfilePanel");
    const RankContainer = $("#RankContainer");
    const LineSelf = $("#LineSelf");
    const TopHeroesRow = $("#TopHeroesRow");
    let LocalPlayerID = Players.GetLocalPlayer();
    let SelectedCategory = -1;
    let CurrentProfileSteam32 = null;
    const FOUNDERS = new Set([409188637, 885116894, 1248303404, 1362960359]);
    const LB_CACHE = { 1: null, 2: null, 3: null };
    const LB_REQUESTED = { 1: false, 2: false, 3: false };
    const PROFILE_CACHE = {};
    const PROFILE_INFLIGHT = {};
    const TTL_MS = 60 * 1000;

    function rankImageFromClass(rankClass) {
        const map = {
            Bronze: "bronze", Silver: "silver", Gold: "gold", Platinum: "platinum",
            Diamond: "diamond", Mythical: "mythical", Legend: "legend",
            Divine: "divine", Hamstergod: "hamstergod"
        };
        const key = map[rankClass] || "bronze";
        return 'url("file://{images}/custom_game/ranks/' + key + '.png")';
    }

    function WarmUp(panel) {
        if (!panel) return;
        const _w = panel.actuallayoutwidth;
        const _h = panel.actuallayoutheight;

        panel.AddClass("warmup");
        $.Schedule(0, function () {
            panel.RemoveClass("warmup");
        });
    }

    function getLeaderboardTable(cat) {
        if (LB_CACHE[cat]) return LB_CACHE[cat];
        const t = CustomNetTables.GetTableValue("globals", "leaderboard_category_" + cat);
        if (t) LB_CACHE[cat] = t;
        return LB_CACHE[cat];
    }

    function gamesWordRu(n) {
        n = Math.abs(Number(n)) || 0;
        const n10 = n % 10, n100 = n % 100;
        if (n10 === 1 && n100 !== 11) return $.Localize("#ov_game_one");
        if (n10 >= 2 && n10 <= 4 && (n100 < 10 || n100 >= 20)) return $.Localize("#ov_game_few");
        return $.Localize("#ov_game_many");
    }

    function canViewerSeeMatches(ownerSteam32) {
        try {
            if (String(ownerSteam32) === String(GetSteamID32(LocalPlayerID))) return true;

            if (typeof IsPlayerSubscribed === "function") {
                try {
                    if (IsPlayerSubscribed(LocalPlayerID)) return true;
                } catch (e) {
                    $.Msg("IsPlayerSubscribed threw:", e);
                }
            }

            return false;
        } catch (err) {
            $.Msg("canViewerSeeMatches error:", err);
            return false;
        }
    }

    function CreateMatchRow(container, match) {
        const row = $.CreatePanel('Panel', container, '');
        row.BLoadLayoutSnippet("MatchRow");
        if (match && match.win === 1) {
            row.AddClass("Win");
        } else if (match) {
            row.AddClass("Loss");
        }
        const icon = row.FindChildrenWithClassTraverse("MatchHeroIcon")[0];
        const name = row.FindChildrenWithClassTraverse("MatchHeroName")[0];
        const kda  = row.FindChildrenWithClassTraverse("MatchKDA")[0];
        const dt   = row.FindChildrenWithClassTraverse("MatchDate")[0];

        const realName = GetOvervodkaHeroName(match && (match.heroname_script));
        const heroPath = "file://{images}/heroes/" + realName + ".png";

        if (icon) {
            if (icon.SetImage) {
                icon.SetImage(heroPath);
            } else {
                icon.style.backgroundImage = 'url("' + heroPath + '")';
            }
        }
        if (name) name.text = match.heroname || realName;
        if (kda)  kda.text = (match.kills||0) + " / " + (match.deaths||0) + " / " + (match.assists||0);
        if (dt)   dt.text = formatDMY(match.date) || "";
    }


    function localizedSince(dateText) {
        if (!dateText) return "";
        const prefix = $.Localize("#ov_in_game_since_prefix");
        return prefix + " " + dateText;
    }

    function formatGames(n) {
        return String(n) + " " + gamesWordRu(n);
    }

    function ensureLeaderboard(cat) {
        if (LB_CACHE[cat]) return;
        if (LB_REQUESTED[cat]) return;
        LB_REQUESTED[cat] = true;
        GameEvents.SendCustomGameEventToServer("server_get_leaderboard_info", { category: cat });
    }

    function findValueInRecords(tbl, s32) {
        if (!tbl || !tbl.records) return null;
        for (let i = 1; i <= 200; i++) {
            const rec = tbl.records[i];
            if (!rec) continue;
            if (String(rec.steamid) === String(s32)) {
                return Number(rec.value);
            }
        }
        for (const k in tbl.records) {
            const rec = tbl.records[k];
            if (rec && String(rec.steamid) === String(s32)) {
                return Number(rec.value);
            }
        }
        return null;
    }

    function now() { return Date.now(); }

    function modeLabel(cat) {
        if (cat === 1) return "SOLO";
        if (cat === 2) return "DUO";
        if (cat === 3) return "5X5";
        return "";
    }

    function setProfileRankDisplay(value, cat) {
        const icon = $("#ProfileRankIcon");
        const text = $("#ProfileRankText");
        if (!icon || !text || value == null) return;

        const rankClass = GetRankClassName(Number(value) || 0);
        icon.style.backgroundImage = rankImageFromClass(rankClass);
        icon.visible = true;

        const lbl = modeLabel(cat);
        text.text = value + (lbl ? (" (" + lbl + ")") : "");
        text.visible = true;
    }

    function updateProfileMaxRankIcon(steam32) {
        const s32 = (steam32 != null ? steam32 : GetSteamID32(LocalPlayerID));
        let bestVal = null, bestCat = null;

        for (const cat of [1, 2, 3]) {
            const tbl = getLeaderboardTable(cat);
            if (!tbl) { ensureLeaderboard(cat); continue; }

            let v = null;

            if (tbl.players && tbl.players[s32] && tbl.players[s32].value != null) {
                v = Number(tbl.players[s32].value);
            }

            if (v == null) {
                v = findValueInRecords(tbl, s32);
            }

            if (v != null && (bestVal == null || v > bestVal)) {
                bestVal = v; bestCat = cat;
            }
        }

        if (bestVal != null) setProfileRankDisplay(bestVal, bestCat);
    }

    function NormalizeArray(t) {
        const arr = [];
        if (!t) return arr;

        if (t.length !== undefined) {
            for (let i = 0; i < t.length; i++) {
                if (t[i] !== undefined && t[i] !== null) arr.push(t[i]);
            }
            return arr;
        }
        const tmp = {};
        for (const k in t) {
            const n = parseInt(k, 10);
            if (!isNaN(n)) tmp[n] = t[k];
        }
        let i = 0;
        while (tmp[i] !== undefined) { arr.push(tmp[i]); i++; }
        if (arr.length === 0) {
            i = 1;
            while (tmp[i] !== undefined) { arr.push(tmp[i]); i++; }
        }
        return arr;
    }

    function formatDMY(iso) {
        if (!iso) return "";
        const d = new Date(iso);
        if (isNaN(d.getTime())) return "";
        const dd = String(d.getDate()).padStart(2, "0");
        const mm = String(d.getMonth() + 1).padStart(2, "0");
        const yy = d.getFullYear();
        return dd + "-" + mm + "-" + yy;
    }

    function ShowProfile(isProfile) {
        if (ProfilePanel) ProfilePanel.SetHasClass("Visible", isProfile);
        if (RankContainer) RankContainer.visible = !isProfile;
        if (LineSelf) LineSelf.visible = !isProfile;
    }
    
    Leaderboard.Initialize = function() {
        if (SelectedCategory === -1) {
            Leaderboard.SelectCategory(4);
        }
    };

    Leaderboard.SelectCategory = function(CategoryID) {
        const localS32 = GetSteamID32(LocalPlayerID);

        if (SelectedCategory === CategoryID) {
            if (CategoryID === 4 && CurrentProfileSteam32 !== localS32) {
                DeselectAllExceptOf(Buttons, 4);
                ShowProfile(true);
                requestProfileAndLoad(localS32);
            }
            return;
        }

        SelectedCategory = CategoryID;
        DeselectAllExceptOf(Buttons, CategoryID);

        const isProfile = (CategoryID === 4);
        ShowProfile(isProfile);

        if (isProfile) {
            requestProfileAndLoad(CurrentProfileSteam32 || localS32);
        } else {
            UpdateRating();
        }
    };

    function SetHeroPortrait(panel, path) {
        if (!panel) return;
        panel.style.backgroundImage = 'url("' + path + '")';
    }

    function requestProfileAndLoad(steam32) {
        const s32 = (steam32 != null ? steam32 : GetSteamID32(LocalPlayerID));
        CurrentProfileSteam32 = s32;

        const cached = PROFILE_CACHE[s32];
        if (cached && (now() - cached.ts) < TTL_MS && cached.data) {
            fillProfile(cached.data, s32);
        } else if (!PROFILE_INFLIGHT[s32]) {
            PROFILE_INFLIGHT[s32] = true;
            GameEvents.SendCustomGameEventToServer("server_get_profile_stats", { steamid: s32 });
        }

        updateProfileMaxRankIcon(s32);
    }

    Leaderboard.OpenProfileForSteamID = function(steam32) {
        SelectedCategory = 4;
        DeselectAllExceptOf(Buttons, 4);
        ShowProfile(true);
        requestProfileAndLoad(steam32);
    };

    GameEvents.Subscribe("server_profile_update", function (data) {
        const steam32 = data.steamid;
        if (!steam32) return;
        PROFILE_INFLIGHT[steam32] = false;

        const table = CustomNetTables.GetTableValue("globals", "profile_" + steam32);
        if (table) {
            PROFILE_CACHE[steam32] = { data: table, ts: now() };
            if (SelectedCategory === 4 && CurrentProfileSteam32 == steam32) {
                fillProfile(table, steam32);
            }
        }
    });

    function fillProfile(data, steam32) {
        const avatar   = $("#ProfileAvatar");
        const nickname = $("#ProfileNickname");
        if (avatar)   avatar.accountid = steam32;
        if (nickname) nickname.accountid = steam32;
        const since = $("#ProfileSince");
        if (since) {
            if (FOUNDERS.has(Number(steam32))) {
                since.text = localizedSince("27-05-2024");
            } else {
                const txt = formatDMY(data.first_game_date);
                since.text = txt ? localizedSince(txt) : "";
            }
        }
        const statGames = $("#StatGames");
        const statWin   = $("#StatWinPct");
        const statKda   = $("#StatKDA");

        if (statGames) statGames.text = String(data.games || 0);
        if (statWin)   statWin.text   = Number(data.win_pct || 0).toFixed(2) + "%";
        if (statKda)   statKda.text   = Number(data.kda || 0).toFixed(2);

        const row = TopHeroesRow;
        const listRaw = data.top_heroes;
        const list = NormalizeArray(listRaw);

        if (!row) return;
        if (!list || list.length < 3) { row.visible = false; return; }
        row.visible = true;

        const slots = [
            { root: $("#TopHero2"), img: $("#TopHero2_Image"), name: $("#TopHero2_Name"), stats: $("#TopHero2_Stats") },
            { root: $("#TopHero1"), img: $("#TopHero1_Image"), name: $("#TopHero1_Name"), stats: $("#TopHero1_Stats") },
            { root: $("#TopHero3"), img: $("#TopHero3_Image"), name: $("#TopHero3_Name"), stats: $("#TopHero3_Stats") },
        ];
        const order = [1, 0, 2];

        for (let i = 0; i < 3; i++) {
            const h = list[order[i]];
            const real = (h && h.heroname_script || "Error").toLowerCase();
            const path = "file://{images}/heroes/selection/" + real + ".png";
            if (slots[i].root)  slots[i].root.visible = true;
            if (slots[i].img) {
                SetHeroPortrait(slots[i].img, path);
                WarmUp(slots[i].img);
            }
            if (slots[i].name)  slots[i].name.text = h.heroname || real;

            const wp  = (h && h.win_pct != null ? Number(h.win_pct).toFixed(2) : "0.00") + "%";
            const kda = (h && h.kda != null ? Number(h.kda).toFixed(2) : "0.00");
            const g   = (h && h.games != null ? h.games : 0);
            const gamesStr = formatGames(g);
            if (slots[i].stats) slots[i].stats.text = gamesStr + " • " + wp + " • KDA " + kda;
        }


        const matchHistoryPanel = $("#MatchHistory");
        const matchList = $("#MatchList");
        const matchNotice = $("#MatchPrivateNotice");
        const BuyButtonStats = $("#BuyButtonStats");

        if (matchHistoryPanel && matchList && matchNotice) {
            DeleteAllChildren(matchList);

            const rawMatches = data.matches || {};
            let matchesArr = NormalizeArray(rawMatches) || [];

            if (!Array.isArray(matchesArr)) {
                const tmp = [];
                for (const k in matchesArr) {
                    if (matchesArr.hasOwnProperty(k)) tmp.push(matchesArr[k]);
                }
                matchesArr = tmp;
            }

            if (matchesArr.length === 0) {
                matchHistoryPanel.visible = true;
                matchList.visible = false;
                matchNotice.visible = false; 
                return; 
            }

            const canView = canViewerSeeMatches(steam32);
            if (!canView && String(steam32) !== String(GetSteamID32(LocalPlayerID))) {
                matchHistoryPanel.visible = true;
                matchList.visible = false;
                matchNotice.visible = true;
                BuyButtonStats.visible = true;
                matchNotice.text = $.Localize("#ov_prime_required") || "Доступно с Overvodka Prime";
                return;
            }

            matchHistoryPanel.visible = true;
            matchNotice.visible = false;
            matchList.visible = true;
            BuyButtonStats.visible = false;

            for (let i = 0; i < matchesArr.length; i++) {
                CreateMatchRow(matchList, matchesArr[i]);
            }
        }
    }

    function UpdateRating() {
        if (SelectedCategory === -1) return;
        let Table = CustomNetTables.GetTableValue("globals", `leaderboard_category_${SelectedCategory}`);
        if (!Table) {
            GameEvents.SendCustomGameEventToServer("server_get_leaderboard_info", { category: SelectedCategory });
        } else {
            LoadLeaderboardRating(SelectedCategory);
        }
    }

    function LoadLeaderboardRating(CategoryID) {
        let Table = CustomNetTables.GetTableValue("globals", `leaderboard_category_${SelectedCategory}`);
        DeleteAllChildren(ContainerAll);
        DeleteAllChildren(Container);
        if (Table && Table.records) {
            for (let i = 1; i <= 100; i++) {
                let Player = Table.records[i];
                if (Player) {
                    CreatePlayer(i, ContainerAll, Player.steamid, Player.value);
                }
            }
        }
        let SteamID32 = GetSteamID32(LocalPlayerID);
        if (Table && Table.players && Table.players[SteamID32]) {
            let Rank = Table.players[SteamID32].ranking ? Table.players[SteamID32].ranking : 0;
            let Value = Table.players[SteamID32].value ? Table.players[SteamID32].value : 0;
            CreatePlayer(Rank, Container, SteamID32, Value);
        }
    }

    function CreatePlayer(Rank, Container, SteamID, Value) {
        let PlayerPanel = $.CreatePanel('Panel', Container, '');
        PlayerPanel.BLoadLayoutSnippet("Player");
        PlayerPanel.SetPanelEvent("onactivate", function () {
            Leaderboard.OpenProfileForSteamID(SteamID);
        });
        PlayerPanel.SetDialogVariableInt("Rank", parseInt(Rank));
        let RankIconClass = GetRankClassName(Value);
        PlayerPanel.AddClass(RankIconClass);
        PlayerPanel.SetHasClass("odd", Rank % 2 != 0);
        PlayerPanel.SetDialogVariable("rating", Value + "");
        let PlayerImage = PlayerPanel.FindChildrenWithClassTraverse("PlayerImage")[0];
        if (PlayerImage) {
            PlayerImage.accountid = SteamID;
        }
        let PlayerNickname = PlayerPanel.FindChildrenWithClassTraverse("PlayerNickname")[0];
        if (PlayerNickname) {
            PlayerNickname.accountid = SteamID;
        }
    }

    function DeselectAllExceptOf(p, CategoryID) {
        let Childs = p.GetChildCount();
        for (let i = 0; i < Childs; i++) {
            const Child = p.GetChild(i);
            if (Child) {
                if (Child.id != "Category" + CategoryID) {
                    Child.RemoveClass("Selected");
                } else {
                    Child.AddClass("Selected");
                }
            }
        }
    }

    GameEvents.Subscribe("server_leaderboard_update", function(data) {
        const cat = data.category;
        if (cat === 1 || cat === 2 || cat === 3) {
            const tbl = CustomNetTables.GetTableValue("globals", "leaderboard_category_" + cat);
            if (tbl) LB_CACHE[cat] = tbl;
        }

        if (data.category === SelectedCategory) {
            LoadLeaderboardRating(data.category);
        }

        if (SelectedCategory === 4 && (cat === 1 || cat === 2 || cat === 3)) {
            updateProfileMaxRankIcon(CurrentProfileSteam32);
        }
    });
})();
