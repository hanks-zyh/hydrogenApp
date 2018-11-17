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
import "android.support.v7.widget.RecyclerView"
import "androlua.adapter.LuaRecyclerAdapter"
import "androlua.adapter.LuaRecyclerHolder"
import "android.support.v7.widget.LinearLayoutManager"
import "android.view.inputmethod.InputMethodManager"
import "android.support.v4.widget.Space"

local JSON = require("cjson")
local uihelper = require('uihelper')
local log = require('log')

-- create view table
local layout = {
    LinearLayout,
    layout_width = "fill",
    layout_height = "fill",
    orientation = "vertical",
    {
        LinearLayout,
        layout_width = "fill",
        layout_height = "48dp",
        orientation = "horizontal",
        layout_marginTop = "48dp",
        layout_marginLeft = "16dp",
        layout_marginRight = "16dp",
        background = "#FFFFFF",
        elevation = "2dp",
        {
            EditText,
            layout_height = "fill",
            layout_weight = 1,
            paddingLeft = "12sp",
            gravity = "center_vertical",
            id = "et_keyword",
            singleLine = true,
            textSize = "14sp",
            textColor = "#888888",
            background = "#00FFFFFF",
        },
        {
            Button,
            background = '#0090ff',
            id = "tv_search",
            textColor = '#ffffff',
            layout_width = "48dp",
            layout_height = "48dp",
            text = "G",
        },
    },
    {
        ScrollView,
        layout_width = "fill",
        padding = "16dp",
        clipToPadding = false,
        {
            LinearLayout,
            id = "layout_content",
            layout_width = "fill",
            layout_height = "fill",
            orientation = "vertical",
        }
    }
}

local adapter

local function unicode_to_utf8(convertStr)
    for a in string.gmatch(convertStr, '\\u([0-9a-z][0-9a-z][0-9a-z][0-9a-z])') do
        if #a == 4 then
            local n = tonumber(a, 16)
            assert(n, "String decoding failed: bad Unicode escape " .. a)
            local x
            if n < 0x80 then
                x = string.char(n % 0x80)
            elseif n < 0x800 then
                x = string.char(0xC0 + (math.floor(n / 64) % 0x20), 0x80 + (n % 0x40))
            else
                x = string.char(0xE0 + (math.floor(n / 4096) % 0x10), 0x80 + (math.floor(n / 64) % 0x40), 0x80 + (n % 0x40))
            end
            convertStr = string.gsub(convertStr, '\\u' .. a, x)
        end
    end
    return convertStr
end

local function text(text, size, color)
    return {
        TextView,
        background = "@drawable/layout_selector_tran",
        layout_width = "fill",
        paddingTop = "16dp",
        paddingTop = "8dp",
        textIsSelectable = true,
        gravity = "center_vertical",
        text = text,
        textSize = size,
        textColor = color,
    }
end

local function text_lr(textLeft, textRight)
    return {
        LinearLayout,
        layout_width = "fill",
        paddingTop = "8dp",
        orientation = "horizontal",
        {
            TextView,
            layout_width = "30dp",
            text = textLeft,
            textIsSelectable = true,
            textSize = '15sp',
            textColor = '#888888',
        },
        {
            TextView,
            layout_width = "fill",
            textIsSelectable = true,
            lineSpacingMultiplier = 1.3,
            text = textRight,
            textSize = '14sp',
            textColor = '#222222',
        },
    }
end

local function text_tb(textTop, textBottom)
    return {
        LinearLayout,
        layout_width = "fill",
        paddingTop = "8dp",
        orientation = "vertical",
        {
            TextView,
            layout_width = "fill",
            text = textTop,
            textSize = '13sp',
            lineSpacingMultiplier = 1.3,
            textIsSelectable = true,
            textColor = '#222222',
        },
        {
            TextView,
            layout_width = "fill",
            layout_marginTop = "8dp",
            text = textBottom,
            textSize = '12sp',
            textColor = '#888888',
            textIsSelectable = true,
            lineSpacingMultiplier = 1.3,
        },
    }
end

local function fillData(json)
    log.print_r(json)
    layout_content.removeAllViews()
    local symbol = json.baesInfo.symbols[1]
    if symbol then
        layout_content.addView(loadlayout(text('基本释义', '16sp', '#0090ff')))

        local ph = {}
        if symbol.ph_en then ph[#ph + 1] = '英[' .. symbol.ph_en .. ']' end
        if symbol.ph_am then ph[#ph + 1] = '美[' .. symbol.ph_am .. ']' end
        layout_content.addView(loadlayout(text(table.concat(ph, '  '), '14sp', '#222222')))
        for _, part in ipairs(symbol.parts) do
            layout_content.addView(loadlayout(text_lr(part.part, table.concat(part.means, '\n'))))
        end
    end

    local sentence = json.sentence
    if #sentence > 0 then
        layout_content.addView(loadlayout(text('双语例句', '16sp', '#0090ff')))
        for _, se in ipairs(sentence) do
            layout_content.addView(loadlayout(text_tb(se.Network_en, se.Network_cn)))
        end
    end

    local netmean = json.netmean
    log.print_r(netmean)
    if netmean then
        layout_content.addView(loadlayout(text('网络释义', '16sp', '#0090ff')))
        if #netmean.PerfectNetExp > 0 then
            layout_content.addView(loadlayout(text('常用词语', '14sp', '#666666')))
            for i, se in ipairs(netmean.PerfectNetExp) do
                layout_content.addView(loadlayout(text_tb(se.exp, se.abs)))
            end
        end
        if #netmean.RelatedPhrase > 0 then
            layout_content.addView(loadlayout(text('相关词条', '14sp', '#666666')))
            for i, se in ipairs(netmean.RelatedPhrase) do
                layout_content.addView(loadlayout(text_tb(se.word .. ' ' .. se.list[1].exp, se.list[1].abs)))
            end
        end
    end
end

local function search(keyword)
    local url = string.format('http://www.iciba.com/index.php?a=getWordMean&c=search&list=1,3,4,8,9,12,13,15&word=%s&_=%d&callback=jsonp1', keyword, os.time() * 1000)
    local options = { url = url }
    LuaHttp.request(options, function(e, code, body)
        uihelper.runOnUiThread(activity, function()
            local json = JSON.decode(unicode_to_utf8(body:sub(8, #body - 1)))
            fillData(json)
        end)
    end)
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0x33000000)
    activity.setContentView(loadlayout(layout))
    tv_search.onClick = function(view)
        local imm = activity.getSystemService(Context.INPUT_METHOD_SERVICE)
        imm.hideSoftInputFromWindow(tv_search.getWindowToken(), 0)
        local keyword = et_keyword.getText().toString()
        search(keyword)
    end
end
