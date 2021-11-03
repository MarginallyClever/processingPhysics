class BodyBox extends Body {
  public float width=1;
  public float height=1;
  
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
          +this.mass+"\t"
          +this.acceleration+"\t"
          +this.velocity+"\t"
          +this.position+"\t"
          +this.width+"\t"
          +this.height+"\t"
          +this.myColor;
  }
  
  PVector [] getCorners() {
    PVector[] corners = new PVector[4];
    corners[0] = new PVector(-width/2,-height/2);
    corners[1] = new PVector( width/2,-height/2);
    corners[2] = new PVector( width/2, height/2);
    corners[3] = new PVector(-width/2, height/2);
    for(int i=0;i<4;++i) {
      corners[i].rotate(radians(this.angle));
      corners[i].add(this.position);
    }
    return corners;
  }
  
  float getMomentOfInertia() {
    return this.mass * (sq(width)+sq(height)) / 12.0;
  }
}
