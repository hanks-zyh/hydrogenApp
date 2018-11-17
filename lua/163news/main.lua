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
local fragmentNews = require "163news/fragment_news"


-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    statusBarColor = "#FF3333",
    {
        TabLayout,
        id = "tab",
        layout_width = "fill",
        layout_height = "48dp",
        background = "#FF3333",
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


table.insert(data.fragments, fragmentNews.newInstance('BA8J7DG9wangning'))
table.insert(data.titles, '推荐')

table.insert(data.fragments, fragmentNews.newInstance('BBM54PGAwangning'))
table.insert(data.titles, '新闻')

table.insert(data.fragments, fragmentNews.newInstance('BD29LPUBwangning'))
table.insert(data.titles, '国内')

table.insert(data.fragments, fragmentNews.newInstance('BD29MJTVwangning'))
table.insert(data.titles, '国际')

table.insert(data.fragments, fragmentNews.newInstance('BA8D4A3Rwangning'))
table.insert(data.titles, '科技')

table.insert(data.fragments, fragmentNews.newInstance('BAI6I0O5wangning'))
table.insert(data.titles, '手机')

table.insert(data.fragments, fragmentNews.newInstance('BAI67OGGwangning'))
table.insert(data.titles, '军事')

table.insert(data.fragments, fragmentNews.newInstance('BA8E6OEOwangning'))
table.insert(data.titles, '体育')

table.insert(data.fragments, fragmentNews.newInstance('BCR1UC1Qwangning'))
table.insert(data.titles, '社会')

table.insert(data.fragments, fragmentNews.newInstance('BA10TA81wangning'))
table.insert(data.titles, '娱乐')

table.insert(data.fragments, fragmentNews.newInstance('BA8FF5PRwangning'))
table.insert(data.titles, '教育')

table.insert(data.fragments, fragmentNews.newInstance('BAI6RHDKwangning'))
table.insert(data.titles, '图片')


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

local function unicode_to_utf8(convertStr)
    local t = {}
    for a in string.gmatch(convertStr, '\\u([0-9a-z][0-9a-z][0-9a-z][0-9a-z])') do
        if #a == 4 then
            local n = tonumber(a, 16)
            assert(n, "String decoding failed: bad Unicode escape " .. a)
            local x
            if n < 0x80 then
                x = string.char(n % 0x80)
            elseif n < 0x800 then
                -- [110x xxxx] [10xx xxxx]
                x = string.char(0xC0 + (math.floor(n / 64) % 0x20), 0x80 + (n % 0x40))
            else
                -- [1110 xxxx] [10xx xxxx] [10xx xxxx]
                x = string.char(0xE0 + (math.floor(n / 4096) % 0x10), 0x80 + (math.floor(n / 64) % 0x40), 0x80 + (n % 0x40))
            end
            convertStr = string.gsub(convertStr, '\\u' .. a, x)
        end
    end
    return convertStr
end

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
