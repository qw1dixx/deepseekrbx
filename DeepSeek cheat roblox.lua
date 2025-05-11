-- Functions
local args = {...}
PlaceId, JobId = game.PlaceId, game.JobId
shade1 = {}
shade2 = {}
shade3 = {}
text1 = {}
text2 = {}
scroll = {}
local cloneref = cloneref or function(o) return o end
COREGUI = cloneref(game:GetService("CoreGui"))
Players = cloneref(game:GetService("Players"))
IYMouse = Players.LocalPlayer:GetMouse()
PlayerGui = Players.LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
UserInputService = cloneref(game:GetService("UserInputService"))
TweenService = cloneref(game:GetService("TweenService"))
HttpService = cloneref(game:GetService("HttpService"))
MarketplaceService = cloneref(game:GetService("MarketplaceService"))
RunService = cloneref(game:GetService("RunService"))
TeleportService = cloneref(game:GetService("TeleportService"))
StarterGui = cloneref(game:GetService("StarterGui"))
GuiService = cloneref(game:GetService("GuiService"))
Lighting = cloneref(game:GetService("Lighting"))
ContextActionService = cloneref(game:GetService("ContextActionService"))
ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
GroupService = cloneref(game:GetService("GroupService"))
PathService = cloneref(game:GetService("PathfindingService"))
SoundService = cloneref(game:GetService("SoundService"))
Teams = cloneref(game:GetService("Teams"))
StarterPlayer = cloneref(game:GetService("StarterPlayer"))
InsertService = cloneref(game:GetService("InsertService"))
ChatService = cloneref(game:GetService("Chat"))
ProximityPromptService = cloneref(game:GetService("ProximityPromptService"))
StatsService = cloneref(game:GetService("Stats"))
MaterialService = cloneref(game:GetService("MaterialService"))
AvatarEditorService = cloneref(game:GetService("AvatarEditorService"))
TextChatService = cloneref(game:GetService("TextChatService"))
CaptureService = cloneref(game:GetService("CaptureService"))
VoiceChatService = cloneref(game:GetService("VoiceChatService"))

currentVersion = "1.6.5a"
everyClipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
HttpService = cloneref(game:GetService("HttpService"))
function toClipboard(txt)
   if everyClipboard then
       everyClipboard(tostring(txt))
   end
end
gethidden = gethiddenproperty or get_hidden_property or get_hidden_prop
local canOpenServerinfo = true
function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

function dragGUI(gui)
	task.spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local delta = input.Position - dragStart
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
		end
		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

function splitString(str,delim)
	local broken = {}
	if delim == nil then delim = "," end
	for w in string.gmatch(str,"[^"..delim.."]+") do
		table.insert(broken,w)
	end
	return broken
end

local lastCmds = {}

local split=" "

cmds={}

function FindInTable(tbl,val)
	if tbl == nil then return false end
	for _,v in pairs(tbl) do
		if v == val then return true end
	end 
	return false
end

customAlias = {}

findCmd=function(cmd_name)
	for i,v in pairs(cmds)do
		if v.NAME:lower()==cmd_name:lower() or FindInTable(v.ALIAS,cmd_name:lower()) then
			return v
		end
	end
	return customAlias[cmd_name:lower()]
end

cmdHistory = {}

local lastBreakTime = 0

