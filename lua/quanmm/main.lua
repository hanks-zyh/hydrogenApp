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
import "pub.hydrogen.android.R"
import "android.net.Uri"
import "android.os.Build"
local uihelper = require "uihelper"
local JSON = require "cjson"
local log = require "log"
local fragmentNews = require "quanmm/fragment_news"
-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    orientation = "vertical",
    {
        View,
        id = "statusBar",
        background = '#FFFF6666',
        layout_width = "fill",
    },
    {
        Toolbar,
        background = '#FFFF6666',
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

table.insert(data.fragments, fragmentNews.newInstance('http://app.quanmama.com/apios/v5/appZdmList.ashx?f=android&test=0&code=503&platform=Tencent&v=5.0.3&phoneversion=22&pageindex=%d&adsysno=1006&trackSysNo=1006&pagetype=3&dplus_fenlei_name=最新&apphomerankindex=1&sort=1&pagesize=20'))
table.insert(data.titles, '最新')

table.insert(data.fragments, fragmentNews.newInstance('http://app.quanmama.com/apios/v5/appZdmList.ashx?f=android&test=0&code=503&platform=Tencent&v=5.0.3&phoneversion=22&pageindex=%d&adsysno=1004&trackSysNo=1004&pagetype=3&dplus_fenlei_name=最热&apphomerankindex=1&sort=1&pagesize=20'))
table.insert(data.titles, '最热')

table.insert(data.fragments, fragmentNews.newInstance('http://app.quanmama.com/apios/v5/appZdmList.ashx?f=android&test=0&code=503&platform=Tencent&v=5.0.3&phoneversion=22&pageindex=%d&category=5391&sort=1&trackSysNo=4030&pagesize=20'))
table.insert(data.titles, '外卖')

table.insert(data.fragments, fragmentNews.newInstance('http://app.quanmama.com/apios/v5/appZdmList.ashx?f=android&test=0&code=503&platform=Tencent&v=5.0.3&phoneversion=22&pageindex=%d&category=1257&sort=1&trackSysNo=4028&pagesize=20'))
table.insert(data.titles, '出行')

table.insert(data.fragments, fragmentNews.newInstance('http://app.quanmama.com/apios/v5/appZdmList.ashx?f=android&test=0&code=503&platform=Tencent&v=5.0.3&phoneversion=22&pageindex=%d&category=1187&sort=1&trackSysNo=4031&pagesize=20'))
table.insert(data.titles, '观影')

table.insert(data.fragments, fragmentNews.newInstance('http://app.quanmama.com/apios/v5/appZdmList.ashx?f=android&test=0&usertoken=&code=503&platform=Tencent&v=5.0.3&phoneversion=22&imei=867247020524723&channelrankindex=1&sort=1&trackSysNo=4032&storetype=-1&youhuitype=100101&pagesize=20&pageindex=%d'))
table.insert(data.titles, '网购')

table.insert(data.fragments, fragmentNews.newInstance('http://app.quanmama.com/apios/v5/appZdmList.ashx?f=android&test=0&usertoken=&code=503&platform=Tencent&v=5.0.3&phoneversion=22&imei=867247020524723&channelrankindex=1&sort=1&trackSysNo=4140&storetype=-1&youhuitype=100102&tagSysNo=26615&pagesize=20&pageindex=%d'))
table.insert(data.titles, '团购')

table.insert(data.fragments, fragmentNews.newInstance('http://app.quanmama.com/apios/v5/appZdmList.ashx?f=android&test=0&usertoken=&code=503&platform=Tencent&v=5.0.3&phoneversion=22&imei=867247020524723&channelrankindex=1&sort=1&trackSysNo=4051&storetype=-1&youhuitype=10010204&pagesize=20&pageindex=%d'))
table.insert(data.titles, '旅游酒店')

table.insert(data.fragments, fragmentNews.newInstance('http://app.quanmama.com/apios/v5/appZdmList.ashx?f=android&test=0&usertoken=&code=503&platform=Tencent&v=5.0.3&phoneversion=22&imei=867247020524723&channelrankindex=1&sort=1&trackSysNo=4053&storetype=-1&tagSysNo=90584&pagesize=20&pageindex=%d'))
table.insert(data.titles, '专享券')
 

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
    toolbar.setNavigationIcon(LuaDrawable.create('quanmm/quan.png'))
    toolbar.setNavigationOnClickListener(luajava.createProxy("android.view.View$OnClickListener",{
        onClick = function(v)
           activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse('http://m.quanmama.com/mobile/home')))
        end
    }));
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

