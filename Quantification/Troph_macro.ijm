showMessage("Select image for analysis ");
open();

run("Split Channels")

//
waitForUser("Choose GFP (green) window for threshold");
run("Duplicate...", "title=GFP");

//run("Threshold...");
setAutoThreshold("Otsu dark no-reset");
setThreshold(179, 255, "raw");
run("Create Mask");
rename("GFP_mask");
run("Watershed");
run("Erode");
run("Dilate")

// Analyze Particles within the active selection
setTool("freehand");
waitForUser("Draw a freehand selection around placenta (GFP_mask).");
// Analyze Particles within the active selection
run("Analyze Particles...", "size=50-15000 show=Outlines display summarize add")