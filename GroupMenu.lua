GroupMenu = {}

GroupMenu.Info = {
    AddOnName = 'GroupMenu',
    Author = 'Contrathetix',
    Version = '3',
    SavedVariablesVersion = 4
}

function GroupMenu.OnAddOnLoaded(_, addonName)

    if addonName ~= GroupMenu.Info.AddOnName then return end

    EVENT_MANAGER:UnregisterForEvent(GroupMenu.Info.AddOnName, EVENT_ADD_ON_LOADED)

    GroupMenu.ConfigData.Saved = ZO_SavedVars:NewAccountWide(
        'GroupMenuData', GroupMenu.Info.SavedVariablesVersion, nil, GroupMenu.ConfigData.GetDefaultSavedData()
    )

    GroupMenu.ConfigMenu.Initialize()
    GroupMenu.GroupList.Initialize()

end

EVENT_MANAGER:RegisterForEvent(GroupMenu.Info.AddOnName, EVENT_ADD_ON_LOADED, GroupMenu.OnAddOnLoaded)
