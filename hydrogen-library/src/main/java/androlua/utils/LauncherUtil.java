package androlua.utils;


import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ProviderInfo;
import android.content.pm.ResolveInfo;
import android.text.TextUtils;

public class LauncherUtil {
    public static final String READ_SETTINGS = "READ_SETTINGS";
    public static final String WRITE_SETTINGS = "WRITE_SETTINGS";

    private LauncherUtil() {
    }

    public static String getDefaultLauncher(Context context) {
        try {
            Intent intent = new Intent("android.intent.action.MAIN");
            intent.addCategory("android.intent.category.HOME");
            ResolveInfo resolveActivity = context.getPackageManager().resolveActivity(intent, 0);
            if (resolveActivity.activityInfo.packageName.equals("android")) {
                return null;
            }
            return resolveActivity.activityInfo.packageName;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static String getAuthorityFromPermission(Context context, String str) {
        String str2 = null;
        if (!(TextUtils.isEmpty(str) || context == null)) {
            String defaultLauncher = getDefaultLauncher(context);
            if (!TextUtils.isEmpty(defaultLauncher)) {
                try {
                    PackageInfo packageInfo = context.getPackageManager().getPackageInfo(defaultLauncher, PackageManager.GET_PROVIDERS);
                    if (packageInfo != null) {
                        ProviderInfo[] providerInfoArr = packageInfo.providers;
                        if (providerInfoArr != null) {
                            for (ProviderInfo providerInfo : providerInfoArr) {
                                if ((!TextUtils.isEmpty(providerInfo.readPermission) && providerInfo.readPermission.contains(str)) || (!TextUtils.isEmpty(providerInfo.writePermission) && providerInfo.writePermission.contains(str))) {
                                    str2 = providerInfo.authority;
                                    break;
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return str2;
    }
}