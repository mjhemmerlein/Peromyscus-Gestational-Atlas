showMessage("Select image for analysis ");
open();

run("Split Channels")

//
waitForUser("Choose mCherry (red) window for threshold");
run("Duplicate...", "title=mCherry");
//run("Threshold...");
setAutoThreshold("Otsu dark no-reset");
setThreshold(240, 255, "raw");
run("Create Mask");
rename("mCherry_mask");
run("Watershed");
run("Erode");
run("Dilate")

// Prompt the user to draw a freehand selection
setTool("freehand");
waitForUser("Draw a freehand selection around NK cell mass (mCherry_mask).");
// Analyze Particles within the active selection
run("Analyze Particles...", "size=50-15000 show=Outlines display summarize add")