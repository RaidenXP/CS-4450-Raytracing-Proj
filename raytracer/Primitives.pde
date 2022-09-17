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
        PVector temp = PVector.sub(this.center, r.origin);
        float projection = PVector.dot(temp, r.direction);
        
        // p = o + t_p * direction
        temp = PVector.mult(r.direction, projection);
        PVector p = PVector.add(r.origin, temp);
        
        //calc the distance from p to c
        temp = PVector.sub(this.center, p);
        float distance = temp.mag();
        
        //calc t-values
        //t = t_p +/- sqrt(sq(radius) - sq(distance))
        float t1 = projection + sqrt(sq(this.radius) - sq(distance));
        float t2 = projection - sqrt(sq(this.radius) - sq(distance));
        
        //if(!(Float.isNaN(t1)))
        //{
        //  print(t1);
        //  print(" ");
        //  println(t2);
        //}
        
        if ((t1 < 0 || t2 < 0) && distance > this.radius){
          return result;
        }
        else if (t1 < t2){
          RayHit entry = new RayHit(); //<>//
          RayHit exit = new RayHit();
          
          temp = PVector.mult(r.direction, t1);
          PVector pEntry = PVector.add(r.origin, temp);
          
          temp = PVector.mult(r.direction, t2);
          PVector pExit = PVector.add(r.origin, temp);
          
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
        else if (t2 < t1){
          RayHit entry = new RayHit();
          RayHit exit = new RayHit();
          
          temp = PVector.mult(r.direction, t2);
          PVector pEntry = PVector.add(r.origin, temp);
          
          temp = PVector.mult(r.direction, t1);
          PVector pExit = PVector.add(r.origin, temp);
          
          entry.t = t2;
          entry.location = pEntry;
          entry.normal = PVector.sub(pEntry, this.center).normalize();
          entry.entry = true;
          entry.material = this.material;
          
          exit.t = t1;
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
       throw new NotImplementedException("Planes not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
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
       throw new NotImplementedException("Triangles not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
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
       throw new NotImplementedException("Cylinders not implemented yet");
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
