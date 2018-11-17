import "androlua.LuaAdapter"
import "androlua.LuaImageLoader"
import "androlua.LuaHttp"
import "androlua.LuaFragment"
import "androlua.widget.webview.WebViewActivity"
local uihelper = require("uihelper")
local JSON = require("cjson")

local function fetchData(baseUrl, data, adapter, fragment)
    local url = string.format(baseUrl, data.page)
    LuaHttp.request({ url = url }, function(error, code, body)
        if error or code ~= 200 then
            print("fetchData error : " .. url)
            return
        end
        local news = {}
        for v in string.gmatch(body, '<li>(.-)</li>') do
            local url = string.match(v, '<a href="(.-)" class="img fl xs[-]100" target="_blank">')
            local imgUrl = string.match(v, '<a.-class="img fl xs[-]100".-<img src="(.-)"/>')
            local title = string.match(v, '<h3>.-target="_blank">(.-)</a>')
            local time = string.match(v, '<span class="fr time">(.-)</span>')
            -- local desc = string.match(v,'<div class="p[-]row">(.-)</div>')
            if url and imgUrl and time then
                title = title:gsub("%s+", "")
                time = time:gsub("%s+", "")
                news[#news + 1] = {
                    title = title,
                    time = time,
                    url = url,
                    imgUrl = imgUrl
                }
            end
        end
        uihelper.runOnUiThread(fragment.getActivity(), function()
            for i = 1, #news do
                data.news[#data.news + 1] = news[i]
            end
            data.page = data.page + 1
            adapter.notifyDataSetChanged()
        end)
    end)
end

function launchDetail(fragment, item)
    local activity = fragment.getActivity()
    local intent = Intent(activity, LuaActivity)
    intent.putExtra("luaPath", 'tv005/activity_agc_detail.lua')
    intent.putExtra("url", '' .. item.url)
    activity.startActivity(intent)
end

function newInstance(baseUrl)

    local layout = {
        ListView,
        id = "listview",
        layout_width = "fill",
        layout_height = "fill",
    }

    local item_view = {
        RelativeLayout,
        layout_width = "fill",
        layout_height = "wrap",
        paddingLeft = "16dp",
        paddingRight = "12dp",
        paddingTop = "16dp",
        paddingBottom = "16dp",
        {
            ImageView,
            id = "iv_image",
            layout_alignParentRight = true,
            layout_width = "100dp",
            layout_height = "75dp",
            scaleType = "centerCrop",
        },
        {
            TextView,
            id = "tv_title",
            layout_width = "fill",
            paddingRight = "16dp",
            maxLines = "2",
            layout_alignParentLeft = true,
            lineSpacingMultiplier = '1.3',
            textSize = "14sp",
            textColor = "#222222",
            layout_toLeftOf = "iv_image",
        },
        {
            TextView,
            id = "tv_time",
            layout_width = "120dp",
            paddingRight = "16dp",
            layout_alignParentLeft = true,
            layout_alignParentBottom = true,
            textSize = "12sp",
            textColor = "#aaaaaa",
            layout_toLeftOf = "iv_image",
        },
    }

    local data = {
        page = 1,
        news = {}
    }

    local ids = {}
    local fragment = LuaFragment.newInstance()
    local adapter
    fragment.setCreator(luajava.createProxy('androlua.LuaFragment$FragmentCreator', {
        onCreateView = function(inflater, container, savedInstanceState)
            return loadlayout(layout, ids)
        end,
        onViewCreated = function(view, savedInstanceState)
            adapter = LuaAdapter(luajava.createProxy("androlua.LuaAdapter$AdapterCreator", {
                getCount = function() return #data.news end,
                getView = function(position, convertView, parent)
                    position = position + 1 -- lua 索引从 1开始
                    if position == #data.news then
                        fetchData(baseUrl, data, adapter, fragment)
                    end
                    if convertView == nil then
                        local views = {} -- store views
                        convertView = loadlayout(item_view, views, ListView)
                        convertView.getLayoutParams().width = parent.getWidth()
                        convertView.setTag(views)
                    end
                    local views = convertView.getTag()
                    local item = data.news[position]
                    if item.imgUrl then
                        views.iv_image.setVisibility(0)
                        LuaImageLoader.load(views.iv_image, item.imgUrl)
                    else views.iv_image.setVisibility(8)
                    end
                    views.tv_title.setText(item.title)
                    views.tv_time.setText(item.time)
                    return convertView
                end
            }))
            ids.listview.setAdapter(adapter)
            ids.listview.setOnItemClickListener(luajava.createProxy("android.widget.AdapterView$OnItemClickListener", {
                onItemClick = function(adapter, view, position, id)
                    launchDetail(fragment, data.news[position + 1])
                end,
            }))
            fetchData(baseUrl, data, adapter, fragment) -- getdata may call ther lua files
        end,
    }))
    return fragment
end

return {
    newInstance = newInstance
}
