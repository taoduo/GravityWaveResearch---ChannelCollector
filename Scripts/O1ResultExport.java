import java.io.File;
import java.io.PrintWriter;
import java.util.List;
import java.util.ArrayList;
import java.io.FileFilter;
import java.util.Arrays;
/**
 * Export the results as a table in html
 */
public class O1ResultExport {
	public static PrintWriter writer;
	public static String outputName = "write-up.html";
	public static String inputPath = "/Users/duotao/Desktop/H1_plots";
	
	public static void main(String ... args) throws Exception {
		// output at where the java file is
		writer = new PrintWriter(outputName, "UTF-8");
		// input folder: it contains a list of folders
		File[] files = new File(inputPath).listFiles(new FileFilter() {
		    @Override
		    public boolean accept(File file) {
		        return !file.isHidden() && file.isDirectory();
		    }
		});
		Arrays.sort(files, (File o1, File o2)-> {
			double d = Double.parseDouble(o1.getName()) - Double.parseDouble(o2.getName());
			int ret = 0;
			if (d > 0) ret = 1;
			else if (d < 0)ret = -1;
			return ret;
		});
		writeTable(files);
		writer.close();
	}

	public static void writeTable(File[] files) {
		File[] chns, wks;
		// l is the freq of this line
		for (File l : files) {
			// get the first td of the row contains the frequency
			writer.println("<tr>\n<td>" + l.getName() + "</td>\n");
			chns = l.listFiles(new FileFilter() {
			    @Override
			    public boolean accept(File file) {
			        return !file.isHidden() && file.isDirectory();
			    }
			});
			// every channel in that line
			for (File c : chns) {
				writer.println("<td>\n<b>" + c.getName().substring(0, c.getName().length()) + "</b><br>");
				wks = c.listFiles(new FileFilter() {
				    @Override
				    public boolean accept(File file) {
				        return !file.isHidden();
				    }
				});
				Arrays.sort(wks, (File o1, File o2)-> {
					String[] s1 = o1.getName().split("\\.");
					String[] s2 = o2.getName().split("\\.");
					String n1 = s1[0];
					String n2 = s2[0];
					return Integer.parseInt(n1.substring(4)) - 
						Integer.parseInt(n2.substring(4));
				});
				// every week of that channel
				for (int i = 0; i < wks.length; i++) {
					writer.println("<a href=\"" + l.getName() + "/" + c.getName() + "/" + wks[i].getName() + "\">Week " + (i + 1) + "</a>");
				}
				writer.println("</td>");
			}
			writer.println("</tr>");
		}
	}
}
