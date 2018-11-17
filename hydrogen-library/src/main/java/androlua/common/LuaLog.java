package androlua.common;

import android.util.Log;

import androlua.LuaManager;


/**
 * LuaLog
 * Created by hanks on 2016/11/19.
 */

public class LuaLog {
    private static final String TAG = "LLogs";

    public static boolean showLog() {
        return LuaManager.getInstance().isDebugable();
    }

    public static void i(String s) {
        if (showLog()) {
            Log.i(TAG, s == null ? "null" : s);
        }
    }

    public static void w(String s) {
        if (showLog()) {
            Log.w(TAG, s == null ? "null" : s);
        }
    }

    public static void d(String s) {
        if (showLog()) {
            Log.d(TAG, s == null ? "null" : s);
        }
    }

    public static void e(String s) {
        if (showLog()) {
            Log.e(TAG, s == null ? "null" : s);
        }
    }

    public static void e(Throwable e) {
        if (showLog() && e != null) {
            e.printStackTrace();
        }
    }
}