function execCmd(cmdStr,speaker,store)
	cmdStr = cmdStr:gsub("%s+$","")
	task.spawn(function()
		local rawCmdStr = cmdStr
		cmdStr = string.gsub(cmdStr,"\\\\","%%BackSlash%%")
		local commandsToRun = splitString(cmdStr,"\\")
		for i,v in pairs(commandsToRun) do
			v = string.gsub(v,"%%BackSlash%%","\\")
			local x,y,num = v:find("^(%d+)%^")
			local cmdDelay = 0
			local infTimes = false
			if num then
				v = v:sub(y+1)
				local x,y,del = v:find("^([%d%.]+)%^")
				if del then
					v = v:sub(y+1)
					cmdDelay = tonumber(del) or 0
				end
			else
				local x,y = v:find("^inf%^")
				if x then
					infTimes = true
					v = v:sub(y+1)
					local x,y,del = v:find("^([%d%.]+)%^")
					if del then
						v = v:sub(y+1)
						del = tonumber(del) or 1
						cmdDelay = (del > 0 and del or 1)
					else
						cmdDelay = 1
					end
				end
			end
			num = tonumber(num or 1)

			if v:sub(1,1) == "!" then
				local chunks = splitString(v:sub(2),split)
				if chunks[1] and lastCmds[chunks[1]] then v = lastCmds[chunks[1]] end
			end

			local args = splitString(v,split)
			local cmdName = args[1]
			local cmd = findCmd(cmdName)
			if cmd then
				table.remove(args,1)
				cargs = args
				if not speaker then speaker = Players.LocalPlayer end
				if store then
					if speaker == Players.LocalPlayer then
						if cmdHistory[1] ~= rawCmdStr and rawCmdStr:sub(1,11) ~= 'lastcommand' and rawCmdStr:sub(1,7) ~= 'lastcmd' then
							table.insert(cmdHistory,1,rawCmdStr)
						end
					end
					if #cmdHistory > 30 then table.remove(cmdHistory) end

					lastCmds[cmdName] = v
				end
				local cmdStartTime = tick()
				if infTimes then
					while lastBreakTime < cmdStartTime do
						local success,err = pcall(cmd.FUNC,args, speaker)
						if not success and _G.IY_DEBUG then
							warn("Command Error:", cmdName, err)
						end
						wait(cmdDelay)
					end
				else
					for rep = 1,num do
						if lastBreakTime > cmdStartTime then break end
						local success,err = pcall(function()
							cmd.FUNC(args, speaker)
						end)
						if not success and _G.IY_DEBUG then
							warn("Command Error:", cmdName, err)
						end
						if cmdDelay ~= 0 then wait(cmdDelay) end
					end
				end
			end
		end
	end)
end	


currentShade1 = Color3.fromRGB(36, 36, 37)
currentShade2 = Color3.fromRGB(46, 46, 47)
currentShade3 = Color3.fromRGB(78, 78, 79)
currentText1 = Color3.new(1, 1, 1)
currentText2 = Color3.new(0, 0, 0)
currentScroll = Color3.fromRGB(78,78,79)
speaker = Players.LocalPlayer

function deleteGuisAtPos()
	pcall(function()
		local guisAtPosition = Players.LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)
		for _, gui in pairs(guisAtPosition) do
			if gui.Visible == true then
				gui:Destroy()
			end
		end
	end)
end




-- Code
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "DeepSeek v" .. currentVersion,
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "DeepSeek",
   LoadingSubtitle = "Into the unknown...",
   Theme = "Ocean", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "DeepSeek",
      Subtitle = "Authorization",
      Note = "Type 'Start Now' to authorize.", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Start Now"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})



local OneTab = Window:CreateTab("1", 0) -- Title, Image
local TwoTab = Window:CreateTab("2", 0) -- Title, Image
local ThreeTab = Window:CreateTab("3", 0) -- Title, Image
local FourTab = Window:CreateTab("4", 0) -- Title, Image
local FiveTab = Window:CreateTab("5", 0) -- Title, Image
local SixTab = Window:CreateTab("6", 0) -- Title, Image
local SevenTab = Window:CreateTab("7", 0) -- Title, Image
local EightTab = Window:CreateTab("8", 0) -- Title, Image
local NineTab = Window:CreateTab("9", 0) -- Title, Image
local TenTab = Window:CreateTab("10", 0) -- Title, Image
local ElevenTab = Window:CreateTab("11", 0) -- Title, Image
local TwelveTab = Window:CreateTab("12", 0) -- Title, Image
local ThirteenTab = Window:CreateTab("13", 0) -- Title, Image
local FourteenTab = Window:CreateTab("14", 0) -- Title, Image
local FiveteenTab = Window:CreateTab("15", 0) -- Title, Image

