require "import"
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "androlua.LuaHttp"
import "androlua.widget.video.VideoPlayerActivity"
local JSON = require "cjson"
local uihelper = require "uihelper"

local layout = {
    ScrollView,
    layout_width = "fill",
    layout_height = "wrap",
    {
        LinearLayout,
        layout_width = "fill",
        layout_height = "wrap",
        orientation = "vertical",
        background = "#FFFFFF",
        {
            FrameLayout,
            layout_width = "fill",
            layout_height = "300dp",
            {
                ImageView,
                id = "iv_bg",
                layout_width = "fill",
                scaleType = "centerCrop",
                layout_height = "220dp",
            },
            {
                View,
                layout_width = "fill",
                layout_height = "220dp",
                background = "#88000000",
            },
            {
                ImageView,
                id = "iv_cover",
                layout_gravity = "bottom",
                layout_marginLeft = "16dp",
                layout_marginBottom = "8dp",
                layout_width = "104dp",
                layout_height = "160dp",
                scaleType = "centerCrop",
                background = "@drawable/ic_loading",
                elevation = "2dp",
            },
            {
                View,
                layout_gravity = "bottom",
                layout_marginLeft = "16dp",
                layout_marginBottom = "8dp",
                layout_width = "104dp",
                layout_height = "160dp",
                elevation = "2dp",
                background = "#44000000",
            },
            {
                ImageView,
                layout_gravity = "bottom",
                layout_marginLeft = "16dp",
                layout_marginBottom = "8dp",
                layout_width = "104dp",
                layout_height = "160dp",
                padding = "35dp",
                elevation = "2dp",
                scaleType = "centerInside",
                src = "#doubanmovie/ic_video_play.png",
            },
            {
                RelativeLayout,
                layout_width = "fill",
                layout_height = "164dp",
                layout_gravity = "bottom",
                layout_marginRight = "16dp",
                layout_marginLeft = "136dp",
                layout_marginBottom = "4dp",
                {
                    TextView,
                    id = "tv_title",
                    layout_width = "fill",
                    textColor = "#faffffff",
                    textSize = "20sp",
                },
                {
                    TextView,
                    layout_below = "tv_title",
                    id = "tv_rate",
                    layout_width = "fill",
                    textColor = "#faffffff",
                    textSize = "16sp",
                    layout_marginTop = "4dp",
                },
                {
                    TextView,
                    id = "tv_year",
                    layout_marginTop = "4dp",
                    layout_alignParentBottom = true,
                    layout_width = "fill",
                    textSize = "14sp",
                    textColor = "#8a8a8a"
                },

                {
                    TextView,
                    id = "tv_directors",
                    layout_marginTop = "4dp",
                    layout_width = "fill",
                    textSize = "14sp",
                    layout_above = "tv_year",
                    textColor = "#8a8a8a"
                },

                {
                    TextView,
                    id = "tv_genres",
                    layout_width = "fill",
                    layout_marginTop = "4dp",
                    textSize = "14sp",
                    textColor = "#8a8a8a",
                    layout_above = "tv_directors",
                },

                {
                    TextView,
                    id = "tv_duration",
                    layout_width = "fill",
                    textColor = "#00ffffff",
                    textSize = "14sp",
                    layout_marginTop = "4dp",
                    layout_above = "tv_genres",
                },
            },
        },
        {
            TextView,
            textSize = "20sp",
            text = "剧情简介",
            textColor = "#444444",
            layout_margin = "16dp",
        },
        {
            TextView,
            id = "tv_summary",
            textSize = "12sp",
            layout_marginLeft = "16dp",
            layout_marginRight = "16dp",
            lineSpacingMultiplier = 1.5,
            textColor = "#777777",
        },
        {
            View,
            layout_margin = "16dp",
            layout_height = 2,
            background = "#f1f1f1",
        },
        {
            TextView,
            layout_margin = "16dp",
            textSize = "20sp",
            text = "剧照",
            textColor = "#444444",
        },
        {
            HorizontalScrollView,
            layout_marginBottom = "16dp",
            {
                LinearLayout,
                id = "layout_casts",
                layout_width = "fill",
                layout_height = "120dp",
                paddingLeft = "16dp",
                clipToPadding = false,
            }
        },
        {
            TextView,
            layout_margin = "16dp",
            textSize = "20sp",
            text = "热门评论",
            textColor = "#444444",
        },
        {
            LinearLayout,
            id = "layout_comment",
            layout_width = "fill",
            orientation = "vertical",
        }
    },
}

