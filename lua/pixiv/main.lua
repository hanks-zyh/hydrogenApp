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
import "android.support.v7.widget.RecyclerView"
import "android.support.v4.widget.SwipeRefreshLayout"
import "androlua.adapter.LuaRecyclerAdapter"
import "androlua.adapter.LuaRecyclerHolder"
import "android.support.v7.widget.StaggeredGridLayoutManager"
import "androlua.widget.picture.PicturePreviewActivity"

local JSON = require("cjson")
local uihelper = require('uihelper')
local date = os.date("%Y%m%d", os.time() - 60 * 60 * 24) -- 20170518
local page = 1
local data = {}
local adapter
local imageWidth = uihelper.getScreenWidth() / 2

-- create view table
local layout = {
    RecyclerView,
    id = "recyclerView",
    layout_width = "fill",
    layout_height = "fill",
}

local item_view = {
    FrameLayout,
    layout_width = "fill",
    {
        ImageView,
        id = "iv_image",
        layout_width = "fill",
        layout_height = "200dp",
        scaleType = "fitXY",
    },
    {
        TextView,
        id = "tv_title",
        layout_gravity = "right",
        background = "#88000000",
        paddingLeft = "6dp",
        paddingRight = "6dp",
        paddingTop = "2dp",
        paddingBottom = "2dp",
        textSize = "10sp",
        textColor = "#aaffffff",
    },
    {
        View,
        id = "layer",
        layout_width = "fill",
        layout_height = "fill",
        background = "@drawable/layout_selector_tran",
        clickable = true,
    },
}

local function offsetDate()
    local y = date:sub(1, 4)
    local m = date:sub(5, 6)
    local d = date:sub(7, 8)
    date = os.date("%Y%m%d", os.time({ year = y, month = m, day = d, hour = 1, min = 1, sec = 1 }) - 60 * 60 * 24)
    page = 1
end

local function fetchData()
    local url = string.format('http://www.pixiv.net/ranking.php?mode=daily&content=illust&p=%s&format=json&date=%s', page, date)
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then
            offsetDate()
            fetchData()
            return
        end
        local json = JSON.decode(body)
        if json.error then
            offsetDate()
            fetchData()
            return
        end
        if json.next == nil or json.next == false then
            page = 1
            date = json.prev_date
        else
            page = json.next
        end
        local arr = json.contents
        uihelper.runOnUiThread(activity, function()
            local s = #data
            for i = 1, #arr do
                local item = arr[i]
                item.calcHeight = math.floor(imageWidth * item.height / item.width)
                data[#data + 1] = item
            end
            adapter.notifyItemRangeChanged(s, #data)
        end)
    end)
end

local function launchDetail(item)
    local args = { uris = {}, headers = { "referer:https://pximg.net" } }
    local original = item.url:gsub('/c/240x480', '')
    local count = tonumber(item.illust_page_count)
    if count then
        for i = 1, count do
            local l, r = original:find('_p(%d+).-jpg$')
            if l and r then
                local rr = original:sub(l, r):gsub('_p(%d+)', '_p' .. i - 1)
                args.uris[#args.uris + 1] = original:sub(1, l - 1) .. rr
            end
        end
    end
    PicturePreviewActivity.start(activity, JSON.encode(args))
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x33000000)
    activity.setContentView(loadlayout(layout))
    adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
        getItemCount = function()
            return #data
        end,
        getItemViewType = function(position)
            return 0
        end,
        onCreateViewHolder = function(parent, viewType)
            local views = {}
            local holder = LuaRecyclerHolder(loadlayout(item_view, views, RecyclerView))
            holder.itemView.getLayoutParams().width = imageWidth
            holder.itemView.setTag(views)
            views.layer.onClick = function(view)
                local position = holder.getAdapterPosition() + 1
                launchDetail(data[position])
            end
            return holder
        end,
        onBindViewHolder = function(holder, position)
            position = position + 1
            local item = data[position]
            local views = holder.itemView.getTag()
            views.iv_image.getLayoutParams().height = item.calcHeight
            if tonumber(item.illust_page_count) == 1 then
                views.tv_title.setVisibility(8)
            else
                views.tv_title.setVisibility(0)
                views.tv_title.setText(item.illust_page_count .. 'P')
            end
            LuaImageLoader.load(views.iv_image, item.url)
            if position == #data then fetchData() end
        end,
    }))
    recyclerView.setLayoutManager(StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL))
    recyclerView.setAdapter(adapter)
    fetchData()
end
