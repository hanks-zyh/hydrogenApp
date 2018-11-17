package com.luajava;

import java.util.Collection;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class LuaTable<K, V> extends LuaObject implements Map<K, V> {

    protected LuaTable(LuaState L, String globalName) {
        super(L, globalName);
    }

    protected LuaTable(LuaState L, int index) {
        super(L, index);
    }

    public LuaTable(LuaState L) {
        super(L);
        L.newTable();
        registerValue(-1);
    }

    @Override
    public void clear() {
        push();
        L.pushNil();
        while (L.next(-2) != 0) {
            L.pop(1);
            L.pushValue(-1);
            L.pushNil();
            L.setTable(-4);
        }
        L.pop(1);
    }

    @Override
    public boolean containsKey(Object key) {
        boolean b = false;
        push();
        try {
            L.pushObjectValue(key);
            b = L.getTable(-2) == LuaState.LUA_TNIL;
            L.pop(1);
        } catch (LuaException e) {
            return false;
        }
        L.pop(1);
        return b;
    }

    @Override
    public boolean containsValue(Object value) {
        return false;
    }

    @Override
    public Set<Entry<K, V>> entrySet() {
        HashSet<Entry<K, V>> sets = new HashSet<Entry<K, V>>();
        push();
        L.pushNil();
        while (L.next(-2) != 0) {
            try {
                sets.add(new LuaEntry<K, V>((K) L.toJavaObject(-2), (V) L.toJavaObject(-1)));
            } catch (LuaException e) {
            }
            L.pop(1);
        }
        L.pop(1);
        return sets;
    }

    @Override
    public V get(Object key) {
        push();
        V obj = null;
        try {
            L.pushObjectValue(key);
            L.getTable(-2);
            obj = (V) L.toJavaObject(-1);
            L.pop(1);
        } catch (LuaException e) {
        }
        L.pop(1);
        return obj;
    }

    @Override
    public boolean isEmpty() {
        push();
        L.pushNil();
        boolean b = L.next(-2) == 0;
        if (b)
            L.pop(1);
        else
            L.pop(3);
        return b;
    }

    @Override
    public Set<K> keySet() {
        HashSet<K> sets = new HashSet<K>();
        push();
        L.pushNil();
        while (L.next(-2) != 0) {
            try {
                sets.add((K) L.toJavaObject(-2));
            } catch (LuaException e) {
            }
            L.pop(1);
        }
        L.pop(1);
        return sets;
    }

    @Override
    public V put(K key, V value) {
        push();
        try {
            L.pushObjectValue(key);
            L.pushObjectValue(value);
            L.setTable(-3);
        } catch (LuaException e) {
        }
        L.pop(1);
        return null;
    }

    @Override
    public void putAll(Map p1) {
    }

    @Override
    public V remove(Object key) {
        push();
        try {
            L.pushObjectValue(key);
            L.setTable(-2);
        } catch (LuaException e) {
        }
        L.pop(1);
        return null;
    }

    public boolean isList() {
        push();
        int len = L.rawLen(-1);
        if (len != 0) {
            pop();
            return true;
        }
        L.pushNil();
        boolean b = L.next(-2) == 0;
        if (b)
            L.pop(1);
        else
            L.pop(3);
        return b;
    }

    public int length() {
        push();
        int len = L.rawLen(-1);
        pop();
        return len;
    }

    @Override
    public int size() {
        int n = 0;
        push();
        L.pushNil();
        while (L.next(-2) != 0) {
            n++;
            L.pop(1);
        }
        L.pop(1);
        return n;
    }

    @Override
    public Collection values() {
        return null;
    }

    public static class LuaEntry<K, V> implements Entry<K, V> {

        private K mKey;

        private V mValue;

        public LuaEntry(K k, V v) {
            mKey = k;
            mValue = v;
        }

        @Override
        public K getKey() {
            return mKey;
        }

        @Override
        public V getValue() {
            return mValue;
        }

        public V setValue(V value) {
            V old = mValue;
            mValue = value;
            return old;
        }
    }
}
