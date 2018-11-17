# 氢应用插件开发

## 插件介绍
插件用 lua 语言开发，所以需要能看懂 lua，插件基于 androlua 框架下，
氢应用插件结构很简单，每个插件放在手机的 sdcard/Android/data/pub.hydrogen.android/files/LLLLLua 目录下

1. 首先在上面的目录下创建插件文件夹
2. 编写插件主程序，插件**至少**包含2文件:
`info.json` 插件描述文件，`main.lua` 插件启动文件，接下来分别介绍：

## 插件结构
首先是 `info.json`
```
{
  "id": "pub.hanks.gacha",
  "name": "网易插画",
  "icon": "http://ww1.sinaimg.cn/large/8c9b876fly1fhaaa8qcofj2046046we9.jpg",
  "main": "main.lua",
  "versionName": "1.0",
  "versionCode": 1,
  "desc": "网易每日插画排行"
}
```

id: 插件唯一标识符号
name: 插件名称
icon: 插件图标
main: 插件启动文件, 可以自定义名称
versionName: 插件版本名称
versionVersion: 插件版本号
desc: 插件描述

然后是启动文件（main.lua），也就是主程序，以`网易插画`的代码为例:

```lua
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
local JSON = require("cjson")
local uihelper = require('uihelper')

-- 上面是需要导入用到的 class 类以及引用的 so 或 lua


local calender = Calendar.getInstance()
local max
local data = {}
local adapter
local imageWidth = uihelper.getScreenWidth() / 2

-- 布局文件
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
        visibility = 'gone',
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

    -- 获取数据
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
    -- 发起请求
    LuaHttp.request({ url = url }, function(error, code, body)
        local json = JSON.decode(body)
        local html = json.result.rankingHtml
        -- 异步回调
        uihelper.runOnUiThread(activity, function()
            -- UI 线程执行
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
    activity.setStatusBarColor(0x33000000) -- 设置状态栏颜色
    activity.setContentView(loadlayout(layout)) -- 设置布局
    -- 创建Adapter
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
```

插件开发完毕


### 参考链接
[AndroLua_pro](https://github.com/nirenr/AndroLua_pro)
[lua语法](http://www.runoob.com/lua/lua-basic-syntax.html)
[lua的手册](https://cloudwu.github.io/lua53doc/manual.html)
[Android文档](https://developer.android.com/develop/index.html?hl=zh-cn)



