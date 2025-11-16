"use strict";

var minimap_container = null;
var OVERVODKA_TIMERS_ROOT = null;

var GOLDEN_RAIN_DURATION = 20.0;
var HAMSTER_DURATION     = 30.0;

function FormatTime(sec) {
    if (sec < 0) sec = 0;
    var minutes = Math.floor(sec / 60);
    var seconds = Math.floor(sec % 60);
    var strMin = minutes < 10 ? "0" + minutes : "" + minutes;
    var strSec = seconds < 10 ? "0" + seconds : "" + seconds;
    return strMin + ":" + strSec;
}

function GetEventPhase(data, now, duration) {
    if (!data) return null;

    var times = [];
    if (data.t1 && data.t1 > 0) times.push(data.t1);
    if (data.t2 && data.t2 > 0) times.push(data.t2);

    if (times.length === 0) return null;

    var active = null;
    var upcoming = null;

    for (var i = 0; i < times.length; i++) {
        var t = times[i];

        if (now >= t && now <= t + duration) {
            active = t;
            break;
        } else if (t > now && (upcoming === null || t < upcoming)) {
            upcoming = t;
        }
    }

    if (active !== null) {
        return { type: "active", time: active };
    }
    if (upcoming !== null) {
        return { type: "upcoming", time: upcoming };
    }

    return null;
}

function UpdateEventTimer(eventKey, panelId, labelId, duration) {
    if (!OVERVODKA_TIMERS_ROOT) return;

    var panel = OVERVODKA_TIMERS_ROOT.FindChildTraverse(panelId);
    if (!panel) return;

    var label = panel.FindChildTraverse(labelId);
    var radial = panel.FindChildTraverse("NewTimerRadial");

    var now = Game.GetGameTime();
    var data = CustomNetTables.GetTableValue("overvodka_events", eventKey);
    var phase = GetEventPhase(data, now, duration);

    if (!phase) {
        panel.visible = false;
        return;
    }

    panel.visible = true;

    var remainingToStart = 0;
    var displayTime = 0;
    var frac = 0;

    if (phase.type === "upcoming") {
        remainingToStart = phase.time - now;
        if (remainingToStart < 0) remainingToStart = 0;

        if (panel._overvodkaLastTargetTime !== phase.time) {
            panel._overvodkaLastTargetTime = phase.time;
            panel._overvodkaFullTime = remainingToStart;
        }

        var full = panel._overvodkaFullTime || remainingToStart || 1;
        if (remainingToStart > full) full = remainingToStart;
        panel._overvodkaFullTime = full;

        frac = 1.0 - (remainingToStart / full);
        if (frac < 0.0) frac = 0.0;
        if (frac > 1.0) frac = 1.0;

        displayTime = remainingToStart;
    } else if (phase.type === "active") {
        remainingToStart = 0;
        displayTime = 0;
        frac = 1.0;
    }

    panel._overvodkaPhaseType = phase.type;
    panel._overvodkaRemainingToStart = remainingToStart;

    if (label) {
        label.text = FormatTime(displayTime);
    }

    if (radial) {
        var angle = 360 * frac;
        radial.style.clip = "radial(50.0% 50.0%, 0deg," + angle + "deg)";
    }
}

function OvervodkaTimersThink() {
    UpdateEventTimer("golden_rain", "OvervodkaGoldenRainTimer", "GoldenRainLabel", GOLDEN_RAIN_DURATION);
    UpdateEventTimer("hamster",     "OvervodkaHamsterTimer",     "HamsterLabel",     HAMSTER_DURATION);

    $.Schedule(0.1, OvervodkaTimersThink);
}

function AttachEventTooltip(panelId, eventKey, duration, baseLocKey) {
    if (!OVERVODKA_TIMERS_ROOT) return;

    var panel = OVERVODKA_TIMERS_ROOT.FindChildTraverse(panelId);
    if (!panel) return;

    panel.SetPanelEvent('onmouseover', function() {
        var now = Game.GetGameTime();
        var data = CustomNetTables.GetTableValue("overvodka_events", eventKey);
        var phase = GetEventPhase(data, now, duration);

        var text = "";

        if (!phase) {
            var doneKey = baseLocKey + "_done";
            text = $.Localize(doneKey);
        } else if (phase.type === "upcoming") {
            var base = $.Localize(baseLocKey);
            var remaining = phase.time - now;
            if (remaining < 0) remaining = 0;
            text = base + " " + FormatTime(remaining);
        } else if (phase.type === "active") {
            var activeKey = baseLocKey + "_active";
            text = $.Localize(activeKey);
        }

        $.DispatchEvent('DOTAShowTextTooltip', panel, text);
    });

    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTextTooltip', panel);
    });
}

(function() {
    minimap_container = FindDotaHudElement("minimap_container");
    if (minimap_container) {
        OVERVODKA_TIMERS_ROOT = $("#OvervodkaEventsTimers");
        OVERVODKA_TIMERS_ROOT.SetParent(minimap_container);

        AttachEventTooltip(
            "OvervodkaGoldenRainTimer",
            "golden_rain",
            GOLDEN_RAIN_DURATION,
            "#overvodka_tooltip_golden_rain"
        );

        AttachEventTooltip(
            "OvervodkaHamsterTimer",
            "hamster",
            HAMSTER_DURATION,
            "#overvodka_tooltip_hamster"
        );
    } else {
        $.Msg("[OvervodkaEventsTimers] minimap_container not found!");
    }

    OvervodkaTimersThink();
})();
