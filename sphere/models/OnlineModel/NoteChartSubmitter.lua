local ThreadPool	= require("aqua.thread.ThreadPool")
local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")

local NoteChartSubmitter = Class:new()

NoteChartSubmitter.construct = function(self)
	self.observable = Observable:new()
end

NoteChartSubmitter.load = function(self)
	ThreadPool.observable:add(self)
end

NoteChartSubmitter.unload = function(self)
	ThreadPool.observable:remove(self)
end

NoteChartSubmitter.receive = function(self, event)
	if event.name == "NoteChartSubmitResponse" then
		self.onlineModel:receive(event)
	end
end

NoteChartSubmitter.submitNoteChart = function(self, noteChartEntry, url)
    print(noteChartEntry.path)

	return ThreadPool:execute(
		[[
			local data = ({...})[1]
            local path = data.path

            local noteChartFile = love.filesystem.newFile(path, "r")
            local content = noteChartFile:read()
            local tempName = "nc" .. os.time()
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
                    notechart = tempName
                }
            })

            if not result then
                print(err, message)
            else
                print(result.body)
                
                thread:push({
                    name = "NoteChartSubmitResponse",
                    body = result.body
                })
            end
            
            os.remove(tempName)
		]],
        {
            {
                host = self.host,
                url = url,
                path = noteChartEntry.path
            }
        }
	)
end

return NoteChartSubmitter
