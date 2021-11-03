float coefficientOfRestitution = 0.6;

void testForCollisions() {
  for(int i=0;i<bodies.size();++i) {
    Body b1 = bodies.get(i);
    testForCollisionsWithWindowEdge(b1);
    
    for(int j=i+1;j<bodies.size();++j) {
      Body b2 = bodies.get(j);
      testCollision(b1,b2);
    }
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
  float boxRadiusSq = sq(b.width)+sq(b.height);
  if(distanceSq > boxRadiusSq + sq(a.radius)) return;
  
  println("Hit 1");
  PVector [] corners = b.getCorners();
  for(int i=0;i<4;++i) {
    int j = (i+1)%4;
    PVector p = lineSegmentCircleIntersection(a,corners[i],corners[j]);
    if(p!=null) {
      println("Hit 2");
      PVector n = PVector.sub(corners[j],corners[i]);
      n.rotate(radians(-90));
      performCollision(a,b,p,n);
    }
  }
}

PVector lineSegmentCircleIntersection(BodyCircle c,PVector a,PVector b) {
  PVector d = PVector.sub(b,a);
  PVector f = PVector.sub(a,c.position);
  float aa = d.dot(d);
  float bb = 2.0*f.dot(d);
  float cc= f.dot(f)- sq(c.radius);
  float discriminant = bb*bb-4.0*aa*cc;
  if(discriminant<0) return null;
  discriminant = sqrt(discriminant);
  float t1 = (-bb - discriminant)/(2.0*aa);
  float t2 = (-bb + discriminant)/(2.0*aa);
  if(t1>=0 && t1<=1) {
    return PVector.add(a,d.mult(t1));
  }
  if(t2>=0 && t2<=1) {
    return PVector.add(a,d.mult(t2));
  }
  return null;
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

void performCollision(Body a,Body b,PVector p,PVector n) {
  PVector Vr = PVector.sub(b.velocity,a.velocity);
  float vn = PVector.dot(Vr,n);
  if(vn<0) return;
  PVector R1 = PVector.sub(p,a.position);
  PVector R2 = PVector.sub(p,b.position);
  
  PVector t1 = R1.cross(n).mult(1.0/a.getInertiaTensor()).cross(R1);
  PVector t2 = R2.cross(n).mult(1.0/b.getInertiaTensor()).cross(R2);
  
  float Jr = (-(1+coefficientOfRestitution) * vn) / ( (1.0/a.mass) + (1.0/b.mass) + PVector.add(t1,t2).dot(n) );
  
  a.velocity.add(PVector.mult(n,-Jr/a.mass));
  b.velocity.add(PVector.mult(n, Jr/b.mass));
  
  a.angularV -= R1.cross(n).z * Jr / a.getInertiaTensor();
  b.angularV += R2.cross(n).z * Jr / b.getInertiaTensor();
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
  if(b.velocity.y>0) {
     if(p.y>height) {
       PVector n=new PVector(0,-1);
       b.velocity.add(n.mult(n.dot(b.velocity)*-2));
     }
  } else if(b.velocity.y<0) {
     if(p.y<0) {
       PVector n=new PVector(0,1);
       b.velocity.add(n.mult(n.dot(b.velocity)*-2));
     }
  }

  if(b.velocity.x>0) {
     if(p.x>height) {
       PVector n=new PVector(-1,0);
       b.velocity.add(n.mult(n.dot(b.velocity)*-2));
     }
  } else if(b.velocity.x<0) {
     if(p.x<0) {
       PVector n=new PVector(1,0);
       b.velocity.add(n.mult(n.dot(b.velocity)*-2));
     }
  }
}

void testCircleWindowEdge(BodyCircle b) {
  if(b.velocity.y>0) {
     if(b.position.y+b.radius>height) {
       PVector n = new PVector(0,-1);
       PVector p = new PVector(b.position.x,height);
       PVector f = n.mult(n.dot(b.velocity)*-2);
       b.applyForceAtPoint(p,f);
     }
  } else if(b.velocity.y<0) {
     if(b.position.y-b.radius<0) {
       PVector n=new PVector(0,1);
       PVector p = new PVector(b.position.x,0);
       PVector f = n.mult(n.dot(b.velocity)*-2);
       b.applyForceAtPoint(p,f);
     }
  }

  if(b.velocity.x>0) {
     if(b.position.x+b.radius>width) {
       PVector n=new PVector(-1,0);
       PVector p = new PVector(width,b.position.y);
       PVector f = n.mult(n.dot(b.velocity)*-2);
       b.applyForceAtPoint(p,f);
     }
  } else if(b.velocity.x<0) {
     if(b.position.x-b.radius<0) {
       PVector n=new PVector(1,0);
       PVector p = new PVector(0,b.position.y);
       PVector f = n.mult(n.dot(b.velocity)*-2);
       b.applyForceAtPoint(p,f);
     }
  }
}
