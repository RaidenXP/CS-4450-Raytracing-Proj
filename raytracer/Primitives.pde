class Sphere implements SceneObject
{
    PVector center;
    float radius;
    Material material;
    
    Sphere(PVector center, float radius, Material material)
    {
       this.center = center;
       this.radius = radius;
       this.material = material;
       
       // remove this line when you implement spheres
       //throw new NotImplementedException("Spheres not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>(); //<>// //<>// //<>//
        // TODO: Step 2: implement ray-sphere intersections
        
        // t_p = (c - o) * direction
        float projection = PVector.dot(PVector.sub(this.center, r.origin), r.direction);
        
        // p = o + t_p * direction
        PVector p = PVector.add(r.origin, PVector.mult(r.direction, projection));
        
        //calc the distance from p to c
        float distance = PVector.sub(this.center, p).mag();
        
        //calc t-values
        //t = t_p +/- sqrt(sq(radius) - sq(distance))
        float t1 = projection + sqrt(sq(this.radius) - sq(distance));
        float t2 = projection - sqrt(sq(this.radius) - sq(distance));
        
        if(t2 < t1){
          float temp = t1;
          t1 = t2;
          t2 = temp;
        } //<>//
        
        if ((t1 > 0 && t2 > 0) && distance < this.radius){
          RayHit entry = new RayHit(); //<>// //<>// //<>//
          RayHit exit = new RayHit();
          
          PVector pEntry = PVector.add(r.origin, PVector.mult(r.direction, t1));
          
          PVector pExit = PVector.add(r.origin, PVector.mult(r.direction, t2));
          
          entry.t = t1;
          entry.location = pEntry;
          entry.normal = PVector.sub(pEntry, this.center).normalize();
          entry.entry = true;
          entry.material = this.material;
          
          exit.t = t2;
          exit.location = pExit;
          exit.normal = PVector.sub(pExit, this.center).normalize();
          exit.entry = false;
          exit.material = this.material;
          
          result.add(entry);
          result.add(exit);
        }
        
        return result;
    }
}

class Plane implements SceneObject
{
    PVector center;
    PVector normal;
    float scale;
    Material material;
    PVector left;
    PVector up;
    
    Plane(PVector center, PVector normal, Material material, float scale)
    {
       this.center = center;
       this.normal = normal.normalize();
       this.material = material;
       this.scale = scale;
       
       // remove this line when you implement planes
       // throw new NotImplementedException("Planes not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        if ( PVector.dot(r.direction, this.normal) != 0) {
            float t = PVector.dot(PVector.sub(this.center, r.origin), this.normal) / PVector.dot(r.direction, this.normal);
            
            if (t > 0) { // should this be greater than or equal to 0?
                RayHit rh = new RayHit();
                rh.t = t;
                rh.location = PVector.add(r.origin, PVector.mult(r.direction, t));
                rh.normal = this.normal;
                if (PVector.dot(r.direction, this.normal) < 0)
                    rh.entry = true;
                else
                    rh.entry = false;
                rh.material = this.material;
                
                result.add(rh);
            }
            
            // Do we need a separate else if statement for when t = 0?
        }
        
        return result;
    }
}

class Triangle implements SceneObject
{
    PVector v1;
    PVector v2;
    PVector v3;
    PVector normal;
    PVector tex1;
    PVector tex2;
    PVector tex3;
    Material material;
    
