class Light
{
   PVector position;
   color diffuse;
   color specular;
   Light(PVector position, color col)
   {
     this.position = position;
     this.diffuse = col;
     this.specular = col;
   }
   
   Light(PVector position, color diffuse, color specular)
   {
     this.position = position;
     this.diffuse = diffuse;
     this.specular = specular;
   }
   
   color shine(color col)
   {
       return scaleColor(col, this.diffuse);
   }
   
   color spec(color col)
   {
       return scaleColor(col, this.specular);
   }
}

class LightingModel
{
    ArrayList<Light> lights;
    LightingModel(ArrayList<Light> lights)
    {
      this.lights = lights;
    }
    color getColor(RayHit hit, Scene sc, PVector viewer)
    {
      color hitcolor = hit.material.getColor(hit.u, hit.v);
      color surfacecol = lights.get(0).shine(hitcolor);
      PVector tolight = PVector.sub(lights.get(0).position, hit.location).normalize();
      float intensity = PVector.dot(tolight, hit.normal);
      return lerpColor(color(0), surfacecol, intensity);
    }
  
}

class PhongLightingModel extends LightingModel
{
    color ambient;        // What even is ambient?
    boolean withshadow;
    PhongLightingModel(ArrayList<Light> lights, boolean withshadow, color ambient)
    {
      super(lights);
      this.withshadow = withshadow;
      this.ambient = ambient;
      
      // remove this line when you implement phong lighting
      // throw new NotImplementedException("Phong Lighting Model not implemented yet");
    }
    color getColor(RayHit hit, Scene sc, PVector viewer)
    {
      color hitcolor = hit.material.getColor(hit.u, hit.v); // color of the hit location
      
      // Calculate the ambient color of the shape
      color i_a = scaleColor(hitcolor, ambient); // Do I use ambient for this color scaling?
      color A = multColor(i_a, hit.material.properties.ka);
      
      // Calculate the diffuse and specular color of the shape for each light and sum them all
      color D = color(0, 0, 0);
      color S = color(0, 0, 0);
      for (Light l : this.lights) {
        PVector tolight = PVector.sub(l.position, hit.location).normalize();
        
        if (withshadow) {
          PVector offsetHit = PVector.add(hit.location, PVector.mult(tolight, EPS));
          Ray pixelRay = new Ray(offsetHit, tolight);
          ArrayList<RayHit> hits = sc.root.intersect(pixelRay);
        
          if ((hits.size() == 0)) {
            color i_d = l.shine(hitcolor);
            float intensity = PVector.dot(tolight, hit.normal);
            color temp = multColor(i_d, hit.material.properties.kd * intensity);
            D = addColors(D, temp);
            
            color i_s = l.spec(hitcolor);
            PVector V = PVector.sub(viewer, hit.location).normalize(); // This should be the direction to the camera, but
                                                                       // I'm not sure if this is right.
            PVector R = PVector.sub(PVector.mult(hit.normal, 2 * PVector.dot(hit.normal, tolight)), tolight).normalize();
            float shiny = PVector.dot(R, V);
            temp = multColor(i_s, hit.material.properties.ks * pow(shiny, hit.material.properties.alpha));
            S = addColors(S, temp);
          }
        }
        else {
          color i_d = l.shine(hitcolor);
          float intensity = PVector.dot(tolight, hit.normal);
          color temp = multColor(i_d, hit.material.properties.kd * intensity);
          D = addColors(D, temp);
          
          color i_s = l.spec(hitcolor);
          PVector V = PVector.sub(viewer, hit.location).normalize(); // This should be the direction to the camera, but
                                                                     // I'm not sure if this is right.
          PVector R = PVector.sub(PVector.mult(hit.normal, 2 * PVector.dot(hit.normal, tolight)), tolight).normalize();
          float shiny = PVector.dot(R, V);
          temp = multColor(i_s, hit.material.properties.ks * pow(shiny, hit.material.properties.alpha));
          S = addColors(S, temp);
        }
      }
      
      // Calculate the specular color of the shape for each light and sum them all
      //color S = color(0, 0, 0);
      //for (Light l : this.lights) {
      //  PVector L = PVector.sub(l.position, hit.location).normalize();
        
      //  if (withshadow) {
      //    // PVector offsetHit = PVector.add(viewer, PVector.mult(PVector.sub(hit.location, viewer).normalize(), hit.t - EPS));
      //    PVector offsetHit = PVector.add(hit.location, PVector.mult(L, EPS));
      //    Ray pixelRay = new Ray(offsetHit, L);
      //    ArrayList<RayHit> hits = sc.root.intersect(pixelRay);
          
      //    if ((hits.size() == 0)) {
      //      color i_s = l.spec(hitcolor);
      //      PVector V = PVector.sub(viewer, hit.location).normalize(); // This should be the direction to the camera, but
      //                                                                 // I'm not sure if this is right.
      //      PVector R = PVector.sub(PVector.mult(hit.normal, 2 * PVector.dot(hit.normal, L)), L).normalize();
      //      float shiny = PVector.dot(R, V);
      //      color temp = multColor(i_s, hit.material.properties.ks * pow(shiny, hit.material.properties.alpha));
      //      S = addColors(S, temp);
      //    }
      //  }
      //  else {
      //    color i_s = l.spec(hitcolor);
      //    PVector V = PVector.sub(viewer, hit.location).normalize(); // This should be the direction to the camera, but
      //                                                               // I'm not sure if this is right.
      //    PVector R = PVector.sub(PVector.mult(hit.normal, 2 * PVector.dot(hit.normal, L)), L).normalize();
      //    float shiny = PVector.dot(R, V);
      //    color temp = multColor(i_s, hit.material.properties.ks * pow(shiny, hit.material.properties.alpha));
      //    S = addColors(S, temp);
      //  }
      //}
      
      // return hit.material.getColor(hit.u, hit.v);
      return addColors(addColors(A, D), S);
      // return addColors(A, D);
      // return A;
    }
  
}
