package pub.hanks.luajandroid;

import org.junit.Test;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.zip.Adler32;
import java.util.zip.CheckedOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import static org.junit.Assert.assertEquals;

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
public class ExampleUnitTest {
    @Test
    public void testAdler32() throws Exception {
        String target = "ajavachecksum.zip";

        FileOutputStream fos = new FileOutputStream(target);

        //使用Adler32算法创建CheckedOutputStream校验输出流
        CheckedOutputStream checksum = new CheckedOutputStream(fos, new Adler32());
        ZipOutputStream zos = new ZipOutputStream(new BufferedOutputStream(checksum));

        int size = 0;
        byte[] buffer = new byte[1024];

        //
        // Get all text files on the working folder.
        //通过FilenameFilter取得所有txt文件
        File dir = new File(".");
        String[] files = dir.list(new FilenameFilter() {
            public boolean accept(File dir, String name) {
                if (name.endsWith(".txt")) {
                    return true;
                } else {
                    return false;
                }
            }
        });

        //压缩成ajavachecksum.zip
        for (int i = 0; i < files.length; i++) {
            System.out.println("压缩中...: " + files[i]);

            FileInputStream fis = new FileInputStream(files[i]);
            ZipEntry zipEntry = new ZipEntry(files[i]);
            zos.putNextEntry(zipEntry);

            while ((size = fis.read(buffer, 0, buffer.length)) > 0) {
                zos.write(buffer, 0, size);
            }

            zos.flush();
            zos.closeEntry();
            fis.close();
        }

        zos.flush();
        zos.close();

        System.out.println(" 校验码  : " + checksum.getChecksum().getValue());

    }

    @Test
    public void testStartWith(){
        System.out.println("asdas".startsWith("[a-z]"));
    }
}