# hydrogenApp

hydrogen is a **pluggable** android app, use `Lua` develop android, minSdkVersion="15", lua 5.3
plugin wrote by `lua` program language

[APK Download](https://www.coolapk.com/apk/pub.hydrogen.android)

<img src="http://ww1.sinaimg.cn/large/8c9b876fly1fxadl4x1lfj20780780sk.jpg"/>

## App Plugin

![](http://image.coolapk.com/apk_image/2017/0706/1-for-148937-o_1bkb0ue7m16mp165il5srd41ei815-uid-518407.jpg.t.jpg)
![](http://image.coolapk.com/apk_image/2017/0706/2-for-148937-o_1bkb0ue7n1h1p1ke3ssuj4q1dab16-uid-518407.jpg.t.jpg)
![](http://image.coolapk.com/apk_image/2017/0706/3-for-148937-o_1bkb0ue7n1sn1nc01k8b17bk3h017-uid-518407.jpg.t.jpg)
![](http://image.coolapk.com/apk_image/2017/0706/4-for-148937-o_1bkb0ue7natj1uk010qm1kbgdq218-uid-518407.jpg.t.jpg)
![](http://image.coolapk.com/apk_image/2017/0901/S70901-173605-for-148937-o_1boucs1494kp1qo81qul1656ei9q-uid-518407.jpg.t.jpg)
![](http://image.coolapk.com/apk_image/2017/0901/S70901-173626-for-148937-o_1boucsbvrkcu1omqrte5d8amc10-uid-518407.jpg.t.jpg)
![](http://image.coolapk.com/apk_image/2017/0901/S70901-173652-for-148937-o_1boucsgnk6rlsvn1j9f1q8177n16-uid-518407.jpg.t.jpg)
![](http://image.coolapk.com/apk_image/2017/0901/S70901-173716-for-148937-o_1boucsl56mdt10am1vgsqs099m1c-uid-518407.jpg.t.jpg)


## 项目结构

宿主：`sample`  
宿主用到的 lua 文件： `lua_main`  

插件目录：`lua`  
脚本：script  


### 插件开发步骤

插件目录：lua  
插件包含文件 `info.json` `main.lua`

```
{
  "id": "pub.hanks.gacha",
  "name": "网易插画",
  "icon": "http://ww1.sinaimg.cn/large/8c9b876fly1fhaaa8qcofj2046046we9.jpg",
  "main": "main.lua",
  "versionName": "1.0",
  "versionCode": 1,
  "desc": "网易每日插画排行"
}

id: 插件唯一标识符号
name: 插件名称
icon: 插件图标
main: 插件启动文件
versionName: 插件版本名称
versionVersion: 插件版本号
desc: 插件描述
```

### 插件发布

插件生成目录 api_luanroid, 执行 java 单元测试 `zipPlugin`， 该方法会打包好插件并更新获取插件的 api, 成功后，然后 push 到线上

[lua语法](http://www.runoob.com/lua/lua-basic-syntax.html)
[lua的手册](https://cloudwu.github.io/lua53doc/manual.html)

```

require "import"
import "android.widget.*"
import "android.view.*"
import "android.app.*"
import "android.net.*"
import "android.content.*"

```


### 更新每日壁纸

https://coding.net/u/zhangyuhan/p/api_luanroid/git/blob/master/api/splash

### 版本更新

https://coding.net/u/zhangyuhan/p/api_luanroid/git/blob/master/api/update


## 插件开发

请看[插件开发指南](https://github.com/hanks-zyh/hydrogenApp/blob/master/PluginDev.md)，更多的功能使用可以参考已有的[插件列表](https://github.com/hanks-zyh/hydrogenApp/tree/master/lua)，目录为 lua 目录


