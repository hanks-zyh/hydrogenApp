package androlua;


public class LuaTimer {
//    private LuaTimerTask task;
//
//    public LuaTimer(LuaContext main, String src) throws LuaException {
//        this(main, src, null);
//    }
//
//    public LuaTimer(LuaContext main, String src, Object[] arg) throws LuaException {
//        super("LuaTimer");
//        this.task = new LuaTimerTask(main, src, arg);
//    }
//
//    public LuaTimer(LuaContext main, LuaObject func) throws LuaException {
//        this(main, func, null);
//    }
//
//    public LuaTimer(LuaContext main, LuaObject func, Object[] arg) throws LuaException {
//        super("LuaTimer");
//        this.task = new LuaTimerTask(main, func, arg);
//    }
//
//    public void gc() {
//        stop();
//    }
//
//    public void start(long delay, long period) {
//        schedule(this.task, delay, period);
//    }
//
//    public void start(long delay) {
//        schedule(this.task, delay);
//    }
//
//    public void stop() {
//        this.task.cancel();
//    }
//
//    public boolean isEnabled() {
//        return this.task.isEnabled();
//    }
//
//    public boolean getEnabled() {
//        return this.task.isEnabled();
//    }
//
//    public void setEnabled(boolean enabled) {
//        this.task.setEnabled(enabled);
//    }
//
//    public long getPeriod() {
//        return this.task.getPeriod();
//    }
//
//    public void setPeriod(long period) {
//        this.task.setPeriod(period);
//    }
}