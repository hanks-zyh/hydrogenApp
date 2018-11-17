package androlua.common;

import android.widget.Toast;

import androlua.LuaManager;

/**
 * Created by hanks on 2017/6/19.
 */

public class LuaToast {
    public static void show(String s) {
        Toast.makeText(LuaManager.getInstance().getContext(), s, Toast.LENGTH_SHORT).show();
    }
}
