import java.io.File;
import java.io.PrintWriter;

public class ResultExport {
	public static PrintWriter writer;
	public static void main(String... args) throws Exception{
		writer = new PrintWriter("write-up.html", "UTF-8");
	    File[] files = new File("/Users/duotao/Desktop/gw/ResultsCleanupAgain").listFiles();
	    writeHead();
	    writeTable(files);
	    writeFoot();
	   	writer.close(); 
	}

	public static void writeTable(File[] files) {
		String freq;
		String cn;
	    for (File file : files) {
	        if (file.isDirectory()) {
	            System.out.println("Directory: " + file.getName());
	            if (file.getName().startsWith("line_")) {
	            	freq = file.getName().substring(5);
	            	writer.println("<tr>\n<td>" + freq + "</td>\n<td>");
	            	writeTable(file.listFiles());
	            	writer.println("</td>\n</tr>");
	            }
	        } else if (file.getName().endsWith("_data.jpg")) {
	        	cn = file.getName();
	        	cn = cn.substring(0, cn.length() - 9);
	            System.out.println("File: " + file.getName());
	            writer.println(cn + "<br>");
	        }
	    }
	}

	public static void writeHead() {
		writer.println("<!DOCTYPE html>\n<html>\n<head>\n<title>HTML Tables</title>\n</head>\n<body>");
		writer.println("<table border='1'>");
		writer.println("<tr>\n<th>Line(Hz)</th>\n<th>Found in Channels</th>\n</tr>");
	}

	public static void writeFoot() {
		writer.println("</table>");
		writer.println("</body>\n</html>");
	}
}