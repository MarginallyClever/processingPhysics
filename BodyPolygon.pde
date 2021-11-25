class BodyPolygon extends Body {
  public float radius;
  public ArrayList<PVector> points = new ArrayList<PVector>();
    
  public void updateRadius() {
    float maxR = -Float.MAX_VALUE;
    for( PVector p : points ) {
      float r = sqrt(sq(p.x-position.x) + sq(p.y-position.y));
      if(r>maxR) maxR=r;
    }
    radius = maxR;
  }
  
  public void render() {
    PVector[] c = getWorldPoints();
    int cSize = c.length;
    
    fill(myColor);
    stroke(myColor);
    beginShape();
    for(int i=0;i<cSize;++i) {
      vertex(c[i].x,c[i].y);
    }
    vertex(c[0].x,c[0].y);
    endShape(CLOSE);

    renderOutline(c);
    //renderNormals(c);
    //renderRadius();
  
    super.render();
  }

  private void renderOutline(PVector[] c) {
    int cSize = c.length;
    stroke(0,0,0);
    for(int i=0;i<cSize;++i) {
      int j=(i+1)%cSize;
      line(c[i].x,c[i].y,
           c[j].x,c[j].y);
    }
  }
  
  private void renderNormals(PVector[] c) {
    int cSize = c.length;
    stroke(128,128,128);
    for(int i=0;i<cSize;++i) {
      int j=(i+1)%cSize;
      PVector n = getNormalTo(c[j],c[i]);
      PVector p = PVector.mult(PVector.add(c[i],c[j]),0.5);
      n = PVector.add(p,PVector.mult(n,10));
      line(p.x,p.y,n.x,n.y);
    }
  }
  
  private void renderRadius() {
    stroke(192,192,192);
    noFill();
    circle(position.x,position.y,radius*2);
  }
  
  public String toString() {
    return "["
          +this.position+", "
          +this.velocity+", "
          +this.force+", "
          +this.getMass()+"/"
          +this.getInverseMass()+", "
          +this.getMomentOfInertia()+"/"
          +this.getInverseMomentOfInertia()+", "
          +colorToString(this.myColor)+", "
          +this.points+", "
          +this.radius+", "
          +"]";
  }
  
  PVector [] getWorldPoints() {
    PVector[] worldPoints = new PVector[points.size()];
    for(int i=0;i<points.size();++i) {
      worldPoints[i] = localToWorld(points.get(i));
    }
    return worldPoints;
  }
  
  void updateShape() {
    float area = 0;
    float moi = 0;
    PVector centerAdjust = new PVector(0,0);
    float kInv3=1.0/3.0;
    
    // find center and moi
    for(int i=0;i<points.size();++i) {
      PVector p1 = points.get(i);
      PVector p2 = points.get((i+1)%points.size());
      float d = p1.cross(p2).z;
      float triangleArea = d/2.0;
      area += triangleArea;
      centerAdjust.add(PVector.add(p1,p2).mult(kInv3*triangleArea));
      float intX2 = p1.x * p1.x + p2.x * p1.x + p2.x * p2.x;
      float intY2 = p1.y * p1.y + p2.y * p1.y + p2.y * p2.y;
      moi += (0.25f * kInv3 * d) * (intX2 + intY2);
    }
    
    // adjust center
    centerAdjust.mult(1.0/area);
    for(PVector p : points) {
      p.sub(centerAdjust);
    }
    
    setMomentOfInertia(moi);
  }
  
  PVector getSupport( PVector dir ) {
    float bestProjection = -Float.MAX_VALUE;

    PVector [] c = getWorldPoints();
    PVector bestVertex = c[0];
    for(int i=0; i<c.length; ++i) {
      PVector v = c[i];
      float projection = v.dot(dir);

      if(projection > bestProjection) {
        bestVertex = v;
        bestProjection = projection;
      }
    }
    //circle(bestVertex.x,bestVertex.y,20);

    return bestVertex;
  }
  
  boolean pointInside(PVector pWorld) {
    int count = points.size();
    if(count==0) return false;
    
    PVector pLocal = worldToLocal(pWorld);
    PVector p0 = points.get(0);
    PVector center = new PVector(0,0,0);
    
    for(int i=0; i<count; ++i) {
      int j = (i+1) % count;
      PVector p1 = points.get(j);
      
      if(pointInTriangle(pLocal,center,p0,p1)) return true;
      p0=p1;
    }
    
    return false;
  }
}
