class BodyCircle extends Body {
  public float radius=1;
  
  public void render() {
    stroke(myColor);
    circle(position.x,position.y,radius*2);
    
    super.render();
  }
  
  public String toString() {
    return BodyCircle.class.getSimpleName()+"\t"
          +this.mass+"\t"
          +this.acceleration+"\t"
          +this.velocity+"\t"
          +this.position+"\t"
          +this.radius+"\t"
          +this.myColor;
  }
  
  float getMomentOfInertia() {
    return this.mass * sq(this.radius) / 2.0;
  }
}
