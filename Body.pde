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
    
    float c = cos(radians(angle));
    float s = sin(radians(angle));
    stroke(0,255,0);
    line(position.x, position.y,
         position.x+c*5, position.y+s*5);
  }
  
  public void addGravity() {
    this.acceleration.y += 9.8 * this.mass;
  }
  
  public void accelerate(float dt) {
    this.velocity.add(this.acceleration.mult(dt/mass));
    this.acceleration.set(0,0,0);
    
    this.angularV += this.torque * (1.0/getMomentOfInertia()) * dt;
    this.torque=0;
  }
  
  public void move(float dt) {
    this.position.add(PVector.mult(this.velocity,dt));
    this.angle += this.angularV*dt;
  }
  
  abstract public String toString();
  abstract float getMomentOfInertia();
    
  void applyForceAtPoint(PVector p,PVector f) {
    PVector n = f.normalize();
    PVector r = getR(p);
    float newTorque = r.cross(n).z;
    this.torque += newTorque;
  }
  
  PVector getCombinedVelocityAtPoint(PVector p) {
    PVector r = getR(p);
    PVector f = r.cross(new PVector(0,0,angularV));
    return PVector.add(f,velocity);
  }
  
  PVector getR(PVector p) {
    return PVector.sub(p,this.position);
  }
}
