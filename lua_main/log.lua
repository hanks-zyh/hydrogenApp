--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/16
-- Time: 10:44
--

-- print table content
local function print_r(sth)
    if type(sth) ~= "table" then
        print(sth)
        return
    end

    local space, deep = string.rep(' ', 4), 0
    local function _dump(t)
        local temp = {}
        for k, v in pairs(t) do
            local key = tostring(k)

            if type(v) == "table" then
                deep = deep + 2
                print(string.format("%s[%s] => Table%s{\n",
                    string.rep(space, deep - 1),
                    key,
                    string.rep(space, deep))) --print.
                _dump(v)

                print(string.format("%s)", string.rep(space, deep)))
                deep = deep - 2
            else
                print(string.format("%s[%s] => %s",
                    string.rep(space, deep + 1),
                    key,
                    v)) --print.
            end
        end
    end

    print(string.format("Table {\n"))
    _dump(sth)
    print(string.format("}"))
end

local log = {}
log.print_r = print_r
return log
