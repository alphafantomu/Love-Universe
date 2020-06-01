
--[[
    Hi, we need to optimize the use of calculating index, and filling in shit for optimization purposes

    The issue with the example below is that, when you #table, it is only up to the highest number index that ends with a nil
    {1, nil, 3}, using #table would indicate the highest index is 1, since index 2 returns a nil value.
    We usually calculate the index by doing #table + 1, so that the missing index can be filled in.
    The issue is that we require the index also to loop through it, so we can easily search through the table itself.
    We can use table.maxn, but the issue here is that it pertains to more time as the table gets bigger
    We can save the last and highest index somewhere so we can loop through the table without performance issues or missing objects or some bullshit like that.

    I don't want to rely on table.maxn for easy looping. The Calculation for index is fine, I just don't want objects to be missing when I am looping. My solution
    for this is to find the highest number index in the table, table.maxn can be used but it's too fucking heavy performance wise, so we're going to do a tricky way
    to do this

    Update
    We have two options, we can either have a record of indexes and search by the first index for the highest index
    Or we can use maxn everytime we want to iterate the loop
    We could also do by highest index but unlikely because if there is a mass number of objects being removed it might cause issues
    
    ---------------EXAMPLE--------------------
    local ClassList = ObjectsByClass[className];
    if (ClassList == nil) then
        ClassList = {};
        ObjectsByClass[className] = ClassList;
    end;
    local ObjectIndex = #ClassList + 1;
    meta.ClassIndex = ObjectIndex;
    ClassList[ObjectIndex] = obj;
    if (ClassList[ObjectIndex] ~= obj) then
        print('There was an error calculating objects');
    end;

    The children_stack is used as: check if exists, 
    ---------------CONCEPT---------------------
    local Object = obj;
    local ContainerTable = {};

    local FillIndex = #ContainerTable + 1; --calculate
    ContainerTable[FillIndex] = obj; --store
    ObjectContainer[obj] = 0;
    meta.FillIndex = FillIndex; --store the index connecting to the object

    --Children Check
    return ObjectContainer[obj] ~= nil
    
    --Recording Indexes--
    local IndexRecord = {};
    table.insert(IndexRecord, FillIndex);
    table.sort(IndexRecord, function(pre, post) --it's better if we somehow sort it in chunks instead
        return post > pre;
    end);
        --Iterating--
        for i = 1, IndexRecord[1] do
            local Object = ContainerTable[i];
            if (Object ~= nil) then
                --do stuff here
            end;
        end;

    --maxn--
        for i = 1, table.maxn(ContainerTable) do
            local Object = ContainerTable[i];
            if (Object ~= nil) then
                --stuff here
             end;
        end;

    --Highest Index--
    local hi = getmetatable(ContainerTable).highestIndex;
    for i = 1, hi do
        local Object = ContainerTable[i];
        if (Object ~= nil) then

        end;
    end;

    --Tried optimizing harder by attempting to rewrite quicksort to find the indexes, but the algorithm isn't made for that and it would be very difficult to implement it
    in the function itself, also quicksort is a lot slower if rewritten in lua, table.sort also uses quicksort but C runs faster than lua so, oof.

    --the purpose below is to make finding the highest index faster than maxn
    if we were to just index a table to find the highest index, it would be infinitely faster than doing table.maxn(t) every time.
    indexing and number loops are insanely fast
]]

local API = {};
local tableStorage = {};
local sortFunction = function(a, b)
    return a > b;
end;
--when 9999999 objects were in a table, Optimizer:maxn() was 4x faster than table.maxn();
API.maxn = function(self, t)
    local data = self:getTableData(t);
    if (data ~= nil) then
        return data[1];
    end;
end;

API.getTableData = function(self, t)
    return tableStorage[t];
end;

API.updateTable = function(self, t)
    local data = self:getTableData(t);
    if (data ~= nil) then table.sort(data, sortFunction) end;
end;

--data needs to be organized, but removing the index for a certain index, it doesn't matter if there are two of the same indexes because it's just a record
--we don't really use the indexes in data
API.__newindex = function(self, t, index)
    local data = self:getTableData(t);
    if (data ~= nil) then
        table.insert(data, index);
    end;
end;

API.__removeindex = function(self, t, index)
    local data = self:getTableData(t);
    if (data ~= nil) then
        for i = 1, #data do
            local foundIndex = data[i];
            if (index == foundIndex) then
                table.remove(data, i);
                break;
            end;
        end;
    end;
end;

--issue is that when we sort the indexes are unidentified after sorting occurs, we have to figure out how to get the indexes from sorting somehow
API.registerTableData = function(self, t)
    local data = {};
    local max = table.maxn(t);
    for i = 1, max do
        if (t[i] ~= nil) then
            table.insert(data, i);
        end;
    end;
    table.sort(data, sortFunction);
    tableStorage[t] = data;
end;

Optimizer = API;