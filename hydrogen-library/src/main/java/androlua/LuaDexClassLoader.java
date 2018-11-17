package androlua;

import java.util.HashMap;

import dalvik.system.DexClassLoader;

public class LuaDexClassLoader extends DexClassLoader {
    private HashMap<String, Class<?>> classCache = new HashMap();
    private String mDexPath;

    public LuaDexClassLoader(String dexPath, String optimizedDirectory, String libraryPath, ClassLoader parent) {
        super(dexPath, optimizedDirectory, libraryPath, parent);
        this.mDexPath = dexPath;
    }

    public String getDexPath() {
        return this.mDexPath;
    }

    protected Class<?> findClass(String name) throws ClassNotFoundException {
        Class<?> cls = (Class) this.classCache.get(name);
        if (cls != null) {
            return cls;
        }
        cls = super.findClass(name);
        this.classCache.put(name, cls);
        return cls;
    }
}