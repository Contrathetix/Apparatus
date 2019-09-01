GroupMenu.GroupData = {}
GroupMenu.GroupData.Cache = {}
GroupMenu.GroupData.EventHandlers = {}
GroupMenu.GroupData.MenuUpdateDelay = 300


-- The data needs to be updated when the add-on is loaded, because player can already be in a group

function GroupMenu.GroupData.Initialize()
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        GroupMenu.GroupData.UpdateMemberData(masterList[i].unitTag, masterList[i])
    end
end


-- Event handlers, in an effort to avoid updating everything every time something small in the
-- group changes, and also to avoid unnecessary requests to get unit this and get unit that.

function GroupMenu.GroupData.EventHandlers.OnGroupMemberJoined(_, _, _, _)
    local masterList = GroupMenu.GroupData.GetMasterList()
    local cachedTags = GroupMenu.GroupData.GetCachedUnitTags()
    for i=1, #masterList do
        if GroupMenu.Utilities.DoesTableContainValue(cachedTags, masterList[i].unitTag) == false then
            GroupMenu.GroupData.GetMemberData(masterList[i].unitTag, masterList[i])
        end
    end
    zo_callLater(GroupMenu.GroupList.UpdateEntireMenu, GroupMenu.GroupData.MenuUpdateDelay)
end

function GroupMenu.GroupData.EventHandlers.OnGroupMemberLeft(_, _, _, _, _, memberDisplayName, _)
    GroupMenu.GroupData.PurgeMemberData(nil, memberDisplayName)
    zo_callLater(GroupMenu.GroupList.UpdateEntireMenu, GroupMenu.GroupData.MenuUpdateDelay)
end

function GroupMenu.GroupData.EventHandlers.OnGroupMemberConnectedStatus(_, unitTag, isOnline)
    GroupMenu.GroupData.Cache[unitTag].ConnectionStatus = isOnline and PLAYER_STATUS_ONLINE or PLAYER_STATUS_OFFLINE
    zo_callLater(GroupMenu.GroupList.UpdateEntireMenu, GroupMenu.GroupData.MenuUpdateDelay)
end

function GroupMenu.GroupData.EventHandlers.OnGroupUpdate(_)
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        GroupMenu.GroupData.UpdateMemberData(masterList.unitTag)
    end
    zo_callLater(GroupMenu.GroupList.UpdateEntireMenu, GroupMenu.GroupData.MenuUpdateDelay)
end

GroupMenu.GroupData.EventHandlers.HandlerMap = {
    [EVENT_GROUP_MEMBER_CONNECTED_STATUS] = GroupMenu.GroupData.EventHandlers.OnGroupMemberConnectedStatus,
    [EVENT_GROUP_MEMBER_JOINED] = GroupMenu.GroupData.EventHandlers.OnGroupMemberJoined,
    --[EVENT_GROUP_UPDATE] = GroupMenu.GroupData.EventHandlers.OnGroupUpdate,
    [EVENT_GROUP_MEMBER_LEFT] = GroupMenu.GroupData.EventHandlers.OnGroupMemberLeft
}

function GroupMenu.GroupData.SetDataChangeEventRegistrationState(registered)
    for eventId, handler in pairs(GroupMenu.GroupData.EventHandlers.HandlerMap) do
        if registered == true then
            EVENT_MANAGER:RegisterForEvent(GroupMenu.Info.AddOnName, eventId, handler)
        else
            EVENT_MANAGER:UnregisterForEvent(GroupMenu.Info.AddOnName, eventId)
        end
    end
end


-- Utility functions related to the group master list, that is being managed by the group list manager
-- but that is also being refreshed (reset) by it, so cannot really store anythign in there.

function GroupMenu.GroupData.GetMasterList()
    return GROUP_LIST_MANAGER.masterList
end

function GroupMenu.GroupData.GetCachedUnitTags()
    local cachedTags = {}
    for tag, _ in pairs(GroupMenu.GroupData.Cache) do
        table.insert(cachedTags, tag)
    end
    return cachedTags
end

function GroupMenu.GroupData.GetCachedUnitTagFromDisplayName(displayName)
    local tagToReturn = nil
    for unitTag, unitData in pairs(GroupMenu.GroupData.Cache) do
        if unitData.DisplayName == displayName then
            tagToReturn = unitTag
            break
        end
    end
    return tagToReturn
end

function GroupMenu.GroupData.GetMemberMasterListIndex(unitTag)
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        if masterList[i].unitTag == unitTag then
            return i
        end
    end
    return 0
end

function GroupMenu.GroupData.GetMemberMasterListData(unitTag)
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        if masterList[i].unitTag == unitTag then
            return masterList[i]
        end
    end
    return nil
