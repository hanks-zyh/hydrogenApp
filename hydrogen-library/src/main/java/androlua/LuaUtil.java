package androlua;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.WindowManager;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import androlua.common.LuaStringUtils;

public class LuaUtil {


    /**
     * 截屏
     *
     * @param activity
     * @return
     */
    public static Bitmap captureScreen(Activity activity) {
        // 获取屏幕大小：
        DisplayMetrics metrics = new DisplayMetrics();
        WindowManager WM = (WindowManager) activity
                .getSystemService(Context.WINDOW_SERVICE);
        Display display = WM.getDefaultDisplay();
        display.getMetrics(metrics);
        int height = metrics.heightPixels; // 屏幕高
        int width = metrics.widthPixels; // 屏幕的宽
        // 获取显示方式
        int pixelformat = display.getPixelFormat();
        PixelFormat localPixelFormat1 = new PixelFormat();
        PixelFormat.getPixelFormatInfo(pixelformat, localPixelFormat1);
        int deepth = localPixelFormat1.bytesPerPixel;// 位深
        byte[] piex = new byte[height * width * deepth];
        try {
            Runtime.getRuntime().exec(
                    new String[]{"/system/bin/su", "-c",
                            "chmod 777 /dev/graphics/fb0"});
        } catch (IOException e) {
            e.printStackTrace();
        }
        try {
            // 获取fb0数据输入流
            InputStream stream = new FileInputStream(new File(
                    "/dev/graphics/fb0"));
            DataInputStream dStream = new DataInputStream(stream);
            dStream.readFully(piex);
        } catch (Exception e) {
            e.printStackTrace();
        }
        // 保存图片
        int[] colors = new int[height * width];
        for (int m = 0; m < colors.length; m++) {
            int r = (piex[m * 4] & 0xFF);
            int g = (piex[m * 4 + 1] & 0xFF);
            int b = (piex[m * 4 + 2] & 0xFF);
            int a = (piex[m * 4 + 3] & 0xFF);
            colors[m] = (a << 24) + (r << 16) + (g << 8) + b;
        }
        // piex生成Bitmap
        Bitmap bitmap = Bitmap.createBitmap(colors, width, height,
                Bitmap.Config.ARGB_8888);
        return bitmap;
    }

    public static byte[] readAsset(Context context, String name) throws IOException {
        AssetManager am = context.getAssets();
        InputStream is = am.open(name);
        byte[] ret = readAll(is);
        is.close();
        //am.close();
        return ret;
    }

    //读取asset文件

    private static byte[] readAll(InputStream input) throws IOException {
        ByteArrayOutputStream output = new ByteArrayOutputStream(4096);
        byte[] buffer = new byte[4096];
        int n = 0;
        while (-1 != (n = input.read(buffer))) {
            output.write(buffer, 0, n);
        }
        byte[] ret = output.toByteArray();
        output.close();
        return ret;
    }

    //复制asset文件到sd卡
    public static void assetsToSD(Context context, String InFileName, String OutFileName) throws IOException {
        InputStream myInput;
        OutputStream myOutput = new FileOutputStream(OutFileName);
        myInput = context.getAssets().open(InFileName);
        byte[] buffer = new byte[8192];
        int length = myInput.read(buffer);
        while (length > 0) {
            myOutput.write(buffer, 0, length);
            length = myInput.read(buffer);
        }

        myOutput.flush();
        myInput.close();
        myOutput.close();
    }

    public static void copyFile(String oldPath, String newPath) {
        try {
            int bytesum = 0;
            int byteread = 0;
            File oldfile = new File(oldPath);
            if (oldfile.exists()) { //文件存在时
                InputStream inStream = new FileInputStream(oldPath); //读入原文件
                FileOutputStream fs = new FileOutputStream(newPath);
                byte[] buffer = new byte[4096];
                int length;
                while ((byteread = inStream.read(buffer)) != -1) {
                    bytesum += byteread; //字节数 文件大小
                    System.out.println(bytesum);
                    fs.write(buffer, 0, byteread);
                }
                inStream.close();
            }
        } catch (Exception e) {
            System.out.println("复制文件操作出错");
            e.printStackTrace();

        }

    }

    public static void rmDir(File dir) {
        File[] fs = dir.listFiles();
        for (File f : fs) {
            if (f.isDirectory())
                rmDir(f);
            else
                f.delete();
        }
        dir.delete();
    }

    public static void rmDir(File dir, String ext) {
        File[] fs = dir.listFiles();
        for (File f : fs) {
            if (f.isDirectory())
                rmDir(f);
            else if (f.getName().endsWith(ext))
                f.delete();
        }
        //dir.delete();
    }

    public static Context getContext() {
        return LuaManager.getInstance().getContext();
    }

    public static float getDensity() {
        return getContext().getResources().getDisplayMetrics().density;
    }

    public static int dp2px(float dp) {
        float density = getContext().getResources().getDisplayMetrics().density;
        return (int) (0.5F + dp * density);
    }

    public static int getScreenWidth() {
        return getContext().getResources().getDisplayMetrics().widthPixels;
    }

    protected int getStatusBarHeight() {
        int identifier = getContext().getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (identifier > 0) {
            return getContext().getResources().getDimensionPixelSize(identifier);
        }
        return 0;
    }

    public static class IntentHelper {
        public static String getLuaPath(Intent intent) {
            String luaPath = intent.getStringExtra("luaPath");
            return LuaStringUtils.isEmpty(luaPath) ? "main.lua" : luaPath;

        }

        public static Object[] getArgs(Intent intent) {
            Object[] arg = (Object[]) intent.getSerializableExtra("arg");
            if (arg == null)
                arg = new Object[0];
            return arg;
        }
    }

    public static boolean isWifi(){
        ConnectivityManager cm =
                (ConnectivityManager)getContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        return activeNetwork != null &&
                activeNetwork.isConnectedOrConnecting() && activeNetwork.getType() == ConnectivityManager.TYPE_WIFI;
    }

}
