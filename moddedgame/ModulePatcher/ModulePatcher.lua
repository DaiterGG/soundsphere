local ModulePatcher = {}

if not ModuleOverrides then
    ModuleOverrides = {}
end

local function patch(instance, override)
    for _, obj in pairs(override.objects) do
        instance[obj.name] = obj.instance
    end

    for _, func in pairs(override.functions) do
        if not func.baseFunction then
            func.baseFunction = instance[func.name]
        end

        instance[func.name] = function(...)
            for _, observer in pairs(func.observers) do
                observer.callback(observer.object, instance)
            end

            return func.baseFunction(...)
        end
    end
end

local function getOverride(filename)
    if ModuleOverrides[filename] then
        return ModuleOverrides[filename]
    end

    ModuleOverrides[filename] = {
        functions = {},
        objects = {}
    }

    package.preload[filename] = function()
        local instance = package.loaders[2](filename)()

        instance.__patch = patch

        if instance.new then -- it's a class
            instance.baseNew = instance.new

            instance.new = function (...)
                instance.baseNew(...)
                local newInstance = select(1, ...)
                newInstance.__patch(newInstance, ModuleOverrides[filename])
                return newInstance
            end

            return instance
        end

        instance.__patch(instance, ModuleOverrides[filename])

        return instance
    end

    return ModuleOverrides[filename]
end

local function getFunctionOverride(override, funcName)
    if override.functions[funcName]  then
        return override.functions[funcName]
    end

    override.functions[funcName]  = {
        name = funcName,
        baseFunction = nil,
        observers = {}
    }

    return override.functions[funcName]
end

--- Inserts any object into a module before it's loaded into the game.
---@param filename string
---@param objectName string
---@param object any
function ModulePatcher:insert(filename, objectName, object)
    local override = getOverride(filename)

    if type(object) == "function" then
        local functionOverride = getFunctionOverride(override, objectName)
        functionOverride.baseFunction = object
    else
        table.insert(override.objects, {
            name = objectName,
            instance = object
        })
    end
end

--- When specified function is called, calls your callback. And it also return the module instance.
---@param filename string
---@param funcName string
---@param callback function
---@param object any
function ModulePatcher:observe(filename, funcName, callback, object)
    local override = getOverride(filename)
    local functionOverride = getFunctionOverride(override, funcName)

    table.insert(functionOverride.observers, {
        callback = callback,
        object = object
    })
end

return ModulePatcher
