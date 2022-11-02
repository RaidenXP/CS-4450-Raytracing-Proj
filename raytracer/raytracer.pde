String input =  "data/tests/milestone3/test10.json";
String output = "data/tests/milestone3/test10.png";
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
    
    color shootRay(ArrayList<RayHit> hits, Ray currentRay, color initial){
      // function should be getting the hits of the current ray, the current ray, and the current color
      
      // loop has the same function to remove exits
      int i = 0; //<>//
      while ((i < hits.size()) && (hits.get(i).entry == false)) {
        i++;
      }
      
      // counter to keep track of how many reflections we've been through
      // not sure if the return is right here
      if(counter == scene.reflections){
        return initial; 
      }
      else{
        ++counter; 
      }
      
      // origin and direction stored to get ready for change
      PVector origin = currentRay.origin;
      PVector direction = currentRay.direction;
      
      if(i < hits.size() && hits.get(i).material.properties.reflectiveness > 0 && hits.get(i).material.properties.reflectiveness < 1){
         // hopefully changed origin to the point of impact with a little offset
         // is the math right here?
         origin = PVector.add(hits.get(i).location, PVector.mult(direction, EPS));
         
         // is this right for the original ray direction?
         PVector v = PVector.mult(direction, -1);
         
         // should be the direction reflected among the normal vector
         direction = PVector.sub(PVector.mult(PVector.mult(hits.get(i).normal, PVector.dot(hits.get(i).normal, v)), 2), v);
         
         Ray nextRay = new Ray(origin, direction);
         
         // getting new hits from the reflective ray
         ArrayList <RayHit> nextHits = new ArrayList<RayHit>();
         nextHits = scene.root.intersect(nextRay);
         
         if(nextHits.size() > 0){
             // same with the other loop just ignore exits
             int j = 0;
             while ((j < nextHits.size()) && (nextHits.get(j).entry == false)) {
               j++;
             }
             
             // get the light of the next object
             if (j < hits.size()){
               // mix the colors as we go
               color next = scene.lighting.getColor(nextHits.get(j), scene, nextRay.origin);
               return lerpColor(initial, shootRay(nextHits, currentRay, next),  nextHits.get(j).material.properties.reflectiveness);
             }
         }
         else{
           // if there are no hits just return the intial/previous color
           return initial;  
         }
      }
      else if(i < hits.size() && hits.get(i).material.properties.reflectiveness == 1){
         // same process as above to create a new reflection ray
         origin = PVector.add(hits.get(i).location, PVector.mult(direction, EPS));
         PVector v = PVector.mult(direction, -1);
         direction = PVector.sub(PVector.mult(PVector.mult(hits.get(i).normal, PVector.dot(hits.get(i).normal, v)), 2), v);
         
         Ray nextRay = new Ray(origin, direction);
         
         ArrayList <RayHit> nextHits = new ArrayList<RayHit>();
         nextHits = scene.root.intersect(nextRay);
         
         if(nextHits.size() > 0){
            int j = 0;
             while ((j < nextHits.size()) && (nextHits.get(j).entry == false)) {
               j++;
             }
             
             // this is the main difference. we dont need to mix colors we just continue with the color that was given by the reflection ray
             if (j < hits.size()){
               color next = scene.lighting.getColor(nextHits.get(j), scene, nextRay.origin);
               return shootRay(nextHits, currentRay, next);
             }
         }
         else{
           // if there are no hits then we just return the initial/previous color
           return initial;   
         }
      }
      else if(i < hits.size() && hits.get(i).material.properties.reflectiveness == 0){
        // if the object is not reflective we just return the previous/initial color
        return initial;
      }
      
      return initial;
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
      
      color colorCombo;
      
      Ray pixelRay = new Ray(origin, direction);
      
      ArrayList<RayHit> hits = scene.root.intersect(pixelRay);
      
      if (scene.reflections > 0)
      {
        if(hits.size() > 0){
          int i = 0;
          while ((i < hits.size()) && (hits.get(i).entry == false)) {
            i++;
          }
          
          color initial = scene.lighting.getColor(hits.get(i), scene, pixelRay.origin);
          colorCombo = shootRay(hits, pixelRay, initial);
          return colorCombo;
        }
          
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
