local Config = {
    DiscordLogging = true,
    DiscordWebhook = --[[ If DiscordLogging is true: set this to your webhook link ]] "https://discord.com/api/webhooks/link-here",
    ChatResourceName = "LifeInvader", --[[ This will show on client messages such as 'no handle set' etc.. ]]
}

Citizen.CreateThread(function()
    TriggerClientEvent('chat:addSuggestion', '/setlife', 'LifeInvader', {
        {name="LifeInvader handle",help="Set your LifeInvader handle"}
    })
    TriggerEvent('chat:addSuggestion', '/life', 'LifeInvader', {
        {name="LifeInvader status",help="Send a message to LifeInvader"}
    })
    TriggerEvent('chat:addSuggestion', '/resetlife', 'LifeInvader', {
        {name="LifeInvader handle reset",help="Reset your LifeInvader handle"}
    })
end)

local li_username_ids = {}
local li_usernames = {}
RegisterCommand('life', function(source, args)
    local HasUsername = false
    for _,v in pairs(li_username_ids) do
        if v == source then
            HasUsername = true
            li_username = li_usernames[v]
        end
    end

    if not HasUsername then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255,0,0},
            args = {Config.ChatResourceName, "You need to set a valid LifeInvader handle first"}
        })
        return;
    end      
    TriggerClientEvent('chat:addMessage', -1, {
        color = nil,
        args = {"", "^5[LIFEINVADER] ^7"..li_username..": "..table.concat(args, " ")}
    })
    if Config.DiscordLogging then
        message = "`[LIFEINVADER] @"..li_username.." (#"..source.."): "..table.concat(args, " ").."`"
        PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = GetPlayerName(source), content = message}), { ['Content-Type'] = 'application/json' })
    end
end)

RegisterCommand('setlife', function(source, args)
    local HasUsername = false
    for _,v in pairs(li_username_ids) do
        if v == source then
            HasUsername = true
        end
    end
    if HasUsername then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255,0,0},
            args = {Config.ChatResourceName, "You already have a handle, to reset do /resetlife"}
        })
        return;
    end
    li_username = table.concat(args, " ")
    table.insert(li_username_ids, source)
    table.insert(li_usernames, li_username)
    TriggerClientEvent('chat:addMessage', source, {
        color = {255,0,0},
        args = {Config.ChatResourceName, "You set your LifeInvader handle to "..li_username}
    })
    return;
end)

RegisterCommand('resetlife', function(source)
    local HasUsername = false
    for _,v in pairs(li_username_ids) do
        if v == source then
            HasUsername = true
            table.remove(li_username_ids, v)
            table.remove(li_usernames, v)
            TriggerClientEvent('chat:addMessage', source, {
                color = {255,0,0},
                args = {Config.ChatResourceName, "You have removed your LifeInvader handle"}
            })
            return;
        end
    end
    if not HasUsername then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255,0,0},
            args = {Config.ChatResourceName, "You don't have a LifeInvader username to remove"}
        })
        return;
    end
end)