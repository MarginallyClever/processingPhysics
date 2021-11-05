
boolean onSegment(PVector p, PVector q, PVector r) {
  return (q.x <= Math.max(p.x, r.x) && q.x >= Math.min(p.x, r.x) &&
          q.y <= Math.max(p.y, r.y) && q.y >= Math.min(p.y, r.y));
}

int orientation(PVector p, PVector q, PVector r) {
  // See https://www.geeksforgeeks.org/orientation-3-ordered-Points/
  // for details of below formula.
  double val = (q.y - p.y) * (r.x - q.x) -
               (q.x - p.x) * (r.y - q.y);

  if (Math.abs(val)<1e-7) return 0; // colinear

  return (val > 0)? 1: 2; // clock or counterclock wise
} 

boolean doIntersect(PVector p1, PVector q1, PVector p2, PVector q2) {
  // Find the four orientations needed for general and special cases
  int o1 = orientation(p1, q1, p2);
  int o2 = orientation(p1, q1, q2);
  int o3 = orientation(p2, q2, p1);
  int o4 = orientation(p2, q2, q1);

  // General case
  if (o1 != o2 && o3 != o4)
      return true;

  // Special Cases
  // p1, q1 and p2 are colinear and p2 lies on segment p1q1
  if (o1 == 0 && onSegment(p1, p2, q1)) return true;

  // p1, q1 and q2 are colinear and q2 lies on segment p1q1
  if (o2 == 0 && onSegment(p1, q2, q1)) return true;

  // p2, q2 and p1 are colinear and p1 lies on segment p2q2
  if (o3 == 0 && onSegment(p2, p1, q2)) return true;

  // p2, q2 and q1 are colinear and q1 lies on segment p2q2
  if (o4 == 0 && onSegment(p2, q1, q2)) return true;

  return false; // Doesn't fall in any of the above cases
}


PVector lineLineIntersection(PVector p1, PVector p2, PVector p3, PVector p4) {
  float d34x = (p3.x-p4.x);
  float d34y = (p3.y-p4.y);
  
  float d = (p1.x-p2.x)*d34y - (p1.y-p2.y)*d34x;
  if(abs(d)<1e-5) return null;  // parallel
  float a = (p1.x*p2.y - p1.y*p2.x)*d34x - (p1.x-p2.x)*(p3.x*p4.y - p3.y*p4.x);
  float b = (p1.x*p2.y - p1.y*p2.x)*d34y - (p1.y-p2.y)*(p3.x*p4.y - p3.y*p4.x);
  
  return new PVector(a/d,b/d);
}
