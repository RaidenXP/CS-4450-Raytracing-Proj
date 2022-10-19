import java.util.Comparator;

class HitCompare implements Comparator<RayHit>
{
  int compare(RayHit a, RayHit b)
  {
     if (a.t < b.t) return -1;
     if (a.t > b.t) return 1;
     if (a.entry) return -1;
     if (b.entry) return 1;
     return 0;
  }
}

class Union implements SceneObject
{
  SceneObject[] children;
  Union(SceneObject[] children)
  {
    this.children = children;
    // remove this line when you implement true unions
    // println("WARNING: Using 'fake' union");
    println("WARNING: \"True\" Union not fully tested");
  }

  ArrayList<RayHit> intersect(Ray r)
  {
     int depth = 0;
     ArrayList<RayHit> hits = new ArrayList<RayHit>();
     
     // Reminder: this is *not* a true union
     // For a true union, you need to ensure that enter-
     // and exit-hits alternate
     for (SceneObject sc : children)
     {
       // rHits contains the ray hits for one object. If the first hit that intersects
       // the scene object is an exit, that means we are inside an object so we increment
       // the depth. This might be wrong.
       ArrayList<RayHit> rHits = sc.intersect(r);
       if ((rHits.size() != 0) && (rHits.get(0).entry == false))
           depth++;
       hits.addAll(rHits);
     }
     hits.sort(new HitCompare());
     
     // Iterate through the sorted ray hits and add appropriate hits to the result
     // according to the Union algorithm.
     ArrayList<RayHit> result = new ArrayList<RayHit>();
     for (RayHit rh : hits)
     {
         if (rh.entry == true) {
             if (depth == 0)
                 result.add(rh);
             depth++;
         }
         else {
             if (depth == 1)
                 result.add(rh);
             depth--;
         }
     }
     
     return result;
  }
  
}

class Intersection implements SceneObject
{
  SceneObject[] elements;
  Intersection(SceneObject[] elements)
  {
    this.elements = elements;
    
    // remove this line when you implement intersection
    // throw new NotImplementedException("CSG Operation: Intersection not implemented yet");
  }
  
  
  ArrayList<RayHit> intersect(Ray r)
  {
     int depth = 0;
     ArrayList<RayHit> hits = new ArrayList<RayHit>();
     
     for (SceneObject sc : elements)
     {
       // rHits contains the ray hits for one object. If the first hit that intersects
       // the scene object is an exit, that means we are inside an object so we increment
       // the depth. This might be wrong.
       ArrayList<RayHit> rHits = sc.intersect(r);
       if ((rHits.size() > 0) && (rHits.get(0).entry == false)){
           depth++;
       }
       
       hits.addAll(rHits);
     }
     hits.sort(new HitCompare());
     
     // Iterate through the sorted ray hits and add appropriate hits to the result
     // according to the Intersection algorithm.
     ArrayList<RayHit> result = new ArrayList<RayHit>();
     int n = this.elements.length;
     for (RayHit rh : hits)
     {
         if (rh.entry == true) {
             if (depth == (n - 1))
                 result.add(rh);
             depth++;
         }
         else {
             if (depth == n) //|| (rh.t == Float.POSITIVE_INFINITY))
                 result.add(rh);
             depth--;
         }
     }
     
     return result;
  }
  
}

class Difference implements SceneObject
{
  SceneObject a;
  SceneObject b;
  Difference(SceneObject a, SceneObject b)
  {
    this.a = a;
    this.b = b;
    
    // remove this line when you implement difference
    //throw new NotImplementedException("CSG Operation: Difference not implemented yet");
  }
  
  ArrayList<RayHit> intersect(Ray r)
  {
     ArrayList<RayHit> rHitsA = a.intersect(r);
     ArrayList<RayHit> rHitsB = b.intersect(r);
     
     int i_a = 0;
     int i_b = 0;
     
     boolean is_a = false;
     boolean is_b = false;
     
     boolean in_a = false;
     boolean in_b = false;
     
     boolean a_first = false;
     boolean prev_entry = false;
     
     RayHit current = new RayHit();
     
     rHitsA.sort(new HitCompare());
     rHitsB.sort(new HitCompare());
     
     ArrayList<RayHit> result = new ArrayList<RayHit>();
     
     if(rHitsA.isEmpty()){
       return result;
     }
     
     if(rHitsB.isEmpty()){
       result.addAll(rHitsA);
       return result;
     }
     
     while(i_a < rHitsA.size() || i_b < rHitsB.size()){
       if(i_a == rHitsA.size()){
         break; 
       }
       
       if(i_b == rHitsB.size()){
         //uncomment this part and comment bottom part to get another image
         //for(int i = i_a; i < rHitsA.size(); ++i){
         //  if(prev_entry && in_a && !in_b){
         //    result.add(rHitsA.get(i));
         //    in_a = false;
         //    prev_entry = false;
         //  }
         //  else if(!prev_entry && (!in_a || in_b)){
         //    result.add(rHitsA.get(i));
         //    prev_entry = true;
         //    in_a = true;
         //  }
         //}
         
         //uncomment this part and comment top for loop to get different image
         result.addAll(rHitsA);
         break; 
       }
       
       if(rHitsA.get(i_a).t < rHitsB.get(i_b).t){
          current.t = rHitsA.get(i_a).t;
          current.location = rHitsA.get(i_a).location;
          current.normal = rHitsA.get(i_a).normal;
          current.entry = rHitsA.get(i_a).entry;
          current.material = rHitsA.get(i_a).material;
          
          is_a = true;
          is_b = false;
          
          if(i_a == 0 && i_b == 0){
            a_first = true; 
          }
          
          ++i_a;
       } 
       else {
         current.t = rHitsB.get(i_b).t;
         current.location = rHitsB.get(i_b).location;
         current.normal = rHitsB.get(i_b).normal;
         current.entry = rHitsB.get(i_b).entry;
         current.material = rHitsB.get(i_b).material;
         
         is_a = false;
         is_b = true;
         
         ++i_b;
       }
       
       if(a_first){
         if(is_a && current.entry && (!in_a || in_b)){
            in_a = true;
            if(in_a && !in_b){
              result.add(current);
              prev_entry = true;
            }
         }
         else if(is_a && !current.entry && in_a && !in_b){
           result.add(current);
           in_a = false;
           prev_entry = false;
         }
         else if(is_b && current.entry && in_a && !in_b){
           current.normal = PVector.mult(current.normal, -1);
           current.entry = false;
           
           prev_entry = false;
           in_b = true;
           
           result.add(current);
         }
         else if(is_b && current.entry && (!in_a || in_b)){
           in_b = true; 
         }
         else if(is_b && !current.entry){
           in_b = false; 
         }
         else if(is_a && !current.entry){
           in_a = false;
         }
       }
       else if(!a_first){
         if(is_b && current.entry && (!in_a || in_b)){
           in_b = true; 
         }
         else if(is_a && current.entry && (!in_a || in_b)){
           in_a = true;
         }
         else if(is_a && !current.entry && (in_a && !in_b)){
           if(prev_entry){
             result.add(current);  
           }
           in_a = false;
         }
         else if(is_b && !current.entry && (!in_a || in_b))
         {
           current.normal = PVector.mult(current.normal, -1);
           current.entry = true;
           
           prev_entry = true;
           in_b = false;
           
           result.add(current);
         }
       }
       
     }
     
       
     //if(i_b == rHitsB.size()){
     //  result.addAll(rHitsA);
     //}
     
     return result;
  }
  
}
