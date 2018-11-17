package androlua.utils;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.View;
import android.widget.EditText;

import com.luajava.LuaException;
import com.luajava.LuaObject;
import com.luajava.LuaTable;

import pub.hanks.luajandroid.R;

/**
 * DialogUtils
 * Created by hanks on 2017/6/30.
 */
public class DialogUtils {
    public static AlertDialog showWithInput(Context context, LuaTable config, final LuaObject callback) {
        if (!(context instanceof Activity)) {
            return null;
        }
        View view = View.inflate(context, R.layout.dialog_input, null);
        final EditText et = (EditText) view.findViewById(R.id.et);
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        if (config.containsKey("title")) {
            builder.setTitle((String) config.get("title"));
        }
        if (config.containsKey("msg")) {
            builder.setMessage((String) config.get("msg"));
        }
        if (config.containsKey("cancelable")) {
            builder.setCancelable((Boolean) config.get("cancelable"));
        }
        if (config.containsKey("content")) {
            et.setText((String) config.get("content"));
        }
        if (config.containsKey("hit")) {
            et.setText((String) config.get("content"));
        }
        if (config.containsKey("title")) {
            builder.setTitle((String) config.get("title"));
        }
        if (config.containsKey("ok")) {
            builder.setPositiveButton((String) config.get("ok"), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    try {
                        callback.call(et.getText().toString());
                    } catch (LuaException e) {
                        e.printStackTrace();
                    }
                }
            });
        } else {
            builder.setPositiveButton("确定", null);
        }
        if (config.containsKey("cancel")) {
            builder.setNegativeButton((String) config.get("cancel"), null);
        } else {
            builder.setNegativeButton("取消", null);
        }
        return  builder.create();
    }
}
