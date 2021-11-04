class BodyCircle extends Body {
  public float radius=1;
  
  public void render() {
    stroke(myColor);
    circle(position.x,position.y,radius*2);
    
    super.render();
  }
  
  public String toString() {
    return BodyCircle.class.getSimpleName()+"\t"
          +this.getMass()+"\t"
          +this.acceleration+"\t"
          +this.velocity+"\t"
          +this.position+"\t"
          +this.radius+"\t"
          +this.myColor;
  }
  
  void updateShape() {
    setMomentOfInertia(this.getMass() * sq(this.radius) / 2.0);
  }
}
