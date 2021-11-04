class BodyBox extends Body {
  public float w=1;
  public float h=1;
  
  public void render() {
    stroke(myColor);
    PVector[] c = getCorners();
    for(int i=0;i<4;++i) {
      int j=(i+1)%4;
      line(c[i].x,c[i].y,
           c[j].x,c[j].y);
    }
    
    super.render();
  }
  
  public String toString() {
    return BodyBox.class.getSimpleName()+"\t"
          +this.getMass()+"\t"
          +this.acceleration+"\t"
          +this.velocity+"\t"
          +this.position+"\t"
          +this.w+"\t"
          +this.h+"\t"
          +this.myColor;
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
    setMomentOfInertia(this.getMass() * (sq(this.w)+sq(this.h)) / 12.0);
  }
}
