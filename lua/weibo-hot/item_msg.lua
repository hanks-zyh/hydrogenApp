return {
    LinearLayout,
    layout_width = "fill",
    paddingTop = "16dp",
    orientation = "vertical",
    background = "@drawable/layout_selector_tran",
    -- head
    {
        FrameLayout,
        layout_width = "match",
        layout_height = "36dp",
        paddingLeft = "16dp",
        paddingRight = "16dp",
        {
            ImageView,
            id = "iv_image",
            layout_width = "36dp",
            layout_height = "36dp",
            scaleType = "centerCrop"
        },
        {
            TextView,
            id = "tv_username",
            layout_marginLeft = "44dp",
            layout_width = "fill",
            paddingRight = "16dp",
            maxLines = "1",
            ellipsize = "end",
            textSize = "14sp",
            textColor = "#e86b0f",
        },
        {
            TextView,
            id = "tv_date",
            layout_gravity = "bottom",
            layout_marginLeft = "44dp",
            layout_width = "fill",
            maxLines = "1",
            textSize = "11sp",
            textColor = "#999999",
        },
    },
    -- content
    {
        TextView,
        id = "tv_content",
        layout_width = "fill",
        layout_marginLeft = "16dp",
        layout_marginRight = "16dp",
        layout_marginTop = "12dp",
        lineSpacingMultiplier = '1.3',
        textSize = "14sp",
        textColor = "#222222",
    },
    -- pictures
    {
        LuaNineGridView,
        id = "iv_nine_grid",
        layout_width = "match",
        layout_height = "200dp",
        gap = "4dp",
        maxSize = 9,
        visibility = "gone",
        layout_marginTop = "12dp",
        layout_marginLeft = "16dp",
        layout_marginRight = "16dp",
    },

    -- video
    {
        FrameLayout,
        id = "layout_video",
        layout_width = "match",
        layout_height = "200dp",
        layout_marginTop = "12dp",
        layout_marginLeft = "16dp",
        layout_marginRight = "16dp",
        visibility = 8,
        {
            ImageView,
            id = "iv_video",
            layout_width = "match",
            layout_height = "200dp",
            scaleType = "centerCrop"
        },
        {
            View,
            layout_height = "match",
            layout_width = "match",
            background = "#66000000",
        },
        {
            ImageView,
            layout_gravity = "center",
            layout_width = "40dp",
            layout_height = "40dp",
            src = "#weibo-hot/ic_video_play.png",
        },
    },
    -- foot
    {
        LinearLayout,
        layout_width = "match",
        layout_height = "56dp",
        paddingLeft = "16dp",
        paddingRight = "16dp",
        gravity = "center_vertical",
        orientation = "horizontal",
        {
            ImageView,
            layout_width = "20dp",
            layout_height = "20dp",
            src = "#weibo-hot/ic_retweet.png",
        },
        {
            TextView,
            id = "tv_retweet",
            layout_width = "70dp",
            paddingLeft = "4dp",
            textSize = "12sp",
            textColor = "#A6A6A6",
        },
        {
            ImageView,
            layout_width = "20dp",
            layout_height = "20dp",
            src = "#weibo-hot/ic_comment.png"
        },
        {
            TextView,
            id = "tv_comment",
            paddingLeft = "4dp",
            layout_width = "70dp",
            textSize = "12sp",
            textColor = "#A6A6A6",
        },
        {
            ImageView,
            layout_width = "20dp",
            layout_height = "20dp",
            src = "#weibo-hot/ic_unlike.png"
        },
        {
            TextView,
            id = "tv_like",
            paddingLeft = "4dp",
            layout_width = "70dp",
            textSize = "12sp",
            textColor = "#A6A6A6",
        },
    },
    {
        View,
        layout_height = "8dp",
        layout_width = "fill",
        background = "#e1e1e1",
    }
}
