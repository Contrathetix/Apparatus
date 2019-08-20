GroupMenu.ConfigMenu = {}

function GroupMenu.ConfigMenu.SetupMenu()

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
        [5] = GroupMenu.ConfigMenu.GetColumnToggleOption('Crown', GroupMenu.Constants.INDEX_CROWN),
        [6] = GroupMenu.ConfigMenu.GetColumnToggleOption('NameOriginal', GroupMenu.Constants.INDEX_NAME_ORIGINAL),
        [7] = GroupMenu.ConfigMenu.GetColumnToggleOption('MemberIndex', GroupMenu.Constants.INDEX_INDEX),
        [8] = GroupMenu.ConfigMenu.GetColumnToggleOption('Name', GroupMenu.Constants.INDEX_NAME),
        [9] = GroupMenu.ConfigMenu.GetColumnToggleOption('Zone', GroupMenu.Constants.INDEX_ZONE),
        [10] = GroupMenu.ConfigMenu.GetColumnToggleOption('Class', GroupMenu.Constants.INDEX_CLASS),
        [11] = GroupMenu.ConfigMenu.GetColumnToggleOption('Level', GroupMenu.Constants.INDEX_LEVEL),
        [12] = GroupMenu.ConfigMenu.GetColumnToggleOption('ChampionIcon', GroupMenu.Constants.INDEX_CHAMPIONICON),
        [13] = GroupMenu.ConfigMenu.GetColumnToggleOption('Role', GroupMenu.Constants.INDEX_ROLE),
        [14] = GroupMenu.ConfigMenu.GetColumnToggleOption('ChampionPoints', GroupMenu.Constants.INDEX_CP),
        [15] = GroupMenu.ConfigMenu.GetColumnToggleOption('Alliance', GroupMenu.Constants.INDEX_ALLIANCE),
        [16] = GroupMenu.ConfigMenu.GetColumnToggleOption('AllianceRank', GroupMenu.Constants.INDEX_ALLIANCERANK),
        [17] = GroupMenu.ConfigMenu.GetColumnToggleOption('Race', GroupMenu.Constants.INDEX_RACE),
        [18] = GroupMenu.ConfigMenu.GetColumnToggleOption('Gender', GroupMenu.Constants.INDEX_GENDER),
        [19] = GroupMenu.ConfigMenu.GetColumnToggleOption('Social', GroupMenu.Constants.INDEX_SOCIAL),
        [20] = {
            type = 'header',
            name = GroupMenu.Strings.ConfigMenu.Header.ColumnWidth
        },
        [21] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Crown', GroupMenu.Constants.INDEX_CROWN),
        [22] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('NameOriginal', GroupMenu.Constants.INDEX_NAME_ORIGINAL),
        [23] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('MemberIndex', GroupMenu.Constants.INDEX_INDEX),
        [24] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Name', GroupMenu.Constants.INDEX_NAME),
        [25] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Zone', GroupMenu.Constants.INDEX_ZONE),
        [26] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Class', GroupMenu.Constants.INDEX_CLASS),
        [27] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Level', GroupMenu.Constants.INDEX_LEVEL),
        [28] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('ChampionIcon', GroupMenu.Constants.INDEX_CHAMPIONICON),
        [29] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Role', GroupMenu.Constants.INDEX_ROLE),
        [30] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('ChampionPoints', GroupMenu.Constants.INDEX_CP),
        [31] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Alliance', GroupMenu.Constants.INDEX_ALLIANCE),
        [32] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('AllianceRank', GroupMenu.Constants.INDEX_ALLIANCERANK),
        [33] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Race', GroupMenu.Constants.INDEX_RACE),
        [34] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Gender', GroupMenu.Constants.INDEX_GENDER),
        [35] = GroupMenu.ConfigMenu.GetColumnWidthSliderOption('Social', GroupMenu.Constants.INDEX_SOCIAL)
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
        choices = { EsoStrings[SI_CURRENCYLOCATION0], EsoStrings[SI_CURRENCYLOCATION3] },
        getFunc = function()
            if GroupMenu.ConfigData.GetNameDisplayMode() == GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_CHARACTER then
                return EsoStrings[SI_CURRENCYLOCATION0]
            else
                return EsoStrings[SI_CURRENCYLOCATION3]
            end
        end,
        setFunc = function(var)
            if var == EsoStrings[SI_CURRENCYLOCATION0] then
                GroupMenu.ConfigData.SetNameDisplayMode(GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_CHARACTER)
            else
                GroupMenu.ConfigData.SetNameDisplayMode(GroupMenu.Constants.MENU_NAME_DISPLAY_OPTION_ACCOUNT)
            end
        end,
    }
end

function GroupMenu.ConfigMenu.GetColumnToggleOption(name, index)
    return {
        type = 'checkbox',
        name = GroupMenu.Strings.ConfigMenu.Option[name],
        tooltip = GroupMenu.Strings.ConfigMenu.Tooltip[name],
        getFunc = function()
            return GroupMenu.ConfigData.GetColumnEnabled(index)
        end,
        setFunc = function(var)
            GroupMenu.ConfigData.SetColumnEnabled(index, var)
        end,
        width = 'full'
    }
end

function GroupMenu.ConfigMenu.GetColumnWidthSliderOption(name, index)
    return {
        type = 'slider',
        name = GroupMenu.Strings.ConfigMenu.Slider[name],
        min = GroupMenu.ConfigData.MinColumnWidth,
        max = GroupMenu.ConfigData.MaxColumnWidth,
        default = GroupMenu.ConfigData.GetDefaultColumnWidth(index),
        step = 1,
        getFunc = function()
            return GroupMenu.ConfigData.GetConfiguredColumnWidth(index)
        end,
        setFunc = function(value)
            GroupMenu.ConfigData.SetConfiguredColumnWidth(index, value)
        end,
        width = 'full'
    }
end
