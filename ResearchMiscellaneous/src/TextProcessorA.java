import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Processed the MATLAB output of the SR project into MATLAB input as an array
 */
public class TextProcessorA {
    public static void main(String...args) {
        Scanner scanner = new Scanner(System.in);
        Pattern p1 = Pattern.compile("(\\d+)W.*");
        Pattern p2 = Pattern.compile(".*:(.*)");

        while (scanner.hasNextLine()) {
            String l1 = scanner.nextLine();
            String l2 = scanner.nextLine();
            String l3 = scanner.nextLine();
            String l4 = scanner.nextLine();
            String l5 = scanner.nextLine();
            scanner.nextLine();
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
            System.out.print(power + "," + transmission + "," + phase + "," + omega + "," + range + ";");
        }
    }
}