    Triangle(PVector v1, PVector v2, PVector v3, PVector tex1, PVector tex2, PVector tex3, Material material)
    {
       this.v1 = v1;
       this.v2 = v2;
       this.v3 = v3;
       this.tex1 = tex1;
       this.tex2 = tex2;
       this.tex3 = tex3;
       this.normal = PVector.sub(v2, v1).cross(PVector.sub(v3, v1)).normalize();
       this.material = material;
       
       // remove this line when you implement triangles
       //throw new NotImplementedException("Triangles not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        if ( PVector.dot(r.direction, this.normal) != 0) {
          float t = PVector.dot(PVector.sub(this.v1, r.origin), this.normal) / PVector.dot(r.direction, this.normal);
          PVector p = PVector.add(r.origin, PVector.mult(r.direction, t));
    
          //Computing UV
          PVector e = PVector.sub(v2, v1);
          PVector g_prime = PVector.sub(v3, v1);
          PVector d = PVector.sub(p, v1);
          float denom = (PVector.dot(e, e) * PVector.dot(g_prime, g_prime)) - (PVector.dot(e, g_prime) * PVector.dot(g_prime, e));
          
          float u = ((PVector.dot(g_prime, g_prime) * PVector.dot(d, e)) - (PVector.dot(e, g_prime) * PVector.dot(d, g_prime))) / denom;
          float v = ((PVector.dot(e, e) * PVector.dot(d, g_prime)) - (PVector.dot(e, g_prime) * PVector.dot(d, e))) / denom;
          
          //Check to see if point is in triangle
          if( u >= 0 && v >= 0 && u+v <= 1){
            RayHit rh = new RayHit();
            rh.t = t;
            rh.location = p;
            rh.normal = this.normal;
            rh.u = u;
            rh.v = v;
            if (PVector.dot(r.direction, this.normal) < 0)
                rh.entry = true;
            else
                rh.entry = false;
            rh.material = this.material;
              
            result.add(rh);
          }
        }
        
        return result;
    }
}

class Cylinder implements SceneObject
{
    float radius;
    float height;
    Material material;
    float scale;
    
    Cylinder(float radius, Material mat, float scale)
    {
       this.radius = radius;
       this.height = -1;
       this.material = mat;
       this.scale = scale;
       
       // remove this line when you implement cylinders
       //throw new NotImplementedException("Cylinders not implemented yet");
    }
    
