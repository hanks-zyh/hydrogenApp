--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/29
-- A zhihu daliy app
--
require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "android.support.v4.view.ViewPager"
import "android.support.design.widget.TabLayout"
import "androlua.adapter.LuaFragmentPageAdapter"
import "androlua.LuaHttp"
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
import "android.graphics.drawable.Drawable"
import "java.net.URL"
import "android.support.v7.widget.Toolbar"
import "android.net.Uri"
import "android.text.Html"
import "android.text.method.LinkMovementMethod"
import "androlua.LuaDrawable"
import "java.lang.Thread"

local JSON = require "cjson"
local uihelper = require "uihelper"

-- create view table
-- create view table
local layout = {
    LinearLayout,
    layout_width = "match",
    layout_height = "match",
    orientation = "vertical",
    fitsSystemWindows = true,
    {
        Toolbar,
        background = '#ffffff',
        id = 'toolbar',
        layout_width = "match",
        layout_height = "56dp",
        elevation = "2dp",
    },
    {
        SwipeRefreshLayout,
        id = "refreshLayout",
        layout_width = "match",
        {
            RecyclerView,
            id = "recyclerView",
            layout_width = "fill",
            layout_height = "fill",
        },
    },
}

local item_view = require "weibo-hot/item_msg"
local adapter
local data = {}
local page = 1

local function launchDetail(msg)
    if msg and msg.mblog.id then
        local url = 'https://m.weibo.cn/status/' .. msg.mblog.id
        WebViewActivity.start(activity, url, 0xFFe86b0f)
        return
    end

    activity.toast('没有 url 可以打开')
end

local function launchPicturePreview(msg, index)
    local urls = {}
    for i = 1, #msg.mblog.pics do
        urls[i] = msg.mblog.pics[i].large.url
    end
    local data = {
        uris = urls,
        currentIndex = index
    }
    PicturePreviewActivity.start(activity, JSON.encode(data))
end

