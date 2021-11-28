abstract class Constraint {
  Body aBody;
  PVector aPoint = new PVector();

  Body bBody;
  PVector bPoint = new PVector();
  
  abstract void resolveConstraint();
}


// this body is pinned at one point.
// aPoint is relative to the body.
// bPoint is relative to the world.
// by comparing the two drift can be calculated and adjusted
class PinConstraint extends Constraint {
  PinConstraint(Body a,PVector aPoint,PVector bPoint) {
    aBody=a;
    this.aPoint.set(aPoint);
    this.bPoint.set(bPoint);
  }
  
  void resolveConstraint() {
    PVector aPointW = aBody.localToWorld(aPoint);
    stroke(255,0,255);
    drawStar(aPointW,5);
    stroke(255,255,0);
    drawStar(bPoint,5);
    
    PVector impulse = aBody.getCombinedVelocityAtPoint(aPointW);
    impulse.mult(-1);
    PVector Ra = aBody.getR(aPointW);
    aBody.applyImpulse(impulse,Ra);
    
    PVector drift = PVector.sub(bPoint,aPointW);
    aBody.position.add(drift);
  }
}


// this object cannot move, it is locked to the world.
class FixedConstraint extends Constraint {
  void resolveConstraint() {}
}


// two bodies that pinned to each other
class HingeConstraint extends Constraint {
  HingeConstraint(Body a,PVector aPoint,Body b,PVector bPoint) {
    aBody=a;
    bBody=b;
    this.aPoint.set(aPoint);
    this.bPoint.set(bPoint);
  }
  
  void resolveConstraint() {
    PVector aPointW = aBody.localToWorld(aPoint);
    PVector bPointW = bBody.localToWorld(bPoint);
    stroke(255,0,255);
    drawStar(aPointW,5);
    stroke(255,255,0);
    drawStar(bPointW,5);
    
    PVector rV = PVector.sub(bBody.getCombinedVelocityAtPoint(bPointW),
                             aBody.getCombinedVelocityAtPoint(aPointW));
    PVector Ra = aBody.getR(aPointW);
    aBody.applyImpulse(PVector.mult(rV,-0.5),Ra);
    PVector Rb = bBody.getR(bPointW);
    aBody.applyImpulse(PVector.mult(rV,0.5),Rb);
    
    PVector drift = PVector.sub(bPointW,aPointW).mult(0.5);
    aBody.position.add(drift);
    bBody.position.sub(drift);
  }
}


class SpringConstraint extends Constraint {
  float restingLength;
  float springConstant=1.0;
  
  SpringConstraint(Body a,PVector aPoint,PVector bPoint) {
    aBody=a;
    this.aPoint.set(aPoint);
    this.bPoint.set(bPoint);
  }
  
  void setRestingLength() {
    PVector diff = PVector.sub(getAPointWorld(),getBPointWorld());
    restingLength = diff.mag();
  }
  
  PVector getAPointWorld() {
    return (aBody!=null) ? aBody.localToWorld(aPoint) : aPoint;
  }
  
  PVector getBPointWorld() {
    return (bBody!=null) ? bBody.localToWorld(bPoint) : bPoint;
  }
  
  void resolveConstraint() {
    PVector aPointW = getAPointWorld();
    PVector bPointW = getBPointWorld();
    
    PVector diff = PVector.sub(aPointW,bPointW); 
    float len = diff.mag();
    float x = len - restingLength;
    float force = -springConstant * x;
    diff.normalize();
    diff.mult(force);
 
    float v = max(min(x,127),-127);
    stroke(0,127+v,255);
    lineA2B(aPointW,bPointW);
    
    if(bBody!=null) {
      diff.mult(0.5);
      bBody.applyImpulse(PVector.mult(diff,-1),bBody.getR(bPointW));
    }
    aBody.applyImpulse(diff,aBody.getR(aPointW));
  }
}
