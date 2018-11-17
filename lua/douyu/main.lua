--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- 漫本联盟 dm5.com
--
require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "androlua.LuaHttp"
import "androlua.LuaAdapter"
import "androlua.widget.video.VideoPlayerActivity"
import "androlua.LuaImageLoader"

import "androlua.LuaImageLoader"
import "androlua.LuaFragment"
import "android.support.v7.widget.RecyclerView"
import "android.support.v4.widget.SwipeRefreshLayout"
import "androlua.adapter.LuaRecyclerAdapter"
import "androlua.adapter.LuaRecyclerHolder"
import "android.support.v7.widget.LinearLayoutManager"
import "android.view.View"
import "android.support.v4.widget.Space"
import "androlua.widget.ninegride.LuaNineGridView"
import "androlua.widget.ninegride.LuaNineGridViewAdapter"
import "androlua.widget.picture.PicturePreviewActivity"
import "androlua.widget.webview.WebViewActivity"
import "android.support.v7.widget.Toolbar"
import "android.support.design.widget.CoordinatorLayout"
import "pub.hydrogen.android.R"
import "android.net.Uri"

local uihelper = require("uihelper")
local JSON = require("cjson")
local log = require("log")
local screenWidth = uihelper.getScreenWidth()
activity.setTheme(R.style.Theme_AppCompat_NoActionBar)
-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    statusBarColor = "#fe7b09",
    {
        Toolbar,
        background = '#fe7b09',
        id = 'toolbar',
        layout_width = "match",
        layout_height = "56dp",
        titleTextColor = "#ffffff",
    },
    {
        RecyclerView,
        background = '#ffffff',
        id = "recyclerView",
        layout_width = "fill",
        layout_height = "fill",
    },
}

local item_banner = {
    FrameLayout,
    layout_height = "142dp",
    layout_width = "match",
    {
        ImageView,
        layout_height = "match",
        layout_width = "match",
        id = "iv_banner",
        scaleType = "centerCrop",
    }
}

local item_title = {
    RelativeLayout,
    layout_height = "48dp",
    { View, layout_width = "4dp", layout_height = "24dp", background = '#fe7b09', layout_centerVertical = true },
    { TextView, paddingLeft = "8dp", id = "tv_category", textSize = "18sp", text = "原创", textColor = "#222222", layout_centerVertical = true, },
    { TextView, text = '更多﹥', layout_alignParentRight = true, layout_centerVertical = true, textColor = '#888888', paddingRight = '8dp' },
}

local ceil_category = {
    LinearLayout,
    layout_width = (screenWidth - uihelper.dp2px(4)) / 2,
    orientation = "vertical",
    {
        ImageView,
        layout_width = "fill",
        layout_height = "120dp",
        scaleType = "centerCrop",
    },
    {
        TextView,
        layout_height = "36dp",
        layout_width = "match",
        singleLine = true,
        maxLines = 1,
        paddingLeft = '4dp',
        ellipsize = 'end',
        textColor = '#000000',
        gravity = "center_vertical",
    },
}

local item_video = {
    LinearLayout,
    id = "row",
    layout_width = "fill",
    orientation = "horizontal",
    ceil_category,
    { View, layout_width = "4dp", layout_height = 1 },
    ceil_category,
}

local data_type = {
    banner = 1,
    title = 2,
    video = 3,
}

local data = {}

local adapter

