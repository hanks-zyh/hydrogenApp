// 功能： 编译 lua

var fs = require('fs');
var path = require('path');
var shelljs = require('shelljs/global');
const os = require('os');


var buildfilePath = '/home/hanks/work/opensource/hydrogenApp/script/lua/buildfile.lua'

if (os.platform() == 'win32') {
    buildfilePath = "D:\\work\\opensource\\hydrogenApp\\script\\lua\\buildfile.lua";
}

function build(file){
  var stats = fs.statSync(file);
  if(stats.isDirectory()){
    fs.readdir(file, function (err, plugins) {
      plugins.forEach(function (p) {
        build(path.join(file,p))
      });
    });
  }else {

    if(!file.endsWith('.lua')) return;
    var dir = path.dirname('file');
    cd(dir)
    var outPath = file + 'c'
    var cmd = 'lua ' +buildfilePath + ' ' + file  + ' ' + outPath;
    console.log(cmd);
    exec(cmd);
    rm(file)
    mv(outPath, file)
    console.log('-----');
  }
}
function buildDir(sourceDir,pluginRoot){
  rm('-rf', pluginRoot);
  cp('-R', sourceDir, pluginRoot);
  build(pluginRoot);
}

if (os.platform() == 'win32') {
    buildDir("D:\\work\\opensource\\hydrogenApp\\lua_main","D:\\work\\opensource\\hydrogenApp\\sample\\src\\main\\assets\\lua")
    buildDir("D:\\work\\opensource\\hydrogenApp\\lua","D:\\work\\opensource\\api_luanroid\\lua")
}else{
    buildDir("/home/hanks/work/opensource/hydrogenApp/lua_main","/home/hanks/work/opensource/hydrogenApp/sample/src/main/assets/lua")
    buildDir("/home/hanks/work/opensource/hydrogenApp/lua","/home/hanks/work/opensource/api_luanroid/lua")
}
