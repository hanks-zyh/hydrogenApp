--
-- Created by IntelliJ IDEA.  Copyright (C) 2017 Hanks
-- User: hanks
-- Date: 2017/5/26
-- A news app
--
require "import"
import "android.widget.*"
import "android.content.*"
import "android.net.*"
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

local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    gravity = "center_horizontal",
    background = "#ffffff",
    orientation = "vertical",
    {
        ImageView,
        id = "logo",
        layout_width = "72dp",
        layout_height = "72dp",
        layout_marginTop = "70dp",
    },
    {
        TextView,
        layout_width = "200dp",
        layout_height = "40dp",
        gravity = "center",
        text = "Note Pro",
        textColor = "#333333",
        textSize = "12sp"
    },
    {
        TextView,
        layout_width = "wrap_content",
        layout_height = "wrap_content",
        layout_marginTop = "48dp",
        lineSpacingMultiplier = "2.5",
        text = "☑ 纯净无广告\n☑ 更多的布局样式\n☑ 自定义主背景\n☑ 便签置顶功能\n☑ 优先体验新功能\n☑ 支持便签项目长期开发",
        textColor = "#333333",
        textSize = "14sp",
    },
    {
        TextView,
        id = "btn_get_pro",
        layout_width = "104dp",
        layout_height = "40dp",
        layout_gravity = "center",
        layout_marginTop = "56dp",
        background = "#C13D34",
        elevation = "2dp",
        gravity = "center",
        text = "Get",
        textColor = "#ffffff",
        textSize = "16sp",
    },
}
function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x33000000)
    activity.setContentView(loadlayout(layout))
    LuaImageLoader.load(logo, "http://ww1.sinaimg.cn/large/8c9b876fly1ftf62owi8wj2040040wec.jpg")
    btn_get_pro.onClick = function()
        -- Toast.makeText(activity,"222",0).show()
        pcall(function()
            local intent = Intent(Intent.ACTION_VIEW)
            intent.setData(Uri.parse("market://details?id=xyz.hanks.note.pro"))
            activity.startActivity(intent)
        end)
    end
end
