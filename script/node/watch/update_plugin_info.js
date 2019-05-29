var fs = require('fs');
var path = require('path');
var archiver = require('archiver');
const os = require('os');

var root = "/home/hanks/work/opensource/hydrogenApp/lua";
var apiFile = "/home/hanks/work/opensource/api_luanroid/api/plugins";

if (os.platform() == 'win32') {
      root = "D:\\work\\opensource\\hydrogenApp\\lua";
      apiFile = "D:\\work\\opensource\\api_luanroid\\api\\plugins";
}

var res = {data:[]};

var plugins = fs.readdirSync(root);
for (var j = 0; j < plugins.length; j++) {
    var pluginDir = path.join(root,plugins[j]);
    var files = fs.readdirSync(pluginDir);
    for (var i = 0; i < files.length; i++) {
       if(files[i] != 'info.json') continue;
       var text = fs.readFileSync(path.join(pluginDir,files[i]),'utf8');
       var json = JSON.parse(text);
       if (json.private && json.private == true){
            continue;
       }
       json.download = 'https://coding.net/u/zhangyuhan/p/api_luanroid/git/raw/master/plugin/' + plugins[j] + '.zip';
       res.data.push(json);
    }
}
// 生成 json
var apiData = JSON.stringify(res);
console.log(apiData);
fs.writeFileSync(apiFile,apiData,'utf8');

