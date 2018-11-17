package androlua;

import android.support.annotation.NonNull;

import com.luajava.LuaException;
import com.luajava.LuaObject;
import com.luajava.LuaTable;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import androlua.common.LuaFileUtils;
import androlua.common.LuaLog;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.FormBody;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.logging.HttpLoggingInterceptor;
import pub.hanks.luajandroid.BuildConfig;

/**
 * context client for lua
 * Created by hanks on 2017/5/15. Copyright (C) 2017 Hanks
 */

public class LuaHttp {

    private static LuaHttp instance;
    private final OkHttpClient httpClient;

    private LuaHttp() {

        HttpLoggingInterceptor interceptor = new HttpLoggingInterceptor();
        interceptor.setLevel(HttpLoggingInterceptor.Level.BODY);
        OkHttpClient.Builder builder = new OkHttpClient.Builder();
        if (!"release".equals(BuildConfig.BUILD_TYPE)) {
            builder.addInterceptor(interceptor);
        }
        httpClient = builder.build();

    }

    public static LuaHttp getInstance() {
        if (instance == null) {
            synchronized (LuaHttp.class) {
                if (instance == null) {
                    instance = new LuaHttp();
                }
            }
        }
        return instance;
    }

    public static void cancelAll() {
        getInstance().httpClient.dispatcher().cancelAll();
    }

    public static void request(final LuaTable options, final LuaObject callback) {
        getInstance().httpClient.newCall(buildRequest(options))
                .enqueue(new Callback() {
                    @Override
                    public void onFailure(Call call, IOException e) {
                        try {
                            callback.call(e);
                        } catch (LuaException e1) {
                            LuaLog.e(e1);
                        }
                    }

                    @Override
                    public void onResponse(Call call, Response response) throws IOException {
                        try {
                            Object o = options.get("outputFile");
                            if (o != null) {
                                InputStream inputStream = response.body().byteStream();
                                String filePath;
                                if (o instanceof String) {
                                    filePath = (String) o;
                                } else {
                                    filePath = o.toString();
                                }
                                String outputFile = LuaFileUtils.saveToFile(inputStream, filePath);
                                callback.call(null, response.code(), outputFile);
                                return;
                            }
                            callback.call(null, response.code(), response.body().string());
                        } catch (LuaException e) {
                            LuaLog.e(e);
                        }
                    }
                });
    }

    public static void requestSync(final LuaTable options, final LuaObject callback) {
        try {
            Response response = getInstance().httpClient.newCall(buildRequest(options)).execute();
            Object o = options.get("outputFile");
            if (o != null) {
                InputStream inputStream = response.body().byteStream();
                String filePath;
                if (o instanceof String) {
                    filePath = (String) o;
                } else {
                    filePath = o.toString();
                }
                String outputFile = LuaFileUtils.saveToFile(inputStream, filePath);
                callback.call(null, response.code(), outputFile);
                return;
            }
            callback.call(null, response.code(), response.body().string());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @NonNull
    private static Request buildRequest(LuaTable options) {
        Request.Builder builder = new Request.Builder();
        String url = (String) options.get("url");
        builder.url(url);

        String method = (String) options.get("method");
        if ("GET".equals(method)) {
            builder.get();
        } else if ("POST".equals(method)) {
            RequestBody requestBody = getRequestBody(options);
            if (requestBody != null) {
                builder.post(requestBody);
            }
        } else if ("PUT".equals(method)) {
            RequestBody requestBody = getRequestBody(options);
            if (requestBody != null) {
                builder.put(requestBody);
            }
        } else if ("DELETE".equals(method)) {
            RequestBody requestBody = getRequestBody(options);
            if (requestBody != null) {
                builder.delete(requestBody);
            } else {
                builder.delete();
            }
        } else {
            builder.get();
        }

        LuaTable headers = (LuaTable) options.get("headers");
        if (headers != null) {
            for (Object key : headers.keySet()) {
                String value = (String) headers.get(key);
                int i = value.indexOf(":");
                if (i == -1) {
                    continue;
                }
                String[] header = new String[]{
                        value.substring(0, i),
                        value.substring(i + 1)
                };
                builder.header(header[0].trim(), header[1].trim());
            }
        }
        return builder.build();
    }

    private static RequestBody getRequestBody(LuaTable options) {

        String body = (String) options.get("body");
        if (body != null) {
            return RequestBody.create(MediaType.parse("application/json; charset=utf-8"), body);
        }


        Map formData = (Map) options.get("formData");
        if (formData != null) {
            FormBody.Builder bodyBuilder = new FormBody.Builder();
            for (Object key : formData.keySet()) {
                String value = (String) formData.get(key);
                int i = value.indexOf(":");
                if (i == -1) {
                    continue;
                }
                String[] params = new String[]{
                        value.substring(0, i),
                        value.substring(i + 1)
                };
                bodyBuilder.add(params[0].trim(), params[1].trim());
            }
            return bodyBuilder.build();
        }

        Map multipart = (Map) options.get("multipart");
        if (multipart != null) {
            MultipartBody.Builder bodyBuilder = new MultipartBody.Builder()
                    .setType(MultipartBody.FORM);
            for (Object key : multipart.keySet()) {
                String value = (String) multipart.get(key);
                int i = value.indexOf(":");
                if (i == -1) {
                    continue;
                }
                String[] params = new String[]{
                        value.substring(0, i),
                        value.substring(i + 1)
                };
                String itemKey = params[0].trim();
                String itemValue = params[1].trim();
                if (itemValue.startsWith("/")) {
                    File file = new File(itemValue);
                    if (file.exists()) {
                        bodyBuilder.addFormDataPart(itemKey, file.getName(),
                                RequestBody.create(MediaType.parse("image/png"), file));
                    }
                } else {
                    bodyBuilder.addFormDataPart(itemKey, itemValue);
                }
            }
            return bodyBuilder.build();
        }
        return new FormBody.Builder().build();
    }

    public static boolean downloadFile(String url, String savePath) {
        return downloadFile(url, savePath, null);
    }

    public static boolean downloadFile(String url, String savePath, ArrayList<String> headers) {
        try {
            final File file = new File(savePath);
            if (file.exists()) {
                return true;
            }
            OkHttpClient client = new OkHttpClient.Builder()
                    .connectTimeout(10, TimeUnit.SECONDS)
                    .writeTimeout(10, TimeUnit.SECONDS)
                    .readTimeout(30, TimeUnit.SECONDS)
                    .build();
            Request.Builder builder = new Request.Builder().url(url);
            if (headers != null) {
                for (String header : headers) {
                    int i = header.indexOf(":");
                    if (i <= 0) {
                        continue;
                    }
                    String key = header.substring(0, i);
                    String v = header.substring(i + 1);
                    builder.addHeader(key, v);
                }
            }
            final Request request = builder.build();
            Response response = client.newCall(request).execute();

            InputStream is = null;
            byte[] buf = new byte[2048];
            FileOutputStream fos = null;
            try {
                is = response.body().byteStream();
                fos = new FileOutputStream(file);
                int len = 0;
                while ((len = is.read(buf)) != -1) {
                    fos.write(buf, 0, len);
                }
                fos.flush();
            } catch (IOException e) {
                LuaLog.e(e);
            } finally {
                try {
                    if (is != null) {
                        is.close();
                    }
                    if (fos != null) {
                        fos.close();
                    }
                } catch (IOException e) {
                    LuaLog.e(e);
                }
            }
            return true;
        } catch (IOException e) {
            LuaLog.e(e);
            return false;
        }
    }

}
