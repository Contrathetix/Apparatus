GroupMenu.Events = {}

GroupMenu.Events.GroupSceneName = 'groupMenuKeyboard'

GroupMenu.Events.GroupChangeEvents = {
    EVENT_GROUP_MEMBER_JOINED,
    EVENT_GROUP_MEMBER_LEFT,
    EVENT_LEVEL_UPDATE,
    EVENT_CHAMPION_POINT_UPDATE,
    EVENT_ZONE_UPDATE,
    EVENT_GROUP_MEMBER_ROLE_CHANGED,
    EVENT_GROUP_MEMBER_CONNECTED_STATUS,
    EVENT_LEADER_UPDATE,
    EVENT_GROUP_UPDATE,
    EVENT_GROUP_MEMBER_ACCOUNT_NAME_UPDATED
}

function GroupMenu.Events.OnGroupChange(...)

    GroupMenu.Interface.UpdateMenuData()

end

function GroupMenu.Events.OnSceneChange(oldState, newState)

    if newState == SCENE_SHOWING and oldState == SCENE_HIDDEN then

        -- menu is about to be shown
        GroupMenu.Interface.UpdateGroupMenuSize(true)

    elseif newState == SCENE_SHOWN then

        -- menu is shown to the user
        GroupMenu.Interface.UpdateMenuData()
        GroupMenu.Events.SetRegisteredForGroupChangeEvents(true)

    elseif newState == SCENE_HIDDEN then

        -- menu is hidden
        GroupMenu.Events.SetRegisteredForGroupChangeEvents(false)
        GroupMenu.Interface.UpdateGroupMenuSize(false)

    end

end

function GroupMenu.Events.SetRegisteredForGroupChangeEvents(registered)

    for i = 1, #GroupMenu.Events.GroupChangeEvents do
        if registered then
            EVENT_MANAGER:RegisterForEvent(GroupMenu.Info.AddOnName, GroupMenu.Events.GroupChangeEvents[i], GroupMenu.Events.OnGroupChange)
        else
            EVENT_MANAGER:UnregisterForEvent(GroupMenu.Info.AddOnName, GroupMenu.Events.GroupChangeEvents[i])
        end
    end

end

function GroupMenu.Events.OnAddOnLoaded(_, addonName)

    if addonName ~= GroupMenu.Info.AddOnName then return end

    EVENT_MANAGER:UnregisterForEvent(GroupMenu.Info.AddOnName, EVENT_ADD_ON_LOADED)

    GroupMenu.ConfigData.Saved = ZO_SavedVars:NewAccountWide('GroupMenuData', 1, nil, GroupMenu.ConfigData.SavedTemplate)
    GroupMenu.ConfigMenu.SetupMenu()

    SCENE_MANAGER:GetScene(GroupMenu.Events.GroupSceneName):RegisterCallback('StateChange', GroupMenu.Events.OnSceneChange)

end

EVENT_MANAGER:RegisterForEvent(GroupMenu.Info.AddOnName, EVENT_ADD_ON_LOADED, GroupMenu.Events.OnAddOnLoaded)
