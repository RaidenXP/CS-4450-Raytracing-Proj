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
      color i_a = scaleColor(hitcolor, ambient); // Do I use ambient for this color scaling
      color A = multColor(i_a, hit.material.properties.ka);
      
      // Calculate the diffuse color of the shape for each light and sum them all
      color D = color(0, 0, 0);
      for (Light l : this.lights) {
        color i_d = l.shine(hitcolor);
        PVector tolight = PVector.sub(l.position, hit.location).normalize();
        float intensity = PVector.dot(tolight, hit.normal);
        color temp = multColor(i_d, hit.material.properties.kd * intensity);
        D = addColors(D, temp);
      }
      
      // Calculate the specular color of the shape for each light and sum them all
      color S = color(0, 0, 0);
      for (Light l : this.lights) {
        color i_s = l.spec(hitcolor);
        PVector V = PVector.sub(viewer, hit.location); // This should be the direction to the camera, but
                                                       // I'm not sure if this is right.
        PVector L = PVector.sub(l.position, hit.location).normalize();
        PVector R = PVector.sub(PVector.mult(PVector.mult(hit.normal, 2), PVector.dot(hit.normal, L)), L).normalize();
        float shiny = PVector.dot(R, V);
        color temp = multColor(i_s, hit.material.properties.ks * pow(shiny, hit.material.properties.alpha));
        S = addColors(S, temp);
      }
      
      return addColors(addColors(A, D), S);
      // return hit.material.getColor(hit.u, hit.v);
    }
  
}
