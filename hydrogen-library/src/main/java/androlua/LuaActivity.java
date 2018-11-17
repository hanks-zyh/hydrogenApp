package androlua;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentManager;
import android.support.v4.widget.DrawerLayout;
import android.view.ContextMenu;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.FrameLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.luajava.JavaFunction;
import com.luajava.LuaException;
import com.luajava.LuaObject;
import com.luajava.LuaState;
import com.luajava.LuaStateFactory;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;

import androlua.base.BaseActivity;
import androlua.common.LuaLog;
import androlua.fragment.MenuFragment;
import pub.hanks.luajandroid.R;

public class LuaActivity extends BaseActivity implements LuaContext {

    public Handler handler;
    public TextView status;
    private LuaState L;
    private ScrollView errorLayout;
    private LuaObject mOnKeyDown;
    private LuaObject mOnKeyUp;
    private LuaObject mOnKeyLongPress;
    private LuaObject mOnTouchEvent;
    private LuaDexLoader luaDexLoader;
    private LuaManager luaManager;
    private FrameLayout main;
    private MenuFragment menuFragment;
    private DrawerLayout layout_drawer;

    public static void start(Context context, String luaPath) {
        Intent starter = new Intent(context, LuaActivity.class);
        starter.putExtra("luaPath", luaPath);
        context.startActivity(starter);
    }

    public void setContentView(View view) {
        main.removeAllViews();
        main.addView(view, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));

