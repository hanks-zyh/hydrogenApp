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


local uihelper = require("uihelper")
local JSON = require("cjson")
local log = require("log")
local screenWidth = uihelper.getScreenWidth()

local category = {
    "原创精品",
    "最新更新",
    "热门连载",
    "少年热血",
    "少女爱情",
    "最新上架",
    "TOP10",
}
-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    statusBarColor = "#FDE04C",
    {
        RelativeLayout,
        layout_width = "fill",
        layout_height = "56dp",
        background = "#FDE04C",
        {
            TextView,
            layout_centerInParent = true,
            text = "动漫屋",
            textColor = "#43250C",
            textSize = "18sp",
        },
        {
            ImageView,
            id = "iv_search",
            layout_width = "56dp",
            layout_height = "56dp",
            padding = "16dp",
            layout_alignParentRight = true,
            src = "#dm5/ic_search.png"
        }
    },
    {
        RecyclerView,
        id = "recyclerView",
        layout_width = "fill",
        layout_height = "fill",
    },
}

local function launchSearch()
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", "dm5/search.lua")
    activity.startActivity(intent)
end

local item_banner = {
    FrameLayout,
    layout_height = "192dp",
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
    paddingLeft = "8dp",
    paddingRight = "8dp",
    {
        TextView,
        id = "tv_category",
        textSize = "16sp",
        text = "原创精品",
        textColor = "#222222",
        layout_centerVertical = true,
    },
    {
        TextView,
        text = '更多﹥',
        visibility = "gone",
        layout_alignParentRight = true,
        layout_centerVertical = true,
    },
}

local ceil_category = {
    LinearLayout,
    layout_width = (screenWidth - uihelper.dp2px(8)) / 3,
    layout_height = "200dp",
    paddingLeft = "4dp",
    paddingRight = "4dp",
    orientation = "vertical",
    {
        ImageView,
        layout_width = "fill",
        layout_height = "160dp",
        scaleType = "centerCrop",
    },
    {
        TextView,
        layout_height = "match",
        layout_width = "match",
        gravity = "center",
    },
}

local item_topList = {
    FrameLayout,
    id = "layout_top",
    layout_height = "96dp",
    padding = "8dp",
    {
        ImageView,
        id = "iv_cover",
        layout_width = "120dp",
        layout_height = "80dp",
        scaleType = "centerCrop",
    },
    {
        TextView,
        id = "tv_title",
        layout_marginLeft = "128dp",
        textColor = "#444444",
        textSize = "14sp",
    },
    {
        TextView,
        id = "tv_subtitle",
        layout_marginLeft = "128dp",
        maxLines = 1,
        textSize = "12sp",
        textColor = "#767676",
        layout_gravity = "center_vertical",
    },
    {
        TextView,
        id = "tv_info",
        layout_marginLeft = "128dp",
        textSize = "12sp",
        textColor = "#ec4646",
        layout_gravity = "bottom",
    },
    {
        TextView,
        id = "tv_score",
        layout_gravity = "right",
        textSize = "10sp",
    },
}

local item_category = {
    LinearLayout,
    id = "row",
    orientation = "horizontal",
    paddingLeft = "4dp",
    paddingRight = "4dp",
    ceil_category,
    ceil_category,
    ceil_category,
}

local data_type = {
    banner = 1,
    title = 2,
    category = 3,
    top = 4,
}

local data = {}
local adapter

local function getData()
    LuaHttp.request({ url = 'http://m.dm5.com/' }, function(error, code, body)
        if error or code ~= 200 then
            print('fetch dm5 data error')
            return
        end
        uihelper.runOnUiThread(activity, function()
            -- banner
            local arr = {}
            local ul = string.match(body, '<ul class="am[-]slides">(.-)</ul>')
            for url, img in string.gmatch(ul, '<a href="(.-)"><img src="(.-)"') do
                if img:find('cdndm5.com') then
                    arr[#arr + 1] = { url = url, img = img }
                end
            end
            data[#data + 1] = { type = data_type.banner, data = arr }

            -- 原创精品 最新更新 热门连载 少年热血 少女爱情 最新上架
            local count = 1
            local titleIndex = 1
            arr = {}
            for li in string.gmatch(body, '<li class="am[-]thumbnail">(.-)</li>') do
                local url, title = string.match(li, '<a href="(.-)".-title="(.-)">')
                local img = string.match(li, '<img src="(.-)"')
                if url and title and img then
                    local item = { url = url, title = title, img = img }

                    if math.fmod(count - 1, 6) == 0 then
                        data[#data + 1] = { type = data_type.title, data = category[titleIndex] }
                        titleIndex = titleIndex + 1
                    end
                    if #arr == 3 then
                        data[#data + 1] = { type = data_type.category, data = arr }
                        arr = {}
                    end
                    arr[#arr + 1] = item
                    count = count + 1
                end
            end

            -- TOP10
            data[#data + 1] = { type = data_type.title, data = category[titleIndex] }

            local rankList = string.match(body, '<div class="rankList">.-<ul class="list">(.-)</ul>')
            for li in string.gmatch(rankList, '<a .-</a>') do
                local url, title = string.match(li, '<a href="(.-)".-title="(.-)">')
                local img = string.match(li, '<img class="cover" src="(.-)"')
                local subtitle = string.match(li, '<p class="subtitle d[-]nowrap">(.-)</p>')
                local updateInfo = string.match(li, '<span class="d[-]nowrap">(.-)</span>')
                local score = string.match(li, '<span class="score">(.-)</span>')
                if title and url and img then
                    local item = { title = title, score = score, updateInfo = updateInfo, url = url, img = img, subtitle = subtitle }
                    data[#data + 1] = { type = data_type.top, data = item }
                end
            end
            adapter.notifyDataSetChanged()
        end)
    end)
end

function onDestroy()
    LuaHttp.cancelAll()
end

local function launchDetail(url)
    if url:find('^http://') == nil then
        url = 'http://m.dm5.com' .. url
    end
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'dm5/detail.lua')
    intent.putExtra("url", url)
    activity.startActivity(intent)
end

function onCreate(savedInstanceState)
    activity.setContentView(loadlayout(layout))
    iv_search.onClick = launchSearch
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
            elseif viewType == data_type.category then
                holder = LuaRecyclerHolder(loadlayout(item_category, views, RecyclerView))
            else
                holder = LuaRecyclerHolder(loadlayout(item_topList, views, RecyclerView))
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
                LuaImageLoader.load(views.iv_banner, item.data[1].img)
                views.iv_banner.onClick = function() launchDetail(item.data[1].url) end
            elseif item.type == data_type.title then
                views.tv_category.setText(item.data)
            elseif item.type == data_type.category then
                for i = 1, #item.data do
                    local child = views.row.getChildAt(i - 1)
                    LuaImageLoader.load(child.getChildAt(0), item.data[i].img)
                    child.getChildAt(1).setText(item.data[i].title)
                    child.onClick = function()
                        launchDetail(item.data[i].url)
                    end
                end
            elseif item.type == data_type.top then
                LuaImageLoader.load(views.iv_cover, item.data.img)
                views.tv_title.setText(item.data.title)
                views.tv_subtitle.setText(item.data.subtitle)
                views.tv_info.setText(item.data.updateInfo)
                views.tv_score.setText(item.data.score)
                views.layout_top.onClick = function()
                    launchDetail(item.data.url)
                end
            end
        end,
    }))
    recyclerView.setLayoutManager(LinearLayoutManager(activity))
    recyclerView.setAdapter(adapter)
    getData()
end
