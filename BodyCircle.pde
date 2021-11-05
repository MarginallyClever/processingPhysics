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
    stroke(myColor);
    circle(position.x,position.y,radius*2);
    
    super.render();
  }
  
  public String toString() {
    return BodyCircle.class.getSimpleName()+"{"
          +this.position+", "
          +this.velocity+", "
          +this.force+", "
          +this.getMass()+"/"
          +this.getInverseMass()+", "
          +this.getMomentOfInertia()+"/"
          +this.getInverseMomentOfInertia()+", "
          +colorToString(this.myColor)+", "
          +this.radius+", "
          +"}";
  }
  
  void updateShape() {
    setMomentOfInertia(PI * this.getMass() * pow(this.radius,4) / 4);
  }
}
