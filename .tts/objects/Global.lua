-- ========================================================
-- GLOBAL SCRIPT
-- ========================================================

-- ============================================================================
-- 1. CENTRAL FACTION PALETTES & MATERIAL SHADERS
-- ============================================================================
-- TTS Material enum: 0 = Plastic, 1 = Wood, 2 = Metal, 3 = Cardboard
FACTIONS = {
    -- Mammon & High Finance (The Shard)
    Capital = { 
        name               = "Capital (Glistening Electrum)",
        color              = Color.new(0.79, 0.73, 0.50), -- Champagne electrum
        material           = 2,                           -- Metal
        specular_color     = Color.new(1.00, 0.97, 0.80), -- Pale icy gold
        specular_intensity = 0.92,
        specular_sharpness = 9.0,
        fresnel_strength   = 0.75
    },

    -- Parliament, Crown & Municipal Bureaucracy
    State = { 
        name               = "The State (Patinated Copper)",
        color              = Color.new(0.20, 0.36, 0.31), -- Thames mist verdigris
        material           = 1,                           -- Wood / Matte
        specular_color     = Color.new(0.45, 0.58, 0.51), -- Tarnished sage
        specular_intensity = 0.22,
        specular_sharpness = 2.5,
        fresnel_strength   = 0.20
    },

    -- Vauxhall Cabal / SIS Building
    Shadow = { 
        name               = "Shadow Cabal (Obsidian / Spectral)",
        color              = Color.new(0.09, 0.11, 0.11), -- Obsidian charcoal
        material           = 0,                           -- Plastic
        specular_color     = Color.new(0.16, 0.96, 0.65), -- Ghostly phosphorus green
        specular_intensity = 0.78,
        specular_sharpness = 7.0,
        fresnel_strength   = 0.90
    },

    -- St Paul's Cathedral & Manifest Christianity
    Faith = { 
        name               = "The Faith (Radiant Opalescence)",
        color              = Color.new(0.93, 0.91, 0.88), -- Alabaster ivory
        material           = 0,                           -- Plastic
        specular_color     = Color.new(1.00, 0.89, 0.60), -- Champagne amber gold
        specular_intensity = 0.65,
        specular_sharpness = 5.0,
        fresnel_strength   = 0.45
    },

    -- Player Factions
    Spirited = { 
        name               = "Spirity Violet",
        color              = Color.new(0.29, 0.12, 0.36),
        material           = 0,                           -- Plastic enamel
        specular_color     = Color.new(0.84, 0.72, 0.91),
        specular_intensity = 0.60,
        specular_sharpness = 8.5,
        fresnel_strength   = 0.40
    },
    Smoking = { 
        name               = "God of Smoking (Tobacco/Ash)",
        color              = Color.new(0.43, 0.29, 0.16),
        material           = 1,                           -- Dull wood / bakelite
        specular_color     = Color.new(0.54, 0.51, 0.47),
        specular_intensity = 0.15,
        specular_sharpness = 2.0,
        fresnel_strength   = 0.10
    },
    Punk = { 
        name               = "Cold Steel Punk",
        color              = Color.new(0.62, 0.68, 0.72),
        material           = 2,                           -- Machined cold metal
        specular_color     = Color.new(1.00, 1.00, 1.00),
        specular_intensity = 0.90,
        specular_sharpness = 9.5,
        fresnel_strength   = 0.90
    },

    -- Baseline Unclaimed State
    Neutral = { 
        name               = "Neutral Baseline",
        color              = Color.new(0.85, 0.82, 0.76),
        material           = 0,                           -- Neutral matte
        specular_color     = Color.new(1.00, 1.00, 1.00),
        specular_intensity = 0.20,
        specular_sharpness = 3.0,
        fresnel_strength   = 0.20
    }
}

CONTROLLABLE_TAG = "Controllable"
POI_TAG          = "POI"

-- ============================================================================
-- 2. UNIVERSAL POI COLLIDER & INJECTED SCRIPT
-- ============================================================================
local COLLIDER_URL = "https://www.dropbox.com/scl/fi/n06ucs6f0962rx6kn61ot/collider1.obj?rlkey=a7lfqlzxgjep8h17t0z5n78zz&st=lqsb6uer&dl=1"

local POI_LUA_SCRIPT = [=[
function onLoad()
    autoDetectApexFromMesh()
    self.addContextMenuItem("Perch on Roof", perchNearestObject)
end

function autoDetectApexFromMesh()
    local customData = self.getCustomObject()
    if not customData or not customData.mesh or customData.mesh == "" then return end

    WebRequest.get(customData.mesh, function(request)
        if request.is_error then return end
        parseMeshApex(request.text)
    end)
end

function parseMeshApex(objText)
    local maxY = -999999

    for line in string.gmatch(objText, "[^\r\n]+") do
        if string.sub(line, 1, 2) == "v " then
            local _, y, _ = string.match(line, "v%s+([%-%d%.eE]+)%s+([%-%d%.eE]+)%s+([%-%d%.eE]+)")
            if y then
                local numY = tonumber(y)
                if numY and numY > maxY then
                    maxY = numY
                end
            end
        end
    end

    if maxY ~= -999999 then
        local centeredApex = Vector(0, maxY + 0.1, 0)
        self.setSnapPoints({{
            position      = centeredApex,
            rotation      = Vector(0, 0, 0),
            rotation_snap = false
        }})
    end
end

function perchNearestObject(player_color)
    local snapPoints = self.getSnapPoints()
    if not snapPoints or #snapPoints == 0 then return end
    
    local targetWorld = self.positionToWorld(snapPoints[1].position)
    local allObjects = getAllObjects()
    local closestObj = nil
    local closestDist = 4.0

    for _, obj in ipairs(allObjects) do
        if obj ~= self and not obj.getLock() and obj.tag ~= "Surface" then
            local dist = Vector.distance(self.getPosition(), obj.getPosition())
            if dist < closestDist then
                closestDist = dist
                closestObj = obj
            end
        end
    end

    if closestObj then
        closestObj.setPositionSmooth(targetWorld + Vector(0, 0.1, 0), false, true)
        closestObj.setLock(true)
        broadcastToAll(closestObj.getName() .. " perches atop " .. self.getName(), {1, 0.4, 0.4})
    else
        broadcastToColor("No unlocked token found near " .. self.getName(), player_color, {1, 0.8, 0.2})
    end
end
]=]

