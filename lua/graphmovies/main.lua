--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- A news app
--
require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "androlua.LuaHttp"
import "androlua.LuaAdapter"
import "androlua.widget.video.VideoPlayerActivity"
import("androlua.LuaImageLoader")

local uihelper = require("uihelper")
local JSON = require("cjson")

-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    background = "#f1f1f1",
    statusBarColor = "#F0000000",
    {
        TextView,
        layout_width = "fill",
        layout_height = "48dp",
        background = "#F0000000",
        gravity = "center",
        text = "图解电影",
        textColor = "#FFFFFF",
        textSize = "18sp",
    },
    {
        ListView,
        id = "listview",
        paddingLeft = "16dp",
        paddingRight = "16dp",
        scrollBarStyle = "outsideOverlay",
        dividerHeight = 0,
        layout_width = "fill",
        layout_height = "fill",
    },
}

local item_view = {
    LinearLayout,
    layout_width = "fill",
    orientation = "vertical",
    background = "#FFFFFF",
    {
        View,
        layout_width = "fill",
        layout_height = "12dp",
        background = "#f1f1f1",
    },
    {
        ImageView,
        id = "iv_image",
        layout_width = "fill",
        layout_height = "200dp",
        scaleType = "centerCrop",
    },
    {
        TextView,
        id = "tv_title",
        layout_width = "fill",
        paddingTop = "16dp",
        paddingBottom = "16dp",
        paddingLeft = "12dp",
        paddingRight = "12dp",
        maxLines = "2",
        lineSpacingMultiplier = '1.2',
        textSize = "16sp",
        textColor = "#222222",
    },
    {
        TextView,
        id = "tv_subtitle",
        layout_width = "fill",
        paddingLeft = "12dp",
        paddingRight = "12dp",
        paddingBottom = "16dp",
        lineSpacingMultiplier = '1.2',
        textSize = "14sp",
        textColor = "#888888",
    },
    -- {
    --     View,
    --     layout_width = "fill",
    --     layout_height = 2,
    --     background = "#eeeeee",
    -- },
    -- {
    --   LinearLayout,
    --   orientation = "horizontal",
    --   layout_width = "fill",
    --   layout_height = "48dp",
    --   gravity = "center_vertical",
    --   {
    --     TextView,
    --     layout_weight = 1,
    --     id = "tv_username",
    --     textSize = "12sp",
    --     textColor = "#888888",
    --   },
    --   {
    --     TextView,
    --     id = "tv_views",
    --     textSize = "12sp",
    --     textColor = "#888888",
    --   },
    --   {
    --     TextView,
    --     id = "tv_rate",
    --     textSize = "12sp",
    --     textColor = "#888888",
    --   },
    -- },
}


local data = {
    dailyList = {},
}
local adapter
local orkey

local function getJsonData()
    local url = string.format('http://www.graphmovies.com/home/2/get.php?orkey=%s', orkey)
    local options = {
        url = url,
        method = 'POST',
        headers = {
            "X-Requested-With: XMLHttpRequest",
            "Content-Type: application/x-www-form-urlencoded",
        },
        formData = {
            "p:15",
            "type:movie",
            "zone:0",
            "tag:0",
            "showtime:0",
            "level:0",
        },
    }
    if #data.dailyList > 0 then
        options.formData[#options.formData + 1] = 't:' .. (data.dailyList[#data.dailyList].onlinetime or '')
    end
    LuaHttp.request(options, function(e, code, body)
        local json = JSON.decode(body)
        local arr = json.data
        uihelper.runOnUiThread(activity, function()
            for i = 1, #arr do
                data.dailyList[#data.dailyList + 1] = arr[i]
            end
            adapter.notifyDataSetChanged()
        end)
    end)
end

local function getData()
    if orkey == nil then
        LuaHttp.request({ url = 'http://www.graphmovies.com/home/2/' }, function(error, code, body)
            orkey = string.match(body, "get.php[?]orkey=(.-)'")
            getJsonData()
        end)
    else
        getJsonData()
    end
end

local log = require('log')
function launchDetail(item)
    local json = { orkey = item.orkey, name = item.name }
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'graphmovies/detail.lua')
    intent.putExtra("json", JSON.encode(json))
    activity.startActivity(intent)
end

function onDestroy()
    LuaHttp.cancelAll()
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x00000000)
    activity.setContentView(loadlayout(layout))
    adapter = LuaAdapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
        getCount = function() return #data.dailyList end,
        getView = function(position, convertView, parent)
            position = position + 1 -- lua 索引从 1开始
            if position == #data.dailyList then
                getData()
            end
            if convertView == nil then
                local views = {} -- store views
                convertView = loadlayout(item_view, views, ListView)
                convertView.getLayoutParams().width = parent.getWidth()
                convertView.setTag(views)
            end
            local views = convertView.getTag()
            local item = data.dailyList[position]
            if item then
                LuaImageLoader.load(views.iv_image, item.bpic or '')
                views.tv_title.setText(item.name or 'error title')
                views.tv_subtitle.setText(item.subtitle or '')
                -- views.tv_username.setText(item.users[1].name)
                -- views.tv_views.setText(item.readdata.played)
                -- views.tv_rate.setText(item.score .. '分')
            end
            return convertView
        end
    }))
    listview.setAdapter(adapter)
    listview.setOnItemClickListener(luajava.createProxy("android.widget.AdapterView$OnItemClickListener", {
        onItemClick = function(adapter, view, position, id)
            launchDetail(data.dailyList[position + 1])
        end,
    }))
    getData()
end