end


-- The add-on adds a death counter to the group menu, and it needs to be reset from time to time

function GroupMenu.GroupData.ResetDeathCount()
    for key, _ in pairs(GroupMenu.GroupData.Cache) do
        GroupMenu.GroupData.Cache[key].DeathCount = 0
    end
end


-- Functions to get and purge member data, based on the display name, because that one is being passed
-- to the event handlers as a parameter, so easiest to use that.

function GroupMenu.GroupData.PurgeMemberData(unitTag, displayName)
    for tag, data in pairs(GroupMenu.GroupData.Cache) do
        if tag == unitTag or data.DisplayName == displayName then
            GroupMenu.GroupData.Cache[tag] = nil
        end
    end
end

function GroupMenu.GroupData.PurgeOldMemberData()

    local currentGroupMembers = {}
    local masterList = GroupMenu.GroupData.GetMasterList()
    local cachedTags = GroupMenu.GroupData.GetCachedUnitTags()

    for i=1, #masterList do
        table.insert(currentGroupMembers, masterList[i].unitTag)
    end

    for i=1, #cachedTags do
        if GroupMenu.Utilities.DoesTableContainValue(currentGroupMembers, cachedTags[i]) == false then
            GroupMenu.GroupData.Cache[cachedTags[i]] = nil
        end
    end

end

function GroupMenu.GroupData.UpdateMemberData(unitTag, masterListData)

    if unitTag == nil then return end

    if masterListData == nil then
        masterListData = GroupMenu.GroupData.GetMemberMasterListData(unitTag)
    end

    if masterListData == nil then return end

    local unitData = GroupMenu.GroupData.Cache[unitTag] ~= nil and GroupMenu.GroupData.Cache[unitTag] or {}

    unitData.IsOnline = masterListData.online
    unitData.IsPlayer = masterListData.isPlayer
    unitData.IsLeader = masterListData.leader
    unitData.CharacterName = masterListData.characterName
    unitData.Zone = masterListData.formattedZone
    unitData.GenderIndex = masterListData.gender
    unitData.Gender = GroupMenu.Strings['Gender'..masterListData.gender]
    unitData.ConnectionStatus = unitData.IsOnline and PLAYER_STATUS_ONLINE or PLAYER_STATUS_OFFLINE
    unitData.Level = masterListData.level

    if unitData.DisplayName == nil then
        unitData.DisplayName = GetUnitDisplayName(unitTag)
    end

    if unitData.Race == nil then
        unitData.Race = GetUnitRace(unitTag)
    end

    if unitData.AllianceId == nil then
        unitData.AllianceId = GetUnitAlliance(unitTag)
    end

    if unitData.AllianceRank == nil then
        unitData.AllianceRank = GetUnitAvARank(unitTag)
    end

    if unitData.AllianceRankName == nil then
        unitData.AllianceRankName = GetAvARankName(masterListData.Gender, unitData.AllianceRank)
    end

    if unitData.AllianceRankIcon == nil then
        unitData.AllianceRankIcon = GetAvARankIcon(unitData.AllianceRank)
    end

    if unitData.AllianceIconPath == nil then
        unitData.AllianceIconPath = ZO_GuildBrowser_GuildList_Keyboard:GetAllianceIcon(unitData.AllianceId)
    end

    if unitData.AllianceName == nil then
        unitData.AllianceName = GetAllianceName(unitData.AllianceId)
    end

    if unitData.SocialStatus == nil then
        if unitData.IsOnline == false then
            unitData.SocialStatus = nil
        elseif masterListData.isPlayer then
            unitData.SocialStatus = GroupMenu.Strings.SocialStatusSelf
        elseif IsUnitFriend(unitTag) then
            unitData.SocialStatus = GroupMenu.Strings.SocialStatusFriend
        elseif IsUnitIgnored(unitTag) then
            unitData.SocialStatus = GroupMenu.Strings.SocialStatusIgnored
        else
            unitData.SocialStatus = GroupMenu.Strings.SocialStatusNeutral
        end
    end

    -- always update champion point count
    unitData.ChampionPoints = unitData.IsOnline and GetUnitChampionPoints(unitTag) or ''

    if unitData.DeathCount == nil then
        unitData.DeathCount = 0
    end

    GroupMenu.GroupData.Cache[unitTag] = unitData

end

function GroupMenu.GroupData.GetMemberData(unitTag, masterListData)

    if unitTag == nil then return nil end

    if GroupMenu.GroupData.Cache[unitTag] == nil then
        GroupMenu.GroupData.UpdateMemberData(unitTag, masterListData)
    end

    return GroupMenu.GroupData.Cache[unitTag]

end
