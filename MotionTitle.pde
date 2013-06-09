//**************************************//
//** MainWindow for the motion images **//
//**************************************//


//--Initialization Vars
int windowHeight = 300;
int windowWidth = 1000;
int bgColor = 0;
boolean DEBUG_MODE = false; //false;

//--Background Image
//Directory for title image
String bgImageDir = "title/";
//Title Image Name
String bgImageName = (DEBUG_MODE) ? "title-rgb-white.png" : "title-separated-design.png";//"title-rgb17.png";
//Loaded Title Image
PImage bgTitleImage;
//Start X of title image
int bgTitleX;
//Start Y of title Image
int bgTitleY;
//List if colored pixels in the title image
ArrayList<PVector> titlePixels;
//Draws the title in the window
boolean showTitle = false;
//Draw Icon Directions
boolean showIconDirection = false;

//--Saving animation images - for conversion into a video
boolean saveOutput = false;
String outputPath = "output/";
int savedImageCount = 0;

//--Names of all the images for icons
String imageIconNames[] = { 
   "A.png", "amper.png", "D.png", "E.png", "G.png",
   "I.png", "N.png", "R.png", "S.png", "T.png"  };

//--Number of icons to make
int MAX_NUM_ICONS = 500;

//--Container for all made motion icons 
MotionIcon[] icons; // = new MotionIcon[1];

//--Setup the display window and all other variables/icons
void setup() {
  //Main View Window size
  size(windowWidth, windowHeight);
  smooth();
  background(bgColor, bgColor, bgColor);
  
  //Create title image centered in the window
  initTitleImage();
  
  /* Motion Icons Base Path 
   * - full path is basePath + fileName
   * - Ex: icons/someImage.png
   */
  //Motion Icons Creation
   //icon = new MotionIcon("icons/" +"A.png", 30, 30);
  initMotionIcons();
//  hideTitlePixels();
  
}

//--Creates the Title Image in the background
void initTitleImage() {
  //Make the global title image
  bgTitleImage = loadImage(bgImageDir + bgImageName);
  //bgTitleImage.resize(2*bgTitleImage.width, 2*bgTitleImage.height);
  //Set Centered Coordinates
  bgTitleX = (width/2) - bgTitleImage.width/2;
  bgTitleY = (height/2) - bgTitleImage.height/2;
  
  //Draw the title image
  updateTitle();
  
  //Now we get every non-black pixel value from our title image and store its
  //--adjusted centered pixel location in the display window.
  titlePixels = new ArrayList<PVector>();
  
  //Get bgTitleImage pixels
  bgTitleImage.loadPixels();
  // Loop through every title image pixel row
  for (int i = 0; i < bgTitleImage.width; i++) {
    //Loop through every title image pixel column
    for (int j = 0; j < bgTitleImage.height; j++) {
      // Use the formula to find the 1D location of current Pixel
      int pixLoc = i + j * bgTitleImage.width;
      //Get the pixelfrom the image
      color bgPixel = bgTitleImage.pixels[pixLoc];
      // Get the R,G,B values from the pixel
      float r = red(bgPixel);
      float g = green(bgPixel);
      float b = blue(bgPixel);
      //Check if our pixel has a color (i.e. it is not black or transparent)
      if (r == 17 && g == 17 && b == 17) {
      //if (r != 0 || g != 0 || b != 0) {
        //Compute the coordinates relative to the centered location in display window
        int newX = bgTitleX + i;
        int newY = bgTitleY + j;
        //Create a point from these coordinates
        PVector coords = new PVector(newX, newY);
        //Push the point into our titlePixels (for use with attraction later)
        titlePixels.add(coords);
      }
    }
  }
  //Finish dealing with the pixels
  bgTitleImage.updatePixels();  
  //print(titlePixels);
  //print(titlePixels.size());
}

//--Creates a bunch of MotionIcons from the given image names
void initMotionIcons() {
 //Number of image names
 int numImages = MAX_NUM_ICONS;//imgIconNames.length;
 //Create a bunch of motionIcons from the image names
 icons = new MotionIcon[numImages];
 for (int i = 0; i <  numImages; i++) {
   //Grab the image for an icon
   String imgNamePath = getImageIconPath(i); 
   //print(imgNamePath);  //Print image path to console.
   
   //Make a new MotionIcon with the image name
   icons[i] = new MotionIcon(imgNamePath); 
   //print(icons[i]);   //Print MotionIcon ID to make sure it isn't NULL
 }
}


//--Gets the path for an image icon based on an index for the imgIconNames 
//-Returns 'icons/' + <imageName.png>
String getImageIconPath(int index) {
  //Make sure index is within the bound of the image names
  index =  index % imageIconNames.length;
  //Base Path location - the folder our image icons are located
  String basePath = "icons/";
  //Return the full path to an image icon based on the input index
  return basePath + imageIconNames[index];
}


