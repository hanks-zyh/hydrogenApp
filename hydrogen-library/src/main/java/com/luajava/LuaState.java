package com.luajava;

import androlua.LuaContext;

public class LuaState {
    public static final int LUAI_MAXSTACK = 1000000;
    public static final int LUA_ERRERR = 6;
    public static final int LUA_ERRGCMM = 5;
    public static final int LUA_ERRMEM = 4;
    public static final int LUA_ERRRUN = 2;
    public static final int LUA_ERRSYNTAX = 3;
    public static final int LUA_GCCOLLECT = 2;
    public static final int LUA_GCCOUNT = 3;
    public static final int LUA_GCCOUNTB = 4;
    public static final int LUA_GCRESTART = 1;
    public static final int LUA_GCSETPAUSE = 6;
    public static final int LUA_GCSETSTEPMUL = 7;
    public static final int LUA_GCSTEP = 5;
    public static final int LUA_GCSTOP = 0;
    public static final int LUA_MULTRET = -1;
    public static final int LUA_OPEQ = 0;
    public static final int LUA_OPLE = 2;
    public static final int LUA_OPLT = 1;
    public static final int LUA_REGISTRYINDEX = -1001000;
    public static final int LUA_RIDX_GLOBALS = 2;
    public static final int LUA_RIDX_LAST = 2;
    public static final int LUA_RIDX_MAINTHREAD = 1;
    public static final int LUA_TBOOLEAN = 1;
    public static final int LUA_TFUNCTION = 6;
    public static final int LUA_TLIGHTUSERDATA = 2;
    public static final int LUA_TNIL = 0;
    public static final int LUA_TNONE = -1;
    public static final int LUA_TNUMBER = 3;
    public static final int LUA_TSTRING = 4;
    public static final int LUA_TTABLE = 5;
    public static final int LUA_TTHREAD = 8;
    public static final int LUA_TUSERDATA = 7;
    public static final int LUA_YIELD = 1;
    private static final String LUAJAVA_LIB = "luajava";
    private static Class<?> Byte_class = Byte.class;
    private static Class<?> Double_class = Double.class;
    private static Class<?> Float_class = Float.class;
    private static Class<?> Integer_class = Integer.class;
    private static Class<?> Long_class = Long.class;
    private static Class<?> Number_class = Number.class;
    private static Class<?> Short_class = Short.class;

    static {
        System.loadLibrary(LUAJAVA_LIB);
    }

    private long luaState;
    private LuaContext mContext;

    protected LuaState() {
        this.luaState = _newstate();
    }

    protected LuaState(long luaState) {
        this.luaState = luaState;
        LuaStateFactory.insertLuaState(this);
    }

    public static Number convertLuaNumber(Double db, Class<?> retType) {
        if (retType.isPrimitive()) {
            if (retType == Integer.TYPE) {
                return Integer.valueOf(db.intValue());
            }
            if (retType == Long.TYPE) {
                return Long.valueOf(db.longValue());
            }
            if (retType == Float.TYPE) {
                return Float.valueOf(db.floatValue());
            }
            if (retType == Double.TYPE) {
                return Double.valueOf(db.doubleValue());
            }
            if (retType == Byte.TYPE) {
                return Byte.valueOf(db.byteValue());
            }
            if (retType == Short.TYPE) {
                return Short.valueOf(db.shortValue());
            }
        } else if (retType.isAssignableFrom(Number_class)) {
            if (retType.isAssignableFrom(Integer_class)) {
                return new Integer(db.intValue());
            }
            if (retType.isAssignableFrom(Long_class)) {
                return new Long(db.longValue());
            }
            if (retType.isAssignableFrom(Float_class)) {
                return new Float(db.floatValue());
            }
            if (retType.isAssignableFrom(Double_class)) {
                return db;
            }
            if (retType.isAssignableFrom(Byte_class)) {
                return new Byte(db.byteValue());
            }
            if (retType.isAssignableFrom(Short_class)) {
                return new Short(db.shortValue());
            }
        }
        return null;
    }

