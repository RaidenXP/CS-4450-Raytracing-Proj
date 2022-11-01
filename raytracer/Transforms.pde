class MoveRotation implements SceneObject
{
  SceneObject child;
  PVector movement;
  PVector rotation;
  
  MoveRotation(SceneObject child, PVector movement, PVector rotation)
  {
    this.child = child;
    this.movement = movement;
    this.rotation = rotation;
    
    // remove this line when you implement Movement+Rotation
    // throw new NotImplementedException("Movement+Rotation not implemented yet");
  }
  
  // Calculate PVector that has been rotated about the z-axis
  PVector rotateZAxis(PVector p, boolean inverse)
  {
      if (inverse)
          return new PVector((cos(-this.rotation.z) * p.x)-(sin(-this.rotation.z) * p.y), (sin(-this.rotation.z) * p.x)+(cos(-this.rotation.z) * p.y), p.z);
      else
          return new PVector((cos(this.rotation.z) * p.x)-(sin(this.rotation.z) * p.y), (sin(this.rotation.z) * p.x)+(cos(this.rotation.z) * p.y), p.z);
  }
  // Calculate PVector that has been rotated about the y-axis
  PVector rotateYAxis(PVector p, boolean inverse)
  {
      if (inverse)
          return new PVector((cos(-this.rotation.y) * p.x)+(sin(-this.rotation.y) * p.z), p.y, (-sin(-this.rotation.y) * p.x)+(cos(-this.rotation.y) * p.z));
      else
          return new PVector((cos(this.rotation.y) * p.x)+(sin(this.rotation.y) * p.z), p.y, (-sin(this.rotation.y) * p.x)+(cos(this.rotation.y) * p.z));
  }
  // Calculate PVector that has been rotated about the x-axis
  PVector rotateXAxis(PVector p, boolean inverse)
  {
      if (inverse)
          return new PVector(p.x, (cos(-this.rotation.x) * p.y)-(sin(-this.rotation.x) * p.z), (sin(-this.rotation.x) * p.y)+(cos(-this.rotation.x) * p.z));
      else
          return new PVector(p.x, (cos(this.rotation.x) * p.y)-(sin(this.rotation.x) * p.z), (sin(this.rotation.x) * p.y)+(cos(this.rotation.x) * p.z));
  }
  
  
  ArrayList<RayHit> intersect(Ray r)
  {
     // 1. Create a new ray by applying the inverse transformation to the ray
     Ray r1 = new Ray(r.origin, r.direction);
     // r1.origin.add(PVector.mult(movement, -1)); // Inverse translate origin          // This might need to be PVector.add(r1.origin, PVector.mult(movement, -1));
     r1.origin = PVector.add(r1.origin, PVector.mult(movement, -1));
     r1.origin = rotateYAxis(r1.origin, true);  // Rotate origin around y-axis
     r1.origin = rotateXAxis(r1.origin, true);  // Rotate origin around x-axis
     r1.origin = rotateZAxis(r1.origin, true);  // Rotate origin around z-axis
     r1.direction = rotateYAxis(r1.direction, true);  // Rotate direction around y-axis
     r1.direction = rotateXAxis(r1.direction, true);  // Rotate direction around x-axis
     r1.direction = rotateZAxis(r1.direction, true);  // Rotate direction around z-axis
     
     // 2. Call intersect on the child
     ArrayList<RayHit> hits = child.intersect(r1);
     
     // 3. Apply the transformation to location and rotation to normal for every hit
     for (RayHit rh : hits) 
     {
         rh.location = rotateZAxis(rh.location, false);
         rh.location = rotateXAxis(rh.location, false);
         rh.location = rotateYAxis(rh.location, false);
         // rh.location.add(movement);
         rh.location = PVector.add(rh.location, movement);
         rh.normal = rotateZAxis(rh.normal, false);
         rh.normal = rotateXAxis(rh.normal, false);
         rh.normal = rotateYAxis(rh.normal, false);
     }
     
     // 4. Return the transformed RayHits
     return hits;
     // return child.intersect(r);
  }
}

class Scaling implements SceneObject
{
  SceneObject child;
  PVector scaling;
  
  Scaling(SceneObject child, PVector scaling)
  {
    this.child = child;
    this.scaling = scaling;
    
    // remove this line when you implement Scaling
    throw new NotImplementedException("Scaling not implemented yet");
  }
  
  
  ArrayList<RayHit> intersect(Ray r)
  {
     return child.intersect(r);
  }
}
