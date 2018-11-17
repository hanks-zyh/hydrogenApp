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
import "android.support.v4.view.ViewPager"
import "android.support.design.widget.TabLayout"
import "androlua.adapter.LuaFragmentPageAdapter"
import "android.support.v7.widget.Toolbar"
import "android.support.design.widget.CoordinatorLayout"
import "pub.hydrogen.android.R"
import "android.net.Uri"
import "android.support.design.widget.AppBarLayout"
import "android.support.design.widget.CollapsingToolbarLayout"
import "android.os.Build"
local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"
local fragmentNews = require "500px/fragment_news"
local AppBarLayoutScrollingViewBehavior = import "android.support.design.widget.AppBarLayout$ScrollingViewBehavior"
-- create view table
local layout = {
    CoordinatorLayout,
    layout_width = "fill",
    layout_height = "fill",
    background = "#eeeeee",
    {
        AppBarLayout,
        id = "appbar",
        layout_width = "match",
        {
            LinearLayout,
            layout_width = "fill",
            orientation = "vertical",
            applayout_scrollFlags = 0x15,
            {
                View,
                id = "statusBar",
                background = '#FF111111',
                layout_width = "fill",
            },
            {
                Toolbar,
                background = '#FF111111',
                id = 'toolbar',
                layout_width = "match",
                layout_height = "48dp",
                titleTextColor = "#88ffffff",
                {
                    TabLayout,
                    id = "tab",
                    layout_width = "match",
                    layout_height = "match",
                },
            },
        },
    },
    {
        FrameLayout,
        applayout_behavior = AppBarLayoutScrollingViewBehavior(),
        layout_width = "fill",
        layout_height = "fill",
        {
            ViewPager,
            id = "viewPager",
            layout_width = "fill",
            layout_height = "fill",
        },
        {
            View,
            layout_width = "fill",
            layout_height = "3dp",
            background = "@drawable/shadow_line_top",
        }
    }
}

local data = {
    titles = {},
    fragments = {},
}

table.insert(data.fragments, fragmentNews.newInstance('p280'))
table.insert(data.titles, '编辑精选')

table.insert(data.fragments, fragmentNews.newInstance('p3473'))
table.insert(data.titles, '热门')

table.insert(data.fragments, fragmentNews.newInstance('p3475'))
table.insert(data.titles, '抽象')

table.insert(data.fragments, fragmentNews.newInstance('p3477'))
table.insert(data.titles, '动物')

table.insert(data.fragments, fragmentNews.newInstance('p3479'))
table.insert(data.titles, '黑白')

table.insert(data.fragments, fragmentNews.newInstance('p3481'))
table.insert(data.titles, '名人')

table.insert(data.fragments, fragmentNews.newInstance('p3483'))
table.insert(data.titles, '城市与建筑')

table.insert(data.fragments, fragmentNews.newInstance('p3487'))
table.insert(data.titles, '音乐会')

table.insert(data.fragments, fragmentNews.newInstance('p3489'))
table.insert(data.titles, '家庭')

table.insert(data.fragments, fragmentNews.newInstance('p3493'))
table.insert(data.titles, '电影')

table.insert(data.fragments, fragmentNews.newInstance('p3495'))
table.insert(data.titles, '艺术')

table.insert(data.fragments, fragmentNews.newInstance('p3497'))
table.insert(data.titles, '美食')

table.insert(data.fragments, fragmentNews.newInstance('p3499'))
table.insert(data.titles, '新闻')

table.insert(data.fragments, fragmentNews.newInstance('p3501'))
table.insert(data.titles, '风景')

table.insert(data.fragments, fragmentNews.newInstance('p3503'))
table.insert(data.titles, '微距')

table.insert(data.fragments, fragmentNews.newInstance('p3505'))
table.insert(data.titles, '自然')

table.insert(data.fragments, fragmentNews.newInstance('p3507'))
table.insert(data.titles, '人物')


table.insert(data.fragments, fragmentNews.newInstance('p3509'))
table.insert(data.titles, '表演艺术')

table.insert(data.fragments, fragmentNews.newInstance('p3511'))
table.insert(data.titles, '运动')

table.insert(data.fragments, fragmentNews.newInstance('p3513'))
table.insert(data.titles, '静物')

table.insert(data.fragments, fragmentNews.newInstance('p3515'))
table.insert(data.titles, '街拍')

table.insert(data.fragments, fragmentNews.newInstance('p3517'))
table.insert(data.titles, '交通')

table.insert(data.fragments, fragmentNews.newInstance('p3519'))
table.insert(data.titles, '旅行')

table.insert(data.fragments, fragmentNews.newInstance('p3521'))
table.insert(data.titles, '水下摄影')

table.insert(data.fragments, fragmentNews.newInstance('p3523'))
table.insert(data.titles, '城市探索')

table.insert(data.fragments, fragmentNews.newInstance('p3525'))
table.insert(data.titles, '婚礼')


local adapter = LuaFragmentPageAdapter(activity.getSupportFragmentManager(),
    luajava.createProxy("androlua.adapter.LuaFragmentPageAdapter$AdapterCreator", {
        getCount = function() return #data.fragments end,
        getItem = function(position)
            position = position + 1
            return data.fragments[position]
        end,
        getPageTitle = function(position)
            position = position + 1
            return data.titles[position]
        end
    }))

function onCreate(savedInstanceState)
    activity.setContentView(loadlayout(layout))
    activity.setSupportActionBar(toolbar)
    activity.setStatusBarColor(0x33000000)
    activity.setTitle('')
    toolbar.setNavigationIcon(LuaDrawable.create('500px/500px.png'))
    local h = 0
    if Build.VERSION.SDK_INT >= 21 then h = uihelper.dp2px(25) end
    statusBar.getLayoutParams().height = h

    viewPager.setAdapter(adapter)
    viewPager.setOffscreenPageLimit(#data.fragments)
    viewPager.setCurrentItem(0)
    tab.setSelectedTabIndicatorColor(0xeeffffff)
    tab.setTabTextColors(0x88ffffff, 0xeeffffff)
    tab.setTabMode(TabLayout.MODE_SCROLLABLE)
    tab.setTabGravity(TabLayout.GRAVITY_CENTER)
    tab.setupWithViewPager(viewPager)
end

