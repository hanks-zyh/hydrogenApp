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
import "android.view.View"
import "androlua.LuaAdapter"
import "androlua.widget.video.VideoPlayerActivity"
import "androlua.LuaImageLoader"
import "androlua.LuaFragment"
import "android.support.v7.widget.RecyclerView"
import "android.support.v4.widget.SwipeRefreshLayout"
import "androlua.adapter.LuaRecyclerAdapter"
import "androlua.adapter.LuaRecyclerHolder"
import "android.support.v7.widget.GridLayoutManager"
import "android.view.View"
import "android.support.v4.widget.Space"
import "androlua.widget.ninegride.LuaNineGridView"
import "androlua.widget.ninegride.LuaNineGridViewAdapter"
import "androlua.widget.picture.PicturePreviewActivity"
import "androlua.widget.webview.WebViewActivity"

local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require("log")
local screenWidth = uihelper.getScreenWidth()

local function getData(rid, data, adapter, fragment, swipe_layout)
    if rid == nil then rid = '/news/getnews' end
    local url = string.format('http://www.buka.cn%s', rid)
    local options = {
        url = url,
        method = 'POST',
        headers = { 'X-Requested-With:XMLHttpRequest' },
        formData = {
            'start=' .. data.page
        }
    }
    LuaHttp.request(options, function(error, code, body)
        if error or code ~= 200 then
            print('fetch buka data error')
            return
        end
        local arr = JSON.decode(body).items
        uihelper.runOnUiThread(activity, function()
            for i = 1, #arr do
                data.items[#data.items + 1] = arr[i]
            end
            data.page = data.page + 1
            adapter.notifyDataSetChanged()
            swipe_layout.setRefreshing(false)
            swipe_layout.setEnabled(false)
        end)
    end)
end

local function launchDetail(fragment, item)
    local activity = fragment.getActivity()
    if item and item.mid then
        local intent = Intent(activity, LuaActivity)
        intent.putExtra("luaPath", 'buka/detail.lua')
        intent.putExtra("mid", item.mid)
        activity.startActivity(intent)
    end
end

function newInstance(rid)

    -- create view table
    local layout = {
        SwipeRefreshLayout,
        layout_width = "fill",
        layout_height = "fill",
        id = "swipe_layout",
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
    }

    local item_category = {
        LinearLayout,
        layout_width = (screenWidth - uihelper.dp2px(8)) / 3,
        layout_height = "210dp",
        paddingLeft = "4dp",
        paddingRight = "4dp",
        paddingTop = "8dp",
        orientation = "vertical",
        gravity = "center",
        {
            ImageView,
            id = "iv_cover",
            layout_width = "fill",
            layout_height = "160dp",
            scaleType = "centerCrop",
        },
        {
            TextView,
            id = "tv_title",
            layout_height = "26dp",
            layout_width = "match",
            padding = "4dp",
            textSize = "14sp",
            textColor = "#444444",
            singleLine = true,
            ellipsize = "end",
            gravity = "center",
        },
        {
            TextView,
            id = "tv_info",
            layout_height = "15dp",
            layout_width = "match",
            textSize = "12sp",
            textColor = "#888888",
            singleLine = true,
            ellipsize = "end",
            gravity = "center",
        },
    }

    local data = { page = 0, items = {} }
    local hadLoadData
    local isVisible
    local ids = {}
    local adapter
    local fragment = LuaFragment.newInstance()
    local function lazyLoad()
        if not isVisible then return end
        if hadLoadData then return end
        if adapter == nil then return end
        hadLoadData = true
        getData(rid, data, adapter, fragment, ids.swipe_layout)
    end

    fragment.setCreator(luajava.createProxy('androlua.LuaFragment$FragmentCreator', {
        onCreateView = function(inflater, container, savedInstanceState)
            return loadlayout(layout, ids)
        end,
        onViewCreated = function(view, savedInstanceState)
            adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
                getItemCount = function()
                    return #data.items
                end,
                getItemViewType = function(position)
                    return 0
                end,
                onCreateViewHolder = function(parent, viewType)
                    local views = {}
                    local holder = LuaRecyclerHolder(loadlayout(item_category, views, RecyclerView))
                    holder.itemView.setTag(views)
                    holder.itemView.getLayoutParams().width = screenWidth / 3
                    holder.itemView.onClick = function(v)
                        local position = holder.getAdapterPosition() + 1
                        launchDetail(fragment, data.items[position])
                    end
                    return holder
                end,
                onBindViewHolder = function(holder, position)
                    position = position + 1
                    local views = holder.itemView.getTag()
                    local item = data.items[position]
                    LuaImageLoader.load(views.iv_cover, item.logo)
                    views.tv_title.setText(item.name)
                    views.tv_info.setText(item.lastup)
                    if position == #data.items then getData(rid, data, adapter, fragment, ids.swipe_layout) end
                end,
            }))
            ids.recyclerView.setLayoutManager(GridLayoutManager(activity, 3))
            ids.recyclerView.setAdapter(adapter)
            ids.swipe_layout.setRefreshing(true)
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
 
 