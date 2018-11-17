--
-- Created by IntelliJ IDEA.
-- User: hanks
-- Date: 2017/5/13
-- Time: 00:01
-- To change this template use File | Settings | File Templates.
--
local JSON = require("cjson")
local ImageLoader = import "androlua.LuaImageLoader"
local LuaFragment = import("androlua.LuaFragment")
local Http = import "androlua.LuaHttp"
local uihelper = require("uihelper")
import "android.support.v7.widget.RecyclerView"
import "android.support.v4.widget.SwipeRefreshLayout"
import "androlua.adapter.LuaRecyclerAdapter"
import "androlua.adapter.LuaRecyclerHolder"
import "android.support.v7.widget.LinearLayoutManager"
import "android.view.View"
import "android.support.v4.widget.Space"
import "androlua.widget.ninegride.LuaNineGridView"
import "androlua.widget.ninegride.LuaNineGridViewAdapter"

local function clearTable(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

local function fetchData(refreshLayout, data, adapter, fragment, reload)
    local url = string.format('http://app.jike.ruguoapp.com/1.0/newsFeed/list')
    print(url)
    local postBody = { trigger = 'user' }
    if data.loadMoreKey and not reload then
        postBody.loadMoreKey = data.loadMoreKey
        postBody.trigger = 'auto'
    end
    local options = {
        url = url,
        method = 'POST',
        body = JSON.encode(postBody),
        headers = {
            "Cookie:io=0_Djvr_i0yLPqdsuFnzY; jike:sess.sig=d-IvFa3n5DhxWNim_0gVasNfTP0; jike:feed:latestNormalMessageId=592e495c7a27e200117d35b3; jike:recommendfeed:latestRecCreatedAt=2017-05-31T06:16:06.797Z; jike:sess=eyJfdWlkIjoiNTdmYjc2YTJhNzViY2ExMzAwZjYyMzkyIiwiX3Nlc3Npb25Ub2tlbiI6IkdRTUU0RmNkTHZhNTZlcExXR1BaYURDaDQifQ==; jikeSocketSticky=33b938e0c7b12816f8f2e027067ee82d69975eb2; jike:feed:latestFeedItemId=592e495c7a27e200117d35b3; jike:feed:noContentPullCount=0"
        }
    }
    Http.request(options, function(error, code, body)
        if error or code ~= 200 then
            print(' ================== get data error')
            return
        end
        local json = JSON.decode(body)
        data.loadMoreKey = json.loadMoreKey
        if reload then
            clearTable(data.msg)
        end
        for i = 1, #json.data do
            local type = json.data[i].type
            if type == 'MESSAGE' then
                data.msg[#data.msg + 1] = json.data[i]
            end
        end
        uihelper.runOnUiThread(fragment.getActivity(), function()
            refreshLayout.setRefreshing(false)
            adapter.notifyDataSetChanged()
        end)
    end)
end

-- local log = require("androlua.common.log")

local function launchDetail(fragment, msg)
    local activity = fragment.getActivity()
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'ithome/activity_news_detail.lua')
    intent.putExtra("url", msg.item.linkUrl)
    activity.startActivity(intent)
end

-- create view table
local layout = {
    LinearLayout,
    layout_width = "match",
    layout_height = "match",
    orientation = "vertical",
    {
        SwipeRefreshLayout,
        id = "refreshLayout",
        {
            RecyclerView,
            id = "recyclerView",
            paddingTop = "25dp",
            clipToPadding = false,
            layout_width = "fill",
            layout_height = "fill",
        },
    },
}

local item_view = require('jike.item_msg')
local item_loading = {
    LinearLayout,
    layout_width = "match",
    layout_height = "72dp",
    gravity = "center",
    {
        ProgressBar,
        layout_width = "32dp",
        layout_height = "32dp",
    },
}


function newInstance()

    local data = { msg = {} }
    local ids = {}
    local fragment = LuaFragment.newInstance()
    local adapter
    fragment.setCreator(luajava.createProxy('androlua.LuaFragment$FragmentCreator', {
        onDestroyView = function() end,
        onDestroy = function() end,
        onCreateView = function(inflater, container, savedInstanceState)
            return loadlayout(layout, ids)
        end,
        onViewCreated = function(view, savedInstanceState)
            adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
                getItemCount = function()
                    if #data.msg > 0 then return #data.msg + 1
                    else return 0
                    end
                end,
                getItemViewType = function(position)
                    if position > 0 and position == #data.msg then return 1 end
                    return 0
                end,
                onCreateViewHolder = function(parent, viewType)
                    local views = {}
                    local holder
                    if viewType == 1 then
                        holder = LuaRecyclerHolder(loadlayout(item_loading, views, RecyclerView))
                    else
                        holder = LuaRecyclerHolder(loadlayout(item_view, views, RecyclerView))
                        holder.itemView.setTag(views)
                        holder.itemView.onClick = function(view)
                            local position = holder.getAdapterPosition() + 1
                            if position <= #data.msg then
                                launchDetail(fragment, data.msg[position])
                            end
                        end
                    end
                    holder.itemView.getLayoutParams().width = parent.getWidth()
                    return holder
                end,
                onBindViewHolder = function(holder, position)
                    position = position + 1
                    if (position == #data.msg) then
                        fetchData(ids.refreshLayout, data, adapter, fragment) -- getdata may call ther lua files
                        return
                    end
                    local msg = data.msg[position]
                    local views = holder.itemView.getTag()
                    views.tv_title.setText(msg.item.title or 'error title')
                    views.tv_content.setText(msg.item.content or '')
                    views.tv_date.setText(msg.item.updatedAt:sub(1, 10) or '')
                    views.tv_collect.setText(string.format('%s', msg.item.collectCount))
                    views.tv_comment.setText(string.format('%s', msg.item.commentCount))
                    ImageLoader.load(views.iv_image, msg.item.topic.thumbnailUrl)
                    if msg.item.video then
                        ImageLoader.load(views.iv_video, msg.item.video.thumbnailUrl)
                        views.layout_video.setVisibility(0)
                    else
                        views.layout_video.setVisibility(8)
                    end

                    if msg.item.pictureUrls and #msg.item.pictureUrls > 0 then
                        local pictures = msg.item.pictureUrls
                        local urls = {}
                        local len = #pictures
                        for i = 1, len do
                            if len == 1 then
                                urls[i] = pictures[i].picUrl
                                views.iv_nine_grid.setSingleImgSize(pictures[i].width, pictures[i].height)
                            else urls[i] = pictures[i].thumbnailUrl
                            end
                        end

                        views.iv_nine_grid.setVisibility(0)
                        if views.iv_nine_grid.getAdapter() == nil then
                            views.iv_nine_grid.setAdapter(LuaNineGridViewAdapter(luajava.createProxy('androlua.widget.ninegride.LuaNineGridViewAdapter$AdapterCreator', {
                                onDisplayImage = function(context, imageView, url)
                                    ImageLoader.load(imageView, url)
                                end,
                                onItemImageClick = function(context, imageView, index, list)
                                    print(list.get(index))
                                end
                            })))
                        end
                        views.iv_nine_grid.setImagesData(urls)
                    else
                        views.iv_nine_grid.setVisibility(8)
                    end
                end,
            }))
            ids.recyclerView.setLayoutManager(LinearLayoutManager(fragment.getActivity()))
            ids.recyclerView.setAdapter(adapter)
            ids.refreshLayout.setOnRefreshListener(luajava.createProxy('android.support.v4.widget.SwipeRefreshLayout$OnRefreshListener', {
                onRefresh = function()
                    fetchData(ids.refreshLayout, data, adapter, fragment, true)
                end
            }))
            ids.refreshLayout.setRefreshing(true)
            fetchData(ids.refreshLayout, data, adapter, fragment) -- getdata may call ther lua files
        end,
    }))
    return fragment
end

return {
    newInstance = newInstance
}