local Button = OneTab:CreateButton({
   Name = "Discord | Support | Help",
   Callback = function()
   	if everyClipboard then
         toClipboard('https://discord.gg/invite/aTY2MKKa')
         Rayfield:Notify({
            Title = "Discord Invite",
            Content = "Copied to clipboard!\ndiscord.gg/aTY2MKKa",
            Duration = 10,
            Image = 0,
         })
      else
         Rayfield:Notify({
            Title = "Discord Invite",
            Content = "discord.gg/aTY2MKKa",
            Duration = 10,
            Image = 0,
         })
      end
      if httprequest then
         httprequest({
            Url = 'http://127.0.0.1:6463/rpc?v=1',
            Method = 'POST',
            Headers = {
               ['Content-Type'] = 'application/json',
               Origin = 'https://discord.com'
            },
            Body = HttpService:JSONEncode({
               cmd = 'INVITE_BROWSER',
               nonce = HttpService:GenerateGUID(false),
               args = {code = 'aTY2MKKa'}
            })
         })
      end
   end,
})

local Button = OneTab:CreateButton({
   Name = "Console",
   Callback = function()
   StarterGui:SetCore("DevConsoleVisible", true)
   end,
})

local Button = OneTab:CreateButton({
   Name = "Old console",
   Callback = function()
   -- Thanks wally!!
	Rayfield:Notify({
      Title = "Loading",
      Content = "Hold on a sec",
      Duration = 10,
      Image = 0,
   })
	local _, str = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/console.lua", true)
	end)

	local s, e = loadstring(str)
	if typeof(s) ~= "function" then
		return
	end

	local success, message = pcall(s)
	if (not success) then
		if printconsole then
			printconsole(message)
		elseif printoutput then
			printoutput(message)
		end
	end
	wait(1)
	Rayfield:Notify({
      Title = "Console",
      Content = "Press F9 to open the console",
      Duration = 10,
      Image = 0,
   })
   end,
})

local Button = OneTab:CreateButton({
   Name = "Dex Explorer",
   Callback = function()
      Rayfield:Notify({
         Title = "Loading",
         Content = "Hold on a sec",
         Duration = 10,
         Image = 0,
      })
      loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
   end,
})

local Button = OneTab:CreateButton({
   Name = "Old Dex",
   Callback = function()
      Rayfield:Notify({
         Title = "Loading old explorer",
         Content = "Hold on a sec",
         Duration = 10,
         Image = 0,
      })

      local getobjects = function(a)
         local Objects = {}
         if a then
            local b = InsertService:LoadLocalAsset(a)
            if b then 
               table.insert(Objects, b) 
            end
         end
         return Objects
      end
   
      local Dex = getobjects("rbxassetid://10055842438")[1]
      Dex.Parent = PARENT
   
      local function Load(Obj, Url)
         local function GiveOwnGlobals(Func, Script)
            -- Fix for this edit of dex being poorly made
            -- I (Alex) would like to commemorate whoever added this dex in somehow finding the worst dex to ever exist
            local Fenv, RealFenv, FenvMt = {}, {
               script = Script,
               getupvalue = function(a, b)
                  return nil -- force it to use globals
               end,
               getreg = function() -- It loops registry for some idiotic reason so stop it from doing that and just use a global
                  return {} -- force it to use globals
               end,
               getprops = getprops or function(inst)
                  if getproperties then
                     local props = getproperties(inst)
                     if props[1] and gethiddenproperty then
                        local results = {}
                        for _,name in pairs(props) do
                           local success, res = pcall(gethiddenproperty, inst, name)
                           if success then
                              results[name] = res
                           end
                        end
   
                        return results
                     end
   
                     return props
                  end
   
                  return {}
               end
            }, {}
            FenvMt.__index = function(a,b)
               return RealFenv[b] == nil and getgenv()[b] or RealFenv[b]
            end
            FenvMt.__newindex = function(a, b, c)
               if RealFenv[b] == nil then 
                  getgenv()[b] = c 
               else 
                  RealFenv[b] = c 
               end
            end
            setmetatable(Fenv, FenvMt)
            pcall(setfenv, Func, Fenv)
            return Func
         end
   
         local function LoadScripts(_, Script)
            if Script:IsA("LocalScript") then
               task.spawn(function()
                  GiveOwnGlobals(loadstring(Script.Source,"="..Script:GetFullName()), Script)()
               end)
            end
            table.foreach(Script:GetChildren(), LoadScripts)
         end
   
         LoadScripts(nil, Obj)
      end
   
      Load(Dex)
   end,
})

