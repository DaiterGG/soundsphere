local ThreadPool	= require("aqua.thread.ThreadPool")
local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")

local ReplaySubmitter = Class:new()

ReplaySubmitter.construct = function(self)
	self.observable = Observable:new()
end

ReplaySubmitter.load = function(self)
	ThreadPool.observable:add(self)
end

ReplaySubmitter.unload = function(self)
	ThreadPool.observable:remove(self)
end

ReplaySubmitter.receive = function(self, event)
	if event.name == "ReplaySubmitResponse" then
		self.onlineModel:receive(event)
	end
end

ReplaySubmitter.submitReplay = function(self, replayHash, url)
    print(replayHash)

	return ThreadPool:execute(
		function(...)
			local data = ({...})[1]

            local replayFile = love.filesystem.newFile("userdata/replays/" .. data.hash, "r")
            local content = replayFile:read()
            local tempName = "rp" .. os.time()
            local tempFile, err = io.open(tempName, "wb")
            if not tempFile then
                print("Can't create temporary file " .. tempName)
                print(err)
            else
                print("Created temporary file " .. tempName)
            end
            tempFile:write(content)
            tempFile:close()

            local request = require("luajit-request")

            print("POST " .. data.host .. "/" .. data.url)
            local result, err, message = request.send(data.host .. "/" .. data.url, {
                method = "POST",
                files = {
                    replay = tempName
                }
            })

            if not result then
                print(err, message)
            else
                print(result.body)

                thread:push({
                    name = "ReplaySubmitResponse",
                    body = result.body
                })
            end

            os.remove(tempName)
		end,
		{
            {
                host = self.host,
                url = url,
                hash = replayHash
            }
        }
	)
end

return ReplaySubmitter
