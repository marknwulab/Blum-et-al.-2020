macro "Green Channel Puncta Analysis [C]" {
//get variables, prior to running load a single image from the folder you will analyze
direct=getDirectory("image");
list = getFileList(direct);
directz=direct+"Z-Stack"+File.separator;
File.makeDirectory(directz);
close("*");

for (i=0; i<list.length; i++) {
	if (endsWith(list[i], ".lsm")){  
	file=direct+list[i];
	run("Bio-Formats Windowless Importer", "open=[file]");
	fname=getTitle;
	name=substring(fname, 0, lengthOf(fname)-4);
	
	//run("Channels Tool...");
	Stack.setDisplayMode("color");
	run("Green");
	Stack.setChannel(2);
	run("Magenta");
	Stack.setDisplayMode("composite");
	
	//Setting the stacks for ZProject
	Stack.getDimensions(width, height, channels, slices, frames);
	waitForUser("Move to start of Zproject");
	Stack.getPosition(channel, slice, frame); // - Returns the current position.
	first=slice;
	Dialog.create("Title");
	Dialog.addNumber("How Many Slices Do You Want To Use?", 5);
	Dialog.show();
	thick=Dialog.getNumber();
	last=first+thick;
	run("Z Project...", "start='first' stop='last' projection=[Max Intensity]");
	saveAs("Tiff", directz+"MAX_"+name+".tif");
	run("Stack to RGB");
	saveAs("Jpg", directz+"MAX_"+name+".jpg");
	// Analyzing Puncta in Green Channel
	selectWindow("MAX_"+name+".tif");
	Stack.setDisplayMode("grayscale");
	Stack.setChannel(1);
	run("Stack to Images");
	selectWindow("MAX_"+name+"-0001");
	run("Auto Threshold", "method=MaxEntropy white show");
	run("Set Measurements...", "area redirect=None decimal=3");
	run("Analyze Particles...", "size=3-100 pixel show=[Count Masks] display clear summarize add in_situ");
	close();
	saveAs("Results", directz+name+"Size.csv");
	// Getting brightness values for all puncta
	open(directz+"MAX_"+name+".tif");
	Stack.setDisplayMode("grayscale");
	Stack.setChannel(1);
	run("Stack to Images");
	close();
	selectWindow("MAX_"+name+"-0001");
	run("Set Measurements...", "mean redirect=None decimal=3");
	roiManager("Multi Measure");
	saveAs("Results", directz+name+"intensity.csv");
	selectWindow("ROI Manager");  // remove this and the next line to see that the results table is not cleared
	run("Close"); 
    run("Close All");
	
	} else {
    	write("Image Processing Complete");
    }
	}
}