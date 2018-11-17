package androlua.common;

import android.content.Context;
import android.content.SharedPreferences;

import androlua.LuaManager;

/**
 * SharedPreferences
 * Created by hanks on 2017/6/19.
 */

public class LuaSp {

    private static LuaSp instance;
    private final SharedPreferences sp;

    public static LuaSp getInstance(String fileName) {
        if (instance == null) {
            synchronized (LuaSp.class) {
                if (instance == null) {
                    instance = new LuaSp(fileName);
                }
            }
        }
        return instance;
    }

    private LuaSp(String fileName) {
        Context context = LuaManager.getInstance().getContext();
        sp = context.getSharedPreferences(fileName, Context.MODE_PRIVATE);
    }

    public void save(String key, Object value) {
        SharedPreferences.Editor editor = sp.edit();
        if (value instanceof Boolean) {
            editor.putBoolean(key, (Boolean) value);
        } else if (value instanceof String) {
            editor.putString(key, (String) value);
        } else if (value instanceof Integer) {
            editor.putInt(key, (Integer) value);
        } else if (value instanceof Float) {
            editor.putFloat(key, (Float) value);
        } else if (value instanceof Long) {
            editor.putLong(key, (Long) value);
        }
        editor.apply();
    }

    public <T> T get(String key, T defaultValue) {
        Object value = null;
        if (defaultValue instanceof Boolean) {
            value = sp.getBoolean(key, (Boolean) defaultValue);
        } else if (defaultValue instanceof String) {
            value = sp.getString(key, (String) defaultValue);
        } else if (defaultValue instanceof Float) {
            value = sp.getFloat(key, (Float) defaultValue);
        } else if (defaultValue instanceof Long) {
            value = sp.getLong(key, (Long) defaultValue);
        } else if (defaultValue instanceof Integer) {
            value = sp.getInt(key, (Integer) defaultValue);
        }
        return (T) value;
    }

    /**
     * 移除某个key值已经对应的值
     */
    public void remove(String key) {
        SharedPreferences.Editor editor = sp.edit();
        editor.remove(key);
        editor.apply();
    }

    /**
     * 是否已经存在该 key
     */
    public boolean contains(String key) {
        return sp.contains(key);
    }


    /**
     * 清除所有数据
     */
    public void clear() {
        SharedPreferences.Editor editor = sp.edit();
        editor.clear();
        editor.apply();
    }

}
