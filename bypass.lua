local Send_Info;
local Encryption_Module;
local Cardinal_Remote;
local Http_Service = game:GetService("HttpService")
local Key;

do 
    for Index, Value in next, getgc(false) do 
        if typeof(Value) == 'function' and debug.info(Value, "n") == "sendInfo" then 
            local Upvalues = debug.getupvalues(Value)
            if #Upvalues == 9 then 
                Send_Info = Value
            end
        end
    end
    Key = debug.getupvalue(Send_Info, 8)
    Encryption_Module = debug.getupvalue(Send_Info, 7)
    Cardinal_Remote = debug.getupvalue(Send_Info, 9)

    repeat wait() until Key ~= nil and Encryption_Module ~= nil and Cardinal_Remote ~= nil 

    hookfunction(Send_Info, function()
        return coroutine.yield()
    end)
end

local function Handshake()
    local Success, Result = pcall(function()
        local Data = {}
        Data = {
            HighestVelocity = tostring(0),
            AngularVelocity = tostring(0), 
            Health = tostring(1), 
            Walkspeed = tostring(1), 
            JumpPower = tostring(1), 
            Gravity = tostring(196), 
            HipHeight = tostring(0), 
            MoverCount = tostring(0), 
            HeadAnchored = "No", 
            HeadCollidable = "Yes"
        };
        Data = Http_Service:JSONEncode(Data)
        Data = Encryption_Module.encryptTransaction(Data, Key)
        Cardinal_Remote:FireServer(Data)
    end)
    return Success, Result
end

while true do 
    task.wait(math.random(3, 5))
    local Success, Result = Handshake()
    if Success then 
        print("Fired succesfully!")
    else
        print("Unable to fire :( " .. tostring(Result))
    end
end
