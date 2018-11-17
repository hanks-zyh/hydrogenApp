package androlua.plugin;

import com.luajava.LuaState;

import androlua.LuaManager;

/**
 * Created by hanks on 2017/5/5. Copyright (C) 2017 Hanks
 */

public class Plugin {
    private final LuaManager luaManager;
    private String path;
    private String id;
    private String name;
    private String iconPath;
    private String mainPath;
    private String versionName;
    private int versionCode;
    private boolean isPlugin;
    private long updateAt;
    private LuaState L;

    public Plugin() {
        luaManager = LuaManager.getInstance();
    }

    public boolean isPlugin() {
        return isPlugin;
    }

    public void setPlugin(boolean plugin) {
        isPlugin = plugin;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setUpdateAt(long updateAt) {
        this.updateAt = updateAt;
    }

    public long getUpdateAt() {
        return updateAt;
    }

    public String getIconPath() {
        if (iconPath == null) {
            return "http://image.coolapk.com/apk_logo/2016/0108/12202_1452248424_4592.png";
        }

        if (iconPath.startsWith("http://") || iconPath.startsWith("https://")) {
            return iconPath;
        }
        if (!iconPath.startsWith("/")) {
            iconPath = getPath() + "/" + iconPath;
        }
        if (iconPath.startsWith("/")) {
            iconPath = "file://" + iconPath;
        }
        return iconPath;
    }

    public void setIconPath(String iconPath) {
        this.iconPath = iconPath;
    }

    public String getMainPath() {
        if (!mainPath.startsWith("/")) {
            setMainPath(getPath() + "/" + mainPath);
        }
        return mainPath;
    }

    public void setMainPath(String mainPath) {
        this.mainPath = mainPath;
    }

    public String getVersionName() {
        return versionName;
    }

    public void setVersionName(String versionName) {
        this.versionName = versionName;
    }

    public int getVersionCode() {
        return versionCode;
    }

    public void setVersionCode(int versionCode) {
        this.versionCode = versionCode;
    }
}
