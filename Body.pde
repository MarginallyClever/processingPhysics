abstract class Body {
  public color myColor = color(0,0);
  private float mass = 1;
  private float inverseMass = 1;
  private float momentOfInertia = 1;
  private float inverseMomentOfInertia = 1;

  public PVector position = new PVector(0,0);
  public PVector velocity = new PVector(0,0);
  public PVector acceleration = new PVector(0,0);
  
  public PVector angle = new PVector(0,0,0);
  public PVector angularV = new PVector(0,0,0);
  public PVector torque = new PVector(0,0,0);
  
  public void setMass(float m) {
    this.mass=m;
    if(m==0) this.inverseMass=0;
    else this.inverseMass = 1.0/m;
  }
  
  public float getInverseMass() {
    return this.inverseMass;
  }
  
  public float getMass() {
    return this.mass;
  }
  
  public float getMomentOfInertia() {
    return this.momentOfInertia;
  }
  
  public float getInverseMomentOfInertia() {
    return this.inverseMomentOfInertia;
  }
  
  public void setMomentOfInertia(float moi) {
    this.momentOfInertia=moi;
    if(moi==0) this.inverseMomentOfInertia=0;
    else this.inverseMomentOfInertia=1.0/moi;
  }
  
  public void setStatic() {
    setMass(0);
    setMomentOfInertia(0);
  }

  public void render() {
    stroke(255,0,0);
    line(position.x,position.y,
         position.x+velocity.x,position.y+velocity.y);
    
    float c = cos(angle.z);
    float s = sin(angle.z);
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
    
    this.angularV.add(PVector.mult( this.torque, (1.0/getMomentOfInertia()) * dt));
    this.torque.set(0,0,0);
  }
  
  public void move(float dt) {
    this.position.add(PVector.mult(this.velocity,dt));
    this.angle.add(PVector.mult(this.angularV,dt));
  }
  
  abstract public String toString();
    
  void applyImpulse(PVector impulse,PVector contactVector) {
    this.velocity.add(PVector.mult(impulse,1.0/mass));
    this.angularV.add( contactVector.cross(impulse) );
  }
  
  PVector getCombinedVelocityAtPoint(PVector p) {
    PVector r = getR(p);
    return PVector.add(velocity,angularV.cross(r));
  }
  
  PVector getR(PVector p) {
    return PVector.sub(p,this.position);
  }
}
