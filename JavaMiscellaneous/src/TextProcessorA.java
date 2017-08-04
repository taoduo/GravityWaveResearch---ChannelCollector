import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Processed the MATLAB output of the SR project into MATLAB input as an array
 */
public class TextProcessorA {
    public static void main(String...args) {
        Pattern p1 = Pattern.compile("(\\d+)W.*");
        Pattern p2 = Pattern.compile(".*:(.*)");
        StringBuilder s = new StringBuilder();

        BufferedReader br = null;
        try {
            br = new BufferedReader(new FileReader(args[0]));
            String l1, l2, l3, l4, l5;
            while ((l1 = br.readLine()) != null) {
                l2 = br.readLine();
                l3 = br.readLine();
                l4 = br.readLine();
                l5 = br.readLine();
                br.readLine();
                Matcher m = p1.matcher(l1);
                String power = "", transmission = "", phase = "", omega = "", range = "";
                if (m.find()) {
                    power = m.group(1);
                }
                m = p2.matcher(l2);
                if (m.find()) {
                    transmission = m.group(1);
                }
                m = p2.matcher(l3);
                if (m.find()) {
                    phase = m.group(1);
                }
                m = p2.matcher(l4);
                if (m.find()) {
                    omega = m.group(1);
                }
                m = p2.matcher(l5);
                if (m.find()) {
                    range = m.group(1);
                }
                s.append(power + "," + transmission + "," + phase + "," + omega + "," + range + ";");
            }
            br.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.print(s.toString());
    }
}
