import ij.*;
import ij.process.*;
import ij.gui.*;
import java.awt.*;
import ij.plugin.*;
// Import the plugin:
import ch.epfl.biop.MaxInscribedCircles;
import ch.epfl.biop.CirclesBasedSpine;
import ch.epfl.biop.CirclesBasedSpine$Settings;

import ij.plugin.frame.RoiManager

def Boolean headless_mode = GraphicsEnvironment.isHeadless()

IJ.run("Close All", "")

// create a test image
ImagePlus imp = IJ.createImage("Untitled", "8-bit black", 1024, 1024, 1)
int[] xpoints = [382,358,358,368,372,366,324,302,272,264,298,372,518,602,670,706,704,632,564,498,480,482,452]
int[] ypoints = [232,272,322,368,418,468,600,652,746,820,900,932,932,914,878,818,750,628,530,428,334,240,200]
Roi organoid_roi = new PolygonRoi(xpoints,ypoints,23,Roi.POLYGON)
imp.setRoi(organoid_roi)

def rm

if (!headless_mode) {
    imp.show()
    rm = new RoiManager()
    rm = rm.getRoiManager()
    rm.reset()
}	
IJ.run(imp, "Fill", "slice")
IJ.run(imp, "Select All", "")

println "Run findCircles"
ArrayList<Roi> circles = MaxInscribedCircles.findCircles(imp, 20, false)
println "Done"

if (!headless_mode){
    for (Roi circle in circles) {
        rm.addRoi(circle)
    }
}

assert circles.size() == 25

Roi circle_roi = circles.get(0)
double circle_roi_radius = circle_roi.getStatistics().width / 2

assert circle_roi_radius == 192

println "Set settings"
CirclesBasedSpine sbp = new CirclesBasedSpine$Settings(imp)
 .closenessTolerance(50)
 .minSimilarity(0.30)
 .showCircles(false)
 .circles(circles)
 .build();
println "Done\nGet spine"
PolygonRoi spine = sbp.getSpine()
println "Done"


if (!headless_mode){
    rm.addRoi(spine)
}

double line_roi_length = spine.getLength()

assert line_roi_length < 794
assert line_roi_length > 793

return
