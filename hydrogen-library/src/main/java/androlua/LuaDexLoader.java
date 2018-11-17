package androlua;


import android.content.res.AssetManager;
import android.content.res.Resources;
import android.content.res.Resources.Theme;

import com.luajava.LuaException;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;

import dalvik.system.DexClassLoader;

public class LuaDexLoader {
    private static HashMap<String, LuaDexClassLoader> dexCache = new HashMap();
    private final LuaManager luaManager;
    private ArrayList<ClassLoader> dexList = new ArrayList();
    private HashMap<String, String> libCache = new HashMap();
    private String luaDir;
    private AssetManager mAssetManager;
    private LuaContext mContext;
    private Resources mResources;
    private Theme mTheme;
    private String odexDir;

    public LuaDexLoader() {
        luaManager = LuaManager.getInstance();
        this.luaDir = luaManager.getLuaDir();
        this.odexDir = luaManager.getOdexDir();
    }

    public Theme getTheme() {
        return this.mTheme;
    }

    public ArrayList<ClassLoader> getClassLoaders() {
        return this.dexList;
    }

    public void loadLibs() throws LuaException {
        File[] libs = new File(LuaManager.getInstance().getLuaExtDir() + "/libs").listFiles();
        if (libs != null) {
            for (File f : libs) {
                if (f.getAbsolutePath().endsWith(".so")) {
                    loadLib(f.getName());
                } else {
                    loadDex(f.getAbsolutePath());
                }
            }
        }
    }

    public void loadLib(String name) throws LuaException {
//        String fn = name;
//        int i = name.indexOf(".");
//        if (i > 0) {
//            fn = name.substring(0, i);
//        }
//        if (fn.startsWith("lib")) {
//            fn = fn.substring(3);
//        }
//        String libPath = this.mContext.getContext().getDir(fn, 0).getAbsolutePath() + "/lib" + fn + ".so";
//        if (!new File(libPath).exists()) {
//            if (new File(this.luaDir + "/libs/lib" + fn + ".so").exists()) {
//                LuaUtil.copyFile(this.luaDir + "/libs/lib" + fn + ".so", libPath);
//            } else {
//                throw new LuaException("can not find lib " + name);
//            }
//        }
//        this.libCache.put(fn, libPath);
    }

    public HashMap<String, String> getLibrarys() {
        return this.libCache;
    }

    public DexClassLoader loadDex(String path) throws LuaException {
        String name = path;
        LuaDexClassLoader dex = (LuaDexClassLoader) dexCache.get(name);
//        if (dex == null) {
//            if (path.charAt(0) != '/') {
//                path = this.luaDir + "/" + path;
//            }
//            if (!new File(path).exists()) {
//                if (new File(path + ".dex").exists()) {
//                    path = path + ".dex";
//                } else if (new File(path + ".jar").exists()) {
//                    path = path + ".jar";
//                } else {
//                    throw new LuaException(path + " not found");
//                }
//            }
//            dex = new LuaDexClassLoader(path, this.odexDir,luaManager.getContext().getApplicationInfo().nativeLibraryDir, this.mContext.getContext().getClassLoader());
//            dexCache.put(name, dex);
//        }
//        if (!this.dexList.contains(dex)) {
//            this.dexList.add(dex);
//            path = dex.getDexPath();
//            if (path.endsWith(".jar")) {
//                loadResources(path);
//            }
//        }
        return dex;
    }

    public void loadResources(String path) {
        try {
//            AssetManager assetManager = (AssetManager) AssetManager.class.newInstance();
//            if (((Integer) assetManager.getClass().getMethod("addAssetPath", new Class[]{String.class}).invoke(assetManager, new Object[]{path})).intValue() != 0) {
//                this.mAssetManager = assetManager;
//                Resources superRes = this.mContext.getContext().getResources();
//                this.mResources = new Resources(this.mAssetManager, superRes.getDisplayMetrics(), superRes.getConfiguration());
//                this.mTheme = this.mResources.newTheme();
//                this.mTheme.setTo(this.mContext.getContext().getTheme());
//            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public AssetManager getAssets() {
        return this.mAssetManager;
    }

    public Resources getResources() {
        return this.mResources;
    }
}
