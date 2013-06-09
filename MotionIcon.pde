//*********************//
//* Motion Image Icon *//
//*********************//
class MotionIcon {
  //--- Properties for a MotionIcon ---//
  //The image for this icon
  private PImage img;
  //Location, velocity, and direction of motion for this icon
  private PVector loc, vel, acc, dir;
  //Maximum speed of the icon
  private float maxSpeed;
  //The mass of this icon
  private float mass;
  //Color of the icon
  private color col; 
  //Has experienced wind
  private boolean hasWind = false;
  //Alpha channel [0, 255]
  private int opacity; 
  //Locking prevents movement of the icon
  boolean isLocked = false;
  //The count of pixels intersected with this icon
  private int lockCount = 0;
  //The maximum number of intersected pixels before this icon is locked
  private int maxLockCount;
  //Describes if we should draw this icon's direction of motion 
  boolean showDirection = false;
  //-- End Properties --//
  
  //--Settings vars --//
  //The standard resize width for icons with no width specified
  int RESIZE_WIDTH = 15;
  //The standard resize height for icons with no height specified
  int RESIZE_HEIGHT = 15;
  //How close our icon location can be to a title image location
  float PIXEL_THRESHOLD = 1;
  //This is how many title pixels we have to cross paths with before we lock
  //--We random it so that certain pixels stop earlier that others

  //--End Global
  
  //-- Begin Functionality for MotionIcon --//
  //--Constructor for loading an image icon and setting size to be 30x30
  MotionIcon(String imgPath) {
    initialize();
    //Set the image based on a given path
    img = loadImage(imgPath);
    
    //No dimensions given so use our standard dimensions
    img.resize(RESIZE_WIDTH, RESIZE_HEIGHT);
  }
  
  //--Constructor for loading icon with resized dimensions 
  MotionIcon(String imgPath, int w, int h) {
    initialize();
    //Set the image based on a given path
    img = loadImage(imgPath);
    //Resize icon
    img.resize(w, h);
  }
  
  //--Set the initial values for each motion Icon
  void initialize() {
    opacity = (int) random(60, 255);
    
   // println(opacity);
    mass = 1.0;              // Use this because we don't have an actual mass
    //loc = new PVector(width/2,height/2);  //Put starting location in the center
    /*Randomly place our image at some <X,Y> corrdinates
     * Note: that we cast to an int because screen coordinates are integers (10) and
     * not float/decimal values (ex. 10.2)
     */
    int randLocX = (int) random(0,width);      
    int randLocY = (int) random(0, height);
    loc = new PVector(randLocX, randLocY); 

    //Get random velocites values for x and y direction
    float velX = random(-0.04, 0.1);
    float velY = random(-0.04, 0.1);
    vel = new PVector(0,0);
    
    //Get random Acceleration value
    float accX = random(-0.1, 0.1);
    float accY = random(-0.1, 0.1); 
    acc = new PVector(0, 0);
    //acc = new PVector(-0.001,0.01);
    maxSpeed = 4;
    //Allow our pixel to move
    isLocked = false;
    //Get a max lock count for this pixel
    maxLockCount = int(random(1, 30));
    //println(maxLockCount); 
  }
  
  
  //--Updates motion values for this image
  void update() {
    //If our pixel is locked, we have no velocity or acceleration
    if (isLocked) {
      vel = new PVector(0,0);
      acc = new PVector(0,0);
    }
    //Apply wind
    if (hasWind) {
      acc.x = random(10.1, 16.0);
      acc.y = random(-13.7, 13.7);
    }
    //Apply gravity force 
    //Update Velocity - add acceleration to the velocity
    vel.add(acc);
    
    //Cap the velocity at maxSpeed
    //vel.limit(maxSpeed);  
    //Apply updated velocity to this images location
    loc.add(vel);
 
    //Reset acceleration
    acc.mult(0.0);
  }
  

