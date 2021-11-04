float coefficientOfRestitution = 0.6;


void performCollision(Body a,Body b,PVector p,PVector n) {
  PVector Ra = a.getR(p);
  PVector Rb = b.getR(p);
  
  PVector Va = a.getCombinedVelocityAtPoint(p);
  PVector Vb = b.getCombinedVelocityAtPoint(p);
  
  PVector Vr = PVector.sub(Vb,Va);
  float contactVel = PVector.dot(Vr,n);
  if(contactVel>0) return;

  float Ran = Ra.cross(n).z;
  float Rbn = Rb.cross(n).z;
  
  float Jr = (-(1+coefficientOfRestitution) * contactVel);
  float denom = a.getInverseMass() + b.getInverseMass() + sq(Ran)/a.getMomentOfInertia() + sq(Rbn)/b.getMomentOfInertia();
  Jr /= denom;
  
  a.applyImpulse( PVector.mult(n,-Jr), Ra );
  b.applyImpulse( PVector.mult(n, Jr), Rb );
}


// against unmovable something
void performCollision(Body a,PVector p,PVector n) {
  PVector Ra = a.getR(p);
  
  PVector Va = a.getCombinedVelocityAtPoint(p);
  
  PVector Vr = PVector.sub(new PVector(0,0,0),Va);
  float contactVel = PVector.dot(Vr,n);
  println("contactVel="+contactVel);
  if(contactVel>0) return;

  float Ran = Ra.cross(n).z;
  
  float Jr = -(1+coefficientOfRestitution) * contactVel;
  float denom = a.getInverseMass() + sq(Ran)/a.getMomentOfInertia();
  Jr /= denom;
  
  a.applyImpulse( PVector.mult(n,-Jr), Ra );
}


void testForCollisions() {
  for(int i=0;i<bodies.size();++i) {
    Body b1 = bodies.get(i);
    testCollision(b1,worldEdge);
    
    for(int j=i+1;j<bodies.size();++j) {
      Body b2 = bodies.get(j);
      testCollision(b1,b2);
    }
    
    worldEdge.velocity.set(0,0,0);
    worldEdge.angularV.set(0,0,0);
  }
}

void testCollision(Body b1,Body b2) {
  if(b1 instanceof BodyCircle) {
    if(b2 instanceof BodyCircle) {
      testForCollisionsCircleCircle((BodyCircle)b1,(BodyCircle)b2);
    } else if(b2 instanceof BodyBox) {
      testForCollisionsCircleBox((BodyCircle)b1,(BodyBox)b2);
    }
  } else if(b1 instanceof BodyBox) {
    if(b2 instanceof BodyCircle) {
      testForCollisionsCircleBox((BodyCircle)b2,(BodyBox)b1);
    } else if(b2 instanceof BodyBox) {
      testForCollisionsBoxBox((BodyBox)b1,(BodyBox)b2);
    }
  }
}

void testForCollisionsBoxBox(BodyBox a,BodyBox b) {
}

void testForCollisionsCircleBox(BodyCircle a,BodyBox b) {
  PVector dp = PVector.sub(a.position,b.position);
  float distanceSq = dp.magSq();
  float boxRadiusSq = sq(b.w)+sq(b.h);
  if(distanceSq > boxRadiusSq + sq(a.radius)) return;
  
  PVector [] corners = b.getCorners();
  for(int i=0;i<4;++i) {
    int j = (i+1)%4;
    ArrayList<PVector> list = lineSegmentCircleIntersection(a.position,a.radius,corners[i],corners[j]);
    if(list.size()>0) {
      PVector p = new PVector(0,0,0);
      for( PVector n : list ) { 
        p.add(n);
      }
      p.mult(1.0/list.size());
      PVector n = PVector.sub(corners[j],corners[i]);
      n.rotate(radians(-90));
      performCollision(a,b,p,n);
    }
  }
}

ArrayList<PVector> lineSegmentCircleIntersection(PVector position,float radius,PVector p1,PVector p2) {
  ArrayList<PVector> list = new ArrayList<PVector>();
  
  PVector n = PVector.sub(p2,p1);
  float len2= n.magSq();
  n.normalize();
  PVector L = PVector.sub(position,p1);
  
    stroke(255,192,0);
  line(p1.x,p1.y,position.x,position.y);
  
  float tca = n.dot(L);
  if(tca<0) return list;
  
  stroke(0,255,0);
  line(position.x,position.y,p1.x+n.x*tca,p1.y+n.y*tca);
  
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

void testForCollisionsCircleCircle(BodyCircle a,BodyCircle b) {
  PVector dp = PVector.sub(a.position,b.position);
  float distance = dp.magSq();
  if(distance>sq(a.radius+b.radius)) return;
  
  PVector n = dp.normalize();
  PVector p = PVector.add(b.position,PVector.mult(n,b.radius));
  //float bias = (a.radius+b.radius - distance)/2;
  //b.acceleration.add(PVector.mult(n,-bias*b.mass));
  //a.acceleration.add(PVector.mult(n,bias*a.mass));

  performCollision(a,b,p,n);
}

void testForCollisionsWithWindowEdge(Body b) {
  if(b instanceof BodyCircle) {
    testCircleWindowEdge((BodyCircle)b);
  } else if(b instanceof BodyBox) {
    testBoxWindowEdge((BodyBox)b);
  }
}

void testBoxWindowEdge(BodyBox b) {
  PVector [] corners = b.getCorners();
  for(PVector c : corners ) {
    testBoxCornerWindowEdge(b,c);
  }
}

void testBoxCornerWindowEdge(BodyBox b,PVector p) {
  PVector v = b.getCombinedVelocityAtPoint(p);
  stroke(255,0,0);
  circle(p.x,p.y,5);
  stroke(255,128,0);
  line(p.x,p.y,p.x+v.x,p.y+v.y);
  
  if(v.y>0) {
    if(p.y>height) {
      println("a");
      //paused=true;
      PVector n=new PVector(0,-1);
      performCollision(b,p,n);
    }
  } else if(v.y<0) {
    if(p.y<30) {
      println("b");
      //paused=true;
      PVector n=new PVector(0,1);
      performCollision(b,p,n);
    }
  }

  if(v.x>0) {
    if(p.x>width) {
      println("c");
      //paused=true;
      PVector n=new PVector(-1,0);
      performCollision(b,p,n);
    }
  } else if(v.x<0) {
    if(p.x<0) {
      println("d");
      //paused=true;
      PVector n=new PVector(1,0);
      performCollision(b,p,n);
    }
  }
}

void testCircleWindowEdge(BodyCircle b) {
  if(b.velocity.y>0) {
     if(b.position.y+b.radius>height) {
       PVector n = new PVector(0,-1);
       PVector p = new PVector(b.position.x,height);
       performCollision(b,p,n);
     }
  } else if(b.velocity.y<0) {
     if(b.position.y-b.radius<30) {
       PVector n = new PVector(0,1);
       PVector p = new PVector(b.position.x,30);
       performCollision(b,p,n);
     }
  }

  if(b.velocity.x>0) {
     if(b.position.x+b.radius>width) {
       PVector n = new PVector(-1,0);
       PVector p = new PVector(width,b.position.y);
       performCollision(b,p,n);
     }
  } else if(b.velocity.x<0) {
     if(b.position.x-b.radius<0) {
       PVector n = new PVector(1,0);
       PVector p = new PVector(0,b.position.y);
       performCollision(b,p,n);
     }
  }
}
