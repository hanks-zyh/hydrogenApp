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
import "androlua.LuaImageLoader"
import "androlua.LuaDrawable"
import "androlua.LuaView"
import "android.graphics.Paint"
import "androlua.LuaUtil"

local uihelper = require("uihelper")
local JSON = require("cjson")
local filehelper = require("filehelper")
local weather = require("weather.weather")
local log = require("log")

local item_hour = {
    LinearLayout,
    layout_weight = 1,
    orientation = "vertical",
    gravity = "center",
    paddingTop = "16dp",
    paddingBottom = "16dp",
    {
        TextView,
        textSize = "13sp",
        textColor = "#666666",
        text = "00:00",
    },
    {
        ImageView,
        layout_width = "match",
        layout_height = "24dp",
        layout_marginBottom = "4dp",
        layout_marginTop = "12dp",
    },
    {
        TextView,
        textSize = "12sp",
        textColor = "#666666",
        text = "0°",
    },
}
local item_week = {
    LinearLayout,
    layout_weight = 1,
    orientation = "vertical",
    gravity = "center",
    paddingTop = "16dp",
    paddingBottom = "16dp",
    {
        TextView,
        textSize = "13sp",
        textColor = "#666666",
        text = "今天",
    },
    {
        ImageView,
        layout_width = "match",
        layout_height = "24dp",
        layout_marginBottom = "4dp",
        layout_marginTop = "16dp",
    },
    {
        TextView,
        textSize = "10sp",
        textColor = "#666666",
        text = "多云",
    },
}

-- create view table
local layout = {
    ScrollView,
    {
        LinearLayout,
        orientation = "vertical",
        {
            LinearLayout,
            background = "#8CCACE",
            layout_width = "fill",
            layout_height = "wrap",
            orientation = "vertical",
            gravity = "center_horizontal",
            {
                RelativeLayout,
                layout_width = "fill",
                layout_height = "56dp",
                layout_marginTop = "25dp",
                {
                    TextView,
                    id = "tv_city",
                    layout_height = "match",
                    gravity = "center",
                    layout_centerVertical = true,
                    textSize = "16sp",
                    textColor = "#ffffff",
                    paddingLeft = "16dp",
                    paddingRight = "16dp",
                },
                {
                    TextView,
                    layout_marginRight = "16dp",
                    id = "tv_update",
                    layout_alignParentRight = true,
                    layout_centerVertical = true,
                    textSize = "12sp",
                    textColor = "#aaffffff",
                },
            },
            {
                LinearLayout,
                layout_width = "fill",
                orientation = "vertical",
                gravity = "center_horizontal",
                paddingBottom = "72dp",
                paddingTop = "24dp",
                {
                    TextView,
                    id = "tv_weather",
                    textSize = "18sp",
                    textColor = "#eeffffff",
                },
                {
                    TextView,
                    id = "tv_temp",
                    layout_marginTop = "8dp",
                    layout_marginBottom = "12dp",
                    textSize = "82sp",
                    textColor = "#f1ffffff",
                },
                {
                    TextView,
                    id = "tv_wind",
                    textSize = "13sp",
                    textColor = "#aaffffff",
                },
            },
        },
        {
            LinearLayout,
            id = "layout_week",
            layout_width = "fill",
            orientation = "horizontal",
            item_week,
            item_week,
            item_week,
            item_week,
            item_week,
            item_week,
        },
        {
            LuaView,
            id = "line_view",
            layout_width = "fill",
            layout_height = "80dp",
        },
        {
            LinearLayout,
            id = "layout_24h",
            layout_width = "fill",
            orientation = "horizontal",
            item_hour,
            item_hour,
            item_hour,
            item_hour,
            item_hour,
            item_hour,
        },
    },
}

-- bg http://i.tq121.com.cn/i/wap2016/news/d11.jpg
local weekTemp = {}

local function safeRun(f)
    pcall(function()
        f()
    end)
end

local function fillBaseInfo(body)
    local json = JSON.decode(string.match(body, '{.*}'))
    tv_city.setText(json.cityname)
    tv_temp.setText(json.temp .. '°')
    tv_update.setText(json.time .. ' 更新')
    tv_weather.setText(json.weather)
    tv_wind.setText(string.format('空气指数 %s  •  %s  •  湿度 %s', json.aqi_pm25, json.WD .. ' ' .. json.WS, json.SD))
end



local function fillWeekInfo(body)
    local json = JSON.decode(string.match(body, '{.*}'))
    for i = 1, #json.f do
        local child = layout_week.getChildAt(i - 1)
        child.getChildAt(0).setText(json.f[i].fj)
        local xmlPath = string.format('%s/weather/img/line_%s.png', luajava.luaextdir, json.f[i].fa)
        child.getChildAt(1).setImageDrawable(LuaDrawable.create(xmlPath))
        child.getChildAt(2).setText(weather['_' .. json.f[i].fa])
        weekTemp[i] = { json.f[i].fc, json.f[i].fd }
    end
    line_view.invalidate()
end

