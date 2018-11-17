require("import")
import "android.widget.*"
import "android.content.*"
import "android.view.View"
import "androlua.LuaAdapter"


local China = require("weather.city")
local filehelper = require("filehelper")

local layout = {
    LinearLayout,
    layout_width = "match",
    layout_height = "match",
    orientation = 'vertical',
    statusBarColor = "#8CCACE",
    {
        LinearLayout,
        layout_height = "56dp",
        layout_width = "match",
        orientation = 'vertical',
        gravity = "center",
        background = "#8CCACE",
        {
            TextView,
            paddingLeft = "16dp",
            textSize = "18sp",
            text = "选择城市",
            textColor = "#eeffffff",
        },
    },
    {
        ListView,
        id = 'listview2',
        layout_width = "match",
        layout_height = "match",
        visibility = "gone",
    },
    {
        ListView,
        id = 'listview',
        layout_width = "match",
        layout_height = "match",
    },
}


local showCityData = false

local item_view = {
    TextView,
    id = "tv_name",
    gravity = "center_vertical",
    layout_width = "fill",
    layout_height = "56dp",
    paddingLeft = "16dp",
    textColor = "#666666",
}

local filePath = luajava.luaextdir .. '/weather/id'
local data = {}
local cityData = {}

local function clearTable(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0xFF8CCACE)
    activity.setContentView(loadlayout(layout))

    for k, _ in pairs(China) do
        data[#data + 1] = k
    end

    local adapter2 = LuaAdapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
        getCount = function() return #cityData end,
        getView = function(position, convertView, parent)
            position = position + 1 -- lua 索引从 1开始
            if convertView == nil then
                local views = {} -- store views
                convertView = loadlayout(item_view, views, ListView)
                convertView.getLayoutParams().width = parent.getWidth()
                convertView.setTag(views)
            end
            local views = convertView.getTag()
            local item = cityData[position]
            views.tv_name.setText(item[2])
            return convertView
        end
    }))
    listview2.setAdapter(adapter2)
    listview2.setOnItemClickListener(luajava.createProxy("android.widget.AdapterView$OnItemClickListener", {
        onItemClick = function(adapter, view, position, id)
            activity.toast('请稍候...')
            position = position + 1
            local id = cityData[position][1]:sub(2)
            filehelper.writefile(filePath, id)
            view.postDelayed(luajava.createProxy('java.lang.Runnable', {
                run = function()
                    activity.finish()
                end
            }), 500)
        end,
    }))

    local adapter = LuaAdapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
        getCount = function() return #data end,
        getView = function(position, convertView, parent)
            position = position + 1 -- lua 索引从 1开始
            if convertView == nil then
                local views = {} -- store views
                convertView = loadlayout(item_view, views, ListView)
                if parent then convertView.getLayoutParams().width = parent.getWidth() end
                convertView.setTag(views)
            end
            local views = convertView.getTag()
            local item = data[position]
            print(position, item)
            print(views.tv_name)
            views.tv_name.setText(item)
            return convertView
        end
    }))
    listview.setAdapter(adapter)
    listview.setOnItemClickListener(luajava.createProxy("android.widget.AdapterView$OnItemClickListener", {
        onItemClick = function(adapter, view, position, id)
            position = position + 1
            local sTable = China[data[position]]
            clearTable(cityData)
            for k, v in pairs(sTable) do
                for k2, v2 in pairs(v) do
                    local name = k .. ' · ' .. v2
                    if k == v2 then
                        name = k
                    end
                    cityData[#cityData + 1] = { k2, name }
                end
            end
            listview2.setVisibility(0)
            listview.setVisibility(8)
            adapter2.notifyDataSetChanged()
            showCityData = true
        end,
    }))
end

function onBackPressed()
    if showCityData then
        listview2.setVisibility(8)
        listview.setVisibility(0)
        showCityData = false
        return true
    end
    return false
end
