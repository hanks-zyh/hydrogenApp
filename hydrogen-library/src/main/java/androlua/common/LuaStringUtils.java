package androlua.common;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * 字符串处理
 * Created by hanks on 2016/11/29.
 */

public class LuaStringUtils {
    public static final String EMPTY_CHAR = "\u200B";

    public static boolean isEmpty(String s) {
        return s == null || s.length() == 0;
    }

    // 去除最后一行换行
    public static String trimEnd(String s) {
        if (!isEmpty(s) && (s.endsWith("\n") || s.endsWith(EMPTY_CHAR))) {
            return s.substring(0, s.length() - 1);
        } else {
            return s;
        }
    }

    public static boolean isEmptyTrim(String s) {
        return s == null || s.trim().length() == 0 || EMPTY_CHAR.equals(s);
    }

    public static String md5(String source) {
        String target = "";
        if (source == null)
            source = "";
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(source.getBytes());
            byte b[] = md.digest();
            int i;
            StringBuffer buf = new StringBuffer("");
            for (int offset = 0; offset < b.length; offset++) {
                i = b[offset];
                if (i < 0)
                    i += 256;
                if (i < 16)
                    buf.append("0");
                buf.append(Integer.toHexString(i));
            }
            target = buf.toString();

        } catch (NoSuchAlgorithmException e) {
        }
        return target;
    }

    public static boolean isUrl(String str) {
        return str != null && (str.startsWith("http://") || str.startsWith("https://"));
    }
}
