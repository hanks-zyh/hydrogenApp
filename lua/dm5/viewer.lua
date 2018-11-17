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
local JSON = require("cjson")

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
        layouti_width = "fill",
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

local htmlTemplate = [[
<!DOCTYPE html>
<html>
<head>
	<title></title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body>
<script type="text/javascript">
%s
</script>
<script type="text/javascript">
var s = {};
s.method = 'setImg';
s.data = newImgs;
window.luaApp.call(JSON.stringify(s));
</script>
</body>
</html>
]]
local function toast(s)
    uihelper.runOnUiThread(activity, function()
        activity.toast(s)
    end)
end


local function getData(url)
    LuaHttp.request({ url = url }, function(error, code, body)
        local script = string.match(body, '<script type="text/javascript">(.-)</script>')
        local data = string.format(htmlTemplate, script)
        uihelper.runOnUiThread(activity, function()
            webview.loadData(data, "text/html; charset=UTF-8", nil)
        end)
    end)
end

local log = require('log')
function launchDetail(item)
end

local function callback(jsonStr)
    local json = JSON.decode(jsonStr)
    if json.method ~= 'setImg' then
        return
    end

    uihelper.runOnUiThread(activity, function()
        for i = 1, #json.data do
            data[#data + 1] = json.data[i]
        end
        adapter.notifyDataSetChanged()
    end)
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x00000000)
    activity.setContentView(loadlayout(layout))

    local id = activity.getIntent().getStringExtra('id')
    local url = 'http://m.dm5.com' .. id

    webview.injectObjectToJavascript(callback, "luaApp")

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
