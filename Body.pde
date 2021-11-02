class Body {
  public PVector position = new PVector(0,0);
  public PVector velocity = new PVector(0,0);
  public PVector acceleration = new PVector(0,0);
  public color myColor = color(0,0);
  public float mass=1;
  public float radius=1;
  
  public void render() {
    stroke(myColor);
    circle(position.x,position.y,radius*2);
    stroke(255,0,0);
    line(position.x,position.y,
         position.x+velocity.x,position.y+velocity.y);
  }
  
  public void addGravity() {
    this.acceleration.y += 9.8 * this.mass;
  }
  
  public void accelerate(float dt) {
    this.velocity.add(this.acceleration.mult(dt));
    this.acceleration.set(0,0,0);
  }
  
  public String toString() {
    return ""+this.mass+"\t"+this.acceleration+"\t"+this.velocity+"\t"+this.position+"\t"+this.radius+"\t"+this.myColor;
  }
  
  public void collide(PVector p, PVector n) {
    float vn = PVector.dot(this.velocity,n);
    if(vn>0) return;
    println("A");
    float coefficientOfRestitution = 0.6;
    this.velocity.add(PVector.mult(n,vn*-(1+coefficientOfRestitution)));
  }
}