    Cylinder(float radius, float height, Material mat, float scale)
    {
       this.radius = radius;
       this.height = height;
       this.material = mat;
       this.scale = scale;
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        float a = sq(r.direction.x) + sq(r.direction.y);
        float b = (2.0 * r.direction.x * r.origin.x) + (2.0 * r.direction.y * r.origin.y);
        float c = sq(r.origin.x) + sq(r.origin.y) - sq(this.radius);
        
        float t1 = 0.0;
        float t2 = 0.0;
        
        if( 2 * a != 0 && (sq(b) - (4.0 * a * c)) >= 0){
          t1 = ((-1.0 * b) + (sqrt(sq(b) - (4.0 * a * c)))) / (2 * a);
          t2 = ((-1.0 * b) - (sqrt(sq(b) - (4.0 * a * c)))) / (2 * a);
        }
        
        if(t2 < t1){
            float temp = t1;
            t1 = t2;
            t2 = temp;
        }
        
        if( t1 > 0 && t2 > 0){
          RayHit entry = new RayHit();
          RayHit exit = new RayHit();
          
          PVector pEntry = PVector.add(r.origin, PVector.mult(r.direction, t1));
          
          PVector pExit = PVector.add(r.origin, PVector.mult(r.direction, t2));
          
          // check for entry of through the cylinder
          if((pEntry.z <= this.height && pEntry.z >= 0) || this.height == -1){
            entry.t = t1;
            entry.location = pEntry;
            entry.normal = new PVector(pEntry.x, pEntry.y, 0).normalize();
            entry.entry = true;
            entry.material = this.material;

            result.add(entry);
          }
          else if(pEntry.z > this.height){
            if(PVector.dot(r.direction, new PVector(0,0,1)) != 0){
               float tTop = PVector.dot(PVector.sub(new PVector(0, 0, this.height), r.origin), new PVector(0,0,1)) / PVector.dot(r.direction, new PVector(0,0,1));
               
               if(tTop > 0){
                 PVector top_entry = PVector.add(r.origin, PVector.mult(r.direction, tTop));
                 if(sq(top_entry.x) + sq(top_entry.y) <= sq(this.radius)){
                    entry.t = tTop;
                    entry.location = top_entry;
                    entry.normal = new PVector(0,0,1);
                    entry.entry = true;
                    entry.material = this.material;
                    
                    result.add(entry);
                 } 
               }
            }
          }
          else if(pEntry.z < 0){
            if(PVector.dot(r.direction, new PVector(0,0,-1)) != 0){
               float tBot = PVector.dot(PVector.sub(new PVector(0, 0, 0), r.origin), new PVector(0,0,-1)) / PVector.dot(r.direction, new PVector(0,0,-1));
               
               if(tBot > 0){
                 PVector bot_entry = PVector.add(r.origin, PVector.mult(r.direction, tBot));
                 if(sq(bot_entry.x) + sq(bot_entry.y) <= sq(this.radius)){
                    entry.t = tBot;
                    entry.location = bot_entry;
                    entry.normal = new PVector(0,0,-1);
                    entry.entry = true;
                    entry.material = this.material;
                    
                    result.add(entry);
                 } 
               }
            }
          }

          // check for the exit of the cylinder
          if ((pExit.z <= this.height && pExit.z >= 0) || this.height == -1){
            exit.t = t2;
            exit.location = pExit;
            exit.normal = new PVector(pExit.x, pExit.y, 0).normalize();
            exit.entry = false;
            exit.material = this.material;

            result.add(exit);
          }
          else if(pExit.z > this.height){
            if(PVector.dot(r.direction, new PVector(0,0,1)) != 0){
               float tTop = PVector.dot(PVector.sub(new PVector(0, 0, this.height), r.origin), new PVector(0,0,1)) / PVector.dot(r.direction, new PVector(0,0,1));
               
               if(tTop > 0){
                 PVector top_exit = PVector.add(r.origin, PVector.mult(r.direction, tTop));
                 if(sq(top_exit.x) + sq(top_exit.y) <= sq(this.radius)){
                    exit.t = tTop;
                    exit.location = top_exit;
                    exit.normal = new PVector(0,0,1);
                    exit.entry = false;
                    exit.material = this.material;
                    
                    result.add(exit);
                 } 
               }
            }
          }
          else if(pExit.z < 0){
            if(PVector.dot(r.direction, new PVector(0,0,-1)) != 0){
               float tBot = PVector.dot(PVector.sub(new PVector(0, 0, 0), r.origin), new PVector(0,0,-1)) / PVector.dot(r.direction, new PVector(0,0,-1));
               
               if(tBot > 0){
                 PVector bot_exit = PVector.add(r.origin, PVector.mult(r.direction, tBot));
                 if(sq(bot_exit.x) + sq(bot_exit.y) <= sq(this.radius)){
                    exit.t = tBot;
                    exit.location = bot_exit;
                    exit.normal = new PVector(0,0,-1);
                    exit.entry = false;
                    exit.material = this.material;
                    
                    result.add(entry);
                 } 
               }
            }
          }        

        }
        
        return result;
    }
}

class Cone implements SceneObject
{
    Material material;
    float scale;
    
    Cone(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement cones
       throw new NotImplementedException("Cones not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
   
}

class Paraboloid implements SceneObject
{
    Material material;
    float scale;
    
    Paraboloid(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement paraboloids
       throw new NotImplementedException("Paraboloid not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
   
}

class HyperboloidOneSheet implements SceneObject
{
    Material material;
    float scale;
    
    HyperboloidOneSheet(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement one-sheet hyperboloids
        throw new NotImplementedException("Hyperboloids of one sheet not implemented yet");
    }
  
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
}

class HyperboloidTwoSheet implements SceneObject
{
    Material material;
    float scale;
    
    HyperboloidTwoSheet(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement two-sheet hyperboloids
        throw new NotImplementedException("Hyperboloids of two sheets not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
}
