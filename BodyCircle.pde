class BodyCircle extends Body {
  public float radius=1;
  
  public BodyCircle() {
    super();
  }
  
  public BodyCircle(float r,float m) {
    this.radius=r;
    this.setMass(m);
    updateShape();
  }
  
  public void render() {
    fill(myColor);
    stroke(0,0,0);
    circle(position.x,position.y,radius*2);
    
    super.render();
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
          +this.radius+", "
          +"]";
  }
  
  void updateShape() {
    setMomentOfInertia(PI * this.getMass() * pow(this.radius,4) / 4);
  }
  
  boolean pointInside(PVector pWorld) {
    PVector diff = PVector.sub(pWorld,this.position);
    return (diff.magSq() <= sq(radius));
  }
}
