package pub.hanks.sample;

import android.app.Application;
import com.tencent.bugly.Bugly;
import com.tencent.bugly.beta.Beta;

import androlua.LuaManager;
import pub.hydrogen.android.R;

/**
 * Created by hanks on 2017/5/16. Copyright (C) 2017 Hanks
 */

public class App extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        LuaManager.getInstance().init(this);
        initBugly();
    }

    public void initBugly() {
        Beta.upgradeDialogLayoutId = R.layout.upgrade_dialog;
        Bugly.init(getApplicationContext(), "4bd5f2ea3e", false);
    }
}
