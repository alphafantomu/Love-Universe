
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

    --Operation is successful, Optimizer:maxn() is 5x faster than table.maxn()
    However the table has to be updated so that it does not lag, that's a big oof
    If we were to only sort the first five highest indexes, we can actually make it very easy and less heavy
    {999,888,666}, {555, 222, 111}
    instead of doing the whole table

    We're adding sections so that we only sort one section with a limited section size, instead of the whole data table, if you have millions of indexes it will
    be very laggy.

    ShiftAdd and getSectionByIndex needs to be checked for inbetweens and duplicated values

    UPDATE: The idea behind optimizer is good, but it's going to have to be something for me to work on at a later time, here are the issues:
    Adding new and higher indexes work fine, but adding indexes BETWEEN each other causes issues, it may be because of shifting issues in ShiftAdd
    Adding new and lower indexes have not been tested yet.
]]

local API = {
    SectionSize = 5;
};
local tableStorage = {};
local indexRanges = {}; --index = {};
local sortFunction = function(a, b)
    return a > b;
end;
--when 9999999 objects were in a table, Optimizer:maxn() was 4-5x faster than table.maxn();
API.maxn = function(self, t)
    local data = self:getTableData(t);
    if (data ~= nil) then
        return data[1][1];
    end;
end;

API.getTableData = function(self, t)
    return tableStorage[t];
end;

--it is a good choice to check for repeating values or inbetweens here
        --an issue could be that if we have section {1, 1, 1, 1, 1}, and we add 0, we expect 0 to be added and one of the values to be moved up. Consistnt and HasRepeating is true
        --{2, 1, 1, 1, 1} and we add 0, 2 should be moved up, consistent is false but HasRepeating is true
        --{1, 2, 3, 4, 5} and we add 0, 5 should be moved up, consistent is true but hasRepeating is false
		--{1, 4, 7, 2, 9} and we add 0, 7 should be moved up, consistent and hasRepeating is false

