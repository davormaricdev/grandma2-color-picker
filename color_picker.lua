--------------------------------------------------------
------------------------ README ------------------------
-- This LUA Plugin assumes that you've already created Sequence containing colors
-- and Filter with Color - Value Times attributes.
--
---- SETUP
------ Fresh show file:
-------- Step 1. Load not active color images at Image 16 THRU 27,
-------- Step 2. Load active color images at Image 32 THRU 43,
-------- Step 3. Load not active sweep image at Image 48 THRU 52,
-------- Step 4. Load active sweep images at Image 53 THRU 57,
-------- Step 5. Run script.
------ Existing show file:
-------- Go through USER DEFINED AREA, adjust parameters there and go through the steps above.
--------------------------------------------------------
---- Copyright: Davor Maric, davormaric@outlook.com ----
--------------------------------------------------------

function Start()
    -- USER DEFINED AREA
    local colors = {
        -- {
        --     label = "White", -- Name of the color.
        --     preset = 1, -- Where can the color be found in a Color preset?
        --     cue = 1, -- Which cue triggers this color at given sequence (you can set sequence in properties).
        --     image = 16, -- How should the color look when it is not selected?
        --     imageActive = 32 -- How should the color look when it is selected?
        -- },
        {
            label = "White",
            preset = 1,
            cue = 1,
            image = 16,
            imageActive = 32
        },
        {
            label = "Red",
            preset = 2,
            cue = 2,
            image = 17,
            imageActive = 33
        },
        {
            label = "Orange",
            preset = 3,
            cue = 3,
            image = 18,
            imageActive = 34
        },
        {
            label = "Yellow",
            preset = 4,
            cue = 4,
            image = 19,
            imageActive = 35
        },
        {
            label = "Deep Green",
            preset = 5,
            cue = 5,
            image = 20,
            imageActive = 36
        },
        {
            label = "Green",
            preset = 6,
            cue = 6,
            image = 21,
            imageActive = 37
        },
        {
            label = "Cyan",
            preset = 7,
            cue = 7,
            image = 22,
            imageActive = 38
        },
        {
            label = "Aqua",
            preset = 8,
            cue = 8,
            image = 23,
            imageActive = 39
        },
        {
            label = "Blue",
            preset = 9,
            cue = 9,
            image = 24,
            imageActive = 40
        },
        {
            label = "Lavender",
            preset = 10,
            cue = 10,
            image = 25,
            imageActive = 41
        },
        {
            label = "Magenta",
            preset = 11,
            cue = 11,
            image = 26,
            imageActive = 42
        },
        {
            label = "Pink",
            preset = 12,
            cue = 12,
            image = 27,
            imageActive = 43
        },
    }

    local fixtureTypes = {
        -- {
        --     name = "Beam", -- Name of the fixture type.
        --     colors = colors, -- Holds reference to colors. Leave this as it is.
        --     macroIndex = 16, -- At which index should macro be created for this fixture type?
        --     imageIndex = 80, -- At which index should images be created for this fixture type?
        --     colorFxIndex = 16, -- Where to paste Color preset triggered by FX/Accent color macros?
        --     colorExecutor = 101 -- Which executor controls this fixture type?
        -- },
        {
            name = "Beam",
            colors = colors,
            macroIndex = 16,
            imageIndex = 80,
            colorFxIndex = 16,
            colorExecutor = 101
        },
        {
            name = "Spot",
            colors = colors,
            macroIndex = 32,
            imageIndex = 96,
            colorFxIndex = 17,
            colorExecutor = 102
        },
        {
            name = "Wash",
            colors = colors,
            macroIndex = 48,
            imageIndex = 112,
            colorFxIndex = 18,
            colorExecutor = 103
        },
    }

    local sweeps = {
        -- { -- You will want this to stay as it is.
        --     label = "none", -- Name of the sweep.
        --     image = 48, -- How should the sweep look when it is not selected.
        --     imageActive = 53, -- How should the sweep look when it is selected.
        --     sweepDirection = 0 -- 0 stands for none, 1 for left to right, 2 for right to left, 3 for out to mid, 4 to mid to out.
        -- },
        {
            label = "none",
            image = 48,
            imageActive = 53,
            sweepDirection = 0
        },
        {
            label = ">",
            image = 49,
            imageActive = 54,
            sweepDirection = 1
        },
        {
            label = "<",
            image = 50,
            imageActive = 55,
            sweepDirection = 2
        },
        {
            label = "<>",
            image = 51,
            imageActive = 56,
            sweepDirection = 3
        },
        {
            label = "><",
            image = 52,
            imageActive = 57,
            sweepDirection = 4
        }
    }

    local properties = {
        colorPage = 1, -- Page that contains color executors. This one you have to create yourself.
        colorSequence = 1, -- Sequence that contains color queues (Split the executor using worlds). This one you have to create yourself.
        colorValueTimeFilterIndex = 2, -- Index of Color - ValueTimes filter. This one you have to create yourself.
        setColorFadeMacroIndex = 1, -- Where to create "Set Color Fade" Macro?
        setColorDelayMacroIndex = 2, -- Where to create "Set Color Delay" Macro?
        execColorFadeMacroIndex = 3, -- Where to create "Exec Color Fade" Macro?
        execColorDelayMacroIndex = 4, -- Where to create "Exec Color Delay" Macro?
        allColorMacroIndex = 64, -- Where to create color picker macro for ALL fixtures?
        fxColorMacroIndex = 80, -- Where to create color picker macro used for FX/Accent color?
        fxColorImageIndex = 64, -- How should the accent color look like when it is selected?
        fxColorPresetIndex = 15, -- Where to save accent color information in Color Preset Type.
        sweepImageStartIndex = 58 -- Starting index of image representation of currently selected sweep.
    }
    -- END USER DEFINED AREA

    -- TODO: Check if there is enough space between resources (conflicts)
    InitVars()
    CreateImages(fixtureTypes, properties.fxColorImageIndex)
    CreateFixtureTypeBasedColorMacros(fixtureTypes, properties)
    CreateAllColorMacros(properties.allColorMacroIndex, fixtureTypes)
    CreateFxColorMacros(properties.fxColorMacroIndex, properties.fxColorImageIndex, fixtureTypes, properties.fxColorPresetIndex)
    CreateFadeDelayColorMacros(properties)
    CreateSweepDelayImages(properties, sweeps)
    CreateSweepDelayMacros(properties, sweeps)


    Print("DONE!")
