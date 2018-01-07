import sys
import os
import datetime
import time
import re

# globals
path = "" # path to the lines folder
source = "" # all the lines in one python call must have the same source
stats = {}


def loadSigfile(path):
    ret = {}
    with open(path, "r") as f:
        for line in f:
            sp = line.split('\t')
            chn = sp[0]
            sig = float(sp[1])
            ret[chn] = sig
    return ret


def getleaps():
    leaps = [46828800, 78364801, 109900802, 173059203, 252028804, 315187205, 346723206, 393984007, 425520008, 457056009, 504489610, 551750411, 599184012, 820108813, 914803214, 1025136015, 1119744016, 1167264017]
    return leaps


def isleap(gpsTime):
    isLeap = False
    leaps = getleaps()
    lenLeaps = len(leaps)
    for leap in leaps:
        if gpsTime == leap:
            isLeap = True
    return isLeap


def countleaps(gpsTime):
    leaps = getleaps()
    lenLeaps = len(leaps)
    nleaps = 0
    for i in range(0, lenLeaps):
        if (gpsTime >= leaps[i]):
            nleaps = nleaps + 1
    return nleaps


def gps2unix(gpsTime):
     unixTime = gpsTime + 315964800
     nleaps = countleaps(gpsTime)
     unixTime = unixTime - nleaps
     if (isleap(gpsTime)):
        unixTime = unixTime + 0.5
     return unixTime



def gpstoutc(gps):
    unix = gps2unix(gps)
    return str(datetime.datetime.utcfromtimestamp(unix))



