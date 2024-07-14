inputDirectory = getArgument();
open(inputDirectory + "/grains.png");
run("Morphological Filters", "operation=Erosion element=Square radius=2");
filename = getTitle();
print(filename);
