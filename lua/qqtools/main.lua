require "import"
import "android.widget.*"
import "android.content.*"
import "android.net.Uri"
import "android.support.v7.widget.Toolbar"
import "android.support.v7.widget.AppCompatSeekBar"
import "android.view.inputmethod.InputMethodManager"
local DialogBuilder = import "android.app.AlertDialog$Builder"
local uihelper = require "uihelper"
-- create view table
local itemHeight = uihelper.getScreenWidth() * 0.16
local itemWidth = uihelper.getScreenWidth() * 0.5
local function doubleButton(leftId, leftText, rightId, rightText)
    return {
        LinearLayout,
        layout_width = "fill",
        {
            FrameLayout,
            layout_width = itemWidth,
            layout_height = itemHeight,
            padding = '8dp',
            {
                ImageView,
                layout_width = "match",
                layout_height = "match",
                scaleType = "centerCrop",
                src = 'http://ww1.sinaimg.cn/large/8c9b876fly1fic6hr2qe9j20ch05mq3q.jpg',
            },
            {
                TextView,
                layout_width = "match",
                layout_height = "match",
                background = '@drawable/layout_selector_tran',
                id = leftId,
                gravity = 'center',
                textColor = '#ffffff',
                text = leftText,
            }
        },
        {
            FrameLayout,
            layout_width = itemWidth,
            layout_height = itemHeight,
            padding = '8dp',
            {
                ImageView,
                scaleType = "centerCrop",
                layout_width = "match",
                layout_height = "match",
                src = 'http://ww1.sinaimg.cn/large/8c9b876fly1fic6i5up5yj20ct0580w6.jpg',
            },
            {
                TextView,
                background = '@drawable/layout_selector_tran',
                layout_width = "match",
                layout_height = "match",
                id = rightId,
                gravity = 'center',
                textColor = '#ffffff',
                text = rightText,
            }
        },
    }
end

local layout = {
    LinearLayout,
    orientation = "vertical",
    layout_width = "fill",
    statusBarColor = '#12B7F5',
    {
        Toolbar,
        background = '#12B7F5',
        id = 'toolbar',
        titleTextColor = '#FFFFFF',
        layout_width = "fill",
        layout_height = "56dp",
    },
    {
        LinearLayout,
        orientation = "vertical",
        padding = "8dp",
        layout_width = "fill",
        doubleButton('qq_chat', 'QQ 强制会话', 'qq_hide_card', 'QQ 隐藏名片'),
        doubleButton('qq_dashang', 'QQ 说说打赏', 'qq_blue_ss', 'QQ 蓝字说说'),
        doubleButton('qq_shuaping', 'QQ 无限刷屏', 'qq_kasi', 'QQ 聊天卡死'),
    },
}

local layout_intput = {
    RelativeLayout,
    layout_width = 'wrap',
    paddingBottom = '8dp',
    paddingRight = '8dp',
    {
        EditText,
        id = 'et',
        layout_margin = '16dp',
        layout_width = 'match',
    },
    {
        Button,
        id = 'tv_ok',
        layout_below = 'et',
        background = '@drawable/layout_selector_tran',
        layout_alignParentRight = true,
        text = '确定',
    },
    {
        Button,
        id = 'tv_cancel',
        layout_below = 'et',
        background = '@drawable/layout_selector_tran',
        layout_toLeftOf = 'tv_ok',
        text = '取消',
    },
}

local function showDialog(title, hint, leftText, rightText, inputType, callback)
    local ids = {}
    local view = loadlayout(layout_intput, ids, ViewGroup)
    local dialog = DialogBuilder(activity).setTitle(title).setView(view).create()
    dialog.show()
    ids.et.setHint(hint or '')
    ids.et.setInputType(inputType or 0x00000001)
    ids.tv_cancel.setText(leftText or '取消')
    ids.tv_ok.setText(rightText or '确定')
    ids.tv_ok.onClick = function()
        dialog.dismiss()
        local text = ids.et.getText().toString()
        callback(text)
    end
    ids.tv_cancel.onClick = function()
        dialog.dismiss()
    end
    ids.et.postDelayed(luajava.createProxy('java.lang.Runnable', {
        run = function()
            activity.getSystemService(Context.INPUT_METHOD_SERVICE).toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS)
        end
    }), 300)
end

local function copyText(text)
    local clipboard = activity.getSystemService(Context.CLIPBOARD_SERVICE)
    local clip = ClipData.newPlainText("氢应用", text)
    clipboard.setPrimaryClip(clip)
    activity.toast('已复制到剪切板')
end

local function installed(package)
    return pcall(function()
        activity.getPackageManager().getPackageInfo(package,0)
    end) 
end

