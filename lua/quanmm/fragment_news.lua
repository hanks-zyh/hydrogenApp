--
-- Created by IntelliJ IDEA.
-- User: hanks
-- Date: 2017/5/13
-- Time: 00:01
-- To change this template use File | Settings | File Templates.
--
require "import"

import "android.widget.*"
import "android.content.*"
import "androlua.LuaAdapter"
import "androlua.LuaImageLoader"
import "androlua.LuaFragment"
import "androlua.LuaHttp"
import "androlua.widget.webview.WebViewActivity"
import "android.support.v4.widget.SwipeRefreshLayout"
import "android.graphics.drawable.GradientDrawable"
import "android.os.Build"
import "android.support.v7.widget.RecyclerView"
import "androlua.adapter.LuaRecyclerAdapter"
import "androlua.adapter.LuaRecyclerHolder"
import "android.support.v7.widget.LinearLayoutManager"
import "androlua.widget.picture.PicturePreviewActivity"
local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"
local floor = math.floor
local tonum = tonumber
local imageWidth = uihelper.getScreenWidth()

local function getData(params, data, adapter, fragment, swipe_layout, reload)
    local url =  string.format(params.url, params.page)
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then return end
        params.page = params.page + 1
        local json = JSON.decode(body)
        local arr = json.data.rows
        uihelper.runOnUiThread(fragment.getActivity(), function()
            if reload then
                for k, _ in ipairs(data) do data[k] = nil end
            end
            local s = #data
            for i = 1, #arr do
                local item = arr[i]
                data[#data + 1] = item
            end
            adapter.notifyItemRangeChanged(s, #arr)
            swipe_layout.setRefreshing(false)
        end)
    end)
end

local function launchDetail(fragment, data, index)
    local item = data[index+1]
    WebViewActivity.start(activity, item.article_link, 0xFFFF6666)
end

local function newInstance(rid)

    -- create view table
    local layout = {
        SwipeRefreshLayout,
        layout_width = "fill",
        layout_height = "fill",
        id = "swipe_layout",
        {
            RecyclerView,
            id = "recyclerView",
            background = '#ffffff',
            layout_width = "fill",
            layout_height = "fill",
        }
    }

    local item_view = {
        FrameLayout,
        layout_width = "fill",
        layout_height = "104dp",
        paddingLeft = "16dp",
        paddingRight = "16dp",
        background = '@drawable/layout_selector_tran',
        { View, layout_width="fill", layout_height="0.5dp", background = "#f0f0f0"},
        {
            ImageView,
            id = "iv_image",
            layout_marginTop = "16dp",
            layout_width = "72dp",
            layout_height = "72dp",
        },
        {
            TextView, 
            id = "tv_title",
            layout_width = "fill",
            layout_height = "20dp",
            layout_marginTop = "14dp",
            layout_marginLeft = "92dp",
            textSize = "15sp",
            textColor = "#111111",
            maxLines = 1,
        },
        {
            TextView, 
            id = "tv_desc",
            layout_width = "fill",
            layout_height = "20dp",
            layout_marginLeft = "92dp",
            layout_gravity = "center_vertical",
            textColor = "#FF4D4D",
            textSize = "13sp",
            maxLines = 1,
        },
        {
            TextView, 
            id = "tv_from",
            layout_height = "16dp",
            layout_gravity = "bottom",
            textColor = "#AEAEAE",
            layout_marginLeft = "92dp",
            layout_marginBottom = "16dp",
            textSize = "12sp",
            maxLines = 1,
        },
        {
            TextView, 
            layout_marginBottom = "16dp",
            id = "tv_viewcount",
            layout_gravity = 85,
            textColor = "#AEAEAE",
            layout_height = "16dp",
            textSize = "12sp",
            maxLines = 1,
        },
         
    }


    local hadLoadData
    local isVisible
    local lastId
    local params = { url = rid, page = 1 }
    local data = {}
    local ids = {}
    local adapter
    local fragment = LuaFragment.newInstance()
    local function lazyLoad()
        if not isVisible then return end
        if hadLoadData then return end
        if adapter == nil then return end
        hadLoadData = true
        getData(params, data, adapter, fragment, ids.swipe_layout)
    end

    fragment.setCreator(luajava.createProxy('androlua.LuaFragment$FragmentCreator', {
        onCreateView = function(inflater, container, savedInstanceState)
            return loadlayout(layout, ids)
        end,
        onViewCreated = function(view, savedInstanceState)
            adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
                getItemCount = function() return #data end,
                onCreateViewHolder = function(parent, viewType)
                    local views = {}
                    local holder = LuaRecyclerHolder(loadlayout(item_view, views, RecyclerView))
                    holder.itemView.getLayoutParams().width = imageWidth
                    holder.itemView.setTag(views)
                    holder.itemView.onClick = function(view)
                        local position = holder.getAdapterPosition()
                        launchDetail(fragment, data, position)
                    end
                    return holder
                end,
                onBindViewHolder = function(holder, position)
                    position = position + 1
                    local item = data[position]
                    local views = holder.itemView.getTag() 
                    LuaImageLoader.load(views.iv_image, item.article_thumbnail)
                    views.tv_title.setText(item.article_title)
                    views.tv_desc.setText(item.article_vicetitle)
                    views.tv_from.setText(item.article_mall)
                    views.tv_viewcount.setText(item.article_read_count_str)
                    if position == #data then getData(params, data, adapter, fragment, ids.swipe_layout) end
                end,
            }))
            ids.recyclerView.setLayoutManager(LinearLayoutManager(activity))
            ids.recyclerView.setAdapter(adapter)
            ids.swipe_layout.setRefreshing(true)
            ids.swipe_layout.setOnRefreshListener(luajava.createProxy('android.support.v4.widget.SwipeRefreshLayout$OnRefreshListener', {
                onRefresh = function()
                    getData(params, data, adapter, fragment, ids.swipe_layout, true)
                end
            }))
            lazyLoad()
        end,
        onUserVisible = function(visible)
            isVisible = visible
            lazyLoad()
        end,
    }))
    return fragment
end

return {
    newInstance = newInstance
}
