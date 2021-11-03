abstract class Body {
  public color myColor = color(0,0);
  public float mass=1;

  public PVector position = new PVector(0,0);
  public PVector velocity = new PVector(0,0);
  public PVector acceleration = new PVector(0,0);
  
  public float angle=random(360);
  public float angularV=0;
  public float torque=0;
  
  public void render() {
    stroke(255,0,0);
    line(position.x,position.y,
         position.x+velocity.x,position.y+velocity.y);
    stroke(0,255,0);
    line(position.x,position.y,
         position.x+cos(angle)*5,position.y+sin(angle)*5);
  }
  
  public void addGravity() {
    this.acceleration.y += 9.8 * this.mass;
  }
  
  public void accelerate(float dt) {
    this.velocity.add(this.acceleration.mult(dt));
    this.acceleration.set(0,0,0);
    
    this.angularV+=this.torque*dt;
    this.torque=0;
  }
  
  public void move(float dt) {
    this.position.add(PVector.mult(this.velocity,dt));
    this.angle += this.angularV*dt;
  }
  
  abstract public String toString();
  abstract float getInertiaTensor();
  
  void applyForceAtPoint(PVector p,PVector f) {
    PVector n = f.normalize();
    PVector r = PVector.sub(p,this.position);
    float newTorque = r.cross(n).z;
    this.torque += newTorque / this.getInertiaTensor();
  }
}
