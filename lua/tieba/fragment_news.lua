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
import "androlua.common.LuaToast"
import "androlua.widget.picture.PicturePreviewActivity"

local uihelper = require "uihelper"
local JSON = require "cjson"

local function cleanTag(text)
    return text:gsub("<.->", ""):gsub("^%s+", ""):gsub("%s$", "")
end

local function getData(params, data, adapter, fragment, swipe_layout, reload)
    -- http://c.tieba.baidu.com/mo/q/m?kw=cxczxzxzxx&pn=0&lp=5024&forum_recommend=1&lm=0&cid=0&has_url_param=0&pn=50&is_ajax=1
    -- http://c.tieba.baidu.com/mo/q/m?kw=河南理工大学&pn=0&lp=5024&forum_recommend=1&lm=0&cid=0&has_url_param=0&pn=50&is_ajax=1
    local url = string.format('http://c.tieba.baidu.com/mo/q/m?kw=%s&pn=0&lp=5024&forum_recommend=1&lm=0&cid=0&has_url_param=0&pn=%d&is_ajax=1', params.rid, params.page * 50)
    print(url)
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then return end
        local json = JSON.decode(body)
        local isEnd = false
        if params.page + 1 >= json.data.page.total_page then isEnd = true end
        params.page = params.page + 1
        local body = json.data.content:gsub('\\"', '"')
        print(body)
        local arr = {}
        local match_p = '<img src="(.-)".-class="ti_author">(.-)</span>.-class="ti_time">(.-)</span>.-<a href="(.-)"%s+class="j_common ti_item".-<div class="ti_title">(.-)</div>.-<div class="ti_func_btn btn_reply">(.-)</div>'
        local i = 0;
        for tl_shadow in string.gmatch(body, '<li class="tl_shadow.-">(.-)</li>') do
            avatar, author, time, url, title, commentCount = string.match(tl_shadow, match_p)
            print(tl_shadow)
            if title ~= nil and author ~= nil and time ~= nil and commentCount ~= nil then
                local imgArr = {}
                for img in string.gmatch(tl_shadow, 'medias_thumb_holder".-data.url="(.-)"') do
                    imgArr[#imgArr + 1] = img
                end
                local item = {
                    url = url,
                    title = cleanTag(title),
                    author = cleanTag(author),
                    avatar = avatar,
                    time = cleanTag(time),
                    commentCount = cleanTag(commentCount),
                    imgs = imgArr,
                }
                arr[#arr + 1] = item
            end
           
        end

        uihelper.runOnUiThread(fragment.getActivity(), function()
            if isEnd then LuaToast.show("finish!!!") end
            if reload then
                for k, _ in ipairs(data) do data[k] = nil end
            end
            local s = #data
            for i = 1, #arr do
                local item = arr[i]
                if item ~= nil and item.title ~= nil and item.title ~= "" then
                    data[#data + 1] = item
                end
            end
            adapter.notifyDataSetChanged()
            swipe_layout.setRefreshing(false)
        end)
    end)
end

local function launchDetail(fragment, item)
    local activity = fragment.getActivity()
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'tieba/activity_news_detail.lua')
    intent.putExtra("item", JSON.encode(item))
    activity.startActivity(intent)
end

local dividerHeight = uihelper.dp2px(8)

local function preview(url)
    local pid = string.match(url,'/([0-9a-z]-).jpg')
    url = string.format('http://imgsrc.baidu.com/forum/pic/item/%s.jpg',  pid)
    local args = { uris = { url }, currentIndex = 0 }
    PicturePreviewActivity.start(activity, JSON.encode(args))
end

local function newInstance(rid)

    -- create view table
    local layout = {
        SwipeRefreshLayout,
        layout_width = "fill",
        layout_height = "fill",
        id = "swipe_layout",
        {
            ListView,
            id = "listview",
            background = '#ebedf0',
            dividerHeight = dividerHeight,
            paddingTop = "8dp",
            clipToPadding = false,
            layout_width = "fill",
            layout_height = "fill",
        }
    }

    local item_view = {
        LinearLayout,
        background = '#FFFFFF',
        padding = "12dp",
        orientation = 'vertical',
        layout_width = "fill",
        {
            FrameLayout,
            layout_width = "fill",
            {
                ImageView,
                id = "iv_avatar",
                layout_width = "32dp",
                layout_height = "32dp",
            },
            {
                TextView,
                id = "tv_author",
                textSize = "13sp",
                textColor = "#626466",
                layout_marginLeft = "40dp",
            },
            {
                TextView,
                id = "tv_time",
                layout_width = "100dp",
                textSize = "11sp",
                layout_marginLeft = "40dp",
                layout_marginTop = "18dp",
                textColor = "#abaeb2",
            },
        },
        {
            TextView,
            id = "tv_title",
            layout_width = "fill",
            maxLines = 2,
            layout_marginTop = "8dp",
            lineSpacingMultiplier = 1.3,
            textSize = "16sp",
            textColor = "#262626",
        },
        {
            LinearLayout,
            id = "layout_image",
            {
                ImageView,
                id = "iv_image1",
                layout_marginTop = '8dp',
                layout_width = "100dp",
                layout_height = "100dp",
                scaleType = "centerCrop",
            },
            {
                ImageView,
                id = "iv_image2",
                layout_marginTop = '8dp',
                layout_marginLeft = '8dp',
                layout_width = "100dp",
                layout_height = "100dp",
                scaleType = "centerCrop",
            },
            {
                ImageView,
                id = "iv_image3",
                layout_marginTop = '8dp',
                layout_marginLeft = '8dp',
                layout_width = "100dp",
                layout_height = "100dp",
                scaleType = "centerCrop",
            },
        },
        {
            TextView,
            layout_marginTop = '8dp',
            layout_width = "fill",  
            gravity = "right",
            id = "tv_comment_count",
            textSize = "12sp",
            textColor = "#7798ca",
        },
    }


    local hadLoadData
    local isVisible
    local lastId
    local params = { rid = rid, page = 0 }
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
            adapter = LuaAdapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
                getCount = function() return #data end,
                getView = function(position, convertView, parent)
                    position = position + 1 -- lua 索引从 1开始
                    if convertView == nil then
                        local views = {} -- store views
                        convertView = loadlayout(item_view, views, ListView)
                        convertView.getLayoutParams().width = parent.getWidth()
                        convertView.setTag(views)
                        views.tv_title.setTypeface(nil, 1);
                    end
                    local views = convertView.getTag()
                    local item = data[position]
                    if item then
                        
                        if item.imgs and #item.imgs > 0 then
                            views.layout_image.setVisibility(0)
                            views.iv_image1.setVisibility(0)
                            LuaImageLoader.load(views.iv_image1, item.imgs[1])
                            views.iv_image1.onClick = function()
                                preview(item.imgs[1])
                            end
                            if #item.imgs > 1 then
                                views.iv_image2.setVisibility(0)
                                LuaImageLoader.load(views.iv_image2, item.imgs[2])
                                views.iv_image2.onClick = function()
                                    preview(item.imgs[2])
                                end
                            else
                                views.iv_image2.setVisibility(8)
                            end

                            if #item.imgs > 2 then
                                views.iv_image3.setVisibility(0)
                                LuaImageLoader.load(views.iv_image3, item.imgs[3])
                                views.iv_image3.onClick = function()
                                    preview(item.imgs[3])
                                end
                            else
                                views.iv_image3.setVisibility(8)
                            end
                          
                        else
                            views.layout_image.setVisibility(8)
                        end
                        LuaImageLoader.loadWithRadius(views.iv_avatar,16,item.avatar)
                        views.tv_title.setText(item.title or 'ERROR TITLE')
                        views.tv_author.setText(item.author or '')
                        views.tv_time.setText(item.time or '')
                        views.tv_comment_count.setText(item.commentCount .. ' 回复')
                    end
                    if position == #data then getData(params, data, adapter, fragment, ids.swipe_layout) end
                    return convertView
                end
            }))
            ids.listview.setAdapter(adapter)
            ids.listview.setOnItemClickListener(luajava.createProxy("android.widget.AdapterView$OnItemClickListener", {
                onItemClick = function(adapter, view, position, id)
                    launchDetail(fragment, data[position + 1])
                end,
            }))
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
