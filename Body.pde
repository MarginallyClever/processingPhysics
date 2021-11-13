abstract class Body {
  public color myColor = color(0,0,0,32);
  private float mass = 1;
  private float inverseMass = 1;
  private float momentOfInertia = 1;
  private float inverseMomentOfInertia = 1;
  
  public float restitution=1;
  public float staticFriction = 0.9;
  public float dynamicFriction = 0.9;

  public PVector position = new PVector(0,0);
  public PVector velocity = new PVector(0,0);
  public PVector force = new PVector(0,0);
  
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
  
  public void integrateForces(float dt) {
    if(this.getInverseMass()==0) return;
    
    println("Gravity="+gravity.z);
    
    PVector f = PVector.add(gravity,PVector.mult(this.force,getInverseMass()));
    
    this.velocity.add( f.mult(dt/2.0) );
    this.angularV.add( PVector.mult( this.torque, getInverseMomentOfInertia()*dt/2.0) );
  }
  
  public void integrateVelocity(float dt) {
    this.position.add(PVector.mult(this.velocity,dt));
    this.angle.add(PVector.mult(this.angularV,dt));
    integrateForces(dt);
  }
  
  abstract public String toString();
    
  void applyImpulse(PVector impulse,PVector contactVector) {
    PVector linVel = PVector.mult( impulse,getInverseMass() );
    stroke(255,128,255);
    line(position.x,
         position.y, 
         position.x+linVel.x, 
         position.y+linVel.y);
      
    this.velocity.add( linVel );
    this.angularV.add( PVector.mult( contactVector.cross(impulse), getInverseMomentOfInertia() ) );
  }
  
  PVector getCombinedVelocityAtPoint(PVector p) {
    PVector r = getR(p);
    return PVector.add(this.velocity,this.angularV.cross(r));
  }
  
  PVector getR(PVector p) {
    return PVector.sub(p,this.position);
  }
}
