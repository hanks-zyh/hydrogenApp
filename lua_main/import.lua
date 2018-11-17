local context = activity or service
local require = require
local table = require "table"
local packages = {}
local loaded = {} -- store bindclass
local imported = {} -- store class via import function
luajava.package = packages
luajava.loaded = loaded
luajava.imported = imported
local _G = _G
local insert = table.insert
local new = luajava.new
local bindClass = luajava.bindClass
local dexes = luajava.astable(context.getClassLoaders())
local libs = context.getLibrarys()
local loaders = {} -- store fun ction to load class

local function libsloader(path)
    local p = libs[path:match("^%a+")]
    if p then
        return assert(package.loadlib(p, "luaopen_" .. (path:gsub("%.", "_")))), p
    else
        return "\n\tno file ./libs/lib" .. path .. ".so"
    end
end

table.insert(package.searchers, libsloader)


-- classname replace '_' to '&'
local function massage_classname(classname)
    if classname:find('_') then
        classname = classname:gsub('_', '$')
    end
    return classname
end

local function import_class(classname, packagename)
    packagename = massage_classname(packagename)
    local res, class = pcall(bindClass, packagename)
    if res then
        loaded[classname] = class
        return class
    end
end

local function import_dex_class(classname, packagename)
    packagename = massage_classname(packagename)
    for _, dex in ipairs(dexes) do
        local res, class = pcall(dex.loadClass, packagename)
        if res then
            loaded[classname] = class
            return class
        end
    end
end

local pkgMT = {
    __index = function(T, classname)
        local ret, class = pcall(bindClass, rawget(T, "__name") .. classname)
        if ret then
            rawset(T, classname, class)
            return class
        else
            error(classname .. " is not in " .. rawget(T, "__name"), 2)
        end
    end
}

local function import_pacckage(packagename)
    local pkg = { __name = packagename }
    setmetatable(pkg, pkgMT)
    return pkg
end

local function import_1(classname)
    for i, p in ipairs(packages) do
        local class = import_class(classname, p .. classname)
        if class then
            return class
        end
    end
end

local function import_2(classname)
    for _, p in ipairs(packages) do
        local class = import_dex_class(classname, p .. classname)
        if class then
            return class
        end
    end
end

local function import_require(name)
    local s, r = pcall(require, name)
    if not s and not r:find("no file") then
        error(r, 0)
    end
    return s and r
end

-- append v to t
local function append(t, v)
    for _, _v in ipairs(t) do
        if _v == v then
            return
        end
    end
    insert(t, v)
end

append(loaders, import_1)
append(loaders, import_2)

local globalMT = {
    __index = function(T, classname)
        for i, p in ipairs(loaders) do
            local class = loaded[classname] or p(classname)
            if class then
                T[classname] = class
                return class
            end
        end
        return nil
    end
}
--setmetatable(_G, globalMT)

-- the implements of import fuction
local function env_import(env)
    local _env = env
    setmetatable(_env, globalMT)
    return function(package)
        local j = package:find(':')
        if j then
            local dexname = package:sub(1, j - 1)
            local classname = package:sub(j + 1, -1)
            local class = context.loadDex(dexname).loadClass(classname)
            local classname = package:match('([^%.$]+)$')
            _env[classname] = class
            append(imported, package)
            return class
        end
        local i = package:find('%*$') -- android.widget.*
        if i then -- a wildcard; put into the package list, including the final '.'
            append(packages, package:sub(1, -2))
            append(imported, package)
            return import_pacckage(package:sub(1, -2))
        else -- android.widget.Button
            local classname = package:match('([^%.$]+)$')
            local class = import_require(package) or import_class(classname, package) or import_dex_class(classname, package)
            if class then
                if class ~= true then
                    --findtable(package)=class
                    if type(class) ~= "table" then
                        append(imported, package)
                    end
                    _env[classname] = class
                end
                return class
            else
                error("cannot find " .. package, 2)
            end
        end
    end
end

function compile(name)
    append(dexes, context.loadDex(name))
end

import = env_import(_G)
append(packages, '')

import 'java.lang.*'
import 'java.util.*'
import 'androlua.*'

import "loadlayout"
import "loadbitmap"
import "loadmenu"

function enum(e)
    return function()
        if e.hasMoreElements() then
            return e.nextElement()
        end
    end
end

function each(o)
    local iter = o.iterator()
    return function()
        if iter.hasNext() then
            return iter.next()
        end
    end
end

