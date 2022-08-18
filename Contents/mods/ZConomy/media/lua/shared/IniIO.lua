-- =============================================================================
-- INI Reader / Writer
-- by RoboMat
--
-- Created: 30.01.14 - 16:59
-- modified by Valrix 16.09.21 - 15:34
-- =============================================================================

-- ------------------------------------------------
-- Global Variables
-- ------------------------------------------------

IniIO = {};

-- ------------------------------------------------
-- Helper Functions
-- ------------------------------------------------
IniIO.contains = function(str1,str2)
    return (string.find(str1,str2,1,true) > 1);
end

IniIO.startsWith = function(str,Start)
    return string.sub(str, 1, string.len(Start)) == Start;
end

IniIO.trim = function(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- ------------------------------------------------
-- INI READER
-- ------------------------------------------------
---
-- Reads a file written in .ini-format:
-- http://en.wikipedia.org/wiki/INI_file
--
-- @param String    _path
-- @param Boolean   _createIfNil
--
function IniIO.readIni(_path, _createIfNil)
    local path = _path;
    local useNewFile = _createIfNil or false;

    -- Create new file reader.
    local reader = getFileReader(path, useNewFile);

    if reader then
        local file = {};
        local section;
        local line;

        while true do
            line = reader:readLine();

            -- If no line can't be read we know that EOF is reached.
            if not line then
                reader:close();
                break;
            end

            -- Trim excess whitespace
            line = IniIO.trim(line);

            if IniIO.startsWith(line, "[") then --[[ We have a new section ]] --
                -- Cut out the actual section name (remove []).
                section = line:sub(2, line:len() - 1)

                -- Create a new nested table for that section.
                file[section] = {};

            elseif IniIO.contains(line, "=") then --[[ We have a key && value line ]] --
                -- Make sure we have an active section to write to.
                assert(file[section], "ERROR: No global properties allowed. There has to be a section declaration first.");

                -- Split the key from the value.
                local key,value = string.gmatch(line, "(.*)=(.*)")();
                key = IniIO.trim(key);
                value = IniIO.trim(value);
                -- convert strings to numbers now for convenience
                if tonumber(value) ~= nil then
                    value = tonumber(value);
                end

                -- Use the key to index the active table and store the value.
                file[section][key] = value;
            end
        end

        return file;
    else
        print("\r\nERROR: Can't read file at: " .. path .. "\r\n");
        return;
    end
end

-- ------------------------------------------------
-- INI WRITER
-- ------------------------------------------------
---
-- @param String    _path
-- @param Table     _ini
-- @param Boolean   _createIfNil
-- @param Boolean   _append
--
function IniIO.writeIni(_path, _ini, _createIfNil, _append)
    local path = _path;
    local ini = _ini;
    local useNewFile = _createIfNil or true;
    local append = _append or false;

    local writer = getFileWriter(path, useNewFile, append);

    if writer then
        for section, values in pairs(ini) do
            writer:write("[" .. tostring(section) .. "]\r\n");

            for key, value in pairs(values) do
                writer:write(tostring(key) .. "=" .. tostring(value) .. "\r\n");
            end
        end

        writer:close();
    else
        print("\r\nERROR: Can't create file at: " .. path .. "\r\n");
        return;
    end
end