local Button = OneTab:CreateButton({
   Name = "Audio Logger",
   Callback = function()
      Rayfield:Notify({
         Title = "Loading",
         Content = "Hold on a sec",
         Duration = 10,
         Image = 0,
      })
      loadstring(game:HttpGet(('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'),true))()
   end,
})

local Button = OneTab:CreateButton({
   Name = "JobId",
   Callback = function()
      local jobId = 'Roblox.GameLauncher.joinGameInstance('..PlaceId..', "'..JobId..'")'
      toClipboard(jobId)
   end
})

local Button = OneTab:CreateButton({
   Name = "Notify JobId",
   Callback = function()
      Rayfield:Notify({
         Title = "JobId | PlaceId",
         Content = JobId..' | '..PlaceId,
         Duration = 10,
         Image = 0,
      })
   end,
})

local Button = OneTab:CreateButton({
   Name = "Rejoin",
   Callback = function()
      if #Players:GetPlayers() <= 1 then
         Players.LocalPlayer:Kick("\nRejoining...")
         wait()
         TeleportService:Teleport(PlaceId, Players.LocalPlayer)
      else
         TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
      end
   end,
})

local Button = OneTab:CreateButton({
   Name = "Auto rejoin",
   Callback = function()
      GuiService.ErrorMessageChanged:Connect(function()
         if #Players:GetPlayers() <= 1 then
            Players.LocalPlayer:Kick("\nRejoining...")
            wait()
            TeleportService:Teleport(PlaceId, Players.LocalPlayer)
         else
            TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
         end
      end)
      Rayfield:Notify({
         Title = "Auto Rejoin",
         Content = 'Auto rejoin enabled',
         Duration = 10,
         Image = 0,
      })
   end,
})

