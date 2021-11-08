
void testAllCollisions() {
  int size=bodies.size();
  for(int i=0;i<size;++i) {
    Body b1 = bodies.get(i);
    for(int j=i+1;j<size;++j) {
      Body b2 = bodies.get(j);
      
      if(b1.getInverseMass()==0 && b2.getInverseMass()==0) continue;
      
      Manifold m = new Manifold(b1,b2);
      m.testCollision();
      if(m.contacts.size()>0) {
        contacts.add(m);
      }
    }
  }
}

void testCollisionPolygonPolygon(Manifold m,BodyPolygon a,BodyPolygon b) {
  float d2 = PVector.sub(a.position,b.position).magSq();
  if(d2 > sq(a.radius+b.radius) ) return;
  
  PVector [] aCorners = a.getPoints();
  PVector [] bCorners = b.getPoints();
  
  int aSize = aCorners.length;
  int bSize = bCorners.length;
  
  //println(a.position+"\tvs\t"+b.position);
  for(int a1=0;a1<aSize;++a1) {
    int a2=(a1+1)%aSize;
    PVector p1 = aCorners[a1];
    PVector p2 = aCorners[a2];
    
    for(int b1=0;b1<bSize;++b1) {
      int b2=(b1+1)%bSize;
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

void testCollisionCirclePolygon(Manifold m,BodyCircle a,BodyPolygon b) {
  float distanceSq = PVector.sub(b.position,a.position).magSq();
  if(distanceSq > sq(b.radius+a.radius)) return;

  float separation = -Float.MAX_VALUE;
  int bestFace = 0;
  
  PVector [] corners = b.getPoints();
  int bSize = corners.length;
  for(int i=0;i<bSize;++i) {
    int j = (i+1)%bSize;
    PVector n = getNormalTo(corners[i],corners[j]);
    float s = n.dot(PVector.sub(a.position,corners[i]));
    if(s>a.radius) return;
    if(s>separation) {
      separation=s;
      bestFace=i;
    }
  }
  
  PVector Pa = corners[bestFace];
  PVector Pb = corners[(bestFace+1)%bSize];
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
    m.normal = PVector.sub(Pa,a.position).normalize();
    m.contacts.add(Pa);
  } else if(dot2 <= 0) {
    if(PVector.sub(a.position,Pb).magSq() > sq(a.radius)) return;
    m.normal = PVector.sub(Pb,a.position).normalize();
    m.contacts.add(Pb);
  } else {
    PVector n = getNormalTo(Pa,Pb);
    if( PVector.dot( PVector.sub(a.position,Pa), n ) > a.radius ) return;
    m.normal = PVector.mult(n,-1);
    PVector p = PVector.add(a.position,PVector.mult(m.normal,a.radius));
    m.contacts.add(p);
  }
}

void testCollisionCircleCircle(Manifold m,BodyCircle a,BodyCircle b) {
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