    public static Number convertLuaNumber(Long lg, Class<?> retType) {
        if (retType.isPrimitive()) {
            if (retType == Integer.TYPE) {
                return Integer.valueOf(lg.intValue());
            }
            if (retType == Long.TYPE) {
                return Long.valueOf(lg.longValue());
            }
            if (retType == Float.TYPE) {
                return Float.valueOf(lg.floatValue());
            }
            if (retType == Double.TYPE) {
                return Double.valueOf(lg.doubleValue());
            }
            if (retType == Byte.TYPE) {
                return Byte.valueOf(lg.byteValue());
            }
            if (retType == Short.TYPE) {
                return Short.valueOf(lg.shortValue());
            }
        } else if (retType.isAssignableFrom(Number_class)) {
            if (retType.isAssignableFrom(Integer_class)) {
                return new Integer(lg.intValue());
            }
            if (retType.isAssignableFrom(Long_class)) {
                return new Long(lg.longValue());
            }
            if (retType.isAssignableFrom(Float_class)) {
                return new Float(lg.floatValue());
            }
            if (retType.isAssignableFrom(Double_class)) {
                return lg;
            }
            if (retType.isAssignableFrom(Byte_class)) {
                return new Byte(lg.byteValue());
            }
            if (retType.isAssignableFrom(Short_class)) {
                return new Short(lg.shortValue());
            }
        }
        return null;
    }

    private native synchronized int _LargError(long j, int i, String str);

    private native synchronized int _LcallMeta(long j, int i, String str);

    private native synchronized void _LcheckAny(long j, int i);

    private native synchronized int _LcheckInteger(long j, int i);

    private native synchronized double _LcheckNumber(long j, int i);

    private native synchronized void _LcheckStack(long j, int i, String str);

    private native synchronized String _LcheckString(long j, int i);

    private native synchronized void _LcheckType(long j, int i, int i2);

    private native synchronized int _LdoFile(long j, String str);

    private native synchronized int _LdoString(long j, String str);

    private native synchronized int _LgetMetaField(long j, int i, String str);

    private native synchronized void _LgetMetatable(long j, String str);

    private native synchronized String _Lgsub(long j, String str, String str2, String str3);

    private native synchronized int _LloadBuffer(long j, byte[] bArr, long j2, String str);

    private native synchronized int _LloadFile(long j, String str);

    private native synchronized int _LloadString(long j, String str);

    private native synchronized int _LnewMetatable(long j, String str);

    private native synchronized int _LoptInteger(long j, int i, int i2);

    private native synchronized double _LoptNumber(long j, int i, double d);

    private native synchronized String _LoptString(long j, int i, String str);

    private native synchronized int _Lref(long j, int i);

    private native synchronized void _LunRef(long j, int i, int i2);

    private native synchronized void _Lwhere(long j, int i);

    private native synchronized void _call(long j, int i, int i2);

    private native synchronized int _checkStack(long j, int i);

    private native synchronized void _close(long j);

    private native synchronized int _compare(long j, int i, int i2, int i3);

    private native synchronized void _concat(long j, int i);

    private native synchronized void _copy(long j, int i, int i2);

    private native synchronized void _createTable(long j, int i, int i2);

    private native synchronized byte[] _dump(long j, int i);

    private native synchronized int _equal(long j, int i, int i2);

    private native synchronized int _error(long j);

    private native synchronized int _gc(long j, int i, int i2);

    private native synchronized int _getField(long j, int i, String str);

    private native synchronized int _getGlobal(long j, String str);

    private native synchronized int _getI(long j, int i, long j2);

    private native synchronized int _getMetaTable(long j, int i);

    private native synchronized Object _getObjectFromUserdata(long j, int i) throws LuaException;

    private native synchronized int _getTable(long j, int i);

