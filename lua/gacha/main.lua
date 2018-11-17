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
import "androlua.LuaImageLoader"
import "android.support.v7.widget.RecyclerView"
import "androlua.adapter.LuaRecyclerAdapter"
import "androlua.adapter.LuaRecyclerHolder"
import "android.support.v7.widget.StaggeredGridLayoutManager"
import "androlua.widget.picture.PicturePreviewActivity"
import "java.util.Calendar"

local calender = Calendar.getInstance()

local JSON = require("cjson")
local uihelper = require('uihelper')
local max
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

    local year = calender.get(Calendar.YEAR)
    local month = calender.get(Calendar.MONTH) + 1
    local day = calender.get(Calendar.DAY_OF_MONTH)

    local markFrom = string.format('%04d-%02d-%02d', year, month, day)
    calender.add(Calendar.DAY_OF_MONTH, -1)
    year = calender.get(Calendar.YEAR)
    month = calender.get(Calendar.MONTH) + 1
    day = calender.get(Calendar.DAY_OF_MONTH)
    local mark = string.format('%04d-%02d-%02d', year, month, day)

    local url = string.format("http://gacha.163.com/api/v1/ranking/pic?type=0&mark=%s&fromMark=%s", mark, markFrom)
    LuaHttp.request({ url = url }, function(error, code, body)
        local json = JSON.decode(body)
        local html = json.result.rankingHtml
        uihelper.runOnUiThread(activity, function()
            local s = #data
            for w, h, url in string.gmatch(html, 'data[-]width="([0-9]+)" data[-]height="([0-9]+)".-data[-]src="(.-)"') do
                local item = { url = url, w = w, h = h }
                local id, type = string.match(item.url, 'http://gacha[.]nosdn[.]127[.]net/([0-9a-z]+)[.]([a-z]+)')
                item.id = id
                item.type = type
                item.fullUrl = string.format('http://gacha.nosdn.127.net/%s.%s', id, type)
                item.calcHeight = math.floor(imageWidth * tonumber(item.h) / tonumber(item.w))
                data[#data + 1] = item
            end
            adapter.notifyItemRangeChanged(s, #data)
        end)
    end)
end

local function launchDetail(item)
    local args = { uris = { item.fullUrl } }
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
            LuaImageLoader.load(views.iv_image, item.url)
            if position == #data then fetchData() end
        end,
    }))
    recyclerView.setLayoutManager(StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL))
    recyclerView.setAdapter(adapter)
    fetchData()
end