local function fill24HInfo(body)
    print(body)
    local json = JSON.decode(string.match(body, 'fc1h_24%s+=(.*);'))
    local j = 0
    for i = 1, #json.jh, 3 do
        local child = layout_24h.getChildAt(j)
        if child then
            child.getChildAt(0).setText(json.jh[i].jf:sub(9, 10) .. ':00')
            local xmlPath = string.format('%s/weather/img/line_%s.png', luajava.luaextdir, json.jh[i].ja)
            child.getChildAt(1).setImageDrawable(LuaDrawable.create(xmlPath))
            child.getChildAt(2).setText(json.jh[i].jb .. '°')
        end
        j = j + 1
    end
end



local function getData(url, successFunc)
    print(url)
    local options = {
        url = url,
        headers = {
            "Referer:http://m.weather.com.cn"
        }
    }
    LuaHttp.request(options, function(error, code, body)
        if error or code ~= 200 then
            print('fetch data error')
            return
        end
        uihelper.runOnUiThread(activity, function()
            successFunc(body)
        end)
    end)
end

local filePath = luajava.luaextdir .. '/weather/id'

local function fetchData(id)
    if id == nil then return end
    getData(string.format('http://d1.weather.com.cn/sk_2d/%s.html', id), fillBaseInfo)
    getData(string.format('http://d1.weather.com.cn/weixinfc/%s.html', id), fillWeekInfo)
    getData(string.format('http://d1.weather.com.cn/wap_40d/%s.html', id), fill24HInfo)
end


function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x00000000)
    activity.setContentView(loadlayout(layout))
    local paint = Paint(1)
    paint.setColor(0xFF666666)
    paint.setTextSize(uihelper.dp2px(10))
    paint.setStrokeWidth(uihelper.dp2px(1.5))
    local linePaint1 = Paint(paint)
    linePaint1.setColor(0xFFFFD139)
    local linePaint2 = Paint(paint)
    linePaint2.setColor(0xFF7FDCEF)

    local radius = uihelper.dp2px(2.5)
    local texWidth = uihelper.dp2px(6)

    line_view.setCreator(luajava.createProxy('androlua.LuaView$Creator', {
        onDraw = function(canvas)
            local count = #weekTemp
            local max = -999
            local min = 999
            for i = 1, count do
                if tonumber(weekTemp[i][1]) > max then max = tonumber(weekTemp[i][1]) end
                if tonumber(weekTemp[i][2]) < min then min = tonumber(weekTemp[i][2]) end
            end
            local dx = line_view.getWidth() / count
            local startY = uihelper.dp2px(18)
            local dy = (line_view.getHeight() - line_view.getPaddingTop() - line_view.getPaddingBottom() - startY - startY) / (max - min)
            local lastPoint1 = {}
            local lastPoint2 = {}
            for i = 1, count do
                local maxT = weekTemp[i][1]
                local minT = weekTemp[i][2]
                local x = dx * (i - 0.5)
                local y1 = startY + (max - maxT) * dy
                local y2 = startY + (max - minT) * dy
                canvas.drawText(maxT .. '°', x - texWidth, y1 - texWidth, paint)
                canvas.drawText(minT .. '°', x - texWidth, y2 + texWidth + texWidth, paint)
                canvas.drawCircle(x, y1, radius, linePaint1)
                canvas.drawCircle(x, y2, radius, linePaint2)
                if lastPoint1[1] and lastPoint1[2] then
                    canvas.drawLine(lastPoint1[1], lastPoint1[2], x, y1, linePaint1)
                end

                if lastPoint2[1] and lastPoint2[2] then
                    canvas.drawLine(lastPoint2[1], lastPoint2[2], x, y2, linePaint2)
                end


                lastPoint1[1] = x
                lastPoint1[2] = y1

                lastPoint2[1] = x
                lastPoint2[2] = y2
            end
        end,
    }))

    tv_city.onClick = function(v)
        local intent = Intent(activity, LuaActivity)
        intent.putExtra("luaPath", 'weather/list_city.lua')
        activity.startActivity(intent)
    end
end


function onDestroy()
    LuaHttp.cancelAll()
end

local function findCityCode(province, city)
    local China = require("weather.city")
    for k, v in pairs(China) do
        if province == k then
            for k2, v2 in pairs(v) do
                if k2 == city then
                    print(city)
                    log.print_r(v2) 
                    for k3,v3 in pairs(v2) do
                        if(v3 == city) then
                            return k3:sub(2)
                        end
                    end
                end
            end
        end
    end
    return '101010100'
end

local function locateMe()
    local id = '101010100'
    local options = {
        url = 'http://ip.taobao.com/service/getIpInfo2.php',
        method = "POST",
        formData = {
            "ip:myip"
        }
    }
    LuaHttp.request(options, function(error, code, body)
        print(body)
        if error or code ~= 200 then
            print('locate failure')
            return
        end
        local json = JSON.decode(body)
        local province = json.data.region
        local city = json.data.city
        local county = json.data.county
        local p = string.match(province, '(.*)省')
        if p then province = p
        else
            p = string.match(province, '(.*)市')
            if p then province = p end
        end

        local c = string.match(province, '(.*)市')
        if c then city = c end

        local id = findCityCode(province, city)
        filehelper.writefile(filePath, id)
        fetchData(id)
    end)
end

function onResume()
    safeRun(function()
        local id = filehelper.readfile(filePath)
        if id == nil then
            locateMe()
        else
            fetchData(id)
        end
    end)
end