    private native synchronized int _getTop(long j);

    private native synchronized String _getUpValue(long j, int i, int i2);

    private native synchronized int _getUserValue(long j, int i);

    private native synchronized void _insert(long j, int i);

    private native synchronized int _isBoolean(long j, int i);

    private native synchronized int _isCFunction(long j, int i);

    private native synchronized int _isFunction(long j, int i);

    private native synchronized int _isInteger(long j, int i);

    private native synchronized boolean _isJavaFunction(long j, int i);

    private native synchronized int _isNil(long j, int i);

    private native synchronized int _isNone(long j, int i);

    private native synchronized int _isNoneOrNil(long j, int i);

    private native synchronized int _isNumber(long j, int i);

    private native synchronized boolean _isObject(long j, int i);

    private native synchronized int _isString(long j, int i);

    private native synchronized int _isTable(long j, int i);

    private native synchronized int _isThread(long j, int i);

    private native synchronized int _isUserdata(long j, int i);

    private native synchronized int _isYieldable(long j);

    private native synchronized int _lessThan(long j, int i, int i2);

    private native synchronized void _newTable(long j);

    private native synchronized long _newstate();

    private native synchronized long _newthread(long j);

    private native synchronized int _next(long j, int i);

    private native synchronized int _objlen(long j, int i);

    private native synchronized void _openBase(long j);

    private native synchronized void _openDebug(long j);

    private native synchronized void _openIo(long j);

    private native synchronized void _openLibs(long j);

    private native synchronized void _openLuajava(long j);

    private native synchronized void _openMath(long j);

    private native synchronized void _openOs(long j);

    private native synchronized void _openPackage(long j);

    private native synchronized void _openString(long j);

    private native synchronized void _openTable(long j);

    private native synchronized int _pcall(long j, int i, int i2, int i3);

    private native synchronized void _pop(long j, int i);

    private native synchronized void _pushBoolean(long j, int i);

    private native synchronized void _pushGlobalTable(long j);

    private native synchronized void _pushInteger(long j, long j2);

    private native synchronized void _pushJavaFunction(long j, JavaFunction javaFunction) throws LuaException;

    private native synchronized void _pushJavaObject(long j, Object obj);

    private native synchronized void _pushNil(long j);

    private native synchronized void _pushNumber(long j, double d);

    private native synchronized void _pushString(long j, String str);

    private native synchronized void _pushString(long j, byte[] bArr, int i);

    private native synchronized void _pushValue(long j, int i);

    private native synchronized int _rawGet(long j, int i);

    private native synchronized int _rawGetI(long j, int i, long j2);

    private native synchronized void _rawSet(long j, int i);

    private native synchronized void _rawSetI(long j, int i, long j2);

    private native synchronized int _rawequal(long j, int i, int i2);

    private native synchronized int _rawlen(long j, int i);

    private native synchronized void _remove(long j, int i);

    private native synchronized void _replace(long j, int i);

    private native synchronized int _resume(long j, long j2, int i);

    private native synchronized void _rotate(long j, int i, int i2);

    private native synchronized void _setField(long j, int i, String str);

    private native synchronized void _setGlobal(long j, String str);

    private native synchronized void _setI(long j, int i, long j2);

    private native synchronized int _setMetaTable(long j, int i);

    private native synchronized void _setTable(long j, int i);

    private native synchronized void _setTop(long j, int i);

    private native synchronized String _setUpValue(long j, int i, int i2);

    private native synchronized void _setUserValue(long j, int i);

    private native synchronized int _status(long j);

    private native synchronized int _strlen(long j, int i);

    private native synchronized int _toBoolean(long j, int i);

    private native synchronized long _toInteger(long j, int i);

    private native synchronized double _toNumber(long j, int i);

    private native synchronized String _toString(long j, int i);

    private native synchronized long _toThread(long j, int i);

    private native synchronized int _type(long j, int i);