function onCreate(savedInstanceState)
    activity.setStatusBarColor(0xff12B7F5)
    activity.setContentView(loadlayout(layout))
    activity.setSupportActionBar(toolbar)
    activity.setTitle('QQ 工具箱')
    toolbar.setNavigationIcon(LuaDrawable.create('qqtools/qq.png'))
    qq_chat.onClick = function()
        showDialog('QQ 强制会话', '对方 qq 号', '放弃', '会话', 0x00000002, function(text)
            local url = "mqqwpa://im/chat?chat_type=wpa&uin=" .. text
            local intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            if (intent.resolveActivity(activity.getPackageManager())) then
                activity.startActivity(intent)
            else
                activity.toast('找不到 QQ 客户端')
            end
        end)
    end

    qq_dashang.onClick = function()
        showDialog('QQ 说说打赏', '打赏金额', '放弃', '生成并复制', 0x00000002, function(text)
            copyText("[em]e10033[/em]{uin:2742,nick: 打赏了" .. text .. "元红包}")
        end)
    end

    qq_blue_ss.onClick = function()
        showDialog('QQ 蓝字说说', '输入说说内容', nil, '生成并复制', nil, function(text)
            copyText("{uin:0,nick:" .. text .. ",who:1}")
        end)
    end

    qq_hide_card.onClick = function()
        showDialog('QQ 隐藏名片', '输入你的名片', nil, '生成并复制', nil, function(text)
            local t = {}
            for i = 1, #text - 1 do
                t[i] = text:sub(i, i + 1)
            end
            copyText("\020" .. table.concat(t, "\020") .. "\020")
        end)
    end

    qq_shuaping.onClick = function()
        local ids = {}
        local layout = {
            LinearLayout,
            layout_width = 'match',
            padding = '12dp',
            {
                AppCompatSeekBar,
                max = 100,
                id = 'progress',
                layout_weight = 1,
            },
            {
                TextView,
                id = 'tv_progress',
                layout_width = '20dp',
                textSize = '12sp',
            }
        }
        local view = loadlayout(layout, ids, ViewGroup)
        ids.progress.setOnSeekBarChangeListener(luajava.createProxy('android.widget.SeekBar$OnSeekBarChangeListener', {
            onProgressChanged = function(seekBar, p, fromUser)
                ids.tv_progress.setText(p .. '')
            end
        }))
        ids.progress.setProgress(50)
        DialogBuilder(activity).setTitle('设置刷屏强度').setView(view).setNegativeButton('取消', nil).setPositiveButton('确定', luajava.createProxy('android.content.DialogInterface$OnClickListener', {
            onClick = function(dialog, which)
                local p = ids.progress.getProgress()
                local text = ''
                for i = 1, p do text = text .. '\n\n\n\n\n\n\n\n\n\n' end
                local qqIntent = Intent(Intent.ACTION_SEND)
                local package = "com.tencent.mobileqq"
                if installed("com.tencent.tim") then package = "com.tencent.tim" end
                qqIntent.setClassName(package, "com.tencent.mobileqq.activity.JumpActivity")
                qqIntent.setType("text/plain")
                qqIntent.putExtra(Intent.EXTRA_TEXT, text)
                if qqIntent.resolveActivity(activity.getPackageManager()) then
                        activity.startActivity(qqIntent)
                else
                    activity.toast('找不到 QQ 客户端')
                end
            end
        })).show()
    end
    qq_kasi.onClick = function()
        local ids = {}
        local layout = {
            LinearLayout,
            layout_width = 'match',
            padding = '12dp',
            {
                AppCompatSeekBar,
                max = 15,
                id = 'progress',
                layout_weight = 1,
            },
            {
                TextView,
                id = 'tv_progress',
                layout_width = '20dp',
                textSize = '12sp',
            }
        }
        local view = loadlayout(layout, ids, ViewGroup)
        ids.progress.setOnSeekBarChangeListener(luajava.createProxy('android.widget.SeekBar$OnSeekBarChangeListener', {
            onProgressChanged = function(seekBar, p, fromUser)
                ids.tv_progress.setText(p .. '')
            end
        }))
        ids.progress.setProgress(8)
        DialogBuilder(activity).setTitle('设置卡死强度').setView(view).setNegativeButton('取消', nil).setPositiveButton('确定', luajava.createProxy('android.content.DialogInterface$OnClickListener', {
            onClick = function(dialog, which)
                local p = ids.progress.getProgress()
                local text = ''
                for i = 1, p do text = text .. "\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\195\186\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\n\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\195\186\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\n\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\195\186\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\n\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\195\186\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\n\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\n\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170\020\194\170" end
                local qqIntent = Intent(Intent.ACTION_SEND)
                local package = "com.tencent.mobileqq"
                if installed("com.tencent.tim") then package = "com.tencent.tim" end
                qqIntent.setClassName(package, "com.tencent.mobileqq.activity.JumpActivity")
                qqIntent.setType("text/plain")
                qqIntent.putExtra(Intent.EXTRA_TEXT, text)
                if qqIntent.resolveActivity(activity.getPackageManager()) then
                        activity.startActivity(qqIntent)
                else
                    activity.toast('找不到 QQ 客户端')
                end
            end
        })).show()
    end
end

