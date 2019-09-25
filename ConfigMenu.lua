GroupMenu.ConfigMenu = {}

function GroupMenu.ConfigMenu.Initialize()

    local LAM2 = LibStub:GetLibrary('LibAddonMenu-2.0')

    -- Skip the configuration if there is no LibAddonMenu
    if LAM2 == nil then return end

    local panelData = {
        type = 'panel',
        name = GroupMenu.Info.AddOnName,
        displayName = GroupMenu.Info.AddOnName,
        author = GroupMenu.Info.Author,
        version = GroupMenu.Info.Version,
        registerForRefresh = true
    }

    LAM2:RegisterAddonPanel('GroupMenuConfig', panelData)

    local optionsData = {
        [1] = {
            type = 'header',
            name = GroupMenu.Strings.ConfigMenu.Header.Display
        },
        [2] = GroupMenu.ConfigMenu.GetNameDisplayModeDropdownOption(),
        [3] = GroupMenu.ConfigMenu.GetChampionPointAboveCapToggleOption(),
        [4] = {
            type = 'header',
            name = GroupMenu.Strings.ConfigMenu.Header.ColumnToggle
        },
        --[] = GroupMenu.ConfigMenu.GetColumnToggleOption('Crown', GroupMenu.Constants.KEY_CROWN),
        [5] = GroupMenu.ConfigMenu.GetColumnToggleOption('NameOriginal', GroupMenu.Constants.KEY_NAME_ORIGINAL),
        [6] = GroupMenu.ConfigMenu.GetColumnToggleOption('MemberIndex', GroupMenu.Constants.KEY_INDEX),
        [7] = GroupMenu.ConfigMenu.GetColumnToggleOption('Name', GroupMenu.Constants.KEY_NAME),
        [8] = GroupMenu.ConfigMenu.GetColumnToggleOption('Zone', GroupMenu.Constants.KEY_ZONE),
        [9] = GroupMenu.ConfigMenu.GetColumnToggleOption('Class', GroupMenu.Constants.KEY_CLASS),
        [10] = GroupMenu.ConfigMenu.GetColumnToggleOption('Level', GroupMenu.Constants.KEY_LEVEL),
        [11] = GroupMenu.ConfigMenu.GetColumnToggleOption('ChampionIcon', GroupMenu.Constants.KEY_CHAMPIONICON),
        [12] = GroupMenu.ConfigMenu.GetColumnToggleOption('Role', GroupMenu.Constants.KEY_ROLE),
        [13] = GroupMenu.ConfigMenu.GetColumnToggleOption('ChampionPoints', GroupMenu.Constants.KEY_CP),
        [14] = GroupMenu.ConfigMenu.GetColumnToggleOption('Alliance', GroupMenu.Constants.KEY_ALLIANCE),
        [15] = GroupMenu.ConfigMenu.GetColumnToggleOption('AllianceRank', GroupMenu.Constants.KEY_ALLIANCERANK),
        [16] = GroupMenu.ConfigMenu.GetColumnToggleOption('Race', GroupMenu.Constants.KEY_RACE),
        [17] = GroupMenu.ConfigMenu.GetColumnToggleOption('Gender', GroupMenu.Constants.KEY_GENDER),
        [18] = GroupMenu.ConfigMenu.GetColumnToggleOption('Social', GroupMenu.Constants.KEY_SOCIAL),
        [19] = {
            type = 'header',
            name = GroupMenu.Strings.ConfigMenu.Header.ColumnWidth
        },
        --[] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Crown', GroupMenu.Constants.KEY_CROWN),
        [20] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('NameOriginal', GroupMenu.Constants.KEY_NAME_ORIGINAL),
        [21] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('MemberIndex', GroupMenu.Constants.KEY_INDEX),
        [22] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Name', GroupMenu.Constants.KEY_NAME),
        [23] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Zone', GroupMenu.Constants.KEY_ZONE),
        [24] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Class', GroupMenu.Constants.KEY_CLASS),
        [25] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Level', GroupMenu.Constants.KEY_LEVEL),
        [26] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('ChampionIcon', GroupMenu.Constants.KEY_CHAMPIONICON),
        [27] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Role', GroupMenu.Constants.KEY_ROLE),
        [28] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('ChampionPoints', GroupMenu.Constants.KEY_CP),
        [29] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Alliance', GroupMenu.Constants.KEY_ALLIANCE),
        [30] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('AllianceRank', GroupMenu.Constants.KEY_ALLIANCERANK),
        [31] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Race', GroupMenu.Constants.KEY_RACE),
        [32] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Gender', GroupMenu.Constants.KEY_GENDER),
        [33] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Social', GroupMenu.Constants.KEY_SOCIAL),
        [34] = {
            type = 'header',
            name = GroupMenu.Strings.ConfigMenu.Header.Miscellaneous
        },
        [35] = {
            type = 'button',
            name = GroupMenu.Strings.ConfigMenu.Option.Reset,
            tooltip = GroupMenu.Strings.ConfigMenu.Tooltip.Reset,
            func = function()
                GroupMenu.ConfigData.ResetSavedData()
            end,
            width = 'full'
        }
    }

    LAM2:RegisterOptionControls('GroupMenuConfig', optionsData)

