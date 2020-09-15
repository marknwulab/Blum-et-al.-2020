macro "Campari RGB Tiffs [C]" {
//get variables, prior to running load a single image from the folder you will analyze
direct=getDirectory("image");
list = getFileList(direct);
directgray=direct+"Grayscale Tiffs"+File.separator;
directtime=direct+"Time Series"+File.separator;
File.makeDirectory(directgray);
File.makeDirectory(directtime);

for (i=0; i<list.length; i++) { 
    if (endsWith(list[i], ".czi")){ 
	file=direct+list[i];
	print(file);
	run("Bio-Formats Windowless Importer", "open=[file]");
	fname=getTitle;
	print(fname);
	name=substring(fname, 0, lengthOf(fname)-4);
	
	run("Z Project...", "projection=[Max Intensity] all");
	
	//This section saves grayscale tiffs of all channels/timepoints separately
	run("Stack to Images");
	selectWindow("MAX_"+name+"-0001");
	saveAs("Tiff", directgray+"MAX_"+name+"-G1.tif");
	selectWindow("MAX_"+name+"-0002");
	saveAs("Tiff", directgray+"MAX_"+name+"-R1.tif");
	selectWindow("MAX_"+name+"-0003");
	saveAs("Tiff", directgray+"MAX_"+name+"-G2.tif");
	selectWindow("MAX_"+name+"-0004");
	saveAs("Tiff", directgray+"MAX_"+name+"-R2.tif");
	
	imageCalculator("Divide create 32-bit", "MAX_"+name+"-R2.tif","MAX_"+name+"-R1.tif");
	imageCalculator("Divide create 32-bit", "MAX_"+name+"-G2.tif","MAX_"+name+"-G1.tif");
	selectWindow("Result of MAX_"+name+"-G2.tif");
	imageCalculator("Divide create 32-bit", "Result of MAX_"+name+"-R2.tif","Result of MAX_"+name+"-G2.tif");
	selectWindow("Result of Result of MAX_"+name+"-R2.tif");
	run("Fire");
	saveAs("Tiff", directgray+"Heat_MAX_"+name+"Heat.tif");
	close("*MAX*");
	
	//This section saves RGB tiffs of each timepoint with R/G information color coded
	selectWindow(fname);
	run("Z Project...", "projection=[Max Intensity] all");
	run("Channels Tool...");
	run("Green");
	Stack.setChannel(2);
	run("Magenta");
	Stack.setDisplayMode("composite");
	run("Stack to RGB", "slices frames keep");
	run("Stack to Images");
	selectWindow("MAX_"+name+"-1-0001");
	saveAs("Tiff", directtime+"MAX_"+name+"-T1.tif");
	close();
	selectWindow("MAX_"+name+"-1-0002");
	saveAs("Tiff", directtime+"MAX_"+name+"-T2.tif");
	run("Close All");
    } else {
    	write("Image Processing Complete");
    }
}
}