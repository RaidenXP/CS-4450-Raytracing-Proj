String input =  "data/tests/submission4/test26.json";
String output = "data/tests/submission4/test26.png";

//String input =  "data/tests/milestone4/test11.json";
//String output = "data/tests/milestone4/test11.png";

int repeat = 0;

int iteration = 1;

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
    }/**/
    
    // This may be useful for debugging:
    // only draw a 3x3 grid of pixels, starting at (315,315)
    // comment out the full loop above, and use this
    // to find issues in a particular region of an image, if necessary
   /* int w = 20;
    int h = 30;
    for (int i = 0; i< w; ++i)
    {
      for (int j = 0; j< h; ++j)
         set(320+i,100+j, rt.getColor(310+i,100+j));
    }/**/
    
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
        
        //initialize the surface color
        color surfaceColor = color(0,0,0);
        
        surfaceColor = scene.lighting.getColor(hits.get(0), scene, currentRay.origin);
        
        // if there is some reflectiveness then we create a redirected ray
        if(scene.reflections > 0 && hits.get(0).material.properties.reflectiveness > 0 && hits.get(0).entry){
          // shoots one last redirected ray if possible otherwise returns surface color or background
          // uses same process below after this if-else block;
          // will now no longer shoot one extra ray to see if we can fix things
          if(counter >= scene.reflections){
            return surfaceColor; 
          }
          else{
            ++counter; 
          }
         
          // origin of the redirected ray starts on the hit location with some offset
          PVector nextOrigin = hits.get(0).location; //PVector.add(hits.get(i).location, PVector.mult(currentRay.direction, EPS));
          
          // v is the opposite direction of the current direction lol
          PVector v = PVector.mult(currentRay.direction, -1);
          
          // our new direction is found through 2 * N (N dot V) - V
          PVector nextDirection = PVector.sub(PVector.mult(hits.get(0).normal, 2 * PVector.dot(hits.get(0).normal, v)), v).normalize();
          
          Ray redirectedRay = new Ray(PVector.add(nextOrigin, PVector.mult(nextDirection, EPS)), nextDirection);
          
          // keep shooting our redirected ray
          color otherColor = shootRay(redirectedRay);

          // mix colors and return
          return lerpColor(surfaceColor, otherColor, hits.get(0).material.properties.reflectiveness);
        }
        // check for transparency if it is not reflective
        else if(hits.get(0).material.properties.transparency > 0){
          // there are still some things that need to be figured out (like how can we tell our current/next refraction index?)
          // as of right now we are assuming that we start from the air/environment
          // then head into a transparent item with refraction
          
          // if our ray hit is an entry rayhit then we start with a h1 of 1
          // else we start with an h1 of the item
          if(hits.get(0).entry){
            // h1/h2
            float coeff = 1/hits.get(0).material.properties.refractionIndex;
            
            // is this the ray vector?
            PVector i = currentRay.direction;
            
            // cos(theta1) = -i dot n
            float cos = PVector.dot(PVector.mult(i, -1.0), hits.get(0).normal);
            
            // (sin(theta2))^2 = (coeff)^2 * (1 - (cos(theta1))^2)
            float sin2 = sq(coeff) * ( 1.0 - sq(cos));
            
            float coeff2 = 0.0;
            
            if(1.0 - sin2 >= 0){
              // used to multiply with the normal vector
              coeff2 = (coeff * cos) - sqrt(1.0 - sin2); 
            }
            else{
              // maybe return background instead???!
              return surfaceColor; 
            }
            
            //refracted ray t = the formula in the project description
            PVector t = PVector.add(PVector.mult(i, coeff), PVector.mult(hits.get(0).normal, coeff2)).normalize();
            
            // what is t? is that the direction??? will the origin be somewhat inside the volume?
            // should we subtract instead of add to put it inside the volume?
            // cause adding makes it start slighty away from the location right?
            PVector nextOrigin = hits.get(0).location;
            Ray redirectedRay = new Ray(PVector.add(nextOrigin, PVector.mult(t, EPS)), t);
            
            // keep shooting till reach the end
            color otherColor = shootRay(redirectedRay);
            
            // mix colors
            return lerpColor(surfaceColor, otherColor, hits.get(0).material.properties.transparency);
          }
          else{
            //in the case of an exit hit not sure how to know what the next refraction Index will be
            
            // h1/h2 but reversed...?
            float coeff = 1/hits.get(0).material.properties.refractionIndex;
            
            //negated norm
            PVector newNorm = PVector.mult(hits.get(0).normal, -1);
            
            // is this the ray vector?
            PVector i = currentRay.direction;
            
            // cos(theta1) = -i dot n
            float cos = PVector.dot(PVector.mult(i, -1.0), newNorm);
            
            // (sin(theta2))^2 = (coeff)^2 * (1 - (cos(theta1))^2)
            float sin2 = sq(coeff) * ( 1.0 - sq(cos));
            
            float coeff2 = 0.0;
            
            if(1.0 - sin2 > 0){
              // used to multiply with the normal vector
              coeff2 = (coeff * cos) - sqrt(1.0 - sin2); 
            }
            else{
              return surfaceColor; 
            }
            
            //refracted ray t = the formula in the project description
            PVector t = PVector.add(PVector.mult(i, coeff), PVector.mult(newNorm, coeff2)).normalize();
            
            // what is t? is that the direction??? will the origin be somewhat inside the volume?
            // should we subtract instead of add to put it inside the volume?
            // cause adding makes it start slighty away from the location right?
            PVector nextOrigin = hits.get(0).location;
            Ray redirectedRay = new Ray(PVector.add(nextOrigin, PVector.mult(t, EPS)), t);
            
            // keep shooting till reach the end
            color otherColor = shootRay(redirectedRay);
            
            // mix colors
            return lerpColor(surfaceColor, otherColor, hits.get(0).material.properties.transparency);
          }
        }
        else{
          // case where reflectiveness is == 0
          // and case where transparency is == 0
          
          int f = 0;
          
          while ((f < hits.size()) && (hits.get(f).entry == false)) {
           f++;
          }
          
          if (f < hits.size())
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
      float u = - (x * 1.0 / w - 0.5);    // ??? I added the minus here because the pictures were flipped. I don't know why they were flipped.
      float v = - (y * 1.0 / h - 0.5);
      
      // Determine the axes for the arbitrary viewing direction
      PVector forward = scene.view;
      PVector left = new PVector(0,0,1).cross(forward).normalize();
      PVector up = forward.cross(left).normalize();
      
      //Direction is prob the direction of the ray to the pixel
      // PVector direction = new PVector(u * w, w/2, v * h).normalize(); // This was the old direction
      
      // Direction is the direction that we shoot the ray
      // Calculate the new direction using any arbitrary direction
      // Multiply left and up by tan(fov/2) to apply the specified fov
      left = PVector.mult(PVector.mult(left, u*w), tan(scene.fov / 2)); // Shouldn't this be normalized
      forward = PVector.mult(forward, w/2);
      up = PVector.mult(PVector.mult(up, v*h), tan(scene.fov/2));        // Shouldn't this be normalized
      PVector direction = PVector.add(PVector.add(left, forward), up).normalize();
      
      Ray pixelRay = new Ray(origin, direction);
      
      color colorCombo = shootRay(pixelRay);
      
      return colorCombo; 
    }
}