    private native synchronized String _typeName(long j, int i);

    private native synchronized void _xmove(long j, long j2, int i);

    private native synchronized int _yield(long j, int i);

    public synchronized void close() {
        LuaStateFactory.removeLuaState(this.luaState);
        _close(this.luaState);
        this.luaState = 0;
    }

    public synchronized boolean isClosed() {
        return this.luaState == 0;
    }

    public long getPointer() {
        return this.luaState;
    }

    public void pushContext(LuaContext context) {
        this.mContext = context;
    }

    public LuaContext getContext() {
        return this.mContext;
    }

    public LuaState newThread() {
        LuaState l = new LuaState(_newthread(this.luaState));
        LuaStateFactory.insertLuaState(l);
        return l;
    }

    public int getTop() {
        return _getTop(this.luaState);
    }

    public void setTop(int idx) {
        _setTop(this.luaState, idx);
    }

    public void pushValue(int idx) {
        _pushValue(this.luaState, idx);
    }

    public void rotate(int idx, int n) {
        _rotate(this.luaState, idx, n);
    }

    public void copy(int fromidx, int toidx) {
        _copy(this.luaState, fromidx, toidx);
    }

    public void remove(int idx) {
        _remove(this.luaState, idx);
    }

    public void insert(int idx) {
        _insert(this.luaState, idx);
    }

    public void replace(int idx) {
        _replace(this.luaState, idx);
    }

    public int checkStack(int sz) {
        return _checkStack(this.luaState, sz);
    }

    public void xmove(LuaState to, int n) {
        _xmove(this.luaState, to.luaState, n);
    }

    public boolean isNumber(int idx) {
        return _isNumber(this.luaState, idx) != 0;
    }

    public boolean isInteger(int idx) {
        return _isInteger(this.luaState, idx) != 0;
    }

    public boolean isString(int idx) {
        return _isString(this.luaState, idx) != 0;
    }

    public boolean isFunction(int idx) {
        return _isFunction(this.luaState, idx) != 0;
    }

    public boolean isCFunction(int idx) {
        return _isCFunction(this.luaState, idx) != 0;
    }

    public boolean isUserdata(int idx) {
        return _isUserdata(this.luaState, idx) != 0;
    }

    public boolean isTable(int idx) {
        return _isTable(this.luaState, idx) != 0;
    }

    public boolean isBoolean(int idx) {
        return _isBoolean(this.luaState, idx) != 0;
    }

    public boolean isNil(int idx) {
        return _isNil(this.luaState, idx) != 0;
    }

    public boolean isThread(int idx) {
        return _isThread(this.luaState, idx) != 0;
    }

    public boolean isNone(int idx) {
        return _isNone(this.luaState, idx) != 0;
    }

    public boolean isNoneOrNil(int idx) {
        return _isNoneOrNil(this.luaState, idx) != 0;
    }

    public int type(int idx) {
        return _type(this.luaState, idx);
    }

    public String typeName(int tp) {
        return _typeName(this.luaState, tp);
    }

    public int equal(int idx1, int idx2) {
        return _equal(this.luaState, idx1, idx2);
    }

    public int compare(int idx1, int idx2, int op) {
        return _compare(this.luaState, idx1, idx2, op);
    }

    public int rawequal(int idx1, int idx2) {
        return _rawequal(this.luaState, idx1, idx2);
    }

    public int lessThan(int idx1, int idx2) {
        return _lessThan(this.luaState, idx1, idx2);
    }

    public double toNumber(int idx) {
        return _toNumber(this.luaState, idx);
    }

    public long toInteger(int idx) {
        return _toInteger(this.luaState, idx);
    }

    public boolean toBoolean(int idx) {
        return _toBoolean(this.luaState, idx) != 0;
    }

    public String toString(int idx) {
        return _toString(this.luaState, idx);
    }

    public int strLen(int idx) {
        return _strlen(this.luaState, idx);
    }

