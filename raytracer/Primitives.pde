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
        ArrayList<RayHit> result = new ArrayList<RayHit>(); //<>//
        // TODO: Step 2: implement ray-sphere intersections
        
        // t_p = (c - o) * direction
        float projection = PVector.dot(PVector.sub(this.center, r.origin), r.direction);
        
        // p = o + t_p * direction
        PVector p = PVector.add(r.origin, PVector.mult(r.direction, projection));
        
        //calc the distance from p to c
        float distance = PVector.sub(this.center, p).mag();
        
        //calc t-values
        //t = t_p +/- sqrt(sq(radius) - sq(distance))
        float t1 = projection - sqrt(sq(this.radius) - sq(distance));
        float t2 = projection + sqrt(sq(this.radius) - sq(distance)); //<>// //<>//
        
        if((t1 > 0) && distance < this.radius){
          RayHit entry = new RayHit();
          
          PVector pEntry = PVector.add(r.origin, PVector.mult(r.direction, t1));
          
          entry.t = t1;
          entry.location = pEntry;
          entry.normal = PVector.sub(pEntry, this.center).normalize();
          entry.entry = true;
          entry.material = this.material;
          
          result.add(entry);
        }
        
        if((t2 > 0) && distance < this.radius){
          RayHit exit = new RayHit();
          
          PVector pExit = PVector.add(r.origin, PVector.mult(r.direction, t2));
          
          exit.t = t2;
          exit.location = pExit;
          exit.normal = PVector.sub(pExit, this.center).normalize();
          exit.entry = false;
          exit.material = this.material;
          
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
        float test = PVector.dot(PVector.sub(this.center, r.origin), this.normal);
        
        if (PVector.dot(r.direction, this.normal) != 0) {
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
            /*
            else if (t < 0) {
                RayHit rh = new RayHit();
                rh.t = Float.POSITIVE_INFINITY;
                rh.location = this.center;
                rh.normal = this.normal;
                rh.entry = false;
                rh.material = this.material;
                
                result.add(rh);
            }*/
            
            // Do we need a separate else if statement for when t = 0?
        }
        if ((PVector.dot(r.direction, this.normal) < 0) && (test > 0)){ // changed from (PVector.dot(r.direction, this.normal) > 0) && (test < 0)
            RayHit rh = new RayHit();
            rh.t = Float.POSITIVE_INFINITY;
            rh.location = this.center; //PVector.add(r.origin, PVector.mult(r.direction, Float.POSITIVE_INFINITY));
            rh.normal = this.normal;
            rh.entry = false;
            rh.material = this.material;
            
            result.add(rh);
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

abstract class Quadrics
{
    float radius;
    float height;
    Material material;
    float scale;
    
    Quadrics(float radius, Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        this.height = -1;
        this.radius = radius;
    }
    
    Quadrics(float radius, float height, Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        this.height = height;
        this.radius = radius;
    }
    
    abstract float calc_a(Ray r);
    abstract float calc_b(Ray r);
    abstract float calc_c(Ray r);
    abstract PVector calc_Normal(PVector p);
    ArrayList<RayHit> myFunction(float a, float b, float c, Ray r) // Temporary function name. 
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
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
            // entry.normal = new PVector(pEntry.x, pEntry.y, 0).normalize();
            entry.normal = calc_Normal(pEntry);
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
            // exit.normal = new PVector(pExit.x, pExit.y, 0).normalize();
            exit.normal = calc_Normal(pExit);
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
                    
                    result.add(entry);    // Should this be result.add(exit);
                 } 
               }
            }
          }        
        }       
        return result;
    }
}

class Cylinder extends Quadrics implements SceneObject
{
    Cylinder(float radius, Material mat, float scale)
    {
      super(radius, mat, scale);
    }
    
    Cylinder(float radius, float height, Material mat, float scale)
    {
        super(radius, height, mat, scale);
    }
    
    float calc_a(Ray r)
    {
        return sq(r.direction.x) + sq(r.direction.y);
    }
    
    float calc_b(Ray r)
    {
        return (2.0 * r.direction.x * r.origin.x) + (2.0 * r.direction.y * r.origin.y);
    }
    
    float calc_c(Ray r)
    {
        return sq(r.origin.x) + sq(r.origin.y) - sq(this.radius);
    }
    
    PVector calc_Normal(PVector p) 
    {
        return new PVector(p.x, p.y, 0).normalize();
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {   
        float a = calc_a(r);
        float b = calc_b(r);
        float c = calc_c(r);
        
        return myFunction(a, b, c, r);
    }
}

class Cone extends Quadrics implements SceneObject
{
    Cone(Material mat, float scale)
    {
        super(-1, mat, scale);
        //this.material = mat;
        //this.scale = scale;
        
        // remove this line when you implement cones
        //throw new NotImplementedException("Cones not implemented yet");
    }
    
