--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- douban - hot movie
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
import "androlua.adapter.LuaRecyclerAdapter"
import "androlua.adapter.LuaRecyclerHolder"
import "android.support.v7.widget.GridLayoutManager"

local uihelper = require("uihelper")
local JSON = require("cjson")
local log = require("log")

-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    statusBarColor = "#DB3C2E",
    {
        TextView,
        layout_width = "fill",
        layout_height = "48dp",
        background = "#DB3C2E",
        gravity = "center",
        text = "热映电影",
        textColor = "#FFFFFF",
        textSize = "18sp",
    },
    {
        FrameLayout,
        layout_width = "fill",
        layout_height = "fill",
        {
            RecyclerView,
            id = "recyclerView",
            layout_width = "fill",
            layout_height = "fill",
            paddingTop = "8dp",
            paddingLeft = "4dp",
            paddingRight = "4dp",
            clipToPadding = false,
        },
        {
            View,
            layout_width = "fill",
            layout_height = "3dp",
            background = "@drawable/shadow_line_top",
        }
    }
}

local item_view = {
    FrameLayout,
    layout_width = "match",
    padding = "4dp",
    {
        ImageView,
        id = "iv_image",
        layout_width = "fill",
        layout_height = "168dp",
        scaleType = "centerCrop",
    },
    {
        View,
        layout_width = "fill",
        layout_height = "36dp",
        background = "#AA000000",
        layout_gravity = "bottom",
    },
    {
        TextView,
        id = "tv_title",
        layout_height = "36dp",
        layout_width = "fill",
        gravity = "center_vertical",
        layout_gravity = "bottom",
        paddingLeft = "28dp",
        textSize = "12sp",
        maxLines = 1,
        ellipsize = "end",
        textColor = "#FFFFFF",
    },
    {
        TextView,
        id = "tv_score",
        layout_height = "36dp",
        paddingLeft = "4dp",
        gravity = "center_vertical",
        layout_gravity = "bottom",
        textSize = "13sp",
        textColor = "#F9B600",
    },
}


local data = {}
local adapter

function getData()
    local url = string.format('http://m.maoyan.com/movie/list.json?type=hot&offset=0&limit=200')
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then
            print('fetch data error')
            return
        end
        local arr = JSON.decode(body).data.movies
        uihelper.runOnUiThread(activity, function()
            for i = 1, #arr do
                data[#data + 1] = arr[i]
            end
            adapter.notifyDataSetChanged()
        end)
    end)
end

local function launchDetail(item)
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'doubanmovie/detail.lua')
    intent.putExtra("id", item.id .. '')
    activity.startActivity(intent)
end


function onDestroy()
    LuaHttp.cancelAll()
end


function onCreate(savedInstanceState)
    activity.setLightStatusBar()
    activity.setContentView(loadlayout(layout))
    local screenWidth = uihelper.getScreenWidth()
    adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
        getItemCount = function()
            return #data
        end,
        getItemViewType = function(position)
            return 0
        end,
        onCreateViewHolder = function(parent, viewType)
            local views = {}
            local holder
            holder = LuaRecyclerHolder(loadlayout(item_view, views, RecyclerView))
            holder.itemView.setTag(views)
            holder.itemView.onClick = function(view)
                local position = holder.getAdapterPosition() + 1
            end
            holder.itemView.getLayoutParams().width = screenWidth / 3
            holder.itemView.onClick = function()
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
            if item then
                LuaImageLoader.load(views.iv_image, item.img)
                views.tv_title.setText(item.nm)
                local sc = item.sc
                if sc == nil or sc == 0 then sc = '' end
                views.tv_score.setText('' .. sc)
            end
        end,
    }))
    recyclerView.setLayoutManager(GridLayoutManager(activity, 3))
    recyclerView.setAdapter(adapter)
    getData()
end
