class RayHit
{
     float t;
     PVector location;
     PVector normal;
     boolean entry;
     Material material;
     float u, v;
}

interface SceneObject
{
   ArrayList<RayHit> intersect(Ray r);
}

class RayHitHolder
{
    RayHit hit;
    boolean is_a;
}

class Scene
{
   LightingModel lighting;
   SceneObject root;
   int reflections;
   color background;
   PVector camera;
   PVector view;
   float fov;
}