end

function InitVars()
    Exec('SetVar $colorFadeTime = 0')
    Exec('SetVar $colorDelayTime = 0')
    Exec('SetVar $sweepDirection = 0') -- see sweeps
end

function CreateImages(fixtureTypes, fxColorImageIndex)
    -- Crate FX color images
    local allColors = fixtureTypes[1].colors
    for fxColorIndex = 1, #allColors, 1 do
        local color = allColors[fxColorIndex]
        local imageFrom = color.image
        local imageTo = (fxColorImageIndex + fxColorIndex) - 1

        Exec("Copy Image " .. imageFrom .." At Image ".. imageTo .." /o")
        Exec('Label Image ' .. imageTo .. ' "' .. GetImageLabelFX(color) .. '"')
    end

    -- Create Fixture color images
    for fixtureTypeIndex = 1, #fixtureTypes, 1 do
        local fixtureType = fixtureTypes[fixtureTypeIndex]
        local numOfColors = #fixtureType.colors
        for colorIndex = 1, numOfColors, 1 do
            local color = fixtureType.colors[colorIndex]
            local imageFrom = color.image
            local imageTo = (fixtureType.imageIndex + colorIndex) - 1
            Exec("Copy Image " .. imageFrom .." At Image ".. imageTo .." /o")
            Exec('Label Image ' .. imageTo .. ' "' .. GetImageLabel(color, fixtureType) .. '"')
        end
    end
end

function CreateFixtureTypeBasedColorMacros(fixtureTypes, properties)
    for fixtureTypeIndex = 1, #fixtureTypes, 1 do
        local fixtureType = fixtureTypes[fixtureTypeIndex]

        CreateResetMacro(fixtureType)

        for colorIndex = 1, #fixtureType.colors, 1 do
            local color = fixtureType.colors[colorIndex]
            local macroIndex = fixtureType.macroIndex + colorIndex

            -- Store Macro container
            Exec("Store Macro 1." .. macroIndex)
            Exec('Label Macro 1.' .. macroIndex .. ' "'.. fixtureType.colors[colorIndex].label..'"')

            -- Trigger Reset Macro
            Exec("Store Macro 1." .. macroIndex..".1")
            Exec('Assign Macro 1.' .. macroIndex..'.1 /cmd="Go Macro '.. fixtureType.macroIndex..'"')
            Exec('Assign Macro 1.' .. macroIndex..'.1 /wait=0.01')

            -- Copy Image
            local imageFrom = color.imageActive
            local imageTo = (fixtureType.imageIndex - 1) + colorIndex
            Exec("Store Macro 1." .. macroIndex..".2")
            Exec('Assign Macro 1.' .. macroIndex..'.2 /cmd="Copy Image '.. imageFrom .. ' at '.. imageTo ..'/o; Label Image '.. imageTo ..' \''.. GetImageLabel(color, fixtureType) ..'\'"')

            -- Fire Executor
            Exec("Store Macro 1." .. macroIndex..".3")
            Exec('Assign Macro 1.' .. macroIndex..'.3 /cmd="Go Executor '.. properties.colorPage ..'.'.. fixtureType.colorExecutor ..' Cue '.. color.cue ..'"')

            -- Update FX color
            Exec("Store Macro 1." .. macroIndex..".4")
            Exec('Assign Macro 1.' .. macroIndex..'.4 /cmd="Copy Preset 4.'.. color.preset .. ' At Preset 4.'.. fixtureType.colorFxIndex ..' /o; Label Preset 4.'.. fixtureType.colorFxIndex ..' \'FX '.. fixtureType.name ..'\'"')
        end

    end
