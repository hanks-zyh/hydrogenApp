package com.luajava;

public abstract class JavaFunction {
    protected LuaState L;

    public JavaFunction(LuaState L) {
        this.L = L;
    }

    public abstract int execute() throws LuaException;

    public LuaObject getParam(int idx) {
        return this.L.getLuaObject(idx);
    }

    public void register(String name) throws LuaException {
        synchronized (this.L) {
            this.L.pushJavaFunction(this);
            this.L.setGlobal(name);
        }
    }
}