--getSectionByIndex should only be used for INBETWEEN numbers within sections
API.getSectionByIndex = function(self, t, i) --we need to think about what if the section doesn't have the max number of size, it would be hard to estimate that way.
    local data = self:getTableData(t);
    --print(ti, i);
    if (data ~= nil) then
        local lowestSectionIndex = #data; 
        local lowestSection, highestSection = data[lowestSectionIndex], data[1];
        local lowestNumber, highestNumber = lowestSection[1], highestSection[1];
        if (i == lowestNumber) then
            --print(ti, i, 'lowest');
            return lowestSection, lowestSectionIndex;
        elseif (i == highestNumber) then
            --print(ti, i, 'highest');
            return highestSection, 1;
        elseif (i >= highestNumber) then
            --if i is larger than the highest number, then we need to make a new section
            --print(ti, i, 'larger');
            --print('index too large')
        elseif (i <= lowestNumber) then
            --print(ti, i, 'smaller');
           -- print('index too small')
        elseif (i ~= lowestNumber and i ~= highestNumber) then
            --print(ti, i, 'between');
            local middleIndex = math.ceil(((lowestSectionIndex - 1)/2));
            local middleSection = data[middleIndex];
            if (middleSection ~= nil) then
                local average = (highestNumber + lowestNumber)/2;
                --[[
                    LOWEST_________44444_______________AVERAGE____________1000000_____________HIGHEST
                    44444 is LESS than the average -> average is MORE than 44444
                    1000000 is MORE than the average -> average is LESS than 1000000

                    The HIGHER the index, the LOWER the numbers are
					THE LOWER the index, the HIGHER the numbers
					
					we do not want to check for the previous section if the section is consistent AND repeating is false
                ]]
				if (average > i) then --this means the average between the highestNumber
					for d = lowestSectionIndex, middleIndex, -1 do --since this is going from the highest index to a lower index, its going from smallest numbers to bigger ones
						local singleSection = data[d];
						local size = #singleSection;
						local HasRepeat, Values = self:HasRepeating(singleSection);
						local Consistent = self:ConsistentDifference(singleSection);
						if (HasRepeat == true) then
							if (Consistent == true or Consistent == false) then
								local higherSection = data[d - 1];
								if (higherSection ~= nil) then
									local highestIndex, lowerIndex = higherSection[1], singleSection[1];
									if (i <= highestIndex and i >= lowerIndex) then
										return higherSection, d - 1;
									end;
								end;
							end;
						elseif (HasRepeat == false) then
							if (Consistent == true or Consistent == false) then
								if (size >= self.SectionSize) then
									local lowestIndex, highestIndex = singleSection[size], singleSection[1];
									if (i <= highestIndex and i >= lowestIndex) then --if i is higher then it won't return anything
										return singleSection, d;
									end;
								elseif (size < self.SectionSize and size > 0) then --we only need t
									local higherSection = data[d - 1];
									if (higherSection ~= nil) then
										local highestIndex, lowerIndex = higherSection[1], singleSection[1];
										if (i <= highestIndex and i >= lowerIndex) then
											return higherSection, d - 1;
										end;
									end;
								end;
							end;
						end;
                    end;
				elseif (average < i) then --this means lowestNumber between the average
					
					for d = 1, middleIndex do --since this is going from the lowest index to a higher index, it's going to be the largest numbers to smaller one
                        local singleSection = data[d];
						local size = #singleSection;
						local HasRepeat, Values = self:HasRepeating(singleSection);
						local Consistent = self:ConsistentDifference(singleSection);
						if (HasRepeat == true) then
							if (Consistent == true or Consistent == false) then
								local higherSection = data[d - 1];
								if (higherSection ~= nil) then
									local highestIndex, lowerIndex = higherSection[1], singleSection[1];
									if (i <= highestIndex and i >= lowerIndex) then
										return higherSection, d - 1;
									end;
								end;
							end;
						elseif (HasRepeat == false) then
							if (Consistent == true or Consistent == false) then
								if (size >= self.SectionSize) then
									local lowestIndex, highestIndex = singleSection[size], singleSection[1];
									if (i <= highestIndex and i >= lowestIndex) then --if i is higher then it won't return anything
										return singleSection, d;
									end;
								elseif (size < self.SectionSize and size > 0) then --we only need t
									local higherSection = data[d - 1];
									if (higherSection ~= nil) then
										local highestIndex, lowerIndex = higherSection[1], singleSection[1];
										if (i <= highestIndex and i >= lowerIndex) then
											return higherSection, d - 1;
										end;
									end;
								end;
							end;
						end;
                    end;
				elseif (average == i) then --take a look at this too
                    for d = 1, #middleSection do
                        local middleIndex = middleSection[d];
                        if (middleIndex == average) then
                            return middleSection, middleIndex;
                        end;
                    end;
                end;
            else --middle index is nil?!??!
                table.sort(data); --this might cause problems, EDIT: this shouldn't cause problems because we're sorting by index, we're only filling in the blanks.
                return self:getSectionByIndex(t, i);
            end;
        end;
    end;
end;

API.getSectionByExistingIndex = function(self, t, i)

end;

