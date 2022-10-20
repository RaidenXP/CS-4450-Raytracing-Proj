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

class HolderCompare implements Comparator<RayHitHolder>
{
    int compare(RayHitHolder a, RayHitHolder b)
    {
        if (a.hit.t < b.hit.t) return -1;
        if (a.hit.t > b.hit.t) return 1;
        if (a.hit.entry) return -1;
        if (b.hit.entry) return 1;
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
     
     // Sort ray hits for A and B
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
     
     // Create a list of RayHitHolders and populate it with the intersections of A and B
     ArrayList<RayHitHolder> hits = new ArrayList<RayHitHolder>();
     for (RayHit rh : rHitsA) {
         RayHitHolder rhh = new RayHitHolder();
         rhh.hit = rh;        // Is this ok or are there some initialization issues?
         rhh.is_a = true;
         hits.add(rhh);
     }
     for (RayHit rh : rHitsB) {
         RayHitHolder rhh = new RayHitHolder();
         rhh.hit = rh;        // Is this ok or are there some initialization issues?
         rhh.is_a = false;
         hits.add(rhh);
     }
     
     // Sort the RayHitHolders using the new comparator class
     hits.sort(new HolderCompare()); // I hope this works...
     
     boolean in_a = false;
     boolean in_b = false;
     
     if (!rHitsA.get(0).entry)
         in_a = true;
     if (!rHitsB.get(0).entry)
         in_b = true;
     
     for (RayHitHolder rhh : hits) {
         if (hits.get(0).is_a){
             if (rhh.is_a && rhh.hit.entry){
                 in_a = true;
                 if (in_a && !in_b)
                     result.add(rhh.hit);
             }
             else if (!rhh.is_a && rhh.hit.entry){
                 if (in_a && !in_b) {
                     rhh.hit.normal = PVector.mult(rhh.hit.normal, -1);
                     rhh.hit.entry = false;
                     result.add(rhh.hit);
                 }
                 in_b = true;
             }
             else if (rhh.is_a && !rhh.hit.entry) {
                 if (in_a && !in_b)
                     result.add(rhh.hit);
                 in_a = false;
             }
             else if (!rhh.is_a && !rhh.hit.entry) {
                 in_b = false;
                 
                 if (in_a && !in_b) {
                     rhh.hit.normal = PVector.mult(rhh.hit.normal, -1);
                     rhh.hit.entry = true;
                     result.add(rhh.hit);
                 }
             }
             
         }
         else {
             if(!rhh.is_a && rhh.hit.entry){
                 if (in_a && !in_b) {
                     rhh.hit.normal = PVector.mult(rhh.hit.normal, -1);
                     rhh.hit.entry = false;
                     result.add(rhh.hit);
                 }
                 in_b = true;
             }
             else if(rhh.is_a && rhh.hit.entry){
                 in_a = true;
                 
                 if(in_a && !in_b){
                      result.add(rhh.hit);
                 }
             }
             else if(rhh.is_a && !rhh.hit.entry){
                 if(in_a && !in_b){
                     result.add(rhh.hit);  
                 }
                 
                 in_a = false;
             }
             else if(!rhh.is_a && !rhh.hit.entry){
                 in_b = false;
                 
                 if (in_a && !in_b) {
                     rhh.hit.normal = PVector.mult(rhh.hit.normal, -1);
                     rhh.hit.entry = true;
                     result.add(rhh.hit);
                 }
             }
         }
     }
     
     return result;
  }
  
}
