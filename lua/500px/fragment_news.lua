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
    local url = string.format('https://api.qingmang.me/v2/article.list?token=c400a7e21688496ca3e7f17c6b0d1846&category_id=%s', params.rid)
    if params.nextUrl then url = params.nextUrl end
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then return end
        local json = JSON.decode(body)
        if json.hasMore and json.nextUrl then params.nextUrl = json.nextUrl end
        local arr = json.articles
        uihelper.runOnUiThread(fragment.getActivity(), function()
            if reload then
                for k, _ in ipairs(data) do data[k] = nil end
            end
            local s = #data
            for i = 1, #arr do
                local item = arr[i]
                if #item.images > 0 then
                    data[#data + 1] = {
                        imgUrl = item.images[1].url,
                        calcHeight = floor(imageWidth * tonum(item.images[1].height) / tonum(item.images[1].width))
                    }
                end
            end
            adapter.notifyItemRangeChanged(s, #arr)
            swipe_layout.setRefreshing(false)
        end)
    end)
end

local function launchDetail(fragment, data, index)
    local args = { uris = {}, currentIndex = index }
    for i = 1, #data do
        args.uris[i] = data[i].imgUrl
    end
    PicturePreviewActivity.start(fragment.getActivity(), JSON.encode(args))
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
            background = '#EEEEEE',
            layout_width = "fill",
            layout_height = "fill",
        }
    }

    local item_view = {
        FrameLayout,
        layout_width = "fill",
        layout_height = "200dp",
        {
            ImageView,
            id = "iv_image",
            layout_width = "fill",
            layout_height = "fill",
            scaleType = "fitXY",
        },
        {
            View,
            id = "layer",
            layout_width = "fill",
            layout_height = "fill",
            background = '@drawable/layout_selector_tran',
        },
    }


    local hadLoadData
    local isVisible
    local lastId
    local params = { rid = rid }
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
                    views.layer.onClick = function(view)
                        local position = holder.getAdapterPosition()
                        launchDetail(fragment, data, position)
                    end
                    return holder
                end,
                onBindViewHolder = function(holder, position)
                    position = position + 1
                    local item = data[position]
                    local views = holder.itemView.getTag()
                    holder.itemView.getLayoutParams().height = item.calcHeight
                    LuaImageLoader.load(views.iv_image, item.imgUrl)
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