API.updateTable = function(self, t) --complicated, but this should work fine
    local data = self:getTableData(t);
    if (data ~= nil) then 
        local highestSection = data[1];
        repeat
            if (highestSection ~= nil) then
                if (#highestSection > 0) then
                    table.sort(highestSection, sortFunction);
                    break;
                elseif (#highestSection <= 0 and data[2] ~= nil) then
                    table.remove(data, 1);
                    highestSection = data[1];
                end;
            end;
        until
            #highestSection > 0;
    end;
end;

--data needs to be organized, but removing the index for a certain index, it doesn't matter if there are two of the same indexes because it's just a record
--we don't really use the indexes in data
--dont need to check inbetween or duplicates
API.checkIfSorted = function(self, section)
    --lowest index should be the highest
    if (#section > 1) then
        local previousIndex = section[1];
        for i = 2, #section do
            local index = section[i];
            if (previousIndex < index) then
                return false;
            end;
            previousIndex = index;
        end;
    end;
    return true;
end;

API.GetRepeatingValues = function(self, section)
    local valueTest = {};
    local repeatingValues = {};
    for i = 1, #section do
        local value = section[i];
        if (valueTest[value] == nil) then
            valueTest[value] = 0;
        elseif (valueTest[value] ~= nil) then
            table.insert(repeatingValues, value);
        end;
    end;
    return repeatingValues;
end;

API.HasRepeating = function(self, section)
    local Values = self:GetRepeatingValues(section);
    return Values[1] ~= nil, Values;
end;

API.ConsistentDifference = function(self, section)
    local previousValue, detectedDifference;
    local size = #section;
    if (size > 1) then
        for i = 1, size do
            if (previousValue ~= nil) then
                if (detectedDifference == nil) then
                    detectedDifference = math.abs(previousValue - section[i]);
                end;
                if (math.abs(previousValue - section[i]) ~= detectedDifference) then
                    return false;
                end;
            elseif (previousValue == nil) then
                previousValue = section[i];
            end;
        end;
    end;
    return true;
end;
--[[
    For adding, not removing we need to add new sections if all current sections are full

    we need to account for the fact when we are trying to find if index is inbetween a section, is that lowestNumber and highestNumber could also be the same
]]
--we definitely need to check for existing duplicate values or values inbetween

--[[
    We need to rewrite ShiftAdd

]]
API.ShiftAdd = function(self, data, section, sectionIndex, index) --this function might need to be revamped
    --print(data, section, sectionIndex, index);
    local amt = #section;
    if (amt >= self.SectionSize) then --when the size is too much, we need to either add the index to an existing section or make a new section and add it there
        --we can either add index to existing section <- this actually shouldn't be possible because of the second conditional, it will fill in any empty spots
        --or we can make a new section and add it there
        --we need to account for what index is inbetween the specified section? This has to be true because section is given to us
        --also there can be repeating values which can cause issues
        --an issue could be that if we have section {1, 1, 1, 1, 1}, and we add 0, we expect 0 to be added and one of the values to be moved up. Consistnt and HasRepeating is true
        --{2, 1, 1, 1, 1} and we add 0, 2 should be moved up, consistent is false but HasRepeating is true
        --{1, 2, 3, 4, 5} and we add 0, 5 should be moved up, consistent is true but hasRepeating is false
        --{1, 4, 7, 2, 9} and we add 0, 7 should be moved up, consistent and hasRepeating is false
        if (self:checkIfSorted(section) == false) then
            print('not sorted?');
            table.sort(section, sortFunction);
		end;
		print'we have reached here';
        local HasRepeating, Values = self:HasRepeating(section);
        local Consistent = self:ConsistentDifference(section);
		local highestValue = section[1];
		
		local nextSection = data[sectionIndex - 1];
        if (nextSection ~= nil) then --higher section does exist, we need to get the highest value and shift it up
			for i = 1, amt do
				local value = section[i];
				if (value == highestValue) then
					table.remove(section, i);
				end;
			end;
			local nextAmt = #nextSection;
			if (nextAmt >= self.SectionSize) then --oh right we can't do this because of tail call optimization
				self:ShiftAdd(data, nextSection, sectionIndex - 1, highestValue);
			elseif (nextAmt < self.SectionSize) then
				table.insert(nextSection, highestValue);
				table.sort(nextSection, sortFunction);
			end;
        elseif (nextSection == nil) then --if the higher section doesnt exist, then instead of moving it down and causing immense lag we create a new section instead
            local newSection = {};
            table.insert(newSection, index);
            self:SectionShiftAdd(data, newSection, sectionIndex);
		end;
		--[[
        if (HasRepeating == true and Consistent == true) then

        elseif (HasRepeating == true and Consistent == false) then

        elseif (HasRepeating == false and Consistent == true) then

        elseif (HasRepeating == false and Consistent == false) then --we DO NOT have to check if the index is inbetween the section boundaries, as getSectionByIndex does that for us
            --we shift the highest value upwards, meaning we decrease the section index to get the higher section
            local nextSection = data[sectionIndex - 1];
            if (nextSection ~= nil) then --higher section does exist, we need to get the highest value and shift it up
                local shiftingValue = section[1];
				for i = 1, amt do
					local value = section[i];
					if (value == shiftingValue) then
						table.remove(section, i);
					end;
				end;
				local nextAmt = #nextSection;
				if (nextAmt >= self.SectionSize) then
					self:ShiftAdd(data, nextSection, sectionIndex - 1, shiftingValue);
				elseif (nextAmt < self.SectionSize) then
					table.insert(nextSection, shiftingValue);
					table.sort(nextSection, sortFunction);
				end;
            elseif (nextSection == nil) then --if the higher section doesnt exist, then instead of moving it down and causing immense lag we create a new section instead
                local newSection = {};
                table.insert(newSection, index);
                self:SectionShiftAdd(data, newSection, sectionIndex);
            end;
        end;]]
    elseif (amt < self.SectionSize) then --this part should actually be okay
        table.insert(section, index);
        table.sort(section, sortFunction);
    end;
end;

API.SectionShiftAdd = function(self, data, section, targetIndex) --this is going to be a bit complicated
    --we want indexes before targetIndex to not be touched, but targetIndexes after it to be shifted up by 1

    --we want to replace the targetIndex's section with another targetIndex's new section
    --then we save that old section of targetIndex, then use that section to replace the targetIndex + 1's section
    local savedSection = section;
    local i = targetIndex;
    repeat
        local currentSection = data[i];
        if (currentSection ~= nil) then
            data[i] = savedSection;
            savedSection = currentSection;
            i = i + 1;
        else
            break;
        end;
    until
        savedSection == nil;
end;

API.PredictIndexPlacement = function(self, t, index)
    local data = self:getTableData(t);
    if (data ~= nil) then
        local lowestSectionIndex = #data; 
        local lowestSection, highestSection = data[lowestSectionIndex], data[1];
        local lowestNumber, highestNumber = lowestSection[#lowestSection], highestSection[1];
        print'_____________________________';
        table.foreach(lowestSection, print);
        print'_____________________________';
        print("LWOWOWOWOW", highestNumber, lowestNumber);
    end;
end;
--we do not have to check for inbetweens or repeating values here
--[[
    1 - The index was too high to be checked between the sections and there are no open spaces for the highest section
    2 - The index was too high to be checked between the sections, though there is an open space in the highest section
    3 - The index was too low to be checked between the sections and there are no open spaces for the lowest section
    4 - The index was too low to be checked between the sections, though there is an open space in the lowest section

    5 - The index is valid in a pure incremental section with no repeating values
    6 - The index is valid in a non incremental section with repeating values
    7 - The index is valid in a purely incremental section with ALL repeating values
    8 - The index is valid within a unfilled section AND the next section does not exist
    9 - The index is valid within a unfilled section AND the previous section does not exist
    10 - The index is invalid in all situations for some reason
    
    A section cannot be both purely incremental and have repeating values
        Because if there are repeating values then that means the increment is 0
            The only exception is that if ALL the values of the section are repeating, then it can be incremental

    If a section is incomplete,
        How do we check if the index is valid on the section?
            We have to split the function into conditionals
                Let primary section be a section
                Let next section be the section LOWER than the primary section
                Let previous section be the section HIGHER than the primary section
            
                If the next section does not exist but the previous section does, this means that primary section should be the highest section
                    Since we know that the primary section is incomplete, we can do calculations there
                        We know that index CANNOT be higher than the primary section's highest value since it's checked elsewhere
                        We grab "index" and check if it is INBETWEEN the "PREVIOUS SECTION's highest value" and "PRIMARY SECTION's highest value"
                If the next section does exist but the previous section doesn't, this means that the primary section should be the lowest section
                    Since we know that the primary section is incomplete, we can do calculations here
                        We know that index CANNOT be lower than the primary section's lowest value since it's checked elsewhere
                        We grab "index" and check if it is INBETWEEN the "NEXT SECTION's lowest value" and "PRIMARY SECTION's lowest value"

    The leveling for data goes like this:
    3 PREVIOUS SECTION
    2 PRIMARY SECTION
    1 NEXT SECTION

    Section orders go like this:
    5 LOWEST VALUE
    4 MIDDLE
    3 MIDDLE
    2 MIDDLE
    1 HIGHEST VALUE

    5-7 should only be given ONLY if the section is at or is greater than the section size.
    1-4 have special cases
    8-max should only be given ONLY if the section is less than the section size
]]

API.PlacementHandlers = {};
API.__newindex = function(self, t, index) --we would have to use our big brain
    local data = self:getTableData(t);
    if (data ~= nil) then
        local PlacementType = self:PredictIndexPlacement(t, index);
        print(PlacementType, "TYPING")
        local PlacementHandler = self.PlacementHandlers[PlacementType];
        if (PlacementHandler ~= nil) then
            PlacementHandler(t, index);
        end;
    end;

    if (data ~= nil) then
        local section, sectionIndex = self:getSectionByIndex(t, index);
        if (section ~= nil) then
            self:ShiftAdd(data, section, sectionIndex, index);
        
        else --the index is either too small or too large, this part of the function works fine actually
            local lowestSection, highestSection = data[#data], data[1];
            local lowestNumber, highestNumber = lowestSection[1], highestSection[1];
            if (index <= lowestNumber) then
                local size = #lowestSection;
                if (size >= self.SectionSize) then
                    local newSection = {};
                    table.insert(newSection, index);
                    table.insert(data, newSection);
                elseif (size < self.SectionSize) then -- and size >= 0) then
                    table.insert(lowestSection, index);
                    table.sort(lowestSection, sortFunction);
                end;
            elseif (index >= highestNumber) then --there is a chance that the section with the highest numbers has a spot open for this index.
                local size = #highestSection;
                if (size >= self.SectionSize) then
                    local newSection = {};
                    table.insert(newSection, index);
                    self:SectionShiftAdd(data, newSection, 1);
                elseif (size < self.SectionSize) then -- and size >= 0) then
                    table.insert(highestSection, index);
                    table.sort(highestSection, sortFunction);
                end;
            end;
        end;
    end;
end;
--checking for inbetween values is not necessary here
API.__removeindex = function(self, t, index) --dont need to shift it down
    local data = self:getTableData(t);
    if (data ~= nil) then
        local section, sectionIndex = self:getSectionByExistingIndex(t, index);
        if (section ~= nil) then
            for i = 1, #section do
                local foundIndex = section[i];
                if (index == foundIndex) then
                    table.remove(section, i);
                    break;
                end;
            end;
            if (#section <= 0) then
                table.remove(data, sectionIndex);
            end;
            --we don't need a sort function here because it just shifts down
        end;
    end;
end;

--issue is that when we sort the indexes are unidentified after sorting occurs, we have to figure out how to get the indexes from sorting somehow
--we only use values to check if it exists
--table.remove shifts down the indexes
API.registerTableData = function(self, t) --this should be okay, checked the order of the top 5 largest values and this was fine
    local data = {};
    local max = table.maxn(t);
    local section = nil;
    for i = max, 1, -1 do
        if (t[i] ~= nil) then
            if (section == nil) then
                section = {};
            end;
            if ((#section + 1) >= self.SectionSize) then
                table.insert(section, i);
                table.sort(section, sortFunction);
                table.insert(data, section);
                section = nil;
            elseif (#section < (self.SectionSize - 1)) then
                table.insert(section, i);
            end;
        end;
    end;
    tableStorage[t] = data;
end;

Optimizer = API;