local Button = OneTab:CreateButton({
   Name = "Serverhop",
   Callback = function()
      -- thanks to NoobSploit for fixing
      if httprequest then
         local servers = {}
         local req = httprequest({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true", PlaceId)})
         local body = HttpService:JSONDecode(req.Body)
 
         if body and body.data then
             for i, v in next, body.data do
                 if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
                     table.insert(servers, 1, v.id)
                 end
             end
         end
 
         if #servers > 0 then
             TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
         else
             return
         end
     else
      Rayfield:Notify({
         Title = "Incompatible Exploit",
         Content = 'Your exploit does not support this command (missing request)',
         Duration = 10,
         Image = 0,
      })
     end
   end,
})

local Input = OneTab:CreateInput({
   Name = "Game teleport",
   CurrentValue = "",
   PlaceholderText = "ID",
   RemoveTextAfterFocusLost = false,
   Flag = "Input1",
   Callback = function(GameID)
   TeleportService:Teleport(GameID)
   end,
})

local Button = OneTab:CreateButton({
   Name = "Anti-AFK",
   Callback = function()
      local GC = getconnections or get_signal_cons
      if GC then
         for i,v in pairs(GC(Players.LocalPlayer.Idled)) do
            if v["Disable"] then
               v["Disable"](v)
            elseif v["Disconnect"] then
               v["Disconnect"](v)
            end
         end
      else
         local VirtualUser = cloneref(game:GetService("VirtualUser"))
         Players.LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
         end)
      end
      if not (args[1] and tostring(args[1]) == 'nonotify') then Rayfield:Notify({
         Title = "Anti Idle",
         Content = 'Anti idle is enabled',
         Duration = 10,
         Image = 0,
      }) end
   end,
})

local Input = OneTab:CreateInput({
   Name = "Data limit",
   CurrentValue = "",
   PlaceholderText = "kbps",
   RemoveTextAfterFocusLost = false,
   Flag = "Input2",
   Callback = function(kbps)
          local NetworkClient = cloneref(game:GetService("NetworkClient"))
          NetworkClient:SetOutgoingKBPSLimit(kbps)
   end,
})

local Input = OneTab:CreateInput({
   Name = "Replication Lag | Backtrack",
   CurrentValue = "",
   PlaceholderText = "num",
   RemoveTextAfterFocusLost = false,
   Flag = "Input3",
   Callback = function(num)
         settings():GetService("NetworkSettings").IncomingReplicationLag = num
   end,
})

local Button = OneTab:CreateButton({
   Name = "Creator ID",
   Callback = function()
      if game.CreatorType == Enum.CreatorType.User then
         Rayfield:Notify({
            Title = "Creator ID",
            Content = game.CreatorId,
            Duration = 10,
            Image = 0,
         })
      elseif game.CreatorType == Enum.CreatorType.Group then
         local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
         Rayfield:Notify({
            Title = "Creator ID",
            Content = OwnerID,
            Duration = 10,
            Image = 0,
         })
      end
   end,
})

local Button = OneTab:CreateButton({
   Name = "Copy creator ID",
   Callback = function()
      if game.CreatorType == Enum.CreatorType.User then
         toClipboard(game.CreatorId)
         Rayfield:Notify({
            Title = "Copied ID",
            Content = 'Copied creator ID to clipboard',
            Duration = 10,
            Image = 0,
         })
      elseif game.CreatorType == Enum.CreatorType.Group then
         local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
         toClipboard(OwnerID)
         Rayfield:Notify({
            Title = "Copied ID",
            Content = 'Copied creator ID to clipboard',
            Duration = 10,
            Image = 0,
         })
      end
   end,
})

local Button = OneTab:CreateButton({
   Name = "No prompts",
   Callback = function()
      COREGUI.PurchasePromptApp.Enabled = false
   end,
})

local Button = OneTab:CreateButton({
   Name = "Show prompts",
   Callback = function()
      COREGUI.PurchasePromptApp.Enabled = true
   end,
})

local invisGUIS = {}

local Button = OneTab:CreateButton({
   Name = "Show GUIs",
   Callback = function()
      for i,v in pairs(speaker:FindFirstChildWhichIsA("PlayerGui"):GetDescendants()) do
         if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and not v.Visible then
            v.Visible = true
            if not FindInTable(invisGUIS,v) then
               table.insert(invisGUIS,v)
            end
         end
      end
   end,
})

local Button = OneTab:CreateButton({
   Name = "Unshow GUIs",
   Callback = function()
      for i,v in pairs(invisGUIS) do
         v.Visible = false
      end
      invisGUIS = {}
   end,
})

local hiddenGUIS = {}

local Button = OneTab:CreateButton({
   Name = "Hide GUIs",
   Callback = function()
      for i,v in pairs(speaker:FindFirstChildWhichIsA("PlayerGui"):GetDescendants()) do
         if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and v.Visible then
            v.Visible = false
            if not FindInTable(hiddenGUIS,v) then
               table.insert(hiddenGUIS,v)
            end
         end
      end
   end,
})

local Button = OneTab:CreateButton({
   Name = "Unhide GUIs",
   Callback = function()
      for i,v in pairs(hiddenGUIS) do
         v.Visible = true
      end
      hiddenGUIS = {}
   end,
})

local deleteGuiInput
local Button = OneTab:CreateButton({
   Name = "GUI delete",
   Callback = function()
      deleteGuiInput = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
         if not gameProcessedEvent then
            if input.KeyCode == Enum.KeyCode.Backspace then
               deleteGuisAtPos()
            end
         end
      end)
      Rayfield:Notify({
         Title = "GUI Delete Enabled",
         Content = 'Hover over a GUI and press backspace to delete it',
         Duration = 10,
         Image = 0,
      })
   end,
})

local Button = OneTab:CreateButton({
   Name = "No GUI delete",
   Callback = function()
      if deleteGuiInput then deleteGuiInput:Disconnect() end
      Rayfield:Notify({
         Title = "GUI Delete Disabled",
         Content = 'GUI backspace delete has been disabled',
         Duration = 10,
         Image = 0,
      })
   end,
})

