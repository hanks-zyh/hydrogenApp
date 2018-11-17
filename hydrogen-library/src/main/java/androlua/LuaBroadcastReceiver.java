package androlua;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class LuaBroadcastReceiver extends BroadcastReceiver {

    private OnReceiveListener mRlt;

    public LuaBroadcastReceiver(OnReceiveListener rlt) {
        mRlt = rlt;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if (mRlt == null) {
            return;
        }
        mRlt.onReceive(context, intent);
    }

    public interface OnReceiveListener {
        void onReceive(Context context, Intent intent);
    }
}
