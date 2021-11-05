
void testForCollisions() {
  int size=bodies.size();
  for(int i=0;i<size;++i) {
    Body b1 = bodies.get(i);
    for(int j=i+1;j<size;++j) {
      Body b2 = bodies.get(j);
      
      if(b1.getInverseMass()==0 && b2.getInverseMass()==0) continue;
      
      Manifold m = new Manifold(b1,b2);
      testCollision(m);
      if(m.contacts.size()>0) {
        contacts.add(m);
      }
    }
  }
}

void testCollision(Manifold m) {
  Body b1=m.a;
  Body b2=m.b;
  
  if(b1 instanceof BodyCircle) {
    if(b2 instanceof BodyCircle) {
      testForCollisionsCircleCircle(m,(BodyCircle)b1,(BodyCircle)b2);
    } else if(b2 instanceof BodyBox) {
      testForCollisionsCircleBox(m,(BodyCircle)b1,(BodyBox)b2);
    }
  } else if(b1 instanceof BodyBox) {
    if(b2 instanceof BodyCircle) {
      testForCollisionsCircleBox(m,(BodyCircle)b2,(BodyBox)b1);
    } else if(b2 instanceof BodyBox) {
      testForCollisionsBoxBox(m,(BodyBox)b1,(BodyBox)b2);
    }
  }
}

void testForCollisionsBoxBox(Manifold m,BodyBox a,BodyBox b) {
  PVector [] aCorners = a.getCorners();
  PVector [] bCorners = b.getCorners();
  
  float d2 = PVector.sub(a.position,b.position).magSq();
  float ar2=sq(a.w)+sq(a.h);
  float br2=sq(b.w)+sq(b.h);
  if(d2>ar2+br2) return;
  
  //println(a.position+"\tvs\t"+b.position);
  for(int a1=0;a1<4;++a1) {
    int a2=(a1+1)%4;
    PVector p1 = aCorners[a1];
    PVector p2 = aCorners[a2];
    
    for(int b1=0;b1<4;++b1) {
      int b2=(b1+1)%4;
      PVector p3 = bCorners[b1];
      PVector p4 = bCorners[b2];
      
      if(doIntersect(p1,p2,p3,p4)) {
        PVector p = lineLineIntersection(p1,p2,p3,p4);
        if(p!=null) {
          m.normal = getNormalTo(p1,p2);
          m.contacts.add(p);
        }
      }
    }
  }
}

void testForCollisionsCircleBox(Manifold m,BodyCircle a,BodyBox b) {
  PVector dp = PVector.sub(b.position,a.position);
  float distanceSq = dp.magSq();
  if(distanceSq > sq(b.r) + sq(a.radius)) return;

  float separation = -Float.MAX_VALUE;
  int bestFace = 0;
  
  PVector [] corners = b.getCorners();
  for(int i=0;i<4;++i) {
    int j = (i+1)%4;
    PVector n = getNormalTo(corners[i],corners[j]);
    float s = n.dot(PVector.sub(a.position,corners[i]));
    if(s>a.radius) return;
    if(s>separation) {
      separation=s;
      bestFace=i;
    }
  }
  
  PVector Pa = corners[bestFace];
  PVector Pb = corners[(bestFace+1)%4];
  if(separation<1e-6) {
    m.normal = getNormalTo(Pa,Pb);
    PVector p = PVector.add(a.position,PVector.mult(m.normal,a.radius));
    m.contacts.add(p);
    m.penetration = a.radius;
    return;
  }
  
  float dot1 = PVector.dot( PVector.sub(a.position,Pa), PVector.sub(Pb,Pa) );
  float dot2 = PVector.dot( PVector.sub(a.position,Pb), PVector.sub(Pa,Pb) );
  m.penetration = a.radius - separation;
  
  if(dot1 <= 0) {
    if(PVector.sub(a.position,Pa).magSq() > sq(a.radius)) return;
    m.normal = PVector.sub(Pa,a.position);
    m.contacts.add(Pa);
  } else if(dot2 <= 0) {
    if(PVector.sub(a.position,Pb).magSq() > sq(a.radius)) return;
    m.normal = PVector.sub(Pb,a.position);
    m.contacts.add(Pb);
  } else {
    PVector n = getNormalTo(Pa,Pb);
    if( PVector.dot( PVector.sub(a.position,Pa), n ) > a.radius ) return;
    m.normal = PVector.mult(n,-1);
    PVector p = PVector.add(a.position,PVector.mult(m.normal,a.radius));
    m.contacts.add(p);
  }
}

void testForCollisionsCircleCircle(Manifold m,BodyCircle a,BodyCircle b) {
  PVector dp = PVector.sub(b.position,a.position);
  float distance2 = dp.magSq();
  float r = a.radius+b.radius;
  if(distance2>sq(r)) return;
  float distance = sqrt(distance2);
  if(distance==0) {
    m.penetration = a.radius;
    m.normal = new PVector(1,0,0);
    m.contacts.add(a.position);
  } else {
    m.penetration = r - distance;
    m.normal = PVector.mult(dp,1.0/distance);
    PVector p = PVector.add(a.position,PVector.mult(m.normal,a.radius));
    m.contacts.add(p);
  }
}