-- ============================================================================
-- 3. LIFECYCLE HOOKS
-- ============================================================================
function onLoad()
    for _, obj in ipairs(getAllObjects()) do
        initializeObject(obj)
    end
end

function onObjectSpawn(obj)
    initializeObject(obj)
end

function onObjectTagUpdate(obj)
    initializeObject(obj)
end

-- Checks if an object qualifies for the alignment/control system
function isAlignable(obj)
    return obj.hasTag(CONTROLLABLE_TAG) or obj.hasTag(POI_TAG)
end

function initializeObject(obj)
    if isAlignable(obj) then
        setupUnifiedContextMenu(obj)
        applyCurrentFactionColor(obj)
    else
        registerPOIContext(obj)
    end
end

-- ============================================================================
-- 4. CONTEXT MENU & FACTION CONTROLLER
-- ============================================================================
function setupUnifiedContextMenu(obj)
    obj.clearContextMenu()

    -- POI conversion option if not yet converted
    if not obj.hasTag(POI_TAG) and obj.getCustomObject() ~= nil then
        obj.addContextMenuItem("Convert to POI", function()
            setupNewPOI(obj)
        end)
    end

    -- Keep roof perching accessible if it has already been converted to a POI
    if obj.hasTag(POI_TAG) then
        obj.addContextMenuItem("Perch on Roof", function(player_color)
            obj.call("perchNearestObject", player_color)
        end)
    end

    -- Alignment options
    for factionKey, factionData in pairs(FACTIONS) do
        obj.addContextMenuItem("Align: " .. factionData.name, function()
            assignFaction(obj, factionKey)
        end)
    end
end

function assignFaction(obj, factionKey)
    local factionData = FACTIONS[factionKey]
    if not factionData then return end

    -- 1. Manage tags
    for key, _ in pairs(FACTIONS) do
        obj.removeTag(key)
    end
    obj.addTag(factionKey)

    -- 2. Apply color tint
    obj.setColorTint(factionData.color)

    -- 3. Check and apply material shader settings
    local customData = obj.getCustomObject()
    if customData and customData.mesh and customData.mesh ~= "" then
        local reloadNeeded = (customData.material ~= factionData.material)
            or (math.abs((customData.specular_intensity or 0) - factionData.specular_intensity) > 0.05)
            or (math.abs((customData.specular_sharpness or 0) - factionData.specular_sharpness) > 0.5)
            or (math.abs((customData.fresnel_strength or 0) - factionData.fresnel_strength) > 0.05)

        customData.material           = factionData.material
        customData.specular_color     = factionData.specular_color
        customData.specular_intensity = factionData.specular_intensity
        customData.specular_sharpness = factionData.specular_sharpness
        customData.fresnel_strength   = factionData.fresnel_strength

        obj.setCustomObject(customData)
        if reloadNeeded then
            obj.reload()
        end
    end
end

function applyCurrentFactionColor(obj)
    -- Only re-apply if the piece has an existing faction tag;
    -- leave unaligned models untouched so manual styling isn't overwritten.
    for factionKey, factionData in pairs(FACTIONS) do
        if obj.hasTag(factionKey) then
            assignFaction(obj, factionKey)
            return
        end
    end
end

-- ============================================================================
-- 5. POI AUTO-CONVERTER LOGIC
-- ============================================================================
function registerPOIContext(obj)
    if obj.hasTag(POI_TAG) then return end

    if obj.getCustomObject() ~= nil then
        obj.addContextMenuItem("Convert to POI", function()
            setupNewPOI(obj)
        end)
    end
end

function setupNewPOI(targetObj)
    local customData = targetObj.getCustomObject()
    if not customData or not customData.mesh or customData.mesh == "" then
        broadcastToAll("Error: Assign a visual Mesh OBJ before converting!", {1, 0.3, 0.3})
        return
    end

    -- 1. Apply cylinder collider
    customData.collider = COLLIDER_URL
    targetObj.setCustomObject(customData)

    -- 2. Tag immediately as POI
    targetObj.addTag(POI_TAG)

    -- 3. Clear setup context menu item before injecting the POI script
    targetObj.clearContextMenu()

    -- 4. Inject apex detector and perching logic
    targetObj.setLuaScript(POI_LUA_SCRIPT)

    -- 5. Reload to compile
    targetObj.reload()
    
    local name = targetObj.getName() ~= "" and targetObj.getName() or "Custom Model"
    broadcastToAll("Converted " .. name .. " to POI!", {0.4, 1, 0.4})
end