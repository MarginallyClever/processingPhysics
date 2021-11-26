
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
  // which polygon is inside the other the most?
  
  BestFitPair fitA = findAxisLeastPenetration(a,b);
  if(fitA.fit>=0) return;  // no overlap
  
  BestFitPair fitB = findAxisLeastPenetration(b,a);
  if(fitB.fit>=0) return;  // no overlap
  
  BodyPolygon b1;
  BodyPolygon b2;
  int faceIndex;
  boolean flip;
  if(fitA.fit > fitB.fit ) {
    // b is inside a more
    //println("A>B");
    b1=a;
    b2=b;
    faceIndex = fitA.index;
    flip=false;
  } else {
    // a is inside b more
    //println("B>A");
    b1=b;
    b2=a;
    faceIndex = fitB.index;
    flip=true;
  }
  
  ArrayList<PVector> face = findIncidentFace(b1,b2,faceIndex);
  
  PVector [] aCorners = b1.getWorldPoints();
  PVector v1 = aCorners[faceIndex];
  PVector v2 = aCorners[(faceIndex+1)%aCorners.length];
  PVector sideNormal = PVector.sub(v2,v1);
  sideNormal.normalize();
  PVector refFaceNormal = new PVector(sideNormal.y, -sideNormal.x);

  float refC = PVector.dot( refFaceNormal, v1);
  float negSide = -PVector.dot( sideNormal, v1);
  float posSide =  PVector.dot( sideNormal, v2);
/*
  println(refC+"\t"+negSide+"\t"+posSide);
  
  stroke(255,0,255);
  strokeWeight(5);
  line(face.get(0).x,face.get(0).y,
       face.get(1).x,face.get(1).y);
  strokeWeight(15);
  point(face.get(0).x,face.get(0).y);
       
  stroke(0,255,255);
  strokeWeight(5);
  line(v1.x,v1.y,
       v2.x,v2.y);
  strokeWeight(15);
  point(v1.x,v1.y);
  
  strokeWeight(1);
  */
  if(clip( PVector.mult(sideNormal,-1), negSide, face)<2) return;
  if(clip( sideNormal, posSide, face)<2) return;
  
  //println("hit!");
  
  int count=0;
  m.normal = PVector.mult(refFaceNormal, flip? -1:1);
  float separation = refFaceNormal.dot(face.get(0)) - refC;
  if(separation<=0) {
    //println("hit 1!");
    m.contacts.add(face.get(0));
    m.penetration = -separation;
    count++;
  } else {
    m.penetration=0;
  }
  
  separation = refFaceNormal.dot(face.get(1)) - refC;
  if(separation<=0) {
    //println("hit 2!");
    m.contacts.add(face.get(1));
    m.penetration += -separation;
    count++;
    m.penetration/=count;
  }
}

int clip( PVector n, float c, ArrayList<PVector> face ) {
  int sp = 0;
  PVector [] out = {
    face.get(0),
    face.get(1)
  };

  // Retrieve distances from each endpoint to the line
  // d = ax + by - c
  float d1 = n.dot( face.get(0) ) - c;
  float d2 = n.dot( face.get(1) ) - c;
  //println("d1="+d1);
  //println("d2="+d2);

  // If negative (behind plane) clip
  if(d1 <= 0.0f) {
    out[sp++] = face.get(0);
    //println("added d1");
  }
  if(d2 <= 0.0f) {
    out[sp++] = face.get(1);
    //println("added d2");
  }
  // If the points are on different sides of the plane
  if(d1 * d2 < 0.0f) {// less than to ignore -0.0f
    // Push interesection point
    float alpha = d1 / (d1 - d2);
    out[sp] = PVector.lerp( face.get(0), face.get(1), alpha );
    //println("clip @ "+out[sp]);
    ++sp;
  }

  // Assign our new converted values
  face.set(0,out[0]);
  face.set(1,out[1]);

  assert( sp != 3 );

  return sp;
}