end

function CreateResetMacro(fixtureType)

    -- Store Macro container
    Exec("Store Macro 1." .. fixtureType.macroIndex.." /o")
    for colorIndex = 1, #fixtureType.colors, 1 do
         local color = fixtureType.colors[colorIndex]
         local imageFrom = color.image
         local imageTo = (fixtureType.imageIndex - 1) + colorIndex

         -- Reset all images
         Exec("Store Macro 1." .. fixtureType.macroIndex .. "."..colorIndex.. " /o")
         Exec('Assign Macro 1.' .. fixtureType.macroIndex .. '.'..colorIndex..' /cmd="Copy Image '.. imageFrom ..' At '.. imageTo .. ' /o; Label Image ' .. imageTo .. ' \''.. GetImageLabel(color, fixtureType)..'\'"')
    end
    Exec('Label Macro 1.' .. fixtureType.macroIndex..' "'..fixtureType.name..'"')
end

function CreateFadeDelayColorMacros(properties)
    local seq = properties.colorSequence
    local setFadeMacroIndex = properties.setColorFadeMacroIndex
    local setDelayMacroIndex = properties.setColorDelayMacroIndex
    local executeFadeMacroIndex = properties.execColorFadeMacroIndex
    local executeDelayMacroIndex = properties.execColorDelayMacroIndex
    local filterIndex = properties.colorValueTimeFilterIndex

    -- Set Color fade
    Exec('Store Macro 1.' .. setFadeMacroIndex)
    Exec('Label Macro 1.' .. setFadeMacroIndex .. ' "Set Color Fade"')

    Exec('Store Macro 1.' .. setFadeMacroIndex .. '.1')
    Exec('Assign Macro 1.' .. setFadeMacroIndex .. '.1 /cmd="SetVar $colorFadeTime = (Fade Time?)"')

    Exec('Store Macro 1.' .. setFadeMacroIndex .. '.2')
    Exec('Assign Macro 1.' .. setFadeMacroIndex .. '.2 /cmd="Go Macro '.. executeFadeMacroIndex ..'"')

    -- Set Color delay
    Exec('Store Macro 1.' .. setDelayMacroIndex)
    Exec('Label Macro 1.' .. setDelayMacroIndex .. ' "Set Color Delay"')

    Exec('Store Macro 1.' .. setDelayMacroIndex .. '.1')
    Exec('Assign Macro 1.' .. setDelayMacroIndex .. '.1 /cmd="SetVar $colorDelayTime = (Delay Time?)"')

    Exec('Store Macro 1.' .. setDelayMacroIndex .. '.2')
    Exec('Assign Macro 1.' .. setDelayMacroIndex .. '.2 /cmd="Go Macro '.. executeDelayMacroIndex ..'"')

   -- Execute Color fade
     Exec('Store Macro 1.' .. executeFadeMacroIndex)
     Exec('Label Macro 1.' .. executeFadeMacroIndex .. ' "Exec Color Fade"')

     Exec('Store Macro 1.' .. executeFadeMacroIndex .. '.1')
     Exec('Assign Macro 1.' .. executeFadeMacroIndex .. '.1 /cmd="Assign Sequence '.. seq ..' Cue * /fade=$colorFadeTime"')

    -- Execute Color delay
    Exec('Store Macro 1.' .. executeDelayMacroIndex)
    Exec('Label Macro 1.' .. executeDelayMacroIndex .. ' "Exec Color Delay"')

    Exec('Store Macro 1.' .. executeDelayMacroIndex .. '.1')
    Exec('Assign Macro 1.' .. executeDelayMacroIndex .. '.1 /cmd="[$sweepDirection == 0] BlindEdit On; SelFix Sequence '.. seq ..'; Filter '.. filterIndex ..'; Delay $colorDelayTime; Store Sequence '.. seq ..' Cue * /m; BlindEdit Off"')

    Exec('Store Macro 1.' .. executeDelayMacroIndex .. '.2')
    Exec('Assign Macro 1.' .. executeDelayMacroIndex .. '.2 /cmd="[$sweepDirection == 1] BlindEdit On; SelFix Sequence '.. seq ..'; Filter '.. filterIndex ..'; Delay 0 THRU $colorDelayTime; Store Sequence '.. seq ..' Cue * /m; BlindEdit Off')

    Exec('Store Macro 1.' .. executeDelayMacroIndex .. '.3')
    Exec('Assign Macro 1.' .. executeDelayMacroIndex .. '.3 /cmd="[$sweepDirection == 2] BlindEdit On; SelFix Sequence '.. seq ..'; Filter '.. filterIndex ..'; Delay $colorDelayTime THRU 0; Store Sequence '.. seq ..' Cue * /m; BlindEdit Off')

    Exec('Store Macro 1.' .. executeDelayMacroIndex .. '.4')
    Exec('Assign Macro 1.' .. executeDelayMacroIndex .. '.4 /cmd="[$sweepDirection == 3] BlindEdit On; SelFix Sequence '.. seq ..'*; Filter '.. filterIndex ..'; Delay $colorDelayTime THRU 0 THRU $colorDelayTime; Store Sequence '.. seq ..' Cue * /m; BlindEdit Off')

    Exec('Store Macro 1.' .. executeDelayMacroIndex .. '.5')
    Exec('Assign Macro 1.' .. executeDelayMacroIndex .. '.5 /cmd="[$sweepDirection == 4] BlindEdit On; SelFix Sequence '.. seq ..'; Filter '.. filterIndex ..'; Delay 0 THRU $colorDelayTime THRU 0; Store Sequence '.. seq ..' Cue * /m; BlindEdit Off')
