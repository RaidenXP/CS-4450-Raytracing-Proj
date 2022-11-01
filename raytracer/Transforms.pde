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
    throw new NotImplementedException("Movement+Rotation not implemented yet");
  }
  
  Ray inverse_transformations(Ray r)
  {
      r.origin.add(movement); //Translate origin by movement
  }
  
  // Calculate PVector that has been rotated about the z-axis
  PVector rotateZAxis(PVector p, boolean inverse)
  {
      float alpha;
      if (inverse)
          alpha = -atan(p.y / p.x);
      else
          alpha = atan(p.y / p.x);
      return new PVector((cos(alpha) * p.x)-(sin(alpha) * p.y), (sin(alpha) * p.x)+(cos(alpha) * p.y), p.z);
  }
  // Calculate PVector that has been rotated about the y-axis
  PVector rotateYAxis(PVector p, boolean inverse)
  {
      float alpha;
      if (inverse)
          alpha = -atan(p.z / p.x);
      else
          alpha = atan(p.z / p.x);
      return new PVector((cos(alpha) * p.x)+(sin(alpha) * p.z), p.y, (-sin(alpha) * p.x)+(cos(alpha) * p.z));
  }
  // Calculate PVector that has been rotated about the x-axis
  PVector rotateXAxis(PVector p, boolean inverse)
  {
      float alpha;
      if (inverse)
          alpha = -atan(p.z / p.y);
      else
          alpha = atan(p.z / p.y);
      return new PVector(p.x, (cos(alpha) * p.y)-(sin(alpha) * p.z), (sin(alpha) * p.y)+(cos(alpha) * p.z));
  }
  
  
  ArrayList<RayHit> intersect(Ray r)
  {
     return child.intersect(r);
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