        FragmentManager fragmentManager = getSupportFragmentManager();
        if (fragmentManager.findFragmentByTag("menu") == null) {
            fragmentManager.beginTransaction()
                    .replace(R.id.menu, menuFragment, "menu").commitAllowingStateLoss();
        }
    }

    public void closeDrawer() {
        if (layout_drawer == null) {
            return;
        }
        layout_drawer.closeDrawer(Gravity.RIGHT);
    }


    @Override
    public void setContentView(View view, LayoutParams params) {
        super.setContentView(view, params);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_lua);
        main = (FrameLayout) findViewById(R.id.main);
        layout_drawer = (DrawerLayout) findViewById(R.id.layout_drawer);
        menuFragment = MenuFragment.newInstance();
        handler = new MainHandler(this);

        // 用于出错时显示
        initErrorLayout();

        initLua(savedInstanceState);
    }

    public void disableDrawer(){
        if (layout_drawer == null) {
            return;
        }
        layout_drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
    }

    private void initLua(Bundle savedInstanceState) {
        try {
            Object[] arg = LuaUtil.IntentHelper.getArgs(getIntent());
            luaManager = LuaManager.getInstance();
            String luaFile = LuaUtil.IntentHelper.getLuaPath(getIntent());

            L = LuaStateFactory.newLuaState();
            L.openLibs();

            L.pushJavaObject(this);
            L.setGlobal("activity");

            L.getGlobal("activity");
            L.setGlobal("this");

            L.pushContext(this);
            L.getGlobal("luajava");

            L.pushString(luaManager.getLuaExtDir());
            L.setField(-2, "luaextdir");

            L.pushString(luaManager.getLuaDir());
            L.setField(-2, "luadir");


            L.pushString(luaManager.getLuaLpath());
            L.setField(-2, "luapath");

            L.pop(1);

            JavaFunction print = new LuaPrint(L);
            print.register("print");

            L.getGlobal("package");
            L.pushString(luaManager.getLuaLpath());
            L.setField(-2, "path");
            L.pushString(luaManager.getLuaCpath());
            L.setField(-2, "cpath");
            L.pop(1);


            mOnKeyDown = L.getLuaObject("onKeyDown");
            if (mOnKeyDown.isNil())
                mOnKeyDown = null;
            mOnKeyUp = L.getLuaObject("onKeyUp");
            if (mOnKeyUp.isNil())
                mOnKeyUp = null;
            mOnKeyLongPress = L.getLuaObject("onKeyLongPress");
            if (mOnKeyLongPress.isNil())
                mOnKeyLongPress = null;
            mOnTouchEvent = L.getLuaObject("onTouchEvent");
            if (mOnTouchEvent.isNil())
                mOnTouchEvent = null;

            luaDexLoader = new LuaDexLoader();
            luaDexLoader.loadLibs();
            if (!luaFile.startsWith("/")) {
                luaFile = luaManager.getLuaExtDir() + "/" + luaFile;
            }
            luaManager.doFile(L, luaFile, arg);
            luaManager.runFunc(L, "onCreate", savedInstanceState);
        } catch (Exception e) {
            sendMsg(e.getMessage());
            setContentView(this.errorLayout);
        }
    }

    private void initErrorLayout() {
        errorLayout = new ScrollView(this);
        errorLayout.setFillViewport(true);
        errorLayout.setBackgroundColor(Color.WHITE);

        status = new TextView(this);
        status.setPadding(10, 100, 10, 0);
        status.setTextColor(Color.BLACK);
        status.setText("");
        status.setTextIsSelectable(true);

        errorLayout.addView(status, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
    }

    public ArrayList<ClassLoader> getClassLoaders() {
        return luaDexLoader.getClassLoaders();
    }

    public HashMap<String, String> getLibrarys() {
        return luaDexLoader.getLibrarys();
    }

    public void loadResources(String path) {
        luaDexLoader.loadResources(path);
    }

    public LuaState getLuaState() {
        return L;
    }

    @Override
    protected void onStart() {
        super.onStart();
        luaManager.runFunc(L, "onStart");
    }

    @Override
    protected void onResume() {
        super.onResume();
        luaManager.runFunc(L, "onResume");
    }

    @Override
    protected void onPause() {
        super.onPause();
        luaManager.runFunc(L, "onPause");
    }

    @Override
    protected void onStop() {
        super.onStop();
        luaManager.runFunc(L, "onStop");
    }

    @Override
    protected void onNewIntent(Intent intent) {
        luaManager.runFunc(L, "onNewIntent", intent);
        super.onNewIntent(intent);
    }

    @Override
    protected void onDestroy() {
        try {
            luaManager.runFunc(L, "onDestroy");
            super.onDestroy();
//            L.close();
            L.gc(LuaState.LUA_GCCOLLECT, 1);
            System.gc();
        } catch (Exception e) {
            LuaLog.e(e);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        luaManager.runFunc(L, "onActivityResult", requestCode, resultCode, data);
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onBackPressed() {
        Object ret = luaManager.runFunc(L, "onBackPressed");
        if (ret != null && ret.getClass() == Boolean.class && (Boolean) ret) {
            return;
        }
        super.onBackPressed();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (mOnKeyDown != null) {
            try {
                Object ret = mOnKeyDown.call(keyCode, event);
                if (ret != null && ret.getClass() == Boolean.class && (Boolean) ret)
                    return true;
            } catch (LuaException e) {
                sendMsg("onKeyDown " + e.getMessage());
            }
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        if (mOnKeyUp != null) {
            try {
                Object ret = mOnKeyUp.call(keyCode, event);
                if (ret != null && ret.getClass() == Boolean.class && (Boolean) ret)
                    return true;
            } catch (LuaException e) {
                sendMsg("onKeyUp " + e.getMessage());
            }
        }
        return super.onKeyUp(keyCode, event);
    }

    @Override
    public boolean onKeyLongPress(int keyCode, KeyEvent event) {
        if (mOnKeyLongPress != null) {
            try {
                Object ret = mOnKeyLongPress.call(keyCode, event);
                if (ret != null && ret.getClass() == Boolean.class && (Boolean) ret)
                    return true;
            } catch (LuaException e) {
                sendMsg("onKeyLongPress " + e.getMessage());
            }
        }
        return super.onKeyLongPress(keyCode, event);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (mOnTouchEvent != null) {
            try {
                Object ret = mOnTouchEvent.call(event);
                if (ret != null && ret.getClass() == Boolean.class && (Boolean) ret)
                    return true;
            } catch (LuaException e) {
                sendMsg("onTouchEvent " + e.getMessage());
            }
        }
        return super.onTouchEvent(event);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        luaManager.runFunc(L, "onCreateOptionsMenu", menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        Object ret = null;
        if (!item.hasSubMenu())
            ret = luaManager.runFunc(L, "onOptionsItemSelected", item);
        if (ret != null && ret.getClass() == Boolean.class && (Boolean) ret)
            return true;
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onCreateContextMenu(ContextMenu menu, View v, ContextMenu.ContextMenuInfo menuInfo) {
        luaManager.runFunc(L, "onCreateContextMenu", menu, v, menuInfo);
        super.onCreateContextMenu(menu, v, menuInfo);
    }

    @Override
    public boolean onContextItemSelected(MenuItem item) {
        luaManager.runFunc(L, "onContextItemSelected", item);
        return super.onContextItemSelected(item);
    }

    public int getWidth() {
        return getResources().getDisplayMetrics().widthPixels;
    }

    public int getHeight() {
        return getResources().getDisplayMetrics().heightPixels;
    }

    public void toast(String msg) {
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
    }


    //显示信息
    public void sendMsg(String msg) {
        Message message = new Message();
        Bundle bundle = new Bundle();
        bundle.putString("data", msg);
        message.setData(bundle);
        message.what = 0;
        handler.sendMessage(message);
        LuaLog.e(msg);
    }


    // avoid handler leak memory
    private static class MainHandler extends Handler {
        WeakReference<Activity> activityWeakReference;

        private MainHandler(Activity activity) {
            activityWeakReference = new WeakReference<>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            Activity activity = activityWeakReference.get();
            if (activity == null || !(activity instanceof LuaActivity)) {
                return;
            }
            LuaActivity luaActivity = (LuaActivity) activity;
            switch (msg.what) {
                case 0: {
                    String data = msg.getData().getString("data");
                    luaActivity.toast(data);
                    luaActivity.status.append(data + "\n");
                    luaActivity.setContentView(luaActivity.errorLayout);
                }
                break;
                //                case 1: {
                //                    Bundle data = msg.getData();
                //                    luaActivity.setField(data.getString("data"), ((Object[]) data.getSerializable("args"))[0]);
                //                }
                //                break;
                //                case 2: {
                //                    String src = msg.getData().getString("data");
                //                    luaActivity.luaManager.runFunc(L, src);
                //                }
                //                break;
                //                case 3: {
                //                    String src = msg.getData().getString("data");
                //                    Serializable args = msg.getData().getSerializable("args");
                //                    luaActivity.luaManager.runFunc(L, src, (Object[]) args);
                //                }
            }
        }
    }
}
