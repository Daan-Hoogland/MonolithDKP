--[[
  Core.lua is intended to store all core functions and variables to be used throughout the addon. 
  Don't put anything in here that you don't want to be loaded immediately after the Libs but before initialization.
--]]

local _, core = ...;
local _G = _G;

core.MonDKP = {};       -- UI Frames global
local MonDKP = core.MonDKP;

core.CColors = {   -- class colors
  ["Druid"] = { r = 1, g = 0.49, b = 0.04, hex = "FF7D0A" },
  ["Hunter"] = {  r = 0.67, g = 0.83, b = 0.45, hex = "ABD473" },
  ["Mage"] = { r = 0.25, g = 0.78, b = 0.92, hex = "40C7EB" },
  ["Priest"] = { r = 1, g = 1, b = 1, hex = "FFFFFF" },
  ["Rogue"] = { r = 1, g = 0.96, b = 0.41, hex = "FFF569" },
  ["Shaman"] = { r = 0.96, g = 0.55, b = 0.73, hex = "F58CBA" },
  ["Warlock"] = { r = 0.53, g = 0.53, b = 0.93, hex = "8787ED" },
  ["Warrior"] = { r = 0.78, g = 0.61, b = 0.43, hex = "C79C6E" }
}

--------------------------------------
-- Addon Defaults
--------------------------------------
local defaults = {
  theme = { r = 0.6823, g = 0.6823, b = 0.8666, hex = "aeaedd" },
  theme2 = { r = 1, g = 0.37, b = 0.37, hex = "ff6060" }
}

core.MonDKPUI = {}        -- global storing entire Configuration UI to hide/show UI
core.TableWidth, core.TableRowHeight, core.TableNumRows = 500, 18, 27; -- width, row height, number of rows
core.SelectedData = { player="none"};         -- stores data of clicked row for manipulation.
core.classFiltered = {};   -- tracks classes filtered out with checkboxes
core.classes = { "Druid", "Hunter", "Mage", "Priest", "Rogue", "Shaman", "Warlock", "Warrior" }
core.MonVersion = "v0.1 (alpha)";
core.WorkingTable = {};       -- table of all entries from MonDKP_DKPTable that are currently visible in the window
core.SelectedRows = {};       -- tracks rows in DKPTable that are currently selected for SetHighlightTexture

function MonDKP:GetCColors(class)
  if core.CColors then 
    local c = core.CColors[class];
    return c;
  else
    return false;
  end
end

function MonDKP:ResetPosition()
  MonDKP.UIConfig:ClearAllPoints();
  MonDKP.UIConfig:SetPoint("CENTER", UIParent, "CENTER", -250, 100);
  MonDKP.UIConfig:SetSize(1000, 590);
  MonDKP:Print("Window Position Reset")
end

function MonDKP:GetThemeColor()
  local c = {defaults.theme, defaults.theme2};
  return c;
end

function MonDKP:Print(...)        --print function to add "MonolithDKP:" to the beginning of print() outputs.
    local defaults = MonDKP:GetThemeColor();
    local prefix = string.format("|cff%s%s|r|cff%s", defaults[1].hex:upper(), "MonolithDKP:", defaults[2].hex:upper());
    local suffix = "|r";
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ..., suffix));
end

-------------------------------------
-- Recursively searches tar (table) for val (string) as far as 4 nests deep
-- returns an indexed array of the keys to get to it.
-- IE: If the returned array is {1,3,2,player} it means it is located at tar[1][3][2][player]
-- use to search for players in SavedVariables. Only two possible returns is the table or false.
-------------------------------------
function MonDKP:Table_Search(tar, val)
  local value = string.upper(tostring(val));
  local location = {}
  for k,v in pairs(tar) do
    if(type(v) == "table") then
      local temp1 = k
      for k,v in pairs(v) do
        if(type(v) == "table") then
          local temp2 = k;
          for k,v in pairs(v) do
            if(type(v) == "table") then
              local temp3 = k
              for k,v in pairs(v) do
                if string.upper(tostring(v)) == value then
                  tinsert(location, {temp1, temp2, temp3, k} )
                end;
              end
            end
            if string.upper(tostring(v)) == value then
              tinsert(location, {temp1, temp2, k} )
            end;
          end
        end
        if string.upper(tostring(v)) == value then
          tinsert(location, {temp1, k} )
        end;
      end
    end
    if string.upper(tostring(v)) == value then  -- only returns in indexed arrays
      tinsert(location, k)
    end;
  end
  if (#location > 0) then
    return location;
  else
    return false;
  end
end

function MonDKP:DKPTable_Set(tar, field, value)              -- updates field with value where name is found    -- core and table functions
  local result = MonDKP:Table_Search(MonDKP_DKPTable, tar);
  for i=1, #result do
    local current = MonDKP_DKPTable[result[i][1]][field];
    if(field == "dkp") then
      MonDKP_DKPTable[result[i][1]][field] = current + value
    else
      MonDKP_DKPTable[result[i][1]][field] = value
    end
  end
  MonDKP:FilterDKPTable("class", "reset")
end
  

function MonDKP:PrintTable(tar)             --prints table structure for testing purposes
  ChatFrame1:Clear()
  for k,v in pairs(tar) do                  -- remove prior to RC
    if (type(v) == "table") then
      print(k)
      for k,v in pairs(v) do
        if (type(v) == "table") then
          print("    ", k)
          for k,v in pairs(v) do
            if (type(v) == "table") then
              print("        ", k)
              for k,v in pairs(v) do
                if (type(v) ~= "table") then
                  print("            ", k, " -> ", v)
                end
              end
              print(" ")
            else
              print("        ", k, " -> ", v)
            end
          end
          print(" ")
        else
          print("    ", k, " -> ", v)
        end
      end
      print(" ")
    else
      print(k, " -> ", v)
    end
  end
  print(" ")
end