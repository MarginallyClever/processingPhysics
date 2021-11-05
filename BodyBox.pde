class BodyBox extends Body {
  public float w=1;
  public float h=1;
  public float r;
  
  public BodyBox() {
    super();
  }
  
  public BodyBox(PVector a,PVector b) {
    w=b.x-a.x;
    h=b.y-a.y;
    position.set(
      (a.x+b.x)/2,
      (a.y+b.y)/2);
    updateRadius();
    updateShape();
  }
  
  public BodyBox(float w,float h,float m) {
    this.w=w;
    this.h=h;
    this.setMass(m);
    updateRadius();
    updateShape();
  }
  
  public void updateRadius() {
    this.r=sqrt(w*w+h*h);
  }
  
  public void render() {
    stroke(myColor);
    PVector[] c = getCorners();
    for(int i=0;i<4;++i) {
      int j=(i+1)%4;
      line(c[i].x,c[i].y,
           c[j].x,c[j].y);
    }
    
    stroke(128,128,128);
    for(int i=0;i<4;++i) {
      int j=(i+1)%4;
      PVector n = getNormalTo(c[j],c[i]);
      PVector p = PVector.mult(PVector.add(c[i],c[j]),0.5);
      n = PVector.add(p,PVector.mult(n,10));
      line(p.x,p.y,n.x,n.y);
    }
    //stroke(192,192,192);
    //circle(position.x,position.y,r);
  
    super.render();
  }
  
  public String toString() {
    return BodyBox.class.getSimpleName()+"{"
          +this.position+", "
          +this.velocity+", "
          +this.force+", "
          +this.getMass()+"/"
          +this.getInverseMass()+", "
          +this.getMomentOfInertia()+"/"
          +this.getInverseMomentOfInertia()+", "
          +colorToString(this.myColor)+", "
          +this.w+", "
          +this.h+", "
          +this.r+", "
          +"}";
  }
  
  PVector [] getCorners() {
    PVector[] corners = new PVector[4];
    corners[0] = new PVector(-this.w/2,-this.h/2);
    corners[1] = new PVector( this.w/2,-this.h/2);
    corners[2] = new PVector( this.w/2, this.h/2);
    corners[3] = new PVector(-this.w/2, this.h/2);
    for(int i=0;i<4;++i) {
      corners[i].rotate(this.angle.z);
      corners[i].add(this.position);
    }
    return corners;
  }
  
  void updateShape() {
    setMomentOfInertia((sq(this.w)+sq(this.h)) * this.getMass() / 12.0);
  }
}