//--Draw the window and handle keypress events
void draw() {
  handleKeypress();
  //Save a frame as img with name output-0001, etc
  if (saveOutput) {
    saveFrame(outputPath+"/output-######.png"); 
    //Increment saved images count
    savedImageCount++;
    //Exit if we have a max of 9999 images saved;
    if(savedImageCount >= 9999) {
      println("Maximum number of images saved!");
      exit(); 
    }
  }
  //Clear previous image
  clearDisplay();
  //Update display of the Title
  updateTitle();
  //Update all of the MotionIcon movements
  updateIcons();
}
//--Clear the display
void clearDisplay() {
  noStroke();
  fill(0,0,0);
  rect(0,0,width,height); 
}

//--Handle keypress events
void handleKeypress() {
  if (keyPressed) {
    //Toggle title visibility
    if (key == ' ') {
      showTitle = !showTitle;
    }
    //Toggle saving output
    if (key == 's') {
      saveOutput = !saveOutput; 
    }
    //Restart animation
    if (key == 'r') {
      setup();
    }
    //Toggle Show Icon Direction
    if (key == 'd') {
      toggleDisplayIconDirections();
    }
    //Apply Wind
    if (key == 't') {
      applyIconWind(); 
    }
    //Lock all icons
    if (key == 'l') {
      lockIcons(); 
    }
    //Exit Application
    if(key ==ENTER || key == RETURN) {
      exit(); 
    }
  }   
}

//--Updates all of the MotionIcons (positions, display, etc);
void updateIcons() {
  //If we have an icon that is within a certain distance of a pixel
  for (int j = 0; j < icons.length; j++) {
    //Grab currentIcon
    MotionIcon currentIcon = icons[j];
    //Apply attraction forces for the currentIcon
    updateAttractionForces(currentIcon);
    //Update the position, velocity, and acceleration of the icon
    currentIcon.update();
    //Make sure the icon stays in the view window
    currentIcon.checkEdges();
    //Redraw thw icon
    currentIcon.display(); 
  } 
}

//--Updates attractive forces between motion icons and 'colored' bgTitleImage Pixels
void updateAttractionForces(MotionIcon icon) {
  for (int i = 0; i < titlePixels.size(); i++) {
    //Get the title pixel location
    PVector pixelLoc = titlePixels.get(i);
    //Now go through all motion icons
    icon.applyAttraction(pixelLoc, M2);
  }
}

//--Updates the display of the title image
void updateTitle() {
    if (showTitle) {
      image(bgTitleImage, bgTitleX, bgTitleY);
      hideTitlePixels();
    }
}

//--Prints the color values
//Newton's Gravitational Constant
static float G = 6.67428E-10;
static float M2 = 20.0;

void hideTitlePixels() {
  //Get pixels
  loadPixels();
  //Loop through every pixel
  for (int x = 0; x < width; x++) {
    // Loop through every pixel row
    for (int y = 0; y < height; y++) {
      // Use the formula to find the 1D location
      int loc = x + y * width;
      // Get the R,G,B values from image at pixel
      float r = red   (pixels[loc]);
      float g = green (pixels[loc]);
      float b = blue  (pixels[loc]);
      //Verify this is a title pixel (the color is not pure black)
      if  (r != 0 || g != 0 && b != 0) { //(r == 17 ) {
        //println(r);
        //Current Pixel Location

        //-Set the color of the image pixel to be black
        //-to blend in with the bg
        pixels[loc] = color(0,255,0);  
      }
    }
  }
  // When we are finished dealing with pixels
  updatePixels();
}

//--hide or show motion direction of MotionIscons
void toggleDisplayIconDirections() {
  showIconDirection = !showIconDirection;
  for (int i = 0; i < icons.length; i++) {
    //Grab currentIcon
    MotionIcon currentIcon = icons[i];
    //Toggle Show Icon Direction
    currentIcon.showDirection = showIconDirection;
  } 
}

//--hide or show motion direction of MotionIscons
void lockIcons() {
  for (int i = 0; i < icons.length; i++) {
    //Grab currentIcon
    MotionIcon currentIcon = icons[i];
    //Toggle Show Icon Direction
    currentIcon.isLocked = true;
  } 
}

//--Turns on the wind force for the motion icons
void applyIconWind() {
  for (int i = 0; i < icons.length; i++) {
    //Grab currentIcon
    MotionIcon currentIcon = icons[i];
    //Toggle Show Icon Direction
    currentIcon.hasWind = true;
  } 
 
}


