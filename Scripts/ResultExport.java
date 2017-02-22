import java.io.File;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.Comparator;
/*
 * Export the results as a table in html
 * To use run java ResultExport <input_folder>
 * The input folder structure:
 * <input_folder>/line_xx/<plots>
 * USED ONLY IN ER9, DOES NOT WORK FOR MULTIPLE WEEKS OF DATA
 */
public class ResultExport {
	public static PrintWriter writer;
	public static boolean newRow = true;

	public static void main(String ... args) throws Exception {
		// output at where the java file is
		writer = new PrintWriter("write-up.html", "UTF-8");
		// input folder: it 
		File[] files = new File(args[0]).listFiles();
		Arrays.sort(files, new Comparator<File>() {
			public int compare(File o1, File o2) {
				return (int) (o1.length() - o2.length());
			}
		});
		writeHead();
		writeTable(files);
		writeFoot();
		writer.close();
	}

	public static void writeTable(File[] files) {
		String freq;
		String cn;

		for (File file : files) {
			if (file.isDirectory() && file.getName().startsWith("line_")) {
				// print one line each time
				freq = file.getName().substring(5);
				// write the lines cell
				if (newRow) {
					writer.println("<tr>\n<td>" + freq + "</td>\n<td>");
					newRow = !newRow;
				} else {
					writer.println("<td>" + freq + "</td>\n<td>");
					newRow = !newRow;
				}
				// write the channels cell
		                File[] pics = file.listFiles();
				Arrays.sort(pics, new Comparator<File>() {
                                        public int compare(File o1, File o2) {
                                                return o1.getName().compareTo(o2.getName());
                                        }
                                });
				writeTable(pics);
				// end of this row
				if (newRow) {
					writer.println("</td>\n</tr>");
				} else {
					writer.println("</td>");
				}
			} else if (file.getName().endsWith("_DQ_data.jpg")) {
				cn = file.getName();
				cn = cn.substring(0, cn.length() - 12);
				writer.println("<a href='" + file.getParentFile().getName() + "/" + file.getName() + "'>" + cn + "</a><br>");
			}
		}
	}

	/**
	 * Write the html head and table head
	 */
	public static void writeHead() {
			writer.println("<!DOCTYPE html>\n<html>\n<head>\n<title>Line Search Write-Up</title>\n</head>\n<body>");
			writer.println("<table border='1'>");
			writer.println("<tr>\n<th>Line(Hz)</th>\n<th>Found in Channels</th>\n<th>Line(Hz)</th>\n<th>Found in Channels</th>\n</tr>");
	}

	public static void writeFoot() {
			writer.println("</table>");
			writer.println("</body>\n</html>");
	}
}
