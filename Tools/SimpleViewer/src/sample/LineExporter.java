package sample;

import java.io.File;
import java.util.List;
import java.util.ArrayList;
import java.io.PrintWriter;
import java.util.Collections;

/*
 * LineExporter.java
 * To use, do
 * java LineExporter <data_path>
 * data_path structure: <data_path>/<weeks_in_gps_time>/<channels>
 * 		** When no data, it should be <data_path>/<weeks_in_gps_time>NODATA
 * <weeks_in_gps_time> example: L1_COH_1161388815_1161993615_SHORT_1_webpage
 * Export as html that works in the same folder as <data_path>
 * It is required that the tail of data_path end with line_xxx. eg. /line_50.12
 */
class LineExporter {
	private static PrintWriter writer;

	/**
	 *
	 * @param location the location where html should be saved (no file name)
	 * @param comments the comments in the form of html
	 * @param source the source URL where line is found
	 * @throws Exception when things go wrong
	 */
	static void export(String location, String comments, String source) throws Exception {
		// init writer
		writer = new PrintWriter(location + "/index.html", "UTF-8");

		// get weeks
		File[] files = new File(location).listFiles();
		List<String> weeks = new ArrayList<>();
		if (files != null) {
			for (File f : files) {
				if (!f.getName().startsWith(".") && f.isDirectory()) {
					weeks.add(f.getName());
				}
			}
		}
		weeks.sort((o1, o2)->{
			int t1 = Integer.parseInt(o1.split("_")[2]);
			int t2 = Integer.parseInt(o2.split("_")[2]);
			return t1 - t2;
		});

		// some parameters
		String observatory = weeks.get(0).split("_")[0];
		String[] line = location.split("/");
		String ln = line[line.length - 1].split("_")[1];

		// modify weeks to include the full path
		for (int i = 0; i < weeks.size(); i++) {
			weeks.set(i, location + "/" + weeks.get(i));
		}
		writeHead(observatory, ln, weeks, comments, source);
		for (int i = 0; i < weeks.size(); i++) {
			writeWeek(new File(weeks.get(i)), "week " + (i + 1));
	    }
	    writeFoot();
	    writer.close();
	}

	private static void writeHead(String observatory, String line, List<String> weeks, String comments, String source) {
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
		writer.println("			.week-btn-open {");
		writer.println("				font-weight: bold;");
		writer.println("			}");
		writer.println("		</style>");
		writer.println("	</head>");
		writer.println("	<body>");
		writer.println("		<div class='container'>");
		writer.println("		<header>");
		writer.println("			<h4>");
		if (source.length() != 0) {
			writer.println("				Presented here are the coherence tool search results of a " + line + " Hz line in " + observatory + ". The line is posted");
			writer.println("				<a href='" + source + "'> here</a>.");
		} else {
			writer.println("				Presented here are the coherence tool search results of a " + line + " Hz line in " + observatory + ".");
		}
		writer.println("			</h4>");
		writer.println("			<h5>" + comments + "</h5>");
		writer.println("		</header>");
		writeWeekBtn(weeks);
		writer.println("		<div class='row'>");
		writer.println("			<div class='col-md-4'>");
		writer.println("			<ul class='list-unstyled'>");
	}

	/*
	 * Write the week buttons
	 */
	private static void  writeWeekBtn(List<String> weeks) {
		writer.println("		<ul class='list-inline'>");
		for (int i = 0; i < weeks.size(); i++) {
			if (weeks.get(i).endsWith("_NODATA")) {
				writer.println("			<li><button disabled class='btn btn-default week-btn' data-target='#week" + (i + 1) + "' data-toggle='collapse' style='text-decoration: line-through;'>WEEK " + (i + 1) + "</button></li>");
				continue;
			}
			File[] chns = new File(weeks.get(i)).listFiles();
			if (chns != null && chns.length != 0) { // normal
				writer.println("			<li><button class='btn btn-default week-btn' data-target='#week" + (i + 1) + "' data-toggle='collapse'>WEEK " + (i + 1) + "</button></li>");
			} else {
				writer.println("			<li><button disabled class='btn btn-default week-btn' data-target='#week" + (i + 1) + "' data-toggle='collapse'>WEEK " + (i + 1) + "</button></li>");
			}
		}
		writer.println("		</ul>");
	}

	/*
	 * Write the channel data for this week
	 */
	private static void writeWeek(File weekFolder, String week) {
		// get file lists and sort them
		File[] files = weekFolder.listFiles();
		List<String> channels = new ArrayList<>();
		if (files != null) {
			for (File f : files) {
				if (!f.getName().startsWith(".") && f.getName().endsWith(".jpg")) {
					channels.add(f.getName());
				}
			}
		}
		Collections.sort(channels);
		// print the first part
		String id = week.replace(" ", "");
		writer.println("				<li class='week-wrapper collapse' id='" + id + "'>");
		writer.println("					<h4>" + week.toUpperCase() + "</h4>");
		writer.println("					<ul class='list-unstyled'>");
		// print the channels
		channels.forEach((chn)-> {
			writer.println("					<li>");
			writer.println("						<a class='btn plot-link' data-plot='./" + weekFolder.getName() + "/" + chn + "'>");
			writer.println("							" + chn.split("\\.")[0]);
			writer.println("						</a>");
			writer.println("					</li>");
		});
		writer.println("					</ul>");
		writer.println("				</li>");
	}



	private static void writeFoot() {
		writer.println("			</ul>");
		writer.println("			</div>");
		writer.println("			<img src=\"\" id=\"plot\" style=\"z-index:-1;position:fixed;height:350px\"class=\"img-fluid img-thumbnail col-md-7\" alt=\"\">");
		writer.println("			</div>");
		writer.println("		</div>");
		writer.println("		<script>");
		writer.println("			$('.plot-link').hover(function() {");
		writer.println("				$('#plot').attr(\"src\", $(this).attr('data-plot'));");
		writer.println("			});");
		writer.println("			$('.week-btn').click(function() {");
		writer.println("				var weekList = $($(this).attr('data-target'));");
		writer.println("				weekList.parent().prepend(weekList);");
		writer.println("				if (weekList.hasClass('collapse')) {");
		writer.println("					$(this).toggleClass('week-btn-open');");
		writer.println("				}");
		writer.println("			});");
		writer.println("		</script>");
		writer.println("	</body>");
		writer.println("</html>");
	}
}