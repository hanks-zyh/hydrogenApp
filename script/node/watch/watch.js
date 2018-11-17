var chokidar = require('chokidar');
var shelljs = require('shelljs');
const os = require('os');
var fs = require('fs');
var path = require('path');

var watchDir = '/Users/zhanks/work/opensource/LuajAndroid/lua';
var pushDir = '/Users/zhanks/work/opensource/LuajAndroid/lua/*'
if (os.platform() == 'win32') {
  watchDir = 'D:\\work\\opensource\\LuaJAndroid\\lua';
  pushDir = 'D:\\work\\opensource\\LuaJAndroid\\lua';
}
console.log(watchDir);

function pushFiles(changedFile) {
	var pushPath = pushDir
	var parent = path.dirname(changedFile);
	var i=0;
	var folderName = ''
	while (parent != watchDir && path.dirname(parent) != watchDir){
		parent =  path.dirname(parent);
		if(++i > 5){
			break;
		}
	}
	pushPath = parent;
	folderName = path.basename(parent);

	var cmd = 'adb push ' + pushPath + '  /sdcard/Android/data/pub.hanks.sample/files/LLLLLua/' + folderName 
	console.log(cmd)
	shelljs.exec(cmd);
}

chokidar.watch(watchDir)
	.on('add', changedFile=>{
		//pushFiles(changedFile)
	})
	.on('change', changedFile =>{
		pushFiles(changedFile)
	});