end

function GroupMenu.ConfigMenu.GetChampionPointAboveCapToggleOption()
    return {
        type = 'checkbox',
        name = GroupMenu.Strings.ConfigMenu.Option.ChampionPointsOverCap,
        tooltip = GroupMenu.Strings.ConfigMenu.Tooltip.ChampionPointsOverCap,
        getFunc = function()
            return GroupMenu.ConfigData.GetDisplayChampionPointsOverCap()
        end,
        setFunc = function(var)
            GroupMenu.ConfigData.SetDisplayChampionPointsOverCap(var)
        end,
        width = 'full'
    }
end

function GroupMenu.ConfigMenu.GetNameDisplayModeDropdownOption()
    return {
        type = 'dropdown',
        name = GroupMenu.Strings.ConfigMenu.Option.NameDisplayMode,
        tooltip = GroupMenu.Strings.ConfigMenu.Tooltip.NameDisplayMode,
        choices = { GroupMenu.Strings.CharacterName, GroupMenu.Strings.DisplayName },
        getFunc = function()
            if GroupMenu.ConfigData.GetNameDisplayMode() == GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_CHARACTER then
                return GroupMenu.Strings.CharacterName
            else
                return GroupMenu.Strings.DisplayName
            end
        end,
        setFunc = function(var)
            if var == GroupMenu.Strings.CharacterName then
                GroupMenu.ConfigData.SetNameDisplayMode(GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_CHARACTER)
            else
                GroupMenu.ConfigData.SetNameDisplayMode(GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_ACCOUNT)
            end
        end,
    }
end

function GroupMenu.ConfigMenu.GetColumnToggleOption(name, key)
    return {
        type = 'checkbox',
        name = GroupMenu.Strings.ConfigMenu.Option[name],
        tooltip = GroupMenu.Strings.ConfigMenu.Tooltip[name],
        getFunc = function()
            return GroupMenu.ConfigData.GetColumnEnabled(key)
        end,
        setFunc = function(var)
            GroupMenu.ConfigData.SetColumnEnabled(key, var)
        end,
        width = 'full'
    }
end

function GroupMenu.ConfigMenu.GetColumnWidthSliderOption(name, key)
    return {
        type = 'slider',
        name = GroupMenu.Strings.ConfigMenu.Slider[name],
        min = GroupMenu.Constants.COLUMN_WIDTH_MIN,
        max = GroupMenu.Constants.COLUMN_WIDTH_MAX,
        default = GroupMenu.ConfigData.GetColumnWidthDefault(key),
        step = 1,
        getFunc = function()
            return GroupMenu.ConfigData.GetColumnWidth(key)
        end,
        setFunc = function(value)
            GroupMenu.ConfigData.SetColumnWidth(key, value)
        end,
        width = 'full'
    }
end
