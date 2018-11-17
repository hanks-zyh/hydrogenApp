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
import "android.support.v7.widget.LinearLayoutManager"
import "androlua.widget.picture.PicturePreviewActivity"
import "android.graphics.BitmapFactory"
import "java.io.File"
import "java.lang.Thread"
local BitmapFactory_Options = import "android.graphics.BitmapFactory$Options"


local JSON = require("cjson")
local uihelper = require('uihelper')
local md5 = require "md5"

local adapter
local imageWidth = uihelper.getScreenWidth()
local data = {}
local list = {
    page = 0,
    index = 1,
    subList = {}
}


math.randomseed(os.time())
--- -然后不断产生随机数
list.page = math.floor(math.random() * 20)

-- create view table
local layout = {
    RelativeLayout,
    layout_width = "fill",
    layout_height = "fill",
    {
        RecyclerView,
        id = "recyclerView",
        layout_width = "fill",
        layout_height = "fill",
    },
    {
        TextView,
        id = "tv_loading",
        text = "加载中....",
        textSize = "12sp",
        textColor = "#888888",
        layout_margin = "16dp",
        layout_alignParentBottom = true,
        layout_alignParentRight = true,
    }
}

local item_view = {
    FrameLayout,
    layout_width = "fill",
    {
        ImageView,
        id = "iv_image",
        layout_width = "fill",
        layout_height = "225dp",
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

local function calcImgInfo(filePath, info)
    if not File(filePath).exists() then
        info.h = uihelper.dp2px(240)
        info.w = imageWidth
        info.localUrl = info.url
        return
    end
    local options = BitmapFactory_Options()
    options.inJustDecodeBounds = true
    local bitmap = BitmapFactory.decodeFile(filePath, options)
    info.h = options.outHeight
    info.w = options.outWidth
    info.localUrl = filePath
end


local function notifyUI(arr)
    uihelper.runOnUiThread(activity, function()
        local s = #data
        for i = 1, #arr do
            local item = arr[i]
            item.calcHeight = math.floor(imageWidth * item.h / item.w)
            data[#data + 1] = item
        end
        tv_loading.setVisibility(8)
        adapter.notifyItemRangeChanged(s, #data)
    end)
end

local function downloadFile(urls, i, arr)
    local item = {}
    item.url = urls[i]
    local filePath = activity.getExternalCacheDir().getAbsolutePath() .. "/" .. md5.sumhexa(item.url)
    if File(filePath).exists() then
        calcImgInfo(filePath, item)
        arr[#arr + 1] = item
        if #arr == #urls then notifyUI(arr) end
    else
        LuaHttp.request({ url = item.url, outputFile = filePath }, function(e, code, path)
            calcImgInfo(path, item)
            arr[#arr + 1] = item
            if #arr == #urls then notifyUI(arr) end
        end)
    end
end

local function fetchData()
    tv_loading.setVisibility(0)
    if list.index > #list.subList then
        list.page = list.page + 1
        print("page", list.page)
        if list.page > 21 then list.page = 1 end
        LuaHttp.request({ url = string.format('http://pic.91.com/girl/list_%d.html', list.page) }, function(error, code, body)
            if error or code ~= 200 then
                print('error', code, url)
                return
            end

            local i = 1
            for k, _ in pairs(list.subList) do list.subList[k] = nil end
            for s in string.gmatch(body, 'http://pic.91.com/girl/[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|].html') do
                list.subList[i] = s
                i = i + 1
            end
            list.index = 1
            fetchData()
        end)
        return
    end

    local url = list.subList[list.index]
    list.index = list.index + 1
    LuaHttp.request({ url = url }, function(error, code, body)
        local arr = {}
        local urls = {}
        local div = string.match(body, '<div class="small_list">(.-)</div>')
        for s in string.gmatch(div, 'bigimg="http://img%d.91.com/uploads/allimg/(.-).jpg') do
            urls[#urls + 1] = string.format('http://img3.91.com/uploads/allimg/%s.jpg', s)
        end
        for i = 1, #urls do
            downloadFile(urls, i, arr)
        end
    end)
end

local function launchDetail(item)
    if item == nil or item.url == nil then return end
    local args = { uris = { item.url } }
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
            LuaImageLoader.load(views.iv_image, item.localUrl)
            if position == #data then fetchData() end
        end,
    }))
    recyclerView.setLayoutManager(LinearLayoutManager(activity))
    recyclerView.setAdapter(adapter)
    fetchData()
end
