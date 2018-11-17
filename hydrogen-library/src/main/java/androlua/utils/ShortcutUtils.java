package androlua.utils;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.text.TextUtils;

import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.ThreadPoolExecutor;

public class ShortcutUtils {

    private static final String ACTION_INSTALL_SHORTCUT = "com.android.launcher.action.INSTALL_SHORTCUT";
    private static final String ACTION_UNINSTALL_SHORTCUT = "com.android.launcher.action.UNINSTALL_SHORTCUT";
    private static final String KEY_DUPLICATE = "duplicate";
    private static final int POOL_SIZE = 3;
    private static final String TAG = "ShortcutUtil";
    private static ThreadPoolExecutor EXECUTOR = null;

    static {
        EXECUTOR = new ScheduledThreadPoolExecutor(POOL_SIZE);
    }

    private ShortcutUtils() {
    }

    public static void installShortcut(Context context, String str, int i, Intent intent) {
        installShortcut(context, str, i, intent, null);
    }

    public static void installShortcut(final Context context, final String str, final int i, final Intent intent, final ActionListener actionListener) {
        EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                addShortcut(context, str, i, intent);
                if (actionListener != null) {
                    actionListener.onSuccess();
                }
            }
        });
    }

    public static void installShortcut(Context context, String str, Bitmap bm,  Intent intent) {
        installShortcut(context, str, bm, intent, null);
    }

    public static void installShortcut(final Context context, final String str, final Bitmap bm, final Intent intent, final ActionListener actionListener) {
        EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                addShortcut(context, str, bm,  intent);
                if (actionListener != null) {
                    actionListener.onSuccess();
                }
            }
        });
    }

    public static void uninstallShortcut(Context context, String str, Intent intent) {
        uninstallShortcut(context, str, intent, null);
    }

    public static void uninstallShortcut(final Context context, final String str, final Intent intent, final ActionListener actionListener) {
        EXECUTOR.execute(new Runnable() {
            @Override
            public void run() {
                removeShortcut(context, str, intent);
                if (actionListener != null) {
                    actionListener.onSuccess();
                }
            }
        });
    }

    private static boolean addShortcut(Context context, String str, int i, Intent intent) {
        intent.setAction("android.intent.action.MAIN");
        intent.addFlags(65536);
        Intent intent2 = new Intent(ACTION_INSTALL_SHORTCUT);
        intent2.putExtra("android.intent.extra.shortcut.INTENT", intent);
        intent2.putExtra("android.intent.extra.shortcut.NAME", str);
        intent2.putExtra("android.intent.extra.shortcut.ICON", BitmapFactory.decodeResource(context.getResources(), i));
        intent2.putExtra("android.intent.extra.shortcut.ICON_RESOURCE", Intent.ShortcutIconResource.fromContext(context, i));
        intent2.putExtra(KEY_DUPLICATE, false);
        context.sendBroadcast(intent2);
        return true;
    }

    private static boolean addShortcut(Context context, String str, Bitmap bm,  Intent intent) {
        intent.setAction("android.intent.action.MAIN");
        intent.addFlags(65536);
        Intent intent2 = new Intent(ACTION_INSTALL_SHORTCUT);
        intent2.putExtra("android.intent.extra.shortcut.INTENT", intent);
        intent2.putExtra("android.intent.extra.shortcut.NAME", str);
        intent2.putExtra("android.intent.extra.shortcut.ICON", bm);
        intent2.putExtra(KEY_DUPLICATE, false);
        context.sendBroadcast(intent2);
        return true;
    }

    private static void removeShortcut(Context context, String str, Intent intent) {
        intent.setAction("android.intent.action.MAIN");
        Intent intent2 = new Intent(ACTION_UNINSTALL_SHORTCUT);
        intent2.putExtra("android.intent.extra.shortcut.INTENT", intent);
        intent2.putExtra("android.intent.extra.shortcut.NAME", str);
        context.sendBroadcast(intent2);
    }

    public static boolean hasShortcut(Context context, String str) {
        boolean z = false;
        Exception e;
        Throwable th;
        Cursor cursor = null;
        if (TextUtils.isEmpty(str)) {
            return false;
        }
        String authorityFromPermission = LauncherUtil.getAuthorityFromPermission(context, LauncherUtil.READ_SETTINGS);
        if (TextUtils.isEmpty(authorityFromPermission)) {
            return false;
        }
        Cursor query;
        try {
            query = context.getContentResolver().query(Uri.parse("content://" + authorityFromPermission + "/favorites?notify=true"), null, "title=?", new String[]{str}, null);
            if (query != null) {
                try {
                    if (query.getCount() > 0) {
                        z = true;
                        if (query != null) {
                            query.close();
                        }
                        return z;
                    }
                } catch (Exception e2) {
                    e = e2;
                    try {
                        e.printStackTrace();
                        if (query == null) {
                            query.close();
                            z = false;
                        } else {
                            z = false;
                        }
                        return z;
                    } catch (Throwable th2) {
                        th = th2;
                        cursor = query;
                        if (cursor != null) {
                            cursor.close();
                        }
                        throw th;
                    }
                }
            }
            z = false;
            if (query != null) {
                query.close();
            }
        } catch (Exception e3) {
            e = e3;
            query = null;
            e.printStackTrace();
            if (query == null) {
                z = false;
            } else {
                query.close();
                z = false;
            }
            return z;
        } catch (Throwable th3) {
            th = th3;
            if (cursor != null) {
                cursor.close();
            }
        }
        return z;
    }

    public interface ActionListener {
        void onFailure(int i);

        void onSuccess();
    }
}