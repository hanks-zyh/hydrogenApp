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

local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"
local fragmentNews = require "douban-daily/fragment_news"


-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#1CC4AD",
    {
        TabLayout,
        id = "tab",
        layout_width = "fill",
        layout_height = "48dp",
        background = "#1CC4AD",
    },
    {
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


table.insert(data.fragments, fragmentNews.newInstance('p38'))
table.insert(data.titles, '今日一刻')

table.insert(data.fragments, fragmentNews.newInstance('p3401'))
table.insert(data.titles, '热门精选')

table.insert(data.fragments, fragmentNews.newInstance('p3363'))
table.insert(data.titles, '打鸡血')

table.insert(data.fragments, fragmentNews.newInstance('p3367'))
table.insert(data.titles, '洗洗睡')

table.insert(data.fragments, fragmentNews.newInstance('p15913'))
table.insert(data.titles, '爱美丽')

table.insert(data.fragments, fragmentNews.newInstance('p3369'))
table.insert(data.titles, '闲翻书')

table.insert(data.fragments, fragmentNews.newInstance('p3371'))
table.insert(data.titles, '看电影')

table.insert(data.fragments, fragmentNews.newInstance('p3373'))
table.insert(data.titles, '听音乐')

table.insert(data.fragments, fragmentNews.newInstance('p3375'))
table.insert(data.titles, '聊艺术')

table.insert(data.fragments, fragmentNews.newInstance('p3379'))
table.insert(data.titles, '哈哈哈')

table.insert(data.fragments, fragmentNews.newInstance('p3381'))
table.insert(data.titles, '假日厨房')

table.insert(data.fragments, fragmentNews.newInstance('p3383'))
table.insert(data.titles, '食记')

table.insert(data.fragments, fragmentNews.newInstance('p3387'))
table.insert(data.titles, '生活家')

table.insert(data.fragments, fragmentNews.newInstance('p3389'))
table.insert(data.titles, '去远方')

table.insert(data.fragments, fragmentNews.newInstance('p3391'))
table.insert(data.titles, '海外志')

table.insert(data.fragments, fragmentNews.newInstance('p3393'))
table.insert(data.titles, '冷知识')

table.insert(data.fragments, fragmentNews.newInstance('p3395'))
table.insert(data.titles, '萌')

table.insert(data.fragments, fragmentNews.newInstance('p3397'))
table.insert(data.titles, '连载')

table.insert(data.fragments, fragmentNews.newInstance('p3399'))
table.insert(data.titles, '鬼敲门')

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
    viewPager.setAdapter(adapter)
    viewPager.setOffscreenPageLimit(#data.fragments)
    viewPager.setCurrentItem(0)
    tab.setSelectedTabIndicatorColor(0xffffffff)
    tab.setTabTextColors(0x88ffffff, 0xffffffff)
    tab.setTabMode(TabLayout.MODE_SCROLLABLE)
    tab.setTabGravity(TabLayout.GRAVITY_CENTER)
    tab.setupWithViewPager(viewPager)
end