def writehead(f, run, observatory, weeks, line, source):
    f.write("<!DOCTYPE html>\n")
    f.write("<html>\n")
    f.write("   <head>\n")
    f.write("       <title>" + observatory + " line " + line + " Hz</title>\n")
    f.write("       <link \n")
    f.write("       href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\" \n")
    f.write("       rel=\"stylesheet\" \n")
    f.write("       integrity=\"sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u\" \n")
    f.write("       crossorigin=\"anonymous\">\n")
    f.write("       <script\n")
    f.write("           src=\"https://code.jquery.com/jquery-3.1.1.min.js\"\n")
    f.write("           integrity=\"sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8=\"\n")
    f.write("           crossorigin=\"anonymous\">\n")
    f.write("       </script>\n")
    f.write("       <script \n")
    f.write("           src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js\" \n")
    f.write("           integrity=\"sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa\"\n")
    f.write("           crossorigin=\"anonymous\">\n")
    f.write("       </script>\n")
    f.write("       <style>\n")
    f.write("           .week-wrapper {\n")
    f.write("               margin-bottom: 10px;\n")
    f.write("           }\n")
    f.write("           .week-btn-open {\n")
    f.write("               font-weight: bold;\n")
    f.write("           }\n")
    f.write("       </style>\n")
    f.write("   </head>\n")
    f.write("   <body>\n")
    f.write("       <div class='container'>\n")
    f.write("       <header>\n")
    f.write("           <h4>\n")
    if (len(source) != 0):
        f.write("               Presented here are the coherence tool search results of a " + line + " Hz line during the " + run + " run at the " + observatory + " observatory.<br>\n")
        f.write("               The line is posted<a href='" + source + "'> here</a>.\n")
    else:
        f.write("               Presented here are the coherence tool search results of a " + line + " Hz line during the " + run + " run at the " + observatory + " observatory.\n")
    f.write('   <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#statModal">Summary</button>')
    f.write("           </h4>\n")
    
    # stats modal
    f.write('   <div class="modal fade" id="statModal" tabindex="-1" role="dialog" aria-labelledby="statModalLabel" aria-hidden="true">')
    f.write('    <div class="modal-dialog modal-lg" role="document">')
    f.write('      <div class="modal-content">')
    f.write('        <div class="modal-header">')
    f.write('          <h5 class="modal-title" id="statModalLabel">Summary</h5>')
    f.write('        </div>')
    f.write('        <div class="modal-body">')
    f.write('           <b>Channels occurrences total: ' + str(stats['totalChannel']) + "</b>" + '<span>  <a href="#" data-toggle="tooltip" title="One channels might occur multiple times in different weeks."> ? </a></span>' + "<br>")
    f.write('           <div class="row">')
    for key, value in sorted(stats['subsystemDict'].iteritems(), key=lambda (k,v): (v,k), reverse=True):
        if key.startswith("PEM-"):
            continue
        f.write('           <div class="col-md-3">')
        if key == "PEM":
            f.write("<em>" + key + "</em> - " + str(value) + " (")
            for k, v in stats['subsystemDict'].iteritems():
                if k.startswith("PEM-"):
                    f.write(k[4:] + ":" + str(v) + ". ")
            f.write(")")
        else:
            f.write("<em>" + key + "</em> - " + str(value))
        f.write('            </div>')

    f.write('           </div>') # close row
    f.write('           <b>Weeks: ' + str(stats['totalWeek']) + '/' + str(len(weeks)) + "</b><br>")

    f.write('           <b>Top 7 sigficant channels: </b><br>')
    f.write('<table class="table">')
    f.write('<thead>')
    f.write('<tr>')
    f.write('  <th scope="col">Name</th>')
    f.write('  <th scope="col"># of Weeks</th>')
    f.write('  <th scope="col">Total Sigficance <span>  <a href="#" data-toggle="tooltip" title="The sum of z-scores of all occurrences of this channel."> ? </a></span></th>')
    f.write('</tr>')
    f.write('</thead>')
    f.write('<tbody>')
    channelDictList = sorted(stats['channelStats'].items(), key=lambda x:x[1][1], reverse=True)
    limit = 7
    for tup in channelDictList:
        f.write('<tr>')
        f.write('  <th scope="row">' + tup[0][:-12] + '</th>')
        f.write('  <td>' + str(tup[1][0]) + '</td>')
        f.write('  <td>' + str(round(tup[1][1],2)) + '</td>')
        f.write('</tr>')
        limit = limit - 1
        if limit == 0:
            break
    f.write('</tbody>')
    f.write('</table>')

    f.write('       </div>') # close modal body
    f.write('        <div class="modal-footer">')
    f.write('           <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>')
    f.write('        </div>')
    f.write('      </div>')
    f.write('    </div>')
    f.write('  </div>')

    # help modal
    f.write('   <button type="button" class="btn btn-info" data-toggle="modal" data-target="#exampleModal" style="position:absolute;top:10px;right:10px">Readme</button>')
    f.write('   <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">')
    f.write('    <div class="modal-dialog modal-lg" role="document">')
    f.write('      <div class="modal-content">')
    f.write('        <div class="modal-header">')
    f.write('          <h5 class="modal-title" id="exampleModalLabel">Help</h5>')
    f.write('        </div>')
    f.write('        <div class="modal-body">')
    f.write('          <em>- The coherence data is integrated weekly.</em><br>')
    f.write('          <em>- The resolution of the coherence tool is 1 mHz.</em><br>')
    f.write('          <em>- Button disabled means there is no significant coherence found in the data of that week. Button with delete line means the data is not available for that week.</em><br>')
    f.write('          <em>- The dates indicate the start of the integration week in UTC, with GPS time in parenthesis.</em><br>')
    f.write('          <em>- Click on the channel to save the plot. </em><br>')
    f.write('          <em>- Definition of significance coherence: the distribution is modeled with half normal distribution. A significant coherence is defined as being more than seven standard deviations off the center, which is mostly zero (i.e. |z-score| > 7) and the value of deviation greater than 0.025. \
        The confidence of this correlation is close to one within 10<sup>-11</sup>.</em><br>')
    f.write('          <em>- The numbers in the parenthesis after the channels are the z-scores of the significant coherence found as is defined above.</em><br>')
    f.write('          <em>- "Significance" refers to the total z-scores of all occurences of a channel. That is used to indicate how much a channel is related to the noise line. </em><br>')
    now = datetime.datetime.now()
    f.write('          <em>- This is produced by Duo Tao at ' + str(now.year) + '-' + str(now.month) + '-' + str(now.day) +  '. Contact Duo if there are any questions, problems or suggestions.</em>')
    f.write('        </div>')
    f.write('        <div class="modal-footer">')
    f.write('           <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>')
    f.write('        </div>')
    f.write('      </div>')
    f.write('    </div>')
    f.write('  </div>')