local function fetchData()
    local url = "https://m.weibo.cn/api/container/getIndex?containerid=102803_ctg1_9999_-_ctg1_9999&count=10&luicode=10000011&lfid=102803_ctg1_8999_-_ctg1_8999_home&page=" .. page
    if page < 2 then url = "https://m.weibo.cn/api/container/getIndex?containerid=102803_ctg1_9999_-_ctg1_9999&count=10&luicode=10000011&lfid=102803_ctg1_8999_-_ctg1_8999_home" end
    local options = {
        url = url
    }
    LuaHttp.request(options, function(error, code, body)
        local cards = JSON.decode(body).data.cards
        uihelper.runOnUiThread(activity, function()
            if page == 0 then
                for k, _ in pairs(data) do data[k] = nil end
            end
            local s = #data
            for i = 1, #cards do
                local item = cards[i]
                if item.card_group then
                    for j = 1, #item.card_group do
                        data[#data + 1] = item.card_group[j]
                    end
                else
                    data[#data + 1] = item
                end
            end
            page = page + 1
            adapter.notifyItemRangeChanged(s, #data)
            refreshLayout.setRefreshing(false)
        end)
    end)
end

 local imgGetter = luajava.createProxy('android.text.Html$ImageGetter', {
    getDrawable = function(imgUrl) return LuaDrawable.create('weibo-hot/weibo_logo.png') end
    -- getDrawable = function(imgUrl)
    --     if not imgUrl:find('^http') then  imgUrl = 'https://' .. imgUrl end
    --     Thread(luajava.createProxy('java.lang.Runnable',{
    --         run = function()
    --             local is = URL(imgUrl).getContent()
    --             local drawable = Drawable.createFromStream(is,"src")
    --             drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight())
    --             is.close()
    --         end
    --     }).start()
    --     local is = URL(imgUrl).getContent()
    --     local drawable = Drawable.createFromStream(is,"src")
    --     drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight())
    --     is.close()
    --     return drawable
    -- end
})

function onCreate(savedInstanceState)
    activity.setLightStatusBar()
    activity.setContentView(loadlayout(layout))
    activity.setSupportActionBar(toolbar)
    activity.setTitle('热门微博')
    toolbar.setNavigationIcon(LuaDrawable.create('weibo-hot/weibo_logo.png'))

    adapter = LuaRecyclerAdapter(luajava.createProxy('androlua.adapter.LuaRecyclerAdapter$AdapterCreator', {
        getItemCount = function() return #data end,
        getItemViewType = function(position) return 0 end,
        onCreateViewHolder = function(parent, viewType)
            local views = {}
            local holder = LuaRecyclerHolder(loadlayout(item_view, views, RecyclerView))
            holder.itemView.getLayoutParams().width = parent.getWidth()
            holder.itemView.setTag(views)
            holder.itemView.onClick = function(view)
                local position = holder.getAdapterPosition() + 1
                launchDetail(data[position])
            end
            return holder
        end,
        onBindViewHolder = function(holder, position)
            position = position + 1
            local msg = data[position]
            local views = holder.itemView.getTag()
           
            views.tv_username.setText(msg.mblog.user.screen_name or 'xxxxx')
            views.tv_content.setText(Html.fromHtml(msg.mblog.text, imgGetter, nil))
            -- views.tv_content.setMovementMethod(LinkMovementMethod.getInstance())
            views.tv_date.setText(msg.mblog.created_at or '刚刚')
            views.tv_retweet.setText(string.format('%d', msg.mblog.reposts_count))
            views.tv_comment.setText(string.format('%d', msg.mblog.comments_count))
            views.tv_like.setText(string.format('%d', msg.mblog.attitudes_count))
            LuaImageLoader.loadWithRadius(views.iv_image, 40, msg.mblog.user.profile_image_url)
            if msg.mblog.pics and #msg.mblog.pics > 0 then
                local pictures = msg.mblog.pics
                local urls = {}
                local len = #pictures
                for i = 1, len do
                    if len == 1 then
                        urls[i] = pictures[i].large.url
                        local w = pictures[i].large.geo.width or 200
                        local h = pictures[i].large.geo.height or 200
                        views.iv_nine_grid.setSingleImgSize(tonumber(w), tonumber(h))
                    else urls[i] = pictures[i].url
                    end
                end
                views.iv_nine_grid.setVisibility(0)
                views.iv_nine_grid.setAdapter(LuaNineGridViewAdapter(luajava.createProxy('androlua.widget.ninegride.LuaNineGridViewAdapter$AdapterCreator', {
                    onDisplayImage = function(context, imageView, url)
                        LuaImageLoader.load(imageView, url)
                    end,
                    onItemImageClick = function(context, imageView, index, list)
                        launchPicturePreview(msg, index)
                    end
                })))
                views.iv_nine_grid.setImagesData(urls)
            else
                views.iv_nine_grid.setVisibility(8)
            end
            if msg.mblog.page_info and msg.mblog.page_info.type == 'video' then
                views.layout_video.setVisibility(0)
                LuaImageLoader.load(views.iv_video, msg.mblog.page_info.page_pic.url)
            else
                views.layout_video.setVisibility(8)
            end

            if position == #data then fetchData() end
        end,
    }))
    recyclerView.setLayoutManager(LinearLayoutManager(activity))
    recyclerView.setAdapter(adapter)
    refreshLayout.setOnRefreshListener(luajava.createProxy('android.support.v4.widget.SwipeRefreshLayout$OnRefreshListener', {
        onRefresh = function()
            page = 1
            fetchData()
        end
    }))
    refreshLayout.setRefreshing(true)
    fetchData()
end

function onCreateOptionsMenu(menu)
    menu.add("网页版")
    return true
end

function onOptionsItemSelected(item)
    local title = item.getTitle()
    if title == "网页版" then
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse('http://m.weibo.cn')))
    end
end