    public int objLen(int idx) {
        return _objlen(this.luaState, idx);
    }

    public int rawLen(int idx) {
        return _rawlen(this.luaState, idx);
    }

    public LuaState toThread(int idx) {
        return new LuaState(_toThread(this.luaState, idx));
    }

    public void pushNil() {
        _pushNil(this.luaState);
    }

    public void pushNumber(double db) {
        _pushNumber(this.luaState, db);
    }

    public void pushInteger(long integer) {
        _pushInteger(this.luaState, integer);
    }

    public void pushString(String str) {
        if (str == null) {
            _pushNil(this.luaState);
        } else {
            _pushString(this.luaState, str);
        }
    }

    public void pushString(byte[] bytes) {
        if (bytes == null) {
            _pushNil(this.luaState);
        } else {
            _pushString(this.luaState, bytes, bytes.length);
        }
    }

    public void pushBoolean(boolean bool) {
        _pushBoolean(this.luaState, bool ? 1 : 0);
    }

    public int getTable(int idx) {
        return _getTable(this.luaState, idx);
    }

    public int getField(int idx, String k) {
        return _getField(this.luaState, idx, k);
    }

    public int getI(int idx, long n) {
        return _getI(this.luaState, idx, n);
    }

    public int rawGet(int idx) {
        return _rawGet(this.luaState, idx);
    }

    public int rawGetI(int idx, long n) {
        return _rawGetI(this.luaState, idx, n);
    }

    public void createTable(int narr, int nrec) {
        _createTable(this.luaState, narr, nrec);
    }

    public void newTable() {
        _newTable(this.luaState);
    }

    public int getMetaTable(int idx) {
        return _getMetaTable(this.luaState, idx);
    }

    public int getUserValue(int idx) {
        return _getUserValue(this.luaState, idx);
    }

    public void setTable(int idx) {
        _setTable(this.luaState, idx);
    }

    public void setField(int idx, String k) {
        _setField(this.luaState, idx, k);
    }

    public void setI(int idx, long n) {
        _setI(this.luaState, idx, n);
    }

    public void rawSet(int idx) {
        _rawSet(this.luaState, idx);
    }

    public void rawSetI(int idx, long n) {
        _rawSetI(this.luaState, idx, n);
    }

    public int setMetaTable(int idx) {
        return _setMetaTable(this.luaState, idx);
    }

    public void setUserValue(int idx) {
        _setUserValue(this.luaState, idx);
    }

    public void call(int nArgs, int nResults) {
        _call(this.luaState, nArgs, nResults);
    }

    public int pcall(int nArgs, int nResults, int errFunc) {
        return _pcall(this.luaState, nArgs, nResults, errFunc);
    }

    public int yield(int nResults) {
        return _yield(this.luaState, nResults);
    }

    public int resume(LuaState from, int nArgs) {
        return _resume(this.luaState, from.getPointer(), nArgs);
    }

    public int status() {
        return _status(this.luaState);
    }

    public int isYieldable() {
        return _isYieldable(this.luaState);
    }

    public int gc(int what, int data) {
        return _gc(this.luaState, what, data);
    }

    public int next(int idx) {
        return _next(this.luaState, idx);
    }

    public int error() {
        return _error(this.luaState);
    }

    public void concat(int n) {
        _concat(this.luaState, n);
    }

    public int LdoFile(String fileName) {
        return _LdoFile(this.luaState, fileName);
    }

    public int LdoString(String str) {
        return _LdoString(this.luaState, str);
    }

    public int LgetMetaField(int obj, String e) {
        return _LgetMetaField(this.luaState, obj, e);
    }

    public int LcallMeta(int obj, String e) {
        return _LcallMeta(this.luaState, obj, e);
    }

    public int LargError(int numArg, String extraMsg) {
        return _LargError(this.luaState, numArg, extraMsg);
    }