def writeweeksbtn(f, linefolder, weeks):
    f.write("       <div class='col-md-3' style='overflow:auto; height:500px; border-style: inset;'>\n")
    f.write("       <ul class='list-inline'>\n");
    for week in weeks:
        weekstart = week.split("_")[2]
        if (week.endswith("_NODATA")):
            f.write("           <li><button disabled class='btn btn-default week-btn' data-target='#" + weekstart + "' style='text-decoration: line-through;'> " + str(gpstoutc(int(weekstart))) + "(" + weekstart + ")</a></li>\n")
            continue
        chns = os.listdir(os.path.join(linefolder, week))
        if len(chns) != 0:
            f.write("           <li><button class='btn btn-default week-btn' data-target='#" +  weekstart + "'> " + str(gpstoutc(int(weekstart))) + "(" + weekstart + ")</a></li>\n")
        else:
            f.write("           <li><button disabled class='btn btn-default week-btn' data-target='#" +  weekstart + "'> " + str(gpstoutc(int(weekstart))) + "(" + weekstart + ")</a></li>\n")
    f.write("       </ul>\n")
    f.write("       </div>\n")


def writeweek(f, weekfolder, week):
    # weekfolder: the folder that contains channels of the week
    # week: the folder name of the week
    sigfile = os.path.join(weekfolder, 'sig.txt')
    if os.path.isfile(sigfile): # if there is any channel in that week
        sigdict = loadSigfile(sigfile)
        files = os.listdir(weekfolder)
        channels = []
        for c in files:
            if not c.startswith(".") and c.endswith(".jpg"):
                channels.append(c)
        channels = sorted(channels)
        # print the first part
        weekstart = week.split("_")[2]
        f.write("               <li class='week-wrapper collapse' id='" + weekstart + "'>\n")
        f.write("                   <h4>" + str(gpstoutc(int(weekstart))) + " (" + weekstart + ")</h4>\n")
        f.write("                   <ul class='list-unstyled'>\n")
        # print the channels
        for chn in channels:
            f.write("                   <li>\n")
            f.write("                       <a class='btn plot-link' href='./" + week + "/" + chn + "' data-plot='./" + week + "/" + chn + "'>" + \
                chn[:-12] + "</a>(" + str(round(sigdict[chn[:-4]], 2)) + ")\n")
            f.write("                   </li>\n")
        f.write("                   </ul>\n")
        f.write("               </li>\n")


def writefoot(f):
    f.write("           <img src=\"\" id=\"plot\" style=\"z-index:10;position:fixed;bottom:10px;display:none\" class=\"img-fluid img-thumbnail col-md-5\" alt=\"\">\n")
    f.write("           </div>\n")
    f.write("       </div>\n")
    f.write("       <script>\n")
    f.write("           $('.plot-link').hover(function() {\n")
    f.write("               $('#plot').show();\n")
    f.write("               $('#plot').attr(\"src\", $(this).attr('data-plot'));\n")
    f.write("           });\n") 
    f.write("           $('.plot-link').mouseout(function() {$('#plot').hide();});\n")
    f.write("           $('.week-btn').click(function() {\n")
    f.write("               var weekList = $($(this).attr('data-target'));\n")
    f.write("               weekList.show();\n")
    f.write("               weekList.siblings().hide();\n")
    f.write("               $('.week-btn-open').removeClass('week-btn-open');\n")
    f.write("               $(this).addClass('week-btn-open');\n")
    f.write("           });\n")
    f.write("           $(document).ready(function(){")
    f.write("               $('[data-toggle=\"tooltip\"]').tooltip();   ")
    f.write("           });")
    f.write("       </script>\n")
    f.write("   </body>\n")
    f.write("</html>\n")


