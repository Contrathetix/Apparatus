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
        [2] = {
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
        },
        [3] = {
            type = 'header',
            name = GroupMenu.Strings.ConfigMenu.Header.ColumnToggle
        },
        [4] = {
            type = 'checkbox',
            name = GroupMenu.Strings.ConfigMenu.Option.ChampionPoint,
            tooltip = GroupMenu.Strings.ConfigMenu.Tooltip.ChampionPoint,
            getFunc = function()
                return GroupMenu.ConfigData.GetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_CP)
            end,
            setFunc = function(var)
                GroupMenu.ConfigData.SetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_CP, var)
            end,
            width = 'full'
        },
		[5] = {
            type = 'checkbox',
            name = GroupMenu.Strings.ConfigMenu.Option.Alliance,
            tooltip = GroupMenu.Strings.ConfigMenu.Tooltip.Alliance,
			getFunc = function()
                return GroupMenu.ConfigData.GetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_ALLIANCE)
            end,
            setFunc = function(var)
                GroupMenu.ConfigData.SetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_ALLIANCE, var)
            end,
            width = 'full'
        },
        [6] = {
            type = 'checkbox',
            name = GroupMenu.Strings.ConfigMenu.Option.AllianceRank,
            tooltip = GroupMenu.Strings.ConfigMenu.Tooltip.AllianceRank,
			getFunc = function()
                return GroupMenu.ConfigData.GetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_ALLIANCE_RANK)
            end,
            setFunc = function(var)
                GroupMenu.ConfigData.SetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_ALLIANCE_RANK, var)
            end,
			width = 'full'
        },
		[7] = {
            type = 'checkbox',
            name =  GroupMenu.Strings.ConfigMenu.Option.Race,
            tooltip = GroupMenu.Strings.ConfigMenu.Tooltip.Race,
			getFunc = function()
                return GroupMenu.ConfigData.GetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_RACE)
            end,
            setFunc = function(var)
                GroupMenu.ConfigData.SetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_RACE, var)
            end,
			width = 'full'
        },
		[8] = {
            type = 'checkbox',
            name = GroupMenu.Strings.ConfigMenu.Option.Gender,
            tooltip = GroupMenu.Strings.ConfigMenu.Tooltip.Gender,
			getFunc = function()
                return GroupMenu.ConfigData.GetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_GENDER)
            end,
            setFunc = function(var)
                GroupMenu.ConfigData.SetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_GENDER, var)
            end,
			width = 'full'
        },
        [9] = {
            type = 'checkbox',
            name = GroupMenu.Strings.ConfigMenu.Option.Social,
            tooltip = GroupMenu.Strings.ConfigMenu.Tooltip.Social,
			getFunc = function()
                return GroupMenu.ConfigData.GetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_SOCIAL)
            end,
            setFunc = function(var)
                GroupMenu.ConfigData.SetColumnEnabled(GroupMenu.Constants.COLUMN_INDEX_SOCIAL, var)
            end,
			width = 'full'
        }
	}

    LAM2:RegisterOptionControls('GroupMenuConfig', optionsData)

end
