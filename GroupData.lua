GroupMenu.GroupData = {}

GroupMenu.GroupData.EventHandlers = {}
GroupMenu.GroupData.MenuUpdateDelay = 300

GroupMenu.GroupData.Cache = {}
GroupMenu.GroupData.Cache.DataMap = {}

GroupMenu.GroupData.EventHandlers.HandlerMap = {
    [EVENT_GROUP_MEMBER_CONNECTED_STATUS] = GroupMenu.GroupData.EventHandlers.OnGroupMemberConnectedStatus,
    [EVENT_GROUP_MEMBER_JOINED] = GroupMenu.GroupData.EventHandlers.OnGroupMemberJoined,
    [EVENT_GROUP_MEMBER_LEFT] = GroupMenu.GroupData.EventHandlers.OnGroupMemberLeft
}


-- The data needs to be updated when the add-on is loaded, because player can already be in a group

function GroupMenu.GroupData.Initialize()
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        GroupMenu.GroupData.Cache.UpdateData(masterList[i].displayName, masterList[i])
    end
    for eventId, handler in pairs(GroupMenu.GroupData.EventHandlers.HandlerMap) do
        EVENT_MANAGER:RegisterForEvent(GroupMenu.Info.AddOnName, eventId, handler)
    end
end


-- Event handlers, in an effort to avoid updating everything every time something small in the
-- group changes, and also to avoid unnecessary requests to get unit this and get unit that.

function GroupMenu.GroupData.EventHandlers.OnGroupMemberJoined(_, _, memberDisplayName, _)
    GroupMenu.GroupData.Cache.UpdateData(memberDisplayName)
    local index = GroupMenu.GroupData.GetMasterListIndex(memberDisplayName)
    local masterList = GroupMenu.GroupData.GetMasterList()
    GroupMenu.GroupList.UpdateRow(index, masterList[index])
end

function GroupMenu.GroupData.EventHandlers.OnGroupMemberLeft(_, _, _, _, _, memberDisplayName, _)
    GroupMenu.GroupData.Cache.PurgeData(memberDisplayName)
end

function GroupMenu.GroupData.EventHandlers.OnGroupMemberConnectedStatus(_, unitTag, isOnline)
    local displayName = GroupMenu.GroupData.GetDisplayName(unitTag)
    GroupMenu.GroupData.Cache.DataMap[displayName].ConnectionStatus = isOnline and PLAYER_STATUS_ONLINE or PLAYER_STATUS_OFFLINE
end

function GroupMenu.GroupData.EventHandlers.OnGroupUpdate(_)
    local cachedNames = GroupMenu.GroupData.Cache.GetKeys()
    for i=1, #cachedNames do
        d('update cached data for '..cachedNames[i])
        GroupMenu.GroupData.Cache.UpdateData(cachedNames[i])
    end
    GroupMenu.GroupList.UpdateEntireMenu()
end

function GroupMenu.GroupData.EventHandlers.OnLeaderUpdate(_, leaderTag)
    local cachedNames = GroupMenu.GroupData.Cache.GetKeys()
    local masterList = GroupMenu.GroupData.GetMasterList()
    for displayName, unitData in pairs(GroupMenu.GroupData.Cache.DataMap) do
        local shouldBeLeader = unitData.UnitTag == leaderTag
        if unitData.IsLeader ~= shouldBeLeader then
            unitData.IsLeader = shouldBeLeader
            local index = GroupMenu.GroupData.GetMasterListIndex(displayName)
            GroupMenu.GroupList.UpdateRow(index, masterList[index])
        end
    end
end

function GroupMenu.GroupData.SetFullMenuUpdateRegistrationState(registered)
    local eventMap = {
        [EVENT_GROUP_UPDATE] = GroupMenu.GroupData.EventHandlers.OnGroupUpdate,
        [EVENT_LEADER_UPDATE] = GroupMenu.GroupData.EventHandlers.OnLeaderUpdate
    }
    for eventId, handler in pairs(eventMap) do
        if registered then
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

function GroupMenu.GroupData.GetMasterListIndex(displayName)
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        if masterList[i].displayName == displayName then
            return i
        end
    end
    return -1