def statCalc(path, weeks):
    ''' subsystem summary
    path: path to the line folder
    weeks: folder names of the weeks
    '''
    subsysDict = {}
    channelDict = {} # value: [week count, signficance total]
    chnTot = 0
    wkTot = 0
    for week in weeks:
        if not week.startswith("."):
            weekfolder = os.path.join(path, week)
            files = os.listdir(weekfolder)
            # get the file names of the channels
            channels = []
            for c in files:
                if not c.startswith(".") and c.endswith(".jpg"):
                    channels.append(c)
            channels = sorted(channels)
            if len(channels) != 0:
                wkTot = wkTot + 1
            # statistics calculations
            for chn in channels:
                chnTot = chnTot + 1
                # subsystem stats
                p = re.compile("[\/:]")
                subsys = p.split(chn.split("-")[0])[1]
                if subsys in subsysDict:
                    subsysDict[subsys] = subsysDict[subsys] + 1
                else:
                    subsysDict[subsys] = 1
                if subsys == "PEM":
                    station = chn.split("-")[1].split("_")[0]
                    subsys = "PEM-" + station
                    if subsys in subsysDict:
                        subsysDict[subsys] = subsysDict[subsys] + 1
                    else:
                        subsysDict[subsys] = 1
                # channels stats
                sigfile = os.path.join(weekfolder, 'sig.txt')
                sigdict = {}
                if os.path.isfile(sigfile): # if there is any channel in that week
                    sigdict = loadSigfile(sigfile)
                if chn in channelDict:
                    tup = channelDict[chn]
                    channelDict[chn] = (tup[0] + 1, tup[1] + sigdict[chn[:-4]])
                else:
                    channelDict[chn] = (1, sigdict[chn[:-4]])
    stats['subsystemDict'] = subsysDict
    stats['totalChannel'] = chnTot
    stats['channelStats'] = channelDict
    stats['totalWeek'] = wkTot


def writeline(path, run, observatory, source, line):
    # path: the path to the line folder
    weeks = [w for w in os.listdir(path) if not w.startswith(".") and w.endswith("_webpage")]
    weeks = sorted(weeks, key=lambda week: int(week.split("_")[2]))
    statCalc(path, weeks)
    f = open(os.path.join(path, "index.html"), "w+")
    writehead(f, run, observatory, weeks, line, source)
    f.write("        <div class='row'>\n")
    writeweeksbtn(f, path, weeks)
    f.write("           <div class='col-md-4'>\n")
    f.write("               <ul class='list-unstyled'>\n")
    for week in weeks:
        if not week.startswith("."):
            weekfolder = os.path.join(path, week)
            writeweek(f, weekfolder, week)
    f.write("               </ul>\n")
    f.write("           </div>\n")
    writefoot(f)
    f.close()
    stats.clear()

'''
command line args
args[1] : path to the lines folder
args[2] : source of the lines, ignore if no source
'''
if __name__ == "__main__":
    path = sys.argv[1] # path to the lines folder
    source = ""
    if len(sys.argv) == 3:
        source = sys.argv[2]
    for line in os.listdir(path):
        if len(line.split("_")) == 4:
            linedir = os.path.join(path, line)
            temp = line.split("_")
            run = temp[0]
            observatory = temp[1]
            l = temp[3]
            if os.path.isdir(linedir):
                writeline(linedir, run, observatory, source, l)
                print("<li><a href='" + run + "_" + observatory + "_line_" + l + "/index.html'>" + run + "/" + observatory + " " + l + "Hz line</a></li>")