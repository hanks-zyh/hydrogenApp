--
-- Created by IntelliJ IDEA.
-- User: hanks
-- Date: 2017/5/13
-- Time: 00:01
-- To change this template use File | Settings | File Templates.
--

import "androlua.LuaImageLoader"
import "androlua.LuaFragment"
import "androlua.LuaHttp"
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

local JSON = require("cjson")
local uihelper = require("uihelper")

local function clearTable(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

local function fetchData(refreshLayout, data, adapter, fragment, reload)
    local url = string.format('http://app.jike.ruguoapp.com/1.0/users/messages/listPopularByTag?tag=ALL')
    local options = {
        url = url,
        headers = {
            "Cookie:io=0_Djvr_i0yLPqdsuFnzY; jike:sess.sig=d-IvFa3n5DhxWNim_0gVasNfTP0; jike:feed:latestNormalMessageId=592e495c7a27e200117d35b3; jike:recommendfeed:latestRecCreatedAt=2017-05-31T06:16:06.797Z; jike:sess=eyJfdWlkIjoiNTdmYjc2YTJhNzViY2ExMzAwZjYyMzkyIiwiX3Nlc3Npb25Ub2tlbiI6IkdRTUU0RmNkTHZhNTZlcExXR1BaYURDaDQifQ==; jikeSocketSticky=33b938e0c7b12816f8f2e027067ee82d69975eb2; jike:feed:latestFeedItemId=592e495c7a27e200117d35b3; jike:feed:noContentPullCount=0"
        }
    }
    LuaHttp.request(options, function(error, code, body)
        if error or code ~= 200 then
            print(' ================== get data error')
            return
        end
        local arr = JSON.decode(body).data
        uihelper.runOnUiThread(fragment.getActivity(), function()
            if reload then
                clearTable(data.msg)
            end
            for i = 1, #arr do
                data.msg[#data.msg + 1] = arr[i]
            end
            refreshLayout.setRefreshing(false)
            adapter.notifyDataSetChanged()
        end)
    end)
end

local log = require("log")

local function launchDetail(fragment, msg)
    local activity = fragment.getActivity()
    --log.print_r(msg)
    local url = 'https://m.okjike.com/originalPosts/' .. msg.id
    WebViewActivity.start(activity, url, 0xFFffe411)
end

local function launchPicturePreview(fragment, msg, index)
    local urls = {}
    for i = 1, #msg.pictures do
        urls[i] = msg.pictures[i].picUrl
    end
    local data = {
        uris = urls,
        currentIndex = index
    }
    PicturePreviewActivity.start(fragment.getActivity(), JSON.encode(data))
end

function newInstance()

    -- create view table
    local layout = {
        LinearLayout,
        layout_width = "match",
        layout_height = "match",
        orientation = "vertical",
        {
            SwipeRefreshLayout,
            id = "refreshLayout",
            layout_width = "match",
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
    local data = { msg = {} }
    local ids = {}
    local fragment = LuaFragment.newInstance()
    local adapter
    fragment.setCreator(luajava.createProxy('androlua.LuaFragment$FragmentCreator', {
        onCreateView = function(inflater, container, savedInstanceState)
            return loadlayout(layout, ids)
        end,
        onViewCreated = function(view, savedInstanceState)
            adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
                getItemCount = function()
                    return #data.msg
                end,
                getItemViewType = function(position)
                    return 0
                end,
                onCreateViewHolder = function(parent, viewType)
                    local views = {}
                    local holder = LuaRecyclerHolder(loadlayout(item_view, views, RecyclerView))
                    holder.itemView.getLayoutParams().width = parent.getWidth()
                    holder.itemView.setTag(views)
                    holder.itemView.onClick = function(view)
                        local position = holder.getAdapterPosition() + 1
                        launchDetail(fragment, data.msg[position])
                    end
                    return holder
                end,
                onBindViewHolder = function(holder, position)
                    position = position + 1
                    local msg = data.msg[position]
                    local views = holder.itemView.getTag()
                    views.tv_title.setText(msg.topic.content or 'error title')
                    views.tv_content.setText(msg.content or '')
                    views.tv_date.setText(msg.createdAt:sub(1, 10) or '')
                    LuaImageLoader.loadWithRadius(views.iv_image, 3, msg.topic.squarePicture.thumbnailUrl)
                    if msg.video then
                        views.layout_video.setVisibility(0)
                        LuaImageLoader.load(views.iv_video, msg.video.thumbnailUrl)
                    else
                        views.layout_video.setVisibility(8)
                    end
                    views.tv_collect.setText(string.format('%d', msg.likeCount))
                    views.tv_comment.setText(string.format('%d', msg.commentCount))

                    if msg.pictures and #msg.pictures > 0 then
                        local pictures = msg.pictures
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
                        views.iv_nine_grid.setAdapter(LuaNineGridViewAdapter(luajava.createProxy('androlua.widget.ninegride.LuaNineGridViewAdapter$AdapterCreator', {
                            onDisplayImage = function(context, imageView, url)
                                LuaImageLoader.load(imageView, url)
                            end,
                            onItemImageClick = function(context, imageView, index, list)
                                launchPicturePreview(fragment, msg, index)
                            end
                        })))
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
