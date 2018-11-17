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
            EditText,
            id = "et_keyword",
            layout_width = "fill",
            layout_height = "fill",
            layout_marginLeft = "16dp",
            layout_marginRight = "64dp",
            maxLines = 1,
            background = "#00FDE04C",
            layout_centerInParent = true,
            hint = "请输入关键字",
            textColor = "#43250C",
            textSize = "16sp",
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


local page = 1
local data = {}
local adapter
local lastKey = ''

local function search()
    -- search
    local key = et_keyword.getText().toString()
    local reset = false
    if key ~= lastKey then
        reset = true
        lastKey = key
        page = 1
    end
    local options = {
        url = 'http://m.dm5.com/pagerdata.ashx',
        method = "POST",
        formData = {
            "t:7",
            "f:0",
            "pageindex:" .. page,
            "title:" .. key,
        }
    }
    log.print_r(options)
    LuaHttp.request(options, function(e, code, body)
        if e or code ~= 200 then return end
        local json = JSON.decode(body)
        page = page + 1
        uihelper.runOnUiThread(activity, function()
            if reset then
                for k, _ in pairs(data) do data[k] = nil end
            end
            for i = 1, #json do
                data[#data + 1] = json[i]
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
    iv_search.onClick = search
    adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
        getItemCount = function()
            return #data
        end,
        getItemViewType = function(position)
            return 0
        end,
        onCreateViewHolder = function(parent, viewType)
            local views = {}
            local holder = LuaRecyclerHolder(loadlayout(item_topList, views, RecyclerView))
            holder.itemView.setTag(views)
            holder.itemView.getLayoutParams().width = screenWidth
            return holder
        end,
        onBindViewHolder = function(holder, position)
            position = position + 1

            local item = data[position]
            local views = holder.itemView.getTag()
            if item == nil or views == nil then return end
            log.print_r(item)
            LuaImageLoader.load(views.iv_cover, item.Pic)
            views.tv_title.setText(item.Title or 'xxxx')
            views.tv_subtitle.setText(item.Categorys or '--')
            views.tv_info.setText(item.LastUpdateInfo or '--')
            views.tv_score.setText(item.Status or '--')
            views.layout_top.onClick = function()
                launchDetail(item.Url)
            end

            if position == #data then
                search(true)
            end
        end,
    }))
    recyclerView.setLayoutManager(LinearLayoutManager(activity))
    recyclerView.setAdapter(adapter)
end
