import java.io.File;
import java.util.List;
import java.util.ArrayList;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Scanner;
import java.util.Collections;

/*
 * To generate hard coded java code to print large amounts of HTML
 * to a file. It takes in lines from the terminal and outputs
 * writer.println("<HTML>");
 * You can just copy the output from terminal into your java code
 * Readings from the command line input ends at a line with only "EOF" (literally)
 * To use, just run the code and put your HTML into the command line. Then end the input
 * with "EOF" in a new line.
 */
public class PrintGenerator {

	public static void main(String... args) {
		Scanner scn = new Scanner(System.in);
		List<String> list = new ArrayList<>();
		String s = "";
		while (!(s = scn.nextLine()).equals("EOF")) {
			list.add(s);
		}
		for (String n : list) {
			n = n.replace("\"", "\\\"");
			System.out.println("writer.println(\"" + n + "\");");
		}
		
	}
}