-- ====================================================================
-- 6-SLOT SNAP POINTS (1 CENTER + 5 PENTAGON ROSETTE) - 10x10 GRID
-- ====================================================================

-- Symmetrical square coordinates:
local ORIGIN_X       = 7.0924
local ORIGIN_Z       = -7.0924

local STEP_X         = -1.5785
local STEP_Z         = 1.5785
local ROSETTE_RADIUS = 0.60

function onLoad()
    self.interactable = true
    buildGridSnapPoints()
end

function buildGridSnapPoints()
    local snapPoints = {}

    for row = 0, 9 do
        for col = 0, 9 do
            local centerX = ORIGIN_X + (col * STEP_X)
            local centerZ = ORIGIN_Z + (row * STEP_Z)

            -- 1. CENTRAL SNAP POINT (solo PC, Bond marker, or Landmark)
            table.insert(snapPoints, {
                position      = Vector(centerX, 0.1, centerZ),
                rotation      = Vector(0, 0, 0),
                rotation_snap = false  -- Allows free rotation at dead-center
            })

            -- 2. FIVE ORBIT SNAP POINTS (crowded node / group party)
            for i = 0, 4 do
                local angle = math.rad(i * 72)
                local snapX = centerX + (math.cos(angle) * ROSETTE_RADIUS)
                local snapZ = centerZ + (math.sin(angle) * ROSETTE_RADIUS)

                table.insert(snapPoints, {
                    position      = Vector(snapX, 0.1, snapZ),
                    rotation      = Vector(0, math.deg(-angle) + 90, 0),
                    rotation_snap = true
                })
            end
        end
    end

    self.setSnapPoints(snapPoints)
end