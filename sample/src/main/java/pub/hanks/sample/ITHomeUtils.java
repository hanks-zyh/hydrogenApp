package pub.hanks.sample;

import java.security.Key;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

/**
 * Created by hanks on 2017/5/27. Copyright (C) 2017 Hanks
 */

public class ITHomeUtils {

    public static String byteToString(byte[] bArr) {
        StringBuffer stringBuffer = new StringBuffer();
        for (byte b : bArr) {
            String toHexString = Integer.toHexString(b & 255);
            System.out.println(b + "," + toHexString);
            if (toHexString.length() == 1) {
                stringBuffer.append("0" + toHexString);
            } else {
                stringBuffer.append(toHexString);
            }
        }
        return stringBuffer.toString();
    }

    public static String desEncode(String id) throws Exception {
        Key secretKeySpec = new SecretKeySpec("p#a@w^s(".getBytes(), "DES");
        Cipher instance = Cipher.getInstance("DES/ECB/NoPadding");
        instance.init(1, secretKeySpec);
        int length = id.length();
        // 补充为 8 个
        if (length < 8) {
            length = 8 - length;
        } else {
            length %= 8;
            if (length != 0) {
                length = 8 - length;
            } else {
                length = 0;
            }
        }
        int i = 0;
        while (i < length) {
            id = id + "\u0000";
            i++;
        }
        return byteToString(instance.doFinal(id.getBytes()));
    }
}