function dump(o)
    local t = {}
    local _t = {}
    local _n = {}
    local space, deep = string.rep(' ', 2), 0
    local function _ToString(o, _k)
        if type(o) == ('number') then
            table.insert(t, o)
        elseif type(o) == ('string') then
            table.insert(t, string.format('%q', o))
        elseif type(o) == ('table') then
            local mt = getmetatable(o)
            if mt and mt.__tostring then
                table.insert(t, tostring(o))
            else
                deep = deep + 2
                table.insert(t, '{')

                for k, v in pairs(o) do
                    if v == _G then
                        table.insert(t, string.format('\r\n%s%s\t=%s ;', string.rep(space, deep - 1), k, "_G"))
                    elseif v ~= package.loaded then
                        if tonumber(k) then
                            k = string.format('[%s]', k)
                        else
                            k = string.format('[\"%s\"]', k)
                        end
                        table.insert(t, string.format('\r\n%s%s\t= ', string.rep(space, deep - 1), k))
                        if type(v) == ('table') then
                            if _t[tostring(v)] == nil then
                                _t[tostring(v)] = v
                                local _k = _k .. k
                                _t[tostring(v)] = _k
                                _ToString(v, _k)
                            else
                                table.insert(t, tostring(_t[tostring(v)]))
                                table.insert(t, ';')
                            end
                        else
                            _ToString(v, _k)
                        end
                    end
                end
                table.insert(t, string.format('\r\n%s}', string.rep(space, deep - 1)))
                deep = deep - 2
            end
        else
            table.insert(t, tostring(o))
        end
        table.insert(t, " ;")
        return t
    end

    t = _ToString(o, '')
    return table.concat(t)
end

local NIL = {}
setmetatable(NIL, { __tostring = function() return "nil" end })

local function printstack()
    local stacks = {}
    for m = 2, 16 do
        local dbs = {}
        local info = debug.getinfo(m)
        if info == nil then
            break
        end
        table.insert(stacks, dbs)
        dbs.info = info
        local func = info.func
        local nups = info.nups
        local ups = {}
        dbs.upvalues = ups
        for n = 1, nups do
            local n, v = debug.getupvalue(func, n)
            if v == nil then
                v = NIL
            end
            if string.byte(n) == 40 then
                if ups[n] == nil then
                    ups[n] = {}
                end
                table.insert(ups[n], v)
            else
                ups[n] = v
            end
        end

        local lps = {}
        dbs.localvalues = lps
        lps.vararg = {}
        --lps.temporary={}
        for n = -1, -255, -1 do
            local k, v = debug.getlocal(m, n)
            if k == nil then
                break
            end
            if v == nil then
                v = NIL
            end
            table.insert(lps.vararg, v)
        end
        for n = 1, 255 do
            local n, v = debug.getlocal(m, n)
            if n == nil then
                break
            end
            if v == nil then
                v = NIL
            end
            if string.byte(n) == 40 then
                if lps[n] == nil then
                    lps[n] = {}
                end
                table.insert(lps[n], v)
            else
                lps[n] = v
            end
            --table.insert(lps,string.format("%s=%s",n,v))
        end
    end
    print(dump(stacks))
    -- print("info="..dump(dbs))
    -- print("_ENV="..dump(ups._ENV or lps._ENV))
end

function getids()
    return luajava.ids
end
local function setmetamethod(t, k, v)
    getmetatable(t)[k] = v
end

local function getmetamethod(t, k, v)
    return getmetatable(t)[k]
end

local function checkPath(path)
    if path:find("^[^/][%w%./_%-]+$") then
        if not path:find("%.lua$") then
            path = string.format("%s/%s.lua", activity.luaDir, path)
        else
            path = string.format("%s/%s", activity.luaDir, path)
        end
    end
    return path
end

local os_mt = {}
os_mt.__index = function(t, k)
    local _t = {}
    _t.__cmd = (rawget(t, "__cmd") or "") .. k .. " "
    setmetatable(_t, os_mt)
    return _t
end
os_mt.__call = function(t, ...)
    local cmd = t.__cmd .. table.concat({ ... }, " ")
    local p = io.popen(cmd)
    local s = p:read("a")
    p:close()
    return s
end
setmetatable(os, os_mt)

local luajava_mt = {
    __index = function(t, k)
        local b, ret = xpcall(function()
            return bindClass((rawget(t, "__name") or "") .. k)
        end,
            function()
                local p = {}
                p.__name = (rawget(t, "__name") or "") .. k .. "."
                setmetatable(p, luajava_mt)
                return p
            end)
        rawset(t, k, ret)
        return ret
    end
}
setmetatable(luajava, luajava_mt)

return _G