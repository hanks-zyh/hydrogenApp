--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- 布卡漫画
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
import "android.support.v7.widget.GridLayoutManager"
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

import "android.support.design.widget.CoordinatorLayout"
import "android.support.design.widget.AppBarLayout"
import "android.support.design.widget.CollapsingToolbarLayout"
import "android.support.v7.widget.Toolbar"
import "android.support.design.widget.FloatingActionButton"

local AppBarLayoutScrollingViewBehavior = import "android.support.design.widget.AppBarLayout$ScrollingViewBehavior"

-- create view table
local layout = {
    CoordinatorLayout,
    layout_width = "match",
    layout_height = "match",
    {
        AppBarLayout,
        id = "appbar",
        layout_width = "match",
        {
            CollapsingToolbarLayout,
            id = "collapsing_toolbar",
            applayout_scrollFlags = 0x3,
            background = "#ffffff",
            layout_width = "match",
            {
                ImageView,
                layout_width = "match",
                layout_height = "240dp",
                applayout_collapseMode = 2,
                id = "iv_cover",
                scaleType = "centerCrop",
            },
            {
                View,
                layout_width = "match",
                layout_height = "240dp",
                applayout_collapseMode = 2,
                background = "#22000000",
            },
            {
                LinearLayout,
                layout_width = "match",
                applayout_collapseMode = 1,
                layout_marginTop = "180dp",
                background = "#ffffff",
                orientation = "vertical",
                {
                    FrameLayout,
                    padding = "16dp",
                    layout_width = "match",
                    background = "#2D2118",
                    {
                        TextView,
                        id = "tv_title",
                        textSize = "22sp",
                        textColor = "#FFFFFF",
                    },
                    {
                        TextView,
                        id = "tv_updateinfo",
                        layout_marginTop = "34dp",
                        textSize = "14sp",
                        textColor = "#FFFFFF",
                    },
                    {
                        TextView,
                        id = "tv_score",
                        layout_gravity = "right",
                        layout_marginTop = "8dp",
                        textSize = "16sp",
                        textColor = "#FFFFFF",
                    },
                    {
                        TextView,
                        id = "tv_type",
                        textSize = "12sp",
                        layout_marginTop = "60dp",
                        textColor = "#EEFFFFFF",
                    },
                },
                {
                    TextView,
                    id = "tv_desc",
                    padding = "16dp",
                    textSize = "14sp",
                    lineSpacingMultiplier = 1.3,
                    textColor = "#444444",
                    background = "#ffffff",
                },
            }
        },
    },
    {
        RecyclerView,
        id = "recyclerView",
        layout_width = "fill",
        layout_height = "fill",
        background = "#ffffff",
        applayout_behavior = AppBarLayoutScrollingViewBehavior(),
    },
}

local item_capter = {
    LinearLayout,
    orientation = "vertical",
    layout_height = "60dp",
    gravity = "center",
    {
        TextView,
        layout_height = "match",
        layout_width = "match",
        layout_margin = "8dp",
        gravity = "center",
        id = "tv_chapter",
        textSize = "13sp",
        textColor = "#444444",
        background = "#C5C8C0",
    },
}

local baseInfo = {}
local data = {}
local adapter

local function trim(s)
    if s == nil then return "" end
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

local function updateHeader()
    -- header
    LuaImageLoader.load(iv_cover, baseInfo.coverImg or '')
    tv_title.setText(baseInfo.title or '')
    tv_type.setText(string.format('%s        %s', trim(baseInfo.author), trim(baseInfo.type)))
    tv_score.setText(baseInfo.score)
    tv_desc.setText(baseInfo.desc or '')
    tv_updateinfo.setText(baseInfo.updateInfo or '')
end

local function getData(mid)
    local url = string.format('http://www.buka.cn/detail/%s', mid)
    print(url)
    LuaHttp.request({ url = url, headers={
        "User-Agent:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.119 Safari/537.36"
    } }, function(error, code, body)
        if error or code ~= 200 then
            print('fetch dm5 data error')
            return
        end
        uihelper.runOnUiThread(activity, function()
            local coverImg, title = string.match(body, 'class="manga.img.-<img src="(.-)".-alt="(.-)"')
            local updateInfo = string.match(body, '<div class="author[-]names".-<span.->(.-)</span>')
            local author = string.match(body, '<a .-class="author">(.-)</a>')
            local desc = string.match(body, '<div class="manga[-]desc[-]font">(.-)</div>')
            print(coverImg)
            baseInfo.coverImg = coverImg
            baseInfo.title = trim(title)
            baseInfo.type = ''
            baseInfo.author = author:gsub('%s+', ' ')
            baseInfo.score = ''
            baseInfo.updateInfo = updateInfo:gsub('%s+', ' ')
            baseInfo.desc = trim(desc)
            updateHeader()
            for url, name in string.gmatch(body, 'class="epsbox.eplink%s+".-href="(.-)".->(.-)</a>') do
                data[#data + 1] = { url = url, name = trim(name) }
            end
            adapter.notifyDataSetChanged()
        end)
    end)
end

function launchDetail(item)
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", "buka/viewer.lua")
    intent.putExtra("url", item.url)
    activity.startActivity(intent)
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x00000000)
    activity.setContentView(loadlayout(layout))

    adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
        getItemCount = function()
            return #data
        end,
        getItemViewType = function(position)
            return 0
        end,
        onCreateViewHolder = function(parent, viewType)
            viewType = viewType + 1
            local views = {}
            local holder = LuaRecyclerHolder(loadlayout(item_capter, views, RecyclerView))
            holder.itemView.setTag(views)
            holder.itemView.getLayoutParams().width = screenWidth / 4
            holder.itemView.onClick = function(view)
                local p = holder.getAdapterPosition() + 1
                launchDetail(data[p])
            end
            return holder
        end,
        onBindViewHolder = function(holder, position)
            position = position + 1
            local views = holder.itemView.getTag()
            if views == nil then return end
            local item = data[position]
            views.tv_chapter.setText(item.name or '')
        end,
    }))

    recyclerView.setLayoutManager(GridLayoutManager(activity, 4))
    recyclerView.setAdapter(adapter)

    local mid = activity.getIntent().getStringExtra('mid')
    getData(mid)
end