end

function CreateSweepDelayMacros(properties, sweeps)
    local startIndex = properties.sweepImageStartIndex
    local executeDelayMacroIndex = properties.execColorDelayMacroIndex

    for sweepIndex = 1, #sweeps, 1 do
        local macroIndex = executeDelayMacroIndex + sweepIndex
        local sweep = sweeps[sweepIndex]
        local imageFrom = sweep.imageActive
        local imageTo = (startIndex - 1) + sweepIndex

        Exec('Store Macro 1.' .. macroIndex)
        Exec('Label Macro 1.' .. macroIndex .. ' "Sweep: '.. sweep.label ..'"')

        Exec('Store Macro 1.' .. macroIndex .. '.1')
        Exec('Assign Macro 1.' .. macroIndex .. '.1 /cmd="SetVar $sweepDirection = '.. sweep.sweepDirection ..'"')

        -- Reset images
        for sweepIndex2 = 1, #sweeps, 1 do
            local sweep2 = sweeps[sweepIndex2]
            local macroLine = sweepIndex2 + 1
            local imageFrom = sweep2.image
            local imageTo = (startIndex - 1) + sweepIndex2

            Exec('Store Macro 1.' .. macroIndex .. '.'..macroLine)
            Exec('Assign Macro 1.' .. macroIndex .. '.'..macroLine..' /cmd="Copy Image '.. imageFrom ..' At Image '.. imageTo ..' /o; Label Image '.. imageTo..' \''.. GetImageLabelSweep(sweep2) ..'\'"')
        end

        Exec('Store Macro 1.' .. macroIndex .. '.'.. #sweeps+2)
        Exec('Assign Macro 1.' .. macroIndex .. '.'.. #sweeps+2 ..' /cmd="Copy Image '.. imageFrom ..' At '.. imageTo ..' /o; Label Image '.. imageTo ..' \''.. GetImageLabelSweep(sweep) ..'\'"')

        Exec('Store Macro 1.' .. macroIndex .. '.'.. #sweeps+3)
        Exec('Assign Macro 1.' .. macroIndex .. '.'.. #sweeps+3 ..' /cmd="Go Macro '.. executeDelayMacroIndex .. '"')
    end
end

function CreateAllColorMacros(startIndex, fixtureTypes)
    -- Store Macro container. Currently doesn't do anything. Acts as a visual feedback
    Exec("Store Macro 1." .. startIndex.." /o")
    Exec('Label Macro 1.' .. startIndex..' "All"')

    local colors = fixtureTypes[1].colors

    for colorIndex = 1, #colors, 1 do
        local macroIndex = startIndex + colorIndex
        local colorName = colors[colorIndex].label

        -- Store Macro container
        Exec("Store Macro 1." .. macroIndex.." /o")
        Exec('Label Macro 1.' .. macroIndex..' "'..colorName..'"')

        for fixtureTypeIndex = 1, #fixtureTypes, 1 do
            local fixtureType = fixtureTypes[fixtureTypeIndex]
            local macroToTrigger = fixtureType.macroIndex + colorIndex

            -- Fire other macros
            Exec('Store Macro 1.' .. macroIndex..'.'..fixtureTypeIndex..' /o')
            Exec('Assign Macro 1.' .. macroIndex..'.'..fixtureTypeIndex..' /cmd="Go Macro '.. macroToTrigger ..'"')
        end
        
    end
end

function CreateFxColorMacros(macroStartIndex, imageStartIndex, fixtureTypes, fxPresetIndex)
    local colors = fixtureTypes[1].colors

    -- Store Macro container. Resets all color images to default state
    Exec("Store Macro 1." .. macroStartIndex.." /o")
    for colorIndex = 1, #colors, 1 do
        local color = colors[colorIndex]
        local imageFrom = color.image
        local imageTo = (imageStartIndex - 1) + colorIndex

        -- Reset all images
        Exec("Store Macro 1." .. macroStartIndex .. "."..colorIndex.. " /o")
        Exec('Assign Macro 1.' .. macroStartIndex .. '.'..colorIndex..' /cmd="Copy Image '.. imageFrom ..' At '.. imageTo .. ' /o; Label Image ' .. imageTo .. ' \''.. GetImageLabelFX(color)..'\'"')
    end
    Exec('Label Macro 1.' .. macroStartIndex..' "FX"')

    for colorIndex = 1, #colors, 1 do
        local color = colors[colorIndex]
        local macroIndex = macroStartIndex + colorIndex
        local colorName = color.label
        local imageFrom = color.imageActive
        local imageTo = (imageStartIndex - 1) + colorIndex
        local presetFrom = color.preset

        -- Store Macro container
        Exec("Store Macro 1." .. macroIndex.." /o")
        Exec('Label Macro 1.' .. macroIndex..' "'..colorName..'"')

        Exec('Store Macro 1.' .. macroIndex..'.1 /o')
        Exec('Assign Macro 1.' .. macroIndex..'.1 /cmd="Go Macro '.. macroStartIndex ..'"')
        Exec('Assign Macro 1.' .. macroIndex..'.1 /wait=0.01')

        Exec('Store Macro 1.' .. macroIndex..'.2 /o')
        Exec('Assign Macro 1.' .. macroIndex..'.2 /cmd="Copy Image '.. imageFrom ..' At Image '.. imageTo ..' /o"')

        Exec('Store Macro 1.' .. macroIndex..'.3 /o')
        Exec('Assign Macro 1.' .. macroIndex..'.3 /cmd="Label Image '.. imageTo ..' \''.. GetImageLabelFX(color) ..'\'"')

        Exec('Store Macro 1.' .. macroIndex..'.4 /o')
        Exec('Assign Macro 1.' .. macroIndex..'.4 /cmd="Copy Preset 4.'.. presetFrom ..' at Preset 4.'.. fxPresetIndex ..' /o; Label Preset 4.'.. fxPresetIndex ..' \'FX Accent\'"')

    end
end

function CreateSweepDelayImages(properties, sweeps)
    local startIndex = properties.sweepImageStartIndex
    for sweepIndex = 1, #sweeps, 1 do
        local sweep = sweeps[sweepIndex]
        local imageFrom = sweep.image
        local imageTo = (startIndex - 1) + sweepIndex
        Exec('Copy Image '.. imageFrom ..' At Image '.. imageTo ..' /o')
        Exec('Label Image '.. imageTo..' \''.. GetImageLabelSweep(sweep) ..'\'')
    end
end

-- HELPER FUNCTIONS

function GetImageLabel(color, fixtureType)
    return color.label .. "#" .. fixtureType.name
end

function GetImageLabelFX(color)
    return color.label .. "#FX"
end

function GetImageLabelSweep(sweep)
    return 'Sweep: '.. sweep.label
end

function Exec(command)
    return gma.cmd(command)
end

function Print(command)
    return gma.feedback(command)
end


return Start