    float calc_a(Ray r)
    {
        return sq(r.direction.x) + sq(r.direction.y) - sq(r.direction.z);
    }
    
    float calc_b(Ray r)
    {
        return (2.0 * r.direction.x * r.origin.x) + (2.0 * r.direction.y * r.origin.y) - (2.0 * r.direction.z * r.origin.z);
    }
    
    float calc_c(Ray r)
    {
        return sq(r.origin.x) + sq(r.origin.y) - sq(r.origin.z);
    }
    
    PVector calc_Normal(PVector p) 
    {
        // This should be (2x, 2y, -2z)
        return new PVector(2 * p.x, 2 * p.y, -2 * p.z).normalize();
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        //ArrayList<RayHit> result = new ArrayList<RayHit>();
        float a = calc_a(r);
        float b = calc_b(r);
        float c = calc_c(r);
        
        return myFunction(a, b, c, r);
    }
}

class Paraboloid extends Quadrics implements SceneObject
{
    Material material;
    float scale;
    
    Paraboloid(Material mat, float scale)
    {
        super(-1, mat, scale);
        // this.material = mat;
        // this.scale = scale;
        
        // remove this line when you implement paraboloids
        // throw new NotImplementedException("Paraboloid not implemented yet");
    }
    
    float calc_a(Ray r)
    {
        return sq(r.direction.x) + sq(r.direction.y);
    }
    
    float calc_b(Ray r)
    {
        return (2.0 * r.direction.x * r.origin.x) + (2.0 * r.direction.y * r.origin.y) - (r.direction.z);
    }
    
    float calc_c(Ray r)
    {
        return sq(r.origin.x) + sq(r.origin.y) - (r.origin.z);
    }
    
    PVector calc_Normal(PVector p) 
    {
        // This should be (2x, 2y, -1)
        return new PVector(2 * p.x, 2 * p.y, -1).normalize();
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        //ArrayList<RayHit> result = new ArrayList<RayHit>();
        float a = calc_a(r);
        float b = calc_b(r);
        float c = calc_c(r);
        
        return myFunction(a, b, c, r);
    }
   
}

class HyperboloidOneSheet extends Quadrics implements SceneObject
{
    Material material;
    float scale;
    
    HyperboloidOneSheet(Material mat, float scale)
    {
        super(-1, mat, scale);
        // this.material = mat;
        // this.scale = scale;
        
        // remove this line when you implement one-sheet hyperboloids
        // throw new NotImplementedException("Hyperboloids of one sheet not implemented yet");
    }
    
    float calc_a(Ray r)
    {
        return sq(r.direction.x) + sq(r.direction.y) - sq(r.direction.z);
    }
    
    float calc_b(Ray r)
    {
        return (2.0 * r.direction.x * r.origin.x) + (2.0 * r.direction.y * r.origin.y) - (2.0 * r.direction.z * r.origin.z);
    }
    
    float calc_c(Ray r)
    {
        return sq(r.origin.x) + sq(r.origin.y) - sq(r.origin.z) - 1;
    }
    
    PVector calc_Normal(PVector p) 
    {
        // This should be (2x, 2y, -2z)
        return new PVector(2 * p.x, 2 * p.y, -2 * p.z).normalize();
    }
  
    ArrayList<RayHit> intersect(Ray r)
    {
        //ArrayList<RayHit> result = new ArrayList<RayHit>();
        float a = calc_a(r);
        float b = calc_b(r);
        float c = calc_c(r);
        
        return myFunction(a, b, c, r);
    }
}

class HyperboloidTwoSheet extends Quadrics implements SceneObject
{
    Material material;
    float scale;
    
    HyperboloidTwoSheet(Material mat, float scale)
    {
        super(-1, mat, scale);
        // this.material = mat;
        // this.scale = scale;
        
        // remove this line when you implement two-sheet hyperboloids
        // throw new NotImplementedException("Hyperboloids of two sheets not implemented yet");
    }
    
    float calc_a(Ray r)
    {
        return sq(r.direction.x) + sq(r.direction.y) - sq(r.direction.z);
    }
    
    float calc_b(Ray r)
    {
        return (2.0 * r.direction.x * r.origin.x) + (2.0 * r.direction.y * r.origin.y) - (2.0 * r.direction.z * r.origin.z);
    }
    
    float calc_c(Ray r)
    {
        return sq(r.origin.x) + sq(r.origin.y) - sq(r.origin.z) + 1;
    }
    
    PVector calc_Normal(PVector p) 
    {
        // This should be (2x, 2y, -2z)
        return new PVector(2 * p.x, 2 * p.y, -2 * p.z).normalize();
    }
  
    ArrayList<RayHit> intersect(Ray r)
    {
        //ArrayList<RayHit> result = new ArrayList<RayHit>();
        float a = calc_a(r);
        float b = calc_b(r);
        float c = calc_c(r);
        
        return myFunction(a, b, c, r);
    }
}
