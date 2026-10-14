-- [[ Reactive Persistent Charge Die Script ]] --

-- Base uncharged amber (#F59E0B) for font resets
local DEFAULT_AMBER = Color(245/255, 158/255, 11/255)

-- Set to true if you want the outer silhouette aura to also stay lit on the table
-- Set to false if you want only the glass core to hold the color while at rest
local KEEP_AURA_ON_REST = false

local settle_wait_id = nil

-- Seat palette mapping
local SEAT_COLORS = {
    ["Black"]  = Color(38/255, 38/255, 38/255),    -- GM: Uncharged Black (Obsidian)
    ["Pink"]   = Color(255/255, 46/255, 147/255),  -- Hot Neon Pink
    ["Orange"] = Color(249/255, 115/255, 22/255),   -- Combustion Orange
    ["White"]  = Color(148/255, 163/255, 184/255),  -- Punk Steel Grey
    ["Blue"]   = Color(168/255, 85/255, 247/255),  -- Spirit World Purple
    ["Red"]    = Color(234/255, 179/255, 8/255),    -- Regal Gold
    ["Green"]  = Color(16/255, 185/255, 129/255),   -- Emerald Green (#10B981)
}

local function clearPendingSettle()
    if settle_wait_id then
        Wait.stop(settle_wait_id)
        settle_wait_id = nil
    end
end

local function getSeatColor(player_color)
    if SEAT_COLORS[player_color] then
        return SEAT_COLORS[player_color]
    end
    return (Player[player_color] and Player[player_color].color) or Color.white
end

local function applyPlayerColor(player_color)
    clearPendingSettle()
    local pColor = getSeatColor(player_color)

    -- Permanently shifts the internal glass core to this player's color
    self.setColorTint(pColor)
    self.highlightOn(pColor)
end

function onPickUp(player_color)
    applyPlayerColor(player_color)
end

function onRandomize(player_color)
    applyPlayerColor(player_color)
end

function onDrop(player_color)
    clearPendingSettle()

    if not KEEP_AURA_ON_REST then
        settle_wait_id = Wait.condition(
            function()
                -- Turns off the selection outline once resting, but retains the core color tint
                self.highlightOff()
                settle_wait_id = nil
            end,
            function()
                return self.resting
            end,
            8,
            function()
                self.highlightOff()
                settle_wait_id = nil
            end
        )
    end
end

-- [[ Callable Font Hook ]] --
-- Call this function from your Pantheon Die font zone/script to purge the charge
function resetToAmber()
    clearPendingSettle()
    self.highlightOff()
    self.setColorTint(DEFAULT_AMBER)
end