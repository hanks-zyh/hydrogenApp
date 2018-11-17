package pub.hanks.sample;

import org.junit.Test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import androlua.common.LuaFileUtils;

import static java.util.zip.Deflater.BEST_COMPRESSION;

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * @see <byteToString href="http://d.android.com/tools/testing">Testing documentation</byteToString>
 */
public class ExampleUnitTest {

    class A{
        
    }
    
    class Aa extends A{
        
    }
    @Test
    public void testRun(){
        A a = new Aa();
        System.out.println("a.getClass() = " + a.getClass());
    }

    public static void execCMD(String command) {
        try {
            Process child = Runtime.getRuntime().exec(command);
            InputStreamReader isr = new InputStreamReader(child.getInputStream());
            BufferedReader buff = new BufferedReader(isr);

            String line;
            while ((line = buff.readLine()) != null)
                System.out.print(line);

            InputStreamReader is2 = new InputStreamReader(child.getErrorStream());
            BufferedReader buff2 = new BufferedReader(is2);

            String line2;
            while ((line2 = buff2.readLine()) != null)
                System.out.println(line2);


        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void zip(ZipOutputStream zOut, File file, String base) {
        try {

            // 如果文件句柄是目录
            if (file.isDirectory()) {
                //获取目录下的文件
                File[] listFiles = file.listFiles();
                // 建立ZIP条目
                zOut.putNextEntry(new ZipEntry(base + "/"));
                base = (base.length() == 0 ? "" : base + "/");
                // 遍历目录下文件
                for (int i = 0; i < listFiles.length; i++) {
                    // 递归进入本方法
                    zip(zOut, listFiles[i], base + listFiles[i].getName());
                }
            }
            // 如果文件句柄是文件
            else {
                if ("".equals(base)) {
                    base = file.getName();
                }
                // 填入文件句柄
                zOut.putNextEntry(new ZipEntry(base));
                // 开始压缩
                // 从文件入流读,写入ZIP 出流
                writeFile(zOut, file);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public static void writeFile(ZipOutputStream zOut, File file) throws IOException {
        FileInputStream in = new FileInputStream(file);
        int len;
        while ((len = in.read()) != -1)
            zOut.write(len);
        in.close();
    }

    @Test
    public void addition_isCorrect() throws Exception {
        LuaFileUtils.unzip("D:\\Desktop\\91pic-o.zip", "D:\\Desktop");
    }

    @Test
    public void unZipPlugin() throws Exception {
        String zipDir = "D:\\work\\opensource\\api_luanroid\\plugin\\eyepetizer.zip";
        LuaFileUtils.unzip(zipDir, "D:\\Desktop");
    }

    @Test
    public void testCommand() throws Exception {
        String command = "node D:\\work\\opensource\\LuaJAndroid\\script\\node\\watch\\update_plugin_info.js";
        execCMD(command);
    }

    // 执行生成插件压缩文件
    @Test
    public void zipPlugin() throws Exception {

        String compileLua = "nodejs /home/hanks/work/opensource/LuaJAndroid/script/node/watch/exec_luac.js";
        String root = "/home/hanks/work/opensource/api_luanroid/lua";
        String outDir = "/home/hanks/work/opensource/api_luanroid/plugin";
        String updateJSON = "nodejs /home/hanks/work/opensource/LuaJAndroid/script/node/watch/update_plugin_info.js";
        String OS = System.getProperty("os.name").toLowerCase();
        if (OS.contains("windows")){
            compileLua = "node D:\\work\\opensource\\LuaJAndroid\\script\\node\\watch\\exec_luac.js";
            root = "D:\\work\\opensource\\api_luanroid\\lua";
            outDir = "D:\\work\\opensource\\api_luanroid\\plugin";
            updateJSON = "node D:\\work\\opensource\\LuaJAndroid\\script\\node\\watch\\update_plugin_info.js";
        }

        execCMD(compileLua);

        File[] files = new File(root).listFiles();
        for (File file : files) {
            if (!file.isDirectory()) {
                continue;
            }
            File[] childFiles = file.listFiles();
            boolean isPlugin = false;
            for (File childFile : childFiles) {
                if (childFile.getName().equals("info.json")) {
                    isPlugin = true;
                    break;
                }
            }
            if (isPlugin) {
                //创建文件输出对象out,提示:注意中文支持
                FileOutputStream out = new FileOutputStream(outDir + File.separator + file.getName() + ".zip");
                //將文件輸出ZIP输出流接起来
                ZipOutputStream zos = new ZipOutputStream(out);
                zos.setLevel(BEST_COMPRESSION);
                zip(zos, file.getAbsoluteFile(), file.getName());
                zos.flush();
                zos.close();
            }
        }

        execCMD(updateJSON);
    }

}