ArrayList<PVector> findIncidentFace(BodyPolygon a,BodyPolygon b,int faceIndex) {
  ArrayList<PVector> list = new ArrayList<PVector>();
  
  // get normal of edge 'faceIndex'
  PVector [] aCorners = a.getWorldPoints();
  int faceIndex2 = (faceIndex+1)%aCorners.length;
  PVector n = getNormalTo(aCorners[faceIndex],aCorners[faceIndex2]);

  // find face of b which is pointing away from 'n' the most.
  BestFitPair f = new BestFitPair();
  f.fit = Float.MAX_VALUE;

  PVector [] bCorners = b.getWorldPoints();
  int bSize = bCorners.length;
  for( int i=0;i<bSize;++i) {
    int j=(i+1)%bSize;
    PVector bn = getNormalTo(bCorners[i],bCorners[j]);
    float d = PVector.dot(n,bn);
    if(d < f.fit) {
      f.fit=d;
      f.index=i;
    }
  }
  
  list.add(bCorners[f.index]);
  list.add(bCorners[(f.index+1)%bSize]);
  
  return list;
}

BestFitPair findAxisLeastPenetration( BodyPolygon a, BodyPolygon b ) {
  BestFitPair best = new BestFitPair();
  PVector [] aCorners = a.getWorldPoints();
  int aSize = aCorners.length;

  PVector bestNormal = null;
  
  for(int a1=0;a1<aSize;++a1) {
    int a2=(a1+1)%aSize;
    
    // Retrieve a face normal from a
    PVector n = getNormalTo(aCorners[a1],aCorners[a2]);
    PVector s = b.getSupport( PVector.mult(n,-1) );
    PVector v = aCorners[a1];

    // Compute penetration distance
    float d = n.dot( PVector.sub(s,v) );
    // Store greatest distance
    if(best.fit < d) {
      best.fit = d;
      best.index = a1;
      bestNormal = n;
    }
  }
/*
  stroke(255,0,0);
  line(
    a.position.x,
    a.position.y,
    a.position.x+bestNormal.x*best.fit,
    a.position.y+bestNormal.y*best.fit
    );
  //println(bestNormal+"\t"+best.fit);
*/
  return best;
}

void testCollisionCirclePolygon(Manifold m,BodyCircle a,BodyPolygon b) {
  float distanceSq = PVector.sub(b.position,a.position).magSq();
  if(distanceSq > sq(b.radius+a.radius)) return;

  PVector center = a.position;
  BestFitPair best = new BestFitPair();
  PVector [] corners = b.getWorldPoints();
  int bSize = corners.length;
  for(int i=0;i<bSize;++i) {
    int j = (i+1)%bSize;
    PVector n = getNormalTo(corners[i],corners[j]);
    float s = n.dot(PVector.sub(center,corners[i]));
    if(s>a.radius) return;
    if(s>best.fit) {
      best.fit=s;
      best.index=i;
    }
  }
  
  PVector Pa = corners[best.index];
  PVector Pb = corners[(best.index+1)%bSize];
  if(best.fit<1e-6) {
    m.normal = PVector.mult(getNormalTo(Pa,Pb),-1);
    PVector p = PVector.add(a.position,PVector.mult(m.normal,a.radius));
    m.contacts.add(p);
    m.penetration = a.radius;
    return;
  }
  
  float dot1 = PVector.dot( PVector.sub(center,Pa), PVector.sub(Pb,Pa) );
  float dot2 = PVector.dot( PVector.sub(center,Pb), PVector.sub(Pa,Pb) );
  m.penetration = a.radius - best.fit;
  
  if(dot1 <= 0) {
    if(PVector.sub(center,Pa).magSq() > sq(a.radius)) return;
    m.normal = PVector.sub(Pa,center).normalize();
    m.contacts.add(Pa);
  } else if(dot2 <= 0) {
    if(PVector.sub(center,Pb).magSq() > sq(a.radius)) return;
    m.normal = PVector.sub(Pb,center).normalize();
    m.contacts.add(Pb);
  } else {
    PVector n = getNormalTo(Pa,Pb);
    if( PVector.dot( PVector.sub(center,Pa), n ) > a.radius ) return;
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