local item_comment = {
    RelativeLayout,
    layout_width = "fill",
    paddingLeft = "16dp",
    paddingRight = "16dp",
    paddingTop = "16dp",
    {
        ImageView,
        id = "iv_avatar",
        layout_width = "36dp",
        layout_height = "36dp",
        scaleType = "centerCrop",
    },
    {
        TextView,
        id = "tv_nick",
        layout_width = "fill",
        textColor = "#111111",
        textSize = "15sp",
        layout_marginLeft = "48dp",
    },

    {
        TextView,
        id = "tv_content",
        layout_width = "fill",
        textColor = "#222222",
        textSize = "13sp",
        layout_below = "tv_nick",
        layout_marginLeft = "48dp",
        layout_marginTop = "8dp",
        lineSpacingMultiplier = 1.2,
    },
    {
        View,
        layout_below = "tv_content",
        layout_marginTop = "16dp",
        layout_marginLeft = "48dp",
        layout_width = "fill",
        layout_height = "1dp",
        background = "#f1f1f1",
    },
}

local item_cast = {
    LinearLayout,
    layout_width = "168dp",
    layout_height = "fill",
    orientation = "vertical",
    gravity = "center",
    paddingRight = "8dp",
    {
        ImageView,
        layout_width = "fill",
        layout_height = "fill",
        scaleType = "centerCrop",
    },
}

local function updateHeader(movie)
    uihelper.runOnUiThread(activity, function()
        local imgUrl = movie.img:gsub("w.h","148.208")
        LuaImageLoader.load(iv_bg, imgUrl)
        LuaImageLoader.load(iv_cover, imgUrl)
        local rate = movie.sc
        if rate == '0' or rate == 0 then rate = '暂无' end
        tv_title.setText(movie.nm)
        tv_rate.setText('评分:  ' .. rate)
        tv_summary.setText(movie.dra or '暂无简介')
        tv_year.setText('上映时间:  ' .. movie.rt or '')
        tv_genres.setText('分类:  ' .. movie.cat)
        tv_duration.setText(string.format('%s/%s分钟', movie.src or '未知', movie.pn))
        tv_directors.setText('导演:  ' .. movie.dir)
        if movie.vd then
            iv_cover.onClick = function(view)
                local json = { url = movie.vd, poster = movie.img }
                VideoPlayerActivity.start(activity, JSON.encode(json))
            end
        end

        if movie.photos then
            layout_casts.removeAllViews()
            for i = 1, #movie.photos do
                local img = movie.photos[i]:gsub('net/.-/movie', 'net/800.1600/movie')
                local child = loadlayout(item_cast)
                LuaImageLoader.load(child.getChildAt(0), img)
                layout_casts.addView(child)
            end
        end
    end)
end

local function updateComment(comments)
    uihelper.runOnUiThread(activity, function()

        layout_comment.removeAllViews()
        for i = 1, #comments do
            local views = {}
            local child = loadlayout(item_comment, views)
            LuaImageLoader.load(views.iv_avatar, comments[i].avatarUrl)
            views.tv_nick.setText(comments[i].nick or '')
            views.tv_content.setText(comments[i].content or '')
            layout_comment.addView(child)
        end
    end)
end

local function getData(id)
    local url = string.format('http://m.maoyan.com/ajax/detailmovie?movieId=%d', id)
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then
            print('get data error ' .. code)
        end
        local json = JSON.decode(body)
        local movie = json.detailMovie
        if movie then updateHeader(movie) end
    end)

    local commentUrl = string.format('http://m.maoyan.com/review/v2/comments.json?movieId=%d&userId=-1&offset=0&limit=15&ts=0&type=3',id)
    LuaHttp.request({ url = commentUrl }, function(error, code, body)
        if error or code ~= 200 then
            print('get data error ' .. code)
        end
        local json = JSON.decode(body)
        local comments = json.data.hotComments -- 热门
        if comments then updateComment(comments) end
    end)
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x00000000)
    activity.setContentView(loadlayout(layout))
    local id = activity.getIntent().getStringExtra('id')
    getData(id)
end
