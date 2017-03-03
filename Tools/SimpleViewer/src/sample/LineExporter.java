package sample;

import java.io.File;
import java.util.List;
import java.util.ArrayList;
import java.io.PrintWriter;
import java.util.Comparator;
import java.util.Collections;

/*
 * LineExporter.java
 * To use, do
 * java LineExporter <data_path>
 * data_path structure: <data_path>/<weeks_in_gps_time>/<channels>
 * <weeks_in_gps_time> example: L1_COH_1161388815_1161993615_SHORT_1_webpage
 * Export as html that works in the same folder as <data_path>
 * It is required that the tail of data_path end with line_xxx. eg. /line_50.12
 */
public class LineExporter {
	public static PrintWriter writer;

	public static void export(String... args) throws Exception {
		File[] files = new File(args[0]).listFiles();
		List<String> weeks = new ArrayList<>();
		for (File f : files) {
			if (!f.getName().startsWith(".") && f.isDirectory()) {
				weeks.add(f.getName());
			}
		}
		Collections.sort(weeks, new Comparator<String>() {
			public int compare(String o1, String o2) {
				int t1 = Integer.parseInt(o1.split("_")[2]);
				int t2 = Integer.parseInt(o2.split("_")[2]);
				return t1 - t2;
			}
		});

		writer = new PrintWriter(args[0] + "/index.html", "UTF-8");
		String observatory = weeks.get(0).split("_")[0];
		String[] line = args[0].split("/");
		String ln = line[line.length - 1].split("_")[1];
		writeHead(observatory, ln);
		for (int i = 0; i < weeks.size(); i++) {
			writeWeek(args[0] + "/" + weeks.get(i), "week " + (i + 1), weeks.get(i));
	    }
	    writeFoot();
	    writer.close();
	}

	/*
	 * path is the path to the week folder
	 */
	public static void writeWeek(String path, String week, String week_folder) {
		String id = week.replace(" ", "");
		writer.println("<li class='week-wrapper'>");
		writer.println("	<button class='btn btn-default' data-target='#" + id + "' data-toggle='collapse'>" + week.toUpperCase() + "</button>");
		writer.println("	<div class='collapse' id='" + id + "'>");
		writer.println("		<ul class='list-unstyled'>");
		File[] files = new File(path).listFiles();
		List<String> channels = new ArrayList<>();
		for (File f : files) {
			if (!f.getName().startsWith(".") && f.getName().endsWith(".jpg")) {
				channels.add(f.getName());
			}
		}
		Collections.sort(channels);

		for (int i = 0; i < channels.size(); i++) {
			writer.println("<li>");
			writer.println("	<a class='btn plot-link' data-plot='" + week_folder + "/" + channels.get(i) + "'>");
			writer.println("		" + channels.get(i).split("\\.")[0]);
			writer.println("	</a>");
			writer.println("</li>");
		}
		writer.println("		</ul>");
		writer.println("	</div>");
		writer.println("</li>");
	}

	public static void writeHead(String observatory, String line) {
		writer.println("<!DOCTYPE html>");
		writer.println("<html>");
		writer.println("	<head>");
		writer.println("		<title>" + observatory + " line " + line + " Hz</title>");
		writer.println("		<link ");
		writer.println("		href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\" ");
		writer.println("		rel=\"stylesheet\" ");
		writer.println("		integrity=\"sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u\" ");
		writer.println("		crossorigin=\"anonymous\">");
		writer.println("		<script");
		writer.println("			src=\"https://code.jquery.com/jquery-3.1.1.min.js\"");
		writer.println("			integrity=\"sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8=\"");
		writer.println("			crossorigin=\"anonymous\">");
		writer.println("		</script>");
		writer.println("		<script ");
		writer.println("			src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js\" ");
		writer.println("			integrity=\"sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa\"");
		writer.println("			crossorigin=\"anonymous\">");
		writer.println("		</script>");
		writer.println("		<style>");
		writer.println("			.week-wrapper {");
		writer.println("				margin-bottom: 10px;");
		writer.println("			}");
		writer.println("		</style>");
		writer.println("	</head>");
		writer.println("	<body>");
		writer.println("		<div class='container'>");
		writer.println("		<header>");
		writer.println("			<h4>");
		writer.println("				Presented here are the coherence tool search results of a " + line + " Hz line in " + observatory + ". The line is posted");
		writer.println("				<a href='#'> here</a>.");
		writer.println("			</h4>");
		writer.println("			<h5>(Comment)</h5>");
		writer.println("		</header>");
		writer.println("		<div class='row'>");
		writer.println("			<div class='col-md-4'>");
		writer.println("			<ul class='list-unstyled'>");
	}

	public static void writeFoot() {
		writer.println("			</ul>");
		writer.println("</div>");
		writer.println("<img src=\"\" id=\"plot\" style=\"z-index:-1;position:fixed;height:500px\"class=\"img-fluid img-thumbnail col-md-8\" alt=\"\">");
		writer.println("			</div>");
		writer.println("		</div>");
		writer.println("		<script>");
		writer.println("			$('.plot-link').hover(function() {");
		writer.println("				$('#plot').attr(\"src\", $(this).attr('data-plot'));");
		writer.println("			});");
		writer.println("		</script>");
		writer.println("	</body>");
		writer.println("</html>");
	}

}