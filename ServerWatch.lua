------------------------------------------------------------
-- ServerWatch
-- World of Warcraft 1.12.1
--
-- Sends periodic RequestRaidInfo() probes.
-- UPDATE_INSTANCE_INFO = server answered.
------------------------------------------------------------

local SW = CreateFrame("Frame", "ServerWatchFrame")

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------

local PROBE_INTERVAL = 5.0
local TIMEOUT        = 15.0
local SOUND_INTERVAL = 3.0

------------------------------------------------------------
-- STATE
------------------------------------------------------------

local probeTimer = 0
local soundTimer = 0

local lastAck = 0
local armed = false
local disconnected = false

------------------------------------------------------------
-- WARNING FRAME
------------------------------------------------------------

local warning = CreateFrame("Frame", "ServerWatchWarning", UIParent)

warning:SetWidth(700)
warning:SetHeight(120)
warning:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
warning:SetFrameStrata("FULLSCREEN_DIALOG")
warning:Hide()

local text = warning:CreateFontString(
    nil,
    "OVERLAY",
    "GameFontNormalLarge"
)

text:SetPoint("CENTER", warning, "CENTER", 0, 0)
text:SetText("SERVER CONNECTION LOST!")
text:SetTextColor(1, 0.05, 0.05)


------------------------------------------------------------
-- CHAT
------------------------------------------------------------

local function Print(msg)

    DEFAULT_CHAT_FRAME:AddMessage(
        "|cffff4040[ServerWatch]|r " .. msg
    )

end


------------------------------------------------------------
-- ALERT
------------------------------------------------------------

local function StartAlert()

    if disconnected then
        return
    end

    disconnected = true
    soundTimer = SOUND_INTERVAL

    warning:Show()

    PlaySound("RaidWarning")

    Print(
        "|cffff0000SERVER NOT RESPONDING!|r"
    )

end


local function StopAlert()

    if not disconnected then
        return
    end

    disconnected = false

    warning:Hide()

    PlaySound("RaidWarning")

    Print(
        "|cff00ff00Server connection restored.|r"
    )

end


------------------------------------------------------------
-- EVENTS
------------------------------------------------------------

SW:RegisterEvent("PLAYER_ENTERING_WORLD")
SW:RegisterEvent("UPDATE_INSTANCE_INFO")


SW:SetScript("OnEvent", function()

    --------------------------------------------------------
    -- Login / zone transition
    --------------------------------------------------------

    if event == "PLAYER_ENTERING_WORLD" then

        armed = false
        disconnected = false

        lastAck = GetTime()

        probeTimer = 0
        soundTimer = 0

        warning:Hide()

        -- Send initial heartbeat
        RequestRaidInfo()

        return
    end


    --------------------------------------------------------
    -- Server answered heartbeat
    --------------------------------------------------------

    if event == "UPDATE_INSTANCE_INFO" then

        lastAck = GetTime()

        if not armed then

            armed = true

            Print("Connection monitor active.")

        end

        if disconnected then
            StopAlert()
        end

        return
    end

end)


------------------------------------------------------------
-- HEARTBEAT
------------------------------------------------------------

SW:SetScript("OnUpdate", function()

    local elapsed = arg1 or 0

    probeTimer = probeTimer + elapsed


    --------------------------------------------------------
    -- Send heartbeat
    --------------------------------------------------------

    if probeTimer >= PROBE_INTERVAL then

        probeTimer = 0

        RequestRaidInfo()

    end


    --------------------------------------------------------
    -- Don't alarm until at least one real reply has arrived.
    --------------------------------------------------------

    if not armed then
        return
    end


    --------------------------------------------------------
    -- Check response age
    --------------------------------------------------------

    local age = GetTime() - lastAck

    if age >= TIMEOUT then

        StartAlert()

    end


    --------------------------------------------------------
    -- Repeat warning sound while dead
    --------------------------------------------------------

    if disconnected then

        soundTimer = soundTimer + elapsed

        if soundTimer >= SOUND_INTERVAL then

            soundTimer = 0

            PlaySound("RaidWarning")

        end

    end

end)


------------------------------------------------------------
-- COMMANDS
------------------------------------------------------------

SLASH_SERVERWATCH1 = "/serverwatch"
SLASH_SERVERWATCH2 = "/swatch"

SlashCmdList["SERVERWATCH"] = function(msg)

    msg = string.lower(msg or "")

    if msg == "test" then

        if disconnected then

            StopAlert()

        else

            StartAlert()

        end

        return

    end


    if msg == "status" then

        local age = GetTime() - lastAck

        Print(
            string.format(
                "armed=%s, disconnected=%s, last reply %.1fs ago",
                tostring(armed),
                tostring(disconnected),
                age
            )
        )

        return

    end


    Print("/serverwatch status")
    Print("/serverwatch test")

end