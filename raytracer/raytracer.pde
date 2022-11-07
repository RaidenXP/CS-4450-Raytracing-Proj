String input =  "data/tests/milestone3/test5.json";
String output = "data/tests/milestone3/test5.png";

int repeat = 0;

int iteration = 0;

// If there is a procedural material in the scene,
// loop will automatically be turned on if this variable is set
boolean doAutoloop = true;

/*// Animation demo:
String input = "data/tests/milestone3/animation1/scene%03d.json";
String output = "data/tests/milestone3/animation1/frame%03d.png";
int repeat = 100;
*/


RayTracer rt;

void setup() {
  size(640, 640);
  noLoop();
  if (repeat == 0)
      rt = new RayTracer(loadScene(input));  
  
}

void draw () {
  background(255);
  if (repeat == 0)
  {
    PImage out = null;
    if (!output.equals(""))
    {
       out = createImage(width, height, RGB);
       out.loadPixels();
    }
    for (int i=0; i < width; i++)
    {
      for(int j=0; j< height; ++j)
      {
        color c = rt.getColor(i,j);
        set(i,j,c);
        if (out != null)
           out.pixels[j*width + i] = c;
      }
    }
    
    // This may be useful for debugging:
    // only draw a 3x3 grid of pixels, starting at (315,315)
    // comment out the full loop above, and use this
    // to find issues in a particular region of an image, if necessary
    /*for (int i = 0; i< 3; ++i)
    {
      for (int j = 0; j< 3; ++j)
         set(315+i,315+j, rt.getColor(315+i,315+j));
    }*/
    
    if (out != null)
    {
       out.updatePixels();
       out.save(output);
    }
    
  }
  else
  {
     // With this you can create an animation!
     // For a demo, try:
     //    input = "data/tests/milestone3/animation1/scene%03d.json"
     //    output = "data/tests/milestone3/animation1/frame%03d.png"
     //    repeat = 100
     // This will insert 0, 1, 2, ... into the input and output file names
     // You can then turn the frames into an actual video file with e.g. ffmpeg:
     //    ffmpeg -i frame%03d.png -vcodec libx264 -pix_fmt yuv420p animation.mp4
     String inputi;
     String outputi;
     for (; iteration < repeat; ++iteration)
     {
        inputi = String.format(input, iteration);
        outputi = String.format(output, iteration);
        if (rt == null)
        {
            rt = new RayTracer(loadScene(inputi));
        }
        else
        {
            rt.setScene(loadScene(inputi));
        }
        PImage out = createImage(width, height, RGB);
        out.loadPixels();
        for (int i=0; i < width; i++)
        {
          for(int j=0; j< height; ++j)
          {
            color c = rt.getColor(i,j);
            out.pixels[j*width + i] = c;
            if (iteration == repeat - 1)
               set(i,j,c);
          }
        }
        out.updatePixels();
        out.save(outputi);
     }
  }
  updatePixels();


}

class Ray
{
     Ray(PVector origin, PVector direction)
     {
        this.origin = origin;
        this.direction = direction;
     }
     PVector origin;
     PVector direction;
}

// TODO: Start in this class!
class RayTracer
{
    Scene scene;
    int counter;
    
    RayTracer(Scene scene)
    {
      setScene(scene);
    }
    
    void setScene(Scene scene)
    {
       this.scene = scene;
    }
    