    public String LcheckString(int numArg) {
        return _LcheckString(this.luaState, numArg);
    }

    public String LoptString(int numArg, String def) {
        return _LoptString(this.luaState, numArg, def);
    }

    public double LcheckNumber(int numArg) {
        return _LcheckNumber(this.luaState, numArg);
    }

    public double LoptNumber(int numArg, double def) {
        return _LoptNumber(this.luaState, numArg, def);
    }

    public int LcheckInteger(int numArg) {
        return _LcheckInteger(this.luaState, numArg);
    }

    public int LoptInteger(int numArg, int def) {
        return _LoptInteger(this.luaState, numArg, def);
    }

    public void LcheckStack(int sz, String msg) {
        _LcheckStack(this.luaState, sz, msg);
    }

    public void LcheckType(int nArg, int t) {
        _LcheckType(this.luaState, nArg, t);
    }

    public void LcheckAny(int nArg) {
        _LcheckAny(this.luaState, nArg);
    }

    public int LnewMetatable(String tName) {
        return _LnewMetatable(this.luaState, tName);
    }

    public void LgetMetatable(String tName) {
        _LgetMetatable(this.luaState, tName);
    }

    public void Lwhere(int lvl) {
        _Lwhere(this.luaState, lvl);
    }

    public int Lref(int t) {
        return _Lref(this.luaState, t);
    }

    public void LunRef(int t, int ref) {
        _LunRef(this.luaState, t, ref);
    }

    public int LloadFile(String fileName) {
        return _LloadFile(this.luaState, fileName);
    }

    public int LloadString(String s) {
        return _LloadString(this.luaState, s);
    }

    public int LloadBuffer(byte[] buff, String name) {
        return _LloadBuffer(this.luaState, buff, (long) buff.length, name);
    }

    public String Lgsub(String s, String p, String r) {
        return _Lgsub(this.luaState, s, p, r);
    }

    public String getUpValue(int funcindex, int n) {
        return _getUpValue(this.luaState, funcindex, n);
    }

    public String setUpValue(int funcindex, int n) {
        return _setUpValue(this.luaState, funcindex, n);
    }

    public byte[] dump(int funcindex) {
        return _dump(this.luaState, funcindex);
    }

    public void pop(int n) {
        _pop(this.luaState, n);
    }

    public synchronized void pushGlobalTable() {
        _pushGlobalTable(this.luaState);
    }

    public synchronized int getGlobal(String global) {
        return _getGlobal(this.luaState, global);
    }

    public synchronized void setGlobal(String name) {
        _setGlobal(this.luaState, name);
    }

    public void openBase() {
        _openBase(this.luaState);
    }

    public void openTable() {
        _openTable(this.luaState);
    }

    public void openIo() {
        _openIo(this.luaState);
    }

    public void openOs() {
        _openOs(this.luaState);
    }

    public void openString() {
        _openString(this.luaState);
    }

    public void openMath() {
        _openMath(this.luaState);
    }

    public void openDebug() {
        _openDebug(this.luaState);
    }

    public void openPackage() {
        _openPackage(this.luaState);
    }

    public void openLibs() {
        _openLibs(this.luaState);
        _openLuajava(this.luaState);
        pushPrimitive();
    }

    public void openLuajava() {
        _openLuajava(this.luaState);
        pushPrimitive();
    }

    public Object getObjectFromUserdata(int idx) throws LuaException {
        return _getObjectFromUserdata(this.luaState, idx);
    }

    public boolean isObject(int idx) {
        return _isObject(this.luaState, idx);
    }

    public void pushJavaObject(Object obj) {
        _pushJavaObject(this.luaState, obj);
    }

    public void pushJavaFunction(JavaFunction func) throws LuaException {
        _pushJavaFunction(this.luaState, func);
    }

    public boolean isJavaFunction(int idx) {
        return _isJavaFunction(this.luaState, idx);
    }

