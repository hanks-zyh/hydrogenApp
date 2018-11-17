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
import "android.graphics.drawable.ColorDrawable"

local JSON = require("cjson")
local uihelper = require('uihelper')
local date = os.date("%Y%m%d", os.time() - 60 * 60 * 24) -- 20170518
local max
local data = {}
local adapter
local imageWidth = uihelper.getScreenWidth() / 2
local colors = {0xffF9F8EB, 0xffABCDCB, 0xffECECEC, 0xffF5F5F5, 0xffF5FEFF, 0xffE8F1F5, 0xffCDE3EB, 0xffFFEBEB}
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
        visibility = 8,
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

local function fetchData()

    local url = 'http://huaban.com/popular/?limit=20&wfl=1'
    if max then
        url = string.format('http://huaban.com/popular/?max=%d&limit=20&wfl=1', max)
    end
    local options = {
        url = url,
        headers = {
            "X-Requested-With:XMLHttpRequest",
        }
    }
    LuaHttp.request(options, function(error, code, body)
        local json = JSON.decode(body)
        local arr = json.pins
        max = arr[#arr].pin_id
        uihelper.runOnUiThread(activity, function()
            local s = #data
            for i = 1, #arr do
                local item = arr[i]
                item.url = string.format('http://img.hb.aicdn.com/%s', item.file.key)
                item.calcHeight = math.floor(imageWidth * tonumber(item.file.height) / tonumber(item.file.width))
                data[#data + 1] = item
            end
            adapter.notifyItemRangeChanged(s, #arr)
        end)
    end)
end

local function launchDetail(item,index)
    local args = { uris = {}, currentIndex=index }
    for i=1,#data do
        args.uris[i] = data[i].url
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
                launchDetail(data[position],position-1)
            end
            return holder
        end,
        onBindViewHolder = function(holder, position)
            local colorIndex = position % 8

            position = position + 1
            local item = data[position]
            local views = holder.itemView.getTag()
            views.iv_image.getLayoutParams().height = item.calcHeight
            -- LuaImageLoader.load(views.iv_image, item.url)
            LuaImageLoader.load(views.iv_image.getContext(), views.iv_image, item.url, 0, 0,
                            ColorDrawable(colors[colorIndex + 1]), ColorDrawable(colors[colorIndex + 1]))

            if position == #data then fetchData() end
        end,
    }))
    recyclerView.setLayoutManager(StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL))
    recyclerView.setAdapter(adapter)
    fetchData()
end
