--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- 图解电影
--
require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "androlua.LuaWebView"
import "androlua.LuaHttp"
import "android.os.Build"
import "android.view.View"

local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"

-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#ff000000",
    {
        LinearLayout,
        orientation = "horizontal",
        layout_width = "fill",
        layout_height = "56dp",
        background = "#ff000000",
        gravity = "center_vertical",
        {
            ImageView,
            id = "back",
            layout_width = "40dp",
            layout_height = "40dp",
            layout_marginLeft = "8dp",
            scaleType = "centerInside",
            src = "@drawable/ic_menu_back",
        },
        {
            TextView,
            layout_height = "56dp",
            layout_width = "fill",
            paddingRight = "16dp",
            singleLine = true,
            textIsSelectable = true,
            ellipsize = "end",
            id = "tv_title",
            gravity = "center_vertical",
            paddingLeft = "8dp",
            textColor = "#ffffff",
            textSize = "16sp",
        },
    },
    {
        FrameLayout,
        layout_width = "fill",
        layout_height = "fill",
        {
            ListView,
            id = "listview",
            dividerHeight = 0,
            layout_width = "fill",
            layout_height = "fill",
        },
        {
            ProgressBar,
            layout_gravity = "center",
            id = "progressBar",
            layout_width = "40dp",
            layout_height = "40dp",
        },
        {
            View,
            layout_width = "fill",
            layout_height = "3dp",
            background = "@drawable/shadow_line_top",
        }
    }
}

local item_view = {
    LinearLayout,
    layout_width = "fill",
    orientation = "vertical",
    paddingLeft = "16dp",
    paddingRight = "16dp",
    {
        ImageView,
        id = "iv_image",
        layout_width = "fill",
        layout_height = "220dp",
    },
    {
        TextView,
        id = "tv_content",
        layout_width = "fill",
        lineSpacingMultiplier = '1.3',
        paddingTop = "8dp",
        paddingBottom = "8dp",
        textSize = "14sp",
        textColor = "#444444",
    },
}

local data = {}
local baseUrl = ""
local adapter

local function unicode_to_utf8(convertStr)
    local t = {}
    for a in string.gmatch(convertStr, '\\u([0-9a-z][0-9a-z][0-9a-z][0-9a-z])') do
        if #a == 4 then
            local n = tonumber(a, 16)
            assert(n, "String decoding failed: bad Unicode escape " .. a)
            local x
            if n < 0x80 then
                x = string.char(n % 0x80)
            elseif n < 0x800 then
                -- [110x xxxx] [10xx xxxx]
                x = string.char(0xC0 + (math.floor(n / 64) % 0x20), 0x80 + (n % 0x40))
            else
                -- [1110 xxxx] [10xx xxxx] [10xx xxxx]
                x = string.char(0xE0 + (math.floor(n / 4096) % 0x10), 0x80 + (math.floor(n / 64) % 0x40), 0x80 + (n % 0x40))
            end
            convertStr = string.gsub(convertStr, '\\u' .. a, x)
        end
    end
    return convertStr
end

local function getData()
    local jsonStr = activity.getIntent().getStringExtra('json')
    local json = JSON.decode(jsonStr)
    listview.setVisibility(0)
    progressBar.setVisibility(8)
    local url1 = string.format('http://h5.graphmovie.com/gmspanel/olr/rw.shu.php?m=%s&p=web&c=me&v=0&n=%s', json.orkey, json.name)
    tv_title.setText(url1)
    LuaHttp.request({ url = url1 }, function(error, code, body)
        -- get orkey
        local orkey = string.match(body, "script.php[?]orkey=(.-)'")
        local options = {
            url = string.format('http://h5.graphmovie.com/gmspanel/olr/script.php?orkey=%s', orkey),
            method = 'POST',
            headers = {
                "X-Requested-With: XMLHttpRequest",
                "Content-Type: application/x-www-form-urlencoded",
            },
            formData = {
                "a:1",
            },
        }
        LuaHttp.request(options, function(e, c, b)
            baseUrl = string.match(b, 'data":{"p":"(.-)"')
            print(baseUrl)
            for m, r in string.gmatch(b, '"m":"(.-)","r":"(.-)"') do
                data[#data + 1] = { m = m, r = r }
            end
            uihelper.runOnUiThread(activity, function()
                adapter.notifyDataSetChanged()
            end)
        end)
    end)
end

function onCreate(savedInstanceState)
    activity.setContentView(loadlayout(layout))
    back.onClick = function()
        activity.finish()
    end

    adapter = LuaAdapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
        getCount = function() return #data end,
        getView = function(position, convertView, parent)
            position = position + 1 -- lua 索引从 1开始
            if position == #data then
                getData()
            end
            if convertView == nil then
                local views = {} -- store views
                convertView = loadlayout(item_view, views, ListView)
                convertView.getLayoutParams().width = parent.getWidth()
                convertView.setTag(views)
            end
            local views = convertView.getTag()
            local item = data[position]
            if item then
                local img = item.m
                if not img:find('^http') then
                    img = baseUrl .. img
                end
                img = img:gsub('\\/', '/')
                LuaImageLoader.load(views.iv_image, img)
                views.tv_content.setText(unicode_to_utf8(item.r or ''))
            end
            return convertView
        end
    }))
    listview.setAdapter(adapter)

    getData()
end
