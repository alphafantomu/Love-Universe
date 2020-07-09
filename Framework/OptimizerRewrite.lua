
--[[
    I had to rewrite the Optimizer, the way I was doing things was getting complicated and I needed a fresh start.

    My purpose in writing Optimizer.lua is:
        ‣ I realized having a shit ton of children objects and trying to loop through all of them to search for a child kinda hurts.
        ‣ Also the issue with the optimization for children currently is that #table does not return the highest index, it only returns the highest
            index until the next value is nil, we should use maxn but it's said that with larger tables it impacts performance
        ‣ I am hoping that Optimizer.lua will improve performance for games that require a lot of data.

    This is the concept behind the data of a array

    Data = {
        HIGHEST SECTION
        SECTION FILL
        SECTION FILL
        SECTION FILL
        LOWEST SECTION
    }

    Section = {
        HIGHEST VALUE
        VALUE FILL
        VALUE FILL
        VALUE FILL
        LOWEST VALUE
    }

    VALUE refers to the index number of the array

    There CANNOT be two values that are the same
]]

local oldInsert, oldRemove = table.insert, table.remove;
local API = {
    SectionSize = 5;
    ArrayData = {};
};
--[[
table.insert = function(self, val)
    local Data = API:ReceiveData(self);
    if (Data ~= nil) then
        API.OptimizerMetatable.__newindex(self, #self + 1, val, false);
    end;
    return oldInsert(self, val);
end;

table.remove = function(self, i)
    local Data = API:ReceiveData(self);
    if (Data ~= nil and tonumber(i) ~= nil) then
        API.OptimizerMetatable.__newindex(self, i, nil, false);
    end;
    return oldRemove(self, i);
end;]]

API.OptimizerMetatable = {
    __newindex = function(self, index, value, preset)
        local Data = API:ReceiveData(self);
        if (Data ~= nil and tonumber(index) ~= nil) then
            local Rewriting = self[index] ~= nil;
            if (Rewriting == true and value == nil) then --we don't have to check if the index exists, we just have to check if it is being removed, if it does exist we do nothing
                --Remove index from section
                print('Removement found')
            elseif (Rewriting == false) then --we have to write this into a new section
				local InsertStatus, Section = API:IndexInsertStatus(self, index);
				print('INSERT STATUS FOUND', InsertStatus, Section)
                if (InsertStatus == 1) then

                elseif (InsertStatus == 2) then

                elseif (InsertStatus == 3) then

                elseif (InsertStatus == 4) then

                elseif (InsertStatus == 5) then

                elseif (InsertStatus == 6) then

                elseif (InsertStatus == 7) then

                elseif (InsertStatus == 8) then

                elseif (InsertStatus == 0) then
					print('AN ERROR HAS OCCURED, SECTION IS SEPERATED');
                end;
            end;
            if (preset == true or preset == nil) then
                rawset(self, index, value);
            end;
        end;
    end;
    __len = function(self)
        local Data = API:ReceiveData(self);
        if (Data ~= nil) then
            return Data[1][1];
        end;
        return 0;
    end;
};
API.Incremental = function(self, s)
	if (#s > 1) then
		local Delta = s[1] - s[2];
		for i = 1, #s do
			local Value, Second = s[i], s[i + 1];
			if (Second ~= nil) then
				if (Delta ~= (Value - Second)) then
					return false, Delta;
				end;
			end;
		end;
	end;
	return true;
end;

API.IndexInsertStatus = function(self, t, i)
    local Data = self:ReceiveData(t);
    if (Data ~= nil) then
        local SectionHigh, SectionLow = Data[1], Data[#Data];
        local Max, Min = SectionHigh[1], SectionLow[#SectionLow];
        if (i > Max) then --index is too high
            local Filled = self:FullSection(SectionHigh);
            if (Filled == true) then --since the section is full there is no space for a new index
                return 1;
            elseif (Filled == false) then --since the section isn't full there must be space
                return 2, SectionHigh;
            end;
        elseif (i < Min) then --index is too low
            local Filled = self:FullSection(SectionLow);
            if (Filled == true) then --since the section is full there is no space for a new index
                return 3;
            elseif (Filled == false) then --since the section isn't full there must be space
                return 4, SectionLow;
            end;
		else
			--using same variable name by b
            for ie = 1, #Data do
                local Section = Data[ie];
				local Filled = self:FullSection(Section);
                local NextSection, PreviousSection = Data[ie - 1], Data[ie + 1];
                if (Filled == true) then

                end;
                if (NextSection ~= nil and PreviousSection ~= nil) then
                    
                elseif (NextSection == nil and PreviousSection ~= nil) then

                elseif (NextSection ~= nil and PreviousSection == nil) then

                end;
				if (Filled == true) then
					local Incremental = self:Incremental(Section);
					if (Incremental == true) then --think about this part
						local LowestValue, HighestValue = Section[#Section], Section[1];
						if (i <= HighestValue and i >= LowestValue) then
							return 5, Section;
						end;
					elseif (Incremental == false) then --because this is not completely incremental, we need to confirm by using other sections as reference
						local LowestValue, HighestValue = PreviousSection[1] or Section[#Section], NextSection[#NextSection] or Section[1];
						if (LowestValue ~= nil and HighestValue ~= nil and i <= HighestValue and i >= LowestValue) then
							return 6, Section;
						end;
					end;
                elseif (Filled == false) then
					if (NextSection == nil and PreviousSection ~= nil) then
						local Initial, Final = PreviousSection[1], Section[1];
						if (i <= Final and i >= Initial) then
							return 7, Section;
						end;
					elseif (PreviousSection == nil and NextSection ~= nil) then
						local Initial, Final = NextSection[#NextSection], Section[#Section];
						if (i <= Initial and i >= Final) then
							return 8, Section;
						end;
					end;
                end;

            end;
        end;
    end;
    return 0;
end;

API.Sort = function(a, b)
    return a > b;
end;

API.ReceiveData = function(self, t)
    return self.ArrayData[t];
end;

API.FullSection = function(self, s)
    return #s >= self.SectionSize;
end;

API.IsAcceptable = function(self, t)
    local n = #t;
    return n ~= nil and tonumber(n) ~= nil and n > 0;
end;

API.Optimize = function(self, t)
    local Data = self:ReceiveData(t);
    if (Data == nil) then
        local ArrayData = {};
        if (self:IsAcceptable(t) == true) then
            local max, section = math.floor(table.maxn(t)), {};
            for i = max, 1, -1 do
                local Exists = t[i] ~= nil;
                if (Exists == true and section ~= nil) then
                    if (self:FullSection(section) == false) then
                        table.insert(section, i);
                        local Filled = self:FullSection(section);
                        if (Filled == true) then
                            table.insert(ArrayData, section);
                            section = {};
                        elseif (Filled == false and (i - self.SectionSize) < 0 and i == 1) then
                            table.insert(ArrayData, section);
                            section = {};
                        end;
                    end;
                end;
            end;
        end;
        self.ArrayData[t] = ArrayData;
        return setmetatable(t, self.OptimizerMetatable);
    end;
end;

Optimizer = API;