    public void pushObjectValue(Object obj) throws LuaException {
        if (obj == null) {
            pushNil();
        } else if (obj instanceof Boolean) {
            pushBoolean(((Boolean) obj).booleanValue());
        } else if (obj instanceof Long) {
            pushInteger(((Long) obj).longValue());
        } else if (obj instanceof Integer) {
            pushInteger((long) ((Integer) obj).intValue());
        } else if (obj instanceof Short) {
            pushInteger((long) ((Short) obj).shortValue());
        } else if (obj instanceof Character) {
            pushInteger((long) ((Character) obj).charValue());
        } else if (obj instanceof Byte) {
            pushInteger((long) ((Byte) obj).byteValue());
        } else if (obj instanceof Float) {
            pushNumber((double) ((Float) obj).floatValue());
        } else if (obj instanceof Double) {
            pushNumber(((Double) obj).doubleValue());
        } else if (obj instanceof String) {
            pushString((String) obj);
        } else if (obj instanceof JavaFunction) {
            pushJavaFunction((JavaFunction) obj);
        } else if (obj instanceof LuaObject) {
            LuaObject ref = (LuaObject) obj;
            if (ref.getLuaState() == this) {
                ref.push();
            } else {
                pushJavaObject(ref);
            }
        } else {
            pushJavaObject(obj);
        }
    }

    public synchronized Object toJavaObject(int idx) throws LuaException {
        Object obj;
        obj = null;
        if (isBoolean(idx)) {
            obj = Boolean.valueOf(toBoolean(idx));
        } else if (type(idx) == 4) {
            obj = toString(idx);
        } else if (isFunction(idx)) {
            obj = getLuaObject(idx);
        } else if (isTable(idx)) {
            obj = getLuaObject(idx);
        } else if (type(idx) == 3) {
            if (isInteger(idx)) {
                obj = Long.valueOf(toInteger(idx));
            } else {
                obj = Double.valueOf(toNumber(idx));
            }
        } else if (isUserdata(idx)) {
            if (isObject(idx)) {
                obj = getObjectFromUserdata(idx);
            } else {
                obj = getLuaObject(idx);
            }
        } else if (isNil(idx)) {
            obj = null;
        }
        return obj;
    }

    public LuaObject getLuaObject(String globalName) {
        pushGlobalTable();
        pushString(globalName);
        rawGet(-2);
        LuaObject obj = getLuaObject(-1);
        pop(2);
        return obj;
    }

    public LuaObject getLuaObject(LuaObject parent, String name) throws LuaException {
        return new LuaObject(parent, name);
    }

    public LuaObject getLuaObject(LuaObject parent, Number name) throws LuaException {
        return new LuaObject(parent, name);
    }

    public LuaObject getLuaObject(LuaObject parent, LuaObject name) throws LuaException {
        if (parent.getLuaState().getPointer() == this.luaState && parent.getLuaState().getPointer() == name.getLuaState().getPointer()) {
            return new LuaObject(parent, name);
        }
        throw new LuaException("Object must have the same LuaState as the parent!");
    }

    public LuaObject getLuaObject(int index) {
        if (isFunction(index)) {
            return new LuaFunction(this, index);
        }
        if (isTable(index)) {
            return new LuaTable(this, index);
        }
        return new LuaObject(this, index);
    }

    public void pushPrimitive() {
        pushJavaObject(Boolean.TYPE);
        setGlobal("boolean");
        pushJavaObject(Byte.TYPE);
        setGlobal("byte");
        pushJavaObject(Character.TYPE);
        setGlobal("char");
        pushJavaObject(Short.TYPE);
        setGlobal("short");
        pushJavaObject(Integer.TYPE);
        setGlobal("int");
        pushJavaObject(Long.TYPE);
        setGlobal("long");
        pushJavaObject(Float.TYPE);
        setGlobal("float");
        pushJavaObject(Double.TYPE);
        setGlobal("double");
    }
}