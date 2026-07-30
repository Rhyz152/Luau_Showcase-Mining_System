const module = {}
module.__index = module

type ObjectCallbackPool = (Object: Instance) -> ()

const function empty() end

function module.Construct(Object: Instance, Amount: number, OnCreate: ObjectCallbackPool, OnGet: ObjectCallbackPool?, OnFree: ObjectCallbackPool)
    const self = setmetatable({}, module)

    self._Objects = {}
    self._Object = Object
    self._OnCreate = OnCreate or empty
    self._OnGet = OnGet or empty
    self._OnFree = OnFree or empty

    for i = 1, Amount do
        const Obj = Object:Clone()
        table.insert(self._Objects, Obj)
        self._OnCreate(Obj)
    end

    return self
end

--// Gets the created object from the stored objects table
function module:Get()
    local Object

    if #self._Objects == 0 then
        Object = self._Object:Clone()
    else
        Object = table.remove(self._Objects, 1)
    end

    self._OnCreate(Object)
    self._OnGet(Object)
    return Object
end

--// Stores the object back
function module:Free(Object: Instance)
    self._OnFree(Object)
    table.insert(self._Objects, Object)
end

--// Clears all objects
function module:Clear()
    for _, Obj in ipairs(self._Objects) do
        Obj:Destroy()
    end
    self._Objects = {}
end

return module