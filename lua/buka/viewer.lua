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
import "androlua.LuaImageLoader"
import "androlua.LuaWebView"

local uihelper = require("uihelper")

-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    {
        ListView,
        id = "listview",
        dividerHeight = "4dp",
        layout_width = "fill",
        layout_height = "fill",
    },
    {
        LuaWebView,
        id = "webview",
        layout_height = 1,
        layout_width = 1,
        background = '#e1e1e1',
    }
}

local item_view = {
    FrameLayout,
    layout_width = "fill",
    layout_height = "560dp",
    {
        ImageView,
        id = "iv_image",
        layout_width = "fill",
        layout_height = "fill",
    },
}

local data = {}
local adapter

local function getData(url)
    LuaHttp.request({ url = url }, function(error, code, body)
        uihelper.runOnUiThread(activity, function()
            for url in string.gmatch(body, ' data[-]original="(.-)"') do
                data[#data + 1] = url
            end
            local u = data[1] or 'http://c-r6.sosobook.cn/pics/103915/65603/t4029739_0001.jpg'
            table.insert(data, 1, u:sub(1, #u - 5) .. '1.jpg')
            adapter.notifyDataSetChanged()
        end)
    end)
end

function launchDetail(item)
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x00000000)
    activity.setContentView(loadlayout(layout))

    local url = activity.getIntent().getStringExtra('url')
    if not url:find('^http://') then
        url = 'http://www.buka.cn' .. url
    end
    adapter = LuaAdapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
        getCount = function() return #data end,
        getView = function(position, convertView, parent)
            position = position + 1 -- lua 索引从 1开始
            if convertView == nil then
                local views = {} -- store views
                convertView = loadlayout(item_view, views, ListView)
                convertView.getLayoutParams().width = parent.getWidth()
                convertView.setTag(views)
            end
            local views = convertView.getTag()
            local item = data[position]
            print(position, item)
            if item then
                LuaImageLoader.load(views.iv_image, item, url)
            end
            return convertView
        end
    }))
    listview.setAdapter(adapter)
    listview.setOnItemClickListener(luajava.createProxy("android.widget.AdapterView$OnItemClickListener", {
        onItemClick = function(adapter, view, position, id)
        end,
    }))
    getData(url)
end
