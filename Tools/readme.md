### Software Tools that help the research

* ChannelsViewer: made with Objective-C. Support multiple line search.

* SimpleViewer: made with JavaFX. Best for single line search.

* LineExporter: export the result of one line as collapsed weeks / channels

* PrintGenerator: generate the java code to print a chunk of HTML into a file

* ResultExport: export the search result of multiple lines as a table

* LineSplitter: an algorithm that splits the given lines to minimize the number of pictures generated and keep the between lines visible 

### Best Usages (depends on how many lines we have in the same plot)

* Single Line: Run MATLAB scritps and do the search in SimpleViewer. Then use LineExport to export to HTML.

* Multiple Lines: Give LineSplitter the lines we want to do search on. LineSplitter generates MATLAB code. MATLAB runs the code and gives the plot to ChannelsViewer. The output of ChannelViewer, when there are multiple lines, can be given to MultipleLineExporter and output the lines as an HTML table.
