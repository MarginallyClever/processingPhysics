
ArrayList<PVector> lineSegmentCircleIntersection(PVector position,float radius,PVector p1,PVector p2) {
  ArrayList<PVector> list = new ArrayList<PVector>();
  
  PVector n = PVector.sub(p2,p1);
  float len2= n.magSq();
  n.normalize();
  PVector L = PVector.sub(position,p1);
  
  //stroke(255,192,0);
  //line(p1.x,p1.y,position.x,position.y);
  
  float tca = n.dot(L);
  if(tca<0) return list;
  
  //stroke(0,255,0);
  //line(position.x,position.y,p1.x+n.x*tca,p1.y+n.y*tca);
  
  //if(tca<0) return list;
  float d2 = L.dot(L) - sq(tca);
  float radius2 = sq(radius);
  if(d2>radius2) return list;
  float thc = sqrt(radius2-d2);
  float v = tca-thc;
  if(v>=0 && sq(v)<=len2) list.add(PVector.add(p1,PVector.mult(n,v)));
  v = tca+thc;
  if(v>=0 && sq(v)<=len2) list.add(PVector.add(p1,PVector.mult(n,v)));
  return list;
}
