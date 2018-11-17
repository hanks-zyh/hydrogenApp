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
import "android.support.v7.widget.StaggeredGridLayoutManager"
import "androlua.widget.picture.PicturePreviewActivity"
import "android.support.v4.app.ActivityCompat"
import "android.Manifest"

local filehelper = require("filehelper")
local JSON = require("cjson")
local uihelper = require('uihelper')
local page = 1
local data = {}
local adapter
local imageWidth = uihelper.getScreenWidth() / 2

local filePath = '/sdcard/ip_pool.json'

-- create view table
local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    layout_height = "fill",
    {
        TextView,
        id = "tv_go",
        layout_width = "fill",
        layout_height = "56dp",
        layout_margin = "40dp",
        background = "#88000000",
        gravity = "center",
        textSize = "14sp",
        text = "开始",
        textColor = "#aaffffff",
    },
    {
        ScrollView,
        layout_width = "fill",
        layout_height = "fill",
        {
            TextView,
            id = "tv_result",
            layout_width = "fill",
            layout_height = "fill",
            textSize = "10sp",
            textColor = "#414141",
        },
    }
    
}
  
local function fetchData()
    local date = os.time() * 1000
    local url = string.format('http://www.mogumiao.com/proxy/free/listFreeIp')
    print(url)
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then
            uihelper.runOnUiThread(activity, function()
                tv_result.setText('失败:' .. code)
            end)
            return
        end
        local json = JSON.decode(body)
        local arr = json.msg
        uihelper.runOnUiThread(activity, function()
            for i = 1, #arr do
                local item = arr[i]
                data[#data + 1] = {
                    ip = item.ip,
                    port = item.port,
                    type = "mogu",
                }
            end
            local result = JSON.encode(data)
            tv_result.setText(result)
            filehelper.writefile(filePath, result)
        end)
    end)
end
 

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x33000000)
    activity.setContentView(loadlayout(layout))
    tv_go.onClick = function()
        fetchData()
    end
    ActivityCompat.requestPermissions(activity,
                {Manifest.permission.WRITE_EXTERNAL_STORAGE},
                0x23);
end