local function getData()
    LuaHttp.request({ url = 'https://m.douyu.com/index/getHomeData' }, function(error, code, body)
        if error or code ~= 200 then
            print('fetch douyu data error')
            return
        end
        local json = JSON.decode(body)
        uihelper.runOnUiThread(activity, function()
            if json == nil then
                return
            end
            -- banner
            if json.banner and #json.banner > 0 then
                data[#data + 1] = { type = data_type.banner, banner = json.banner }
            end

            if json.hotList and #json.hotList > 0 then
                data[#data + 1] = { type = data_type.title, title = '最热', room_id = 'https://m.douyu.com/list/index' }
                local item = json.hotList[1]
                for j = 1, #item.data, 2 do
                    if j < #item.data then
                        data[#data + 1] = { type = data_type.video, data = { item.data[j], item.data[j + 1] } }
                    end
                end
            end

            if json.liveList and #json.liveList > 0 then
                data[#data + 1] = { type = data_type.title, title = '正在直播', room_id = 'https://m.douyu.com/list/index' }
                for i = 1, #json.liveList, 2 do
                    if i < #json.liveList then
                        data[#data + 1] = { type = data_type.video, data = { json.liveList[i], json.liveList[i + 1] } }
                    end
                end
            end

            if json.yzList and #json.yzList > 0 then
                data[#data + 1] = { type = data_type.title, title = '颜值', room_id = 'https://m.douyu.com/roomlists/yz' }
                for i = 1, #json.yzList, 2 do
                    if i < #json.yzList then
                        data[#data + 1] = { type = data_type.video, data = { json.yzList[i], json.yzList[i + 1] } }
                    end
                end
            end
            if json.mixList and #json.mixList > 0 then
                for i = 1, #json.mixList do
                    local item = json.mixList[i]
                    data[#data + 1] = { type = data_type.title, title = item.tabName, room_id = 'https://m.douyu.com/list/custom/' .. item.shortName }
                    for j = 1, #item.data, 2 do
                        if j < #item.data then
                            data[#data + 1] = { type = data_type.video, data = { item.data[j], item.data[j + 1] } }
                        end
                    end
                end
            end
            adapter.notifyDataSetChanged()
        end)
    end)
end

function onDestroy()
    LuaHttp.cancelAll()
end

local function launchDetail(item)
    local url = item.room_id
    if type(url) == 'number' or not url:find("^http") then
        url = string.format('https://m.douyu.com/%d', url)
    end
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'douyu/detail.lua')
    print(url)
    intent.putExtra("url", url)
    activity.startActivity(intent)
end

function onCreate(savedInstanceState)
    activity.setContentView(loadlayout(layout))
    activity.setSupportActionBar(toolbar)
    activity.setTitle('斗鱼直播')
    toolbar.setNavigationIcon(LuaDrawable.create('douyu/douyu.png'))
    adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
        getItemCount = function()
            return #data
        end,
        getItemViewType = function(position)
            position = position + 1
            return data[position].type
        end,
        onCreateViewHolder = function(parent, viewType)
            local views = {}
            local holder
            if viewType == data_type.banner then
                holder = LuaRecyclerHolder(loadlayout(item_banner, views, RecyclerView))
            elseif viewType == data_type.title then
                holder = LuaRecyclerHolder(loadlayout(item_title, views, RecyclerView))
            elseif viewType == data_type.video then
                holder = LuaRecyclerHolder(loadlayout(item_video, views, RecyclerView))
            end
            holder.itemView.setTag(views)
            holder.itemView.getLayoutParams().width = screenWidth
            return holder
        end,
        onBindViewHolder = function(holder, position)
            position = position + 1
            local item = data[position]
            local views = holder.itemView.getTag()
            if item == nil or views == nil then return end
            -- fill data
            if item.type == data_type.banner then
                LuaImageLoader.load(views.iv_banner, item.banner[1].pic_url)
                views.iv_banner.onClick = function() launchDetail(item.banner[1].room) end
            elseif item.type == data_type.title then
                views.tv_category.setText(item.title)
                holder.itemView.onClick = function()
                    launchDetail(item)
                end
            elseif item.type == data_type.video then
                local child1 = views.row.getChildAt(0)
                local child2 = views.row.getChildAt(2)
                LuaImageLoader.load(child1.getChildAt(0), item.data[1].room_src)
                LuaImageLoader.load(child2.getChildAt(0), item.data[2].room_src)
                child1.getChildAt(1).setText(item.data[1].room_name)
                child2.getChildAt(1).setText(item.data[2].room_name)
                child1.onClick = function()
                    launchDetail(item.data[1])
                end
                child2.onClick = function()
                    launchDetail(item.data[2])
                end
            end
        end,
    }))
    recyclerView.setLayoutManager(LinearLayoutManager(activity))
    recyclerView.setAdapter(adapter)
    getData()
end

function onCreateOptionsMenu(menu)
    menu.add("网页版")
    return true
end

function onOptionsItemSelected(item)
    local title = item.getTitle()
    if title == "网页版" then
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse('http://m.douyu.com')))
    end
end
