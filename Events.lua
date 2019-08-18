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
    EVENT_PLAYER_ACTIVATED,
    EVENT_GROUP_MEMBER_ACCOUNT_NAME_UPDATED
}

function GroupMenu.Events.OnGroupChange(...)
    --GroupMenu.Interface.UpdateMenu()
end

function GroupMenu.Events.OnSceneChange(oldState, newState)

    if newState == SCENE_SHOWING and oldState == SCENE_HIDDEN then
        -- menu is about to be shown
        GroupMenu.Interface.UpdateGroupMenuSize(true)
    elseif newState == SCENE_SHOWN then
        -- menu is shown to the user
        GroupMenu.Interface.UpdateMenu()
    elseif newState == SCENE_HIDDEN then
        -- menu is hidden
        GroupMenu.Interface.UpdateGroupMenuSize(false)
    end

end

function GroupMenu.Events.OnAddOnLoaded(_, addonName)

    if addonName ~= GroupMenu.Info.AddOnName then return end

    -- unregister to avoid unnecessary spam
    EVENT_MANAGER:UnregisterForEvent(GroupMenu.Info.AddOnName, EVENT_ADD_ON_LOADED)

    -- init the saved variables
    GroupMenu.ConfigData.Saved = ZO_SavedVars:NewAccountWide('GroupMenuData', 1, nil, GroupMenu.ConfigData.Default)

    -- init the configuration menu with LAM, as well as the group menu graphics elements
    GroupMenu.ConfigMenu.SetupMenu()
    GroupMenu.Interface.Init()

    -- register for the group menu hide/show events
    SCENE_MANAGER:GetScene(GroupMenu.Events.GroupSceneName):RegisterCallback('StateChange', GroupMenu.Events.OnSceneChange)

    -- register for group member events, like leaving, cp updates, etc.
    for i = 1, #GroupMenu.Events.GroupChangeEvents do
        EVENT_MANAGER:RegisterForEvent(GroupMenu.Info.AddOnName, GroupMenu.Events.GroupChangeEvents[i], GroupMenu.Events.OnGroupChange)
    end

end

EVENT_MANAGER:RegisterForEvent(GroupMenu.Info.AddOnName, EVENT_ADD_ON_LOADED, GroupMenu.Events.OnAddOnLoaded)
