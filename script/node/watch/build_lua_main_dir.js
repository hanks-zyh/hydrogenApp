// 功能： 编译 lua

var fs = require('fs');
var path = require('path');
var shelljs = require('shelljs/global');
const os = require('os');


var buildfilePath = '/home/hanks/work/opensource/LuaJAndroid/script/lua/buildfile.lua'

if (os.platform() == 'win32') {
    buildfilePath = "D:\\work\\opensource\\LuaJAndroid\\script\\lua\\buildfile.lua";
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
    buildDir("D:\\work\\opensource\\LuaJAndroid\\lua_main","D:\\work\\opensource\\LuaJAndroid\\sample\\src\\main\\assets\\lua")
}else{
    buildDir("/home/hanks/work/opensource/LuaJAndroid/lua_main","/home/hanks/work/opensource/LuaJAndroid/sample/src/main/assets/lua")
}