end

function GroupMenu.GroupData.GetMasterListData(displayName)
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        if masterList[i].displayName == displayName then
            return masterList[i]
        end
    end
    return nil
end

function GroupMenu.GroupData.GetDisplayName(unitTag)
    local displayName = nil
    local masterList = GroupMenu.GroupData.GetMasterList()
    for i=1, #masterList do
        if masterList[i].unitTag == unitTag then
            displayName = masterList[i].displayName
            break
        end
    end
    return displayName
end


-- The add-on adds a death counter to the group menu, and it needs to be reset from time to time

function GroupMenu.GroupData.ResetDeathCount()
    for key, _ in pairs(GroupMenu.GroupData.Cache.DataMap) do
        GroupMenu.GroupData.Cache[key].DeathCount = 0
    end
end


-- Functions to manage the data cache that is intended to reduce the amount of functions calls to get data.

function GroupMenu.GroupData.Cache.GetKeys()
    local keys = {}
    for key, _ in pairs(GroupMenu.GroupData.Cache.DataMap) do
        table.insert(keys, key)
    end
    return keys
end

function GroupMenu.GroupData.Cache.GetRawData(displayName)
    local cachedData = GroupMenu.GroupData.Cache.DataMap[displayName]
    return cachedData ~= nil and cachedData or {}
end

function GroupMenu.GroupData.Cache.PurgeData(displayName)
    if GroupMenu.GroupData.Cache.DataMap[displayName] then
        GroupMenu.GroupData.Cache.DataMap[displayName] = nil
    end
end

function GroupMenu.GroupData.Cache.Cleanup()

    local currentGroupMembers = {}
    local masterList = GroupMenu.GroupData.GetMasterList()
    local cachedNames = GroupMenu.GroupData.Cache.GetKeys()

    for i=1, #masterList do
        table.insert(currentGroupMembers, masterList[i].displayName)
    end

    for i=1, #cachedNames do
        if GroupMenu.Utilities.DoesTableContainValue(currentGroupMembers, cachedNames[i]) == false then
            GroupMenu.GroupData.Cache.DataMap[cachedNames[i]] = nil
        end
    end

end

function GroupMenu.GroupData.Cache.UpdateData(displayName, masterListData)

    if displayName == nil then return end

    masterListData = masterListData ~= nil and masterListData or GroupMenu.GroupData.GetMasterListData(displayName)

    if masterListData == nil then return end

    local unitData = GroupMenu.GroupData.Cache.GetRawData(displayName)

    unitData.UnitTag = masterListData.unitTag
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
        unitData.DisplayName = GetUnitDisplayName(masterListData.unitTag)
    end

    if unitData.Race == nil then
        unitData.Race = GetUnitRace(masterListData.unitTag)
    end

    if unitData.AllianceId == nil then
        unitData.AllianceId = GetUnitAlliance(masterListData.unitTag)
    end

    if unitData.AllianceRank == nil then
        unitData.AllianceRank = GetUnitAvARank(masterListData.unitTag)
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
        elseif IsUnitFriend(masterListData.unitTag) then
            unitData.SocialStatus = GroupMenu.Strings.SocialStatusFriend
        elseif IsUnitIgnored(masterListData.unitTag) then
            unitData.SocialStatus = GroupMenu.Strings.SocialStatusIgnored
        else
            unitData.SocialStatus = GroupMenu.Strings.SocialStatusNeutral
        end
    end

    -- always update champion point count
    unitData.ChampionPoints = unitData.IsOnline and GetUnitChampionPoints(masterListData.unitTag) or ''

    if unitData.DeathCount == nil then
        unitData.DeathCount = 0
    end

    GroupMenu.GroupData.Cache.DataMap[displayName] = unitData

end

function GroupMenu.GroupData.Cache.GetData(displayName, masterListData)

    if displayName == nil then return nil end

    if GroupMenu.GroupData.Cache.DataMap[displayName] == nil then
        GroupMenu.GroupData.Cache.UpdateData(displayName, masterListData)
    end

    return GroupMenu.GroupData.Cache.DataMap[displayName]

end
