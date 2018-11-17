--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- qiqu
--
require "import"
import "android.widget.*"
import "android.content.*"
import "android.support.v4.view.ViewPager"
import "androlua.adapter.LuaPagerAdapter"
import "androlua.LuaImageLoader"
import "android.app.DownloadManager"
import "android.os.Environment"
import "android.net.Uri"
local DialogBuilder = import "android.app.AlertDialog$Builder"
local DownloadManagerRequest = import "android.app.DownloadManager$Request"

local uihelper = require('uihelper')
local JSON = require("cjson")
-- create view table
local layout = {
    FrameLayout,
    layout_width = "fill",
    layout_height = "fill",
    {
        ViewPager,
        id = "viewPager",
        layout_width = "fill",
        layout_height = "fill",
    },
    {
        LinearLayout,
        layout_width = "fill",
        layout_gravity = "bottom",
        orientation = "vertical",
        paddingBottom = "24dp",
        paddingLeft = "20dp",
        paddingRight = "20dp",
        paddingTop = "120dp",
        background = "@drawable/shadow_splash",
        {
            RelativeLayout,
            layout_width = "fill",
            layout_height = "40dp",
            layout_marginBottom = "20dp",
            {
                TextView,
                id = "tv_date",
                layout_alignParentRight = true,
                layout_alignParentBottom = true,
                textSize = "14sp",
                textColor = "#FFFFFF",
            },
            {
                TextView,
                id = "tv_day",
                layout_toLeftOf = "tv_date",
                layout_alignBaseline = "tv_date",
                textSize = "30sp",
                gravity = "right",
                textColor = "#FFFFFF",
            },
        },
        {
            TextView,
            id = "tv_text",
            layout_width = "match",
            gravity = "right",
            lineSpacingMultiplier = 1.5,
            textSize = "14sp",
            textColor = "#FFFFFF",
        },
    }
}

local item_view = {
    ImageView,
    id = "iv_bg",
    layout_width = "match",
    layout_height = "match",
    scaleType = "centerCrop",
}

local adapter
local data = {}

local function downloadPicture(url)
    local manager = activity.getSystemService(Context.DOWNLOAD_SERVICE)
    local request = DownloadManagerRequest(Uri.parse(url))
    request.setNotificationVisibility(DownloadManagerRequest.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
    request.setDescription("下载中...")
    request.setTitle("下载")
    request.setDestinationInExternalPublicDir(Environment.DIRECTORY_PICTURES, os.time() .. ".jpg")
    manager.enqueue(request)
end

local function getData()
    LuaHttp.request({ url = 'https://coding.net/u/zhangyuhan/p/api_luanroid/git/raw/master/api/splash' }, function(e, code, body)
        print(body)
        local json = JSON.decode(body)
        local arr = json.data
        uihelper.runOnUiThread(activity, function()
            local views = {}
            for i = 1, #arr do
                data[#data + 1] = arr[i]
                local ids = {}
                local view = loadlayout(item_view, ids, ViewGroup)
                LuaImageLoader.load(ids.iv_bg, arr[i].img)
                ids.iv_bg.onClick = function()
                    DialogBuilder(activity).setTitle('保存图片').setMessage('保存到相册？').setNegativeButton('取消', nil).setPositiveButton('确定', luajava.createProxy('android.content.DialogInterface$OnClickListener', {
                        onClick = function(dialog, which)
                            downloadPicture(arr[i].img)
                            activity.toast('保存到相册...')
                        end
                    })).show()
                end
                views[#views + 1] = view
            end
            adapter.addViews(views)
            adapter.notifyDataSetChanged()
            if #data > 0 then
                tv_date.setText(string.format('%d月', tonumber(data[1].date:sub(5, 6))))
                tv_day.setText(string.format('%d/', tonumber(data[1].date:sub(7, 8))))
                tv_text.setText(data[1].text)
            end
        end)
    end)
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x00000000)
    activity.setContentView(loadlayout(layout))
    adapter = LuaPagerAdapter(nil)
    viewPager.setAdapter(adapter)
    viewPager.addOnPageChangeListener(luajava.createProxy('android.support.v4.view.ViewPager$OnPageChangeListener', {
        onPageSelected = function(position)
            position = position + 1
            local item = data[position]
            tv_date.setText(string.format('/%d月', tonumber(item.date:sub(5, 6))))
            tv_day.setText(string.format('%d', tonumber(item.date:sub(7, 8))))
            tv_text.setText(item.text)
        end
    }))
    getData()
end