local Button = OneTab:CreateButton({
   Name = "Hide DS",
   Callback = function()
      Rayfield:Destroy()
   end,
})

local Button = OneTab:CreateButton({
   Name = "Save game",
   Callback = function()
      if saveinstance then
         Rayfield:Notify({
            Title = "Loading",
            Content = 'Downloading game. This will take a while',
            Duration = 10,
            Image = 0,
         })
         saveinstance()
         Rayfield:Notify({
            Title = "Game Saved",
            Content = 'Saved place to the workspace folder within your exploit folder.',
            Duration = 10,
            Image = 0,
         })
     else
      Rayfield:Notify({
         Title = "Incompatible Exploit",
         Content = 'Your exploit does not support this command (missing saveinstance)',
         Duration = 10,
         Image = 0,
      })
     end
   end,
})

local Button = OneTab:CreateButton({
   Name = "Clear error",
   Callback = function()
      GuiService:ClearError()
   end,
})

local Slider = OneTab:CreateSlider({
   Name = "Volume",
   Range = {0, 10},
   Increment = 1,
   Suffix = ".",
   CurrentValue = 6,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(level)
      UserSettings():GetService("UserGameSettings").MasterVolume = level
   end,
})

local Button = OneTab:CreateButton({
   Name = "Anti-Lag | Boost FPS | Low Graphics",
   Callback = function()
      local Terrain = workspace:FindFirstChildOfClass('Terrain')
      Terrain.WaterWaveSize = 0
      Terrain.WaterWaveSpeed = 0
      Terrain.WaterReflectance = 0
      Terrain.WaterTransparency = 0
      Lighting.GlobalShadows = false
      Lighting.FogEnd = 9e9
      settings().Rendering.QualityLevel = 1
      for i,v in pairs(game:GetDescendants()) do
         if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
         elseif v:IsA("Decal") then
            v.Transparency = 1
         elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
         elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
         end
      end
      for i,v in pairs(Lighting:GetDescendants()) do
         if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
         end
      end
      workspace.DescendantAdded:Connect(function(child)
         task.spawn(function()
            if child:IsA('ForceField') then
               RunService.Heartbeat:Wait()
               child:Destroy()
            elseif child:IsA('Sparkles') then
               RunService.Heartbeat:Wait()
               child:Destroy()
            elseif child:IsA('Smoke') or child:IsA('Fire') then
               RunService.Heartbeat:Wait()
               child:Destroy()
            end
         end)
      end)
   end,
})

local Input = OneTab:CreateInput({
   Name = "Notify",
   CurrentValue = "",
   PlaceholderText = "Text",
   RemoveTextAfterFocusLost = false,
   Flag = "Input5",
   Callback = function(Text)
      Rayfield:Notify({
         Title = "Notification",
         Content = Text,
         Duration = 10,
         Image = 0,
      })
   end,
})

local Button = OneTab:CreateButton({
   Name = "Exit",
   Callback = function()
      game:Shutdown()
   end,
})

local Noclipping = nil
local Button = TwoTab:CreateButton({
   Name = "Noclip",
   Callback = function()
      Clip = false
	wait(0.1)
	local function NoclipLoop()
		if Clip == false and speaker.Character ~= nil then
			for _, child in pairs(speaker.Character:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
					child.CanCollide = false
				end
			end
		end
	end
	Noclipping = RunService.Stepped:Connect(NoclipLoop)
	if args[1] and args[1] == 'nonotify' then return end
	Rayfield:Notify({
      Title = "Noclip",
      Content = "Noclip Enabled",
      Duration = 10,
      Image = 0,
   })
   end,
})

local Button = TwoTab:CreateButton({
   Name = "Clip",
   Callback = function()
      if Noclipping then
         Noclipping:Disconnect()
      end
      Clip = true
      if args[1] and args[1] == 'nonotify' then return end
      Rayfield:Notify({
         Title = "Noclip",
         Content = "Noclip Disabled",
         Duration = 10,
         Image = 0,
      })
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})

local Button = TwoTab:CreateButton({
   Name = "",
   Callback = function()
      
   end,
})
