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
import "android.net.Uri"

local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"
local fragmentNews = require "pengpai/fragment_news"


-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#33000000",
    {
        Toolbar,
        background = '#ffffff',
        id = 'toolbar',
        layout_width = "match",
        layout_height = "56dp",
        {
            ImageView,
            layout_width = "54dp",
            layout_height = "32dp",
            scaleType = "fitXY",
            src = "#pengpai/logo.png"
        },
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


table.insert(data.fragments, fragmentNews.newInstance('25949'))
table.insert(data.titles, '精选')


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
    activity.setTitle('')
    viewPager.setAdapter(adapter)
    viewPager.setOffscreenPageLimit(#data.fragments)
    viewPager.setCurrentItem(0)
end

function onCreateOptionsMenu(menu)
    menu.add("网页版")
    return true
end

function onOptionsItemSelected(item)
    local title = item.getTitle()
    if title == "网页版" then
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse('http://m.thepaper.cn')))
    end
end