  void applyGravity() {
    //Apply Normal Gravity scaled 
    float g = -0.01;
    PVector gravity = new PVector(0, g);
    acc.add(gravity);
  }
  
  
  //Returns this icon's x-coordinate such that the center of the icon
  //--is at point loc.x
  int getCenteredX() {
    return (int) (loc.x - 0.5*img.width); 
  }
  //Returns this icon's y-coordinate such that the center of the icon
  //--is at point loc.y
  int getCenteredY() {
    return (int) (loc.y - 0.5*img.height); 
  }
  //Returns this icon's centered location (the top-left location such that
  //--the middle of the icon is at (loc.x, loc.y)
  PVector getCenteredLocation() {
    return new PVector(getCenteredX(), getCenteredY()); 
  }
 
  //--Draws the image icon & if necessary the icon's direction
  void display() {
    //Get loc coordinates s.t. loc is at the middle of image
    int xMid = getCenteredX();
    int yMid = getCenteredY();
    //Apply an opacity change to the icon
    tint(255, opacity);
    //Draw the image with loc at the center of the image 
    image(img, xMid, yMid);
      
    //Draw the icon's direction of motion
    if (showDirection) {
      stroke(255,0, 0);
      int magX = (int) constrain(10*vel.x, 10, 20);
      magX = (vel.x < 0) ? -magX : magX;    //Sign adjustment
      int magY = (int) constrain(10*vel.y, 10, 20);
      magY = (vel.y < 0) ? -magY : magY;    //Sign adjustment
      line(loc.x, loc.y, xMid + magX, yMid + magY);
      strokeWeight(1);
    }
    //stroke(0);
    //fill(175);
    //ellipse(loc.x,loc.y,16,16);
    // println((int)loc.x + " , " + (int)loc.y);
  }


  //--Ensure our icon stays within our view frame
  void checkEdges() {
    //If we have wind, our icons should disappear from the display window
    if (hasWind) {
      return;
    }
    if (loc.x > width) {
      //upper bound (right of window)
      loc.x = width;
      vel.x *= -1;
    } else if (loc.x < 0) {
      //lower bound (left of window)
      loc.x = 0;
      vel.x *= -1;
    }
    if (loc.y > height) {
      //upper bound (bottom window)
      loc.y = height;
      vel.y *= -1;

    } else if (loc.y < 0) {
     //lower bound (top of window)
     loc.y = 0;
     vel.y *= -1;
    }  
  
  }

  //--Allows external forces to be added to the motion icon
  void applyForce(PVector force) {
     // Newton's Law: F = M*A
     //Get acceleration applied to this object 
     PVector a = force.div(force, mass); 
     //Apply force's acceleration to our acceleration of the object 
     acc.add(a);
  }
  
  //--Applies a  gravitational attraction force based on a title pixel's location
  //--relative to this icon's location
  //F = G(m1*m2)dir/(distance^2)
  void applyAttraction(PVector pixelLoc, float mass2) {
    //If we have an icon that is within a certain distance of a pixel force,
    //--don't move it (halt movement & no attraction)
    //Check if our icon is locked by being in the threshold of a pixel
    if (isLocked) {
      //If so, we don't have attraction, or update movement
      //print("LOCKED");
      return;
    }
    //Direction Vector between pixel and icon
    PVector iconLoc = getCenteredLocation();
    PVector dir = PVector.sub(pixelLoc, loc);//getCenteredLocation());
    
    //Distance b/w the two location points
    float distance = dir.mag();
    
    //Check to see if we should lock the pixel, because of its proximity
    if (distance <= PIXEL_THRESHOLD) {
      //print("NOW LOCKED");
      lockCount +=1;
      //Lock the pixel & do nothing
      if (lockCount == maxLockCount) {
        isLocked = true;
        return;
      }
    }
    //Prevents super strong force
    distance = constrain(distance,5.0,100.0);
    
    //Get Unit Direction Vector
    dir.normalize();
    
    //Calculate the gravitational force
    dir.mult(G*(mass*mass2)/(distance*distance));
    //Apply the force
    PVector gForce = dir.get();
    gForce.mult(10E7);
    
    //Apply the force
    applyForce(gForce);
  }

} // End MotionIcon Class Declaration
  