    color shootRay(Ray currentRay){
      // only takes the current ray that is shot
      
      // shoots the ray and looks for the intersections //<>//
      ArrayList<RayHit> hits = scene.root.intersect(currentRay); //<>//
      
      // if the ray hits something we go get its color and check for reflections
      if(hits.size() > 0){
        // helps ignore the exit rays
        int i = 0;
        /*while ((i < hits.size()) && (hits.get(i).entry == false)) {
            i++;
        }*/
        
        //initialize the surface color
        color surfaceColor = color(0,0,0);
        
        // if our i is still in range and is an entry we get the color of the current object
        if(i < hits.size()){
          surfaceColor = scene.lighting.getColor(hits.get(i), scene, currentRay.origin);
        }
        
        // shoots one last redirected ray if possible otherwise returns surface color or background
        // uses same process below after this if-else block;
        if(counter > scene.reflections){
          if(i < hits.size() && hits.get(i).material.properties.reflectiveness > 0){
            PVector nextOrigin = PVector.add(hits.get(i).location, PVector.mult(currentRay.direction, EPS));
            PVector v = PVector.mult(currentRay.direction, -1);
            PVector nextDirection = PVector.sub(PVector.mult(hits.get(i).normal, 2 * PVector.dot(hits.get(i).normal, v)), v).normalize();
            
            Ray redirectedRay = new Ray(nextOrigin, nextDirection);
            
            ArrayList<RayHit> nextHits = scene.root.intersect(redirectedRay);
            
            if(nextHits.size() > 0){
              int j = 0;
              /*while ((j < nextHits.size()) && (nextHits.get(j).entry == false)) {
                  j++;
              }*/
              
              color otherColor = color(0,0,0);
              
              if(j < nextHits.size()){
                otherColor = scene.lighting.getColor(nextHits.get(j), scene, redirectedRay.origin);
                return lerpColor(surfaceColor, otherColor, hits.get(i).material.properties.reflectiveness);
              }
            }
          }
          else if(i < hits.size()){
            return surfaceColor; 
          }
          
          return scene.background;
        }
        else{
          ++counter; 
        }
        
        // if there is some reflectiveness then we create a redirected ray
        if(i < hits.size() && hits.get(i).material.properties.reflectiveness > 0){
          // origin of the redirected ray starts on the hit location with some offset
          PVector nextOrigin = hits.get(i).location; //PVector.add(hits.get(i).location, PVector.mult(currentRay.direction, EPS));
          
          // v is the opposite direction of the current direction lol
          PVector v = PVector.mult(currentRay.direction, -1);
          
          // our new direction is found through 2 * N (N dot V) - V
          PVector nextDirection = PVector.sub(PVector.mult(hits.get(i).normal, 2 * PVector.dot(hits.get(i).normal, v)), v).normalize();
          
          Ray redirectedRay = new Ray(PVector.add(nextOrigin, PVector.mult(nextDirection, EPS)), nextDirection);
          
          // keep shooting our redirected ray
          color otherColor = shootRay(redirectedRay);
          
          // mix colors and return
          return lerpColor(surfaceColor, otherColor, hits.get(i).material.properties.reflectiveness);
        }
        else if(i < hits.size()){
          // case where reflectiveness is == 0
          return surfaceColor; 
        }
        
      }
      
      // if we hit nothing it should be the background then
      // no real way to actually get the color of the previous/current color if there are no hits
      return scene.background;
    }
    
    color getColor(int x, int y)
    {
      PVector origin = scene.camera;
      float w = width;
      float h = height;
      
      counter = 0;
      
      //Code found on the slides
      //Seems like this is for general squared-scene cases
      //Calculating how far left or right and how far up or down we must go
      float u = x * 1.0 / w - 0.5;
      float v = - (y * 1.0 / h - 0.5);
      
      //Direction is prob the direction of the ray to the pixel
      PVector direction = new PVector(u * w, w/2, v * h).normalize();
      
      Ray pixelRay = new Ray(origin, direction);
      
      ArrayList<RayHit> hits = scene.root.intersect(pixelRay);
      
      if (scene.reflections > 0)
      {
          color colorCombo = shootRay(pixelRay);
          return colorCombo;   
      }
      else if(hits.size() > 0){
        // The while loop is used for not displaying objects that we are inside of
        int i = 0;
        while ((i < hits.size()) && (hits.get(i).entry == false)) {
          i++;
        }
        
        if (i < hits.size())
            return scene.lighting.getColor(hits.get(i), scene, pixelRay.origin);
      }
      
      /// this will be the fallback case
      return this.scene.background;
    }
}
