showMessage("Select image for analysis ");
open();

run("Split Channels")

//
waitForUser("Choose dapi (blue) window");
run("Blue");
rename("Dapi");
waitForUser("Choose mCherry (red) window");
run("Red");
rename("mCherry");
waitForUser("Choose GFP (green) window");
run("Green")
rename("GFP")

//
run("Merge Channels...", "c1=mCherry c2=GFP c3=Dapi create");
run("Channels Tool...");
waitForUser("Select Channel 1 and Channel 2");
waitForUser("Close 'Channels Window'; Check for NKs in placental zones and conduct placental measurements");
run("Set Scale...", "distance=1536 known=1 unit=micron global")
