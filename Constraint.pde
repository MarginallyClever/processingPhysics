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
    
    PVector drift = PVector.sub(aPointW,bPoint);
    aBody.position.sub(drift);
  }
}


// this object cannot move, it is locked to the world.
class FixedConstraint extends Constraint {
  void resolveConstraint() {}
}


// two bodies that pinned to each other
class HingeConstraint extends Constraint {
  HingeConstraint(Body a,PVector aPoint,PVector bPoint) {
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
    
    PVector drift = PVector.sub(aPointW,bPoint);
    aBody.position.sub(drift);
  }
}


class SpringConstraint extends Constraint {
  float restingLength;
  float springConstant=0.25;
  
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
    
    PVector diff = PVector.sub(bPointW,aPointW); 
    float len = diff.mag();
    float x = len - restingLength;
    float force = -springConstant * x;
    float adjust = (len==0 ? 0 : force/len);
    diff.mult(adjust);
    
    float v = max(min(x,127),-127);
    stroke(0,127+v,255);      
    line(aPointW.x,aPointW.y,bPointW.x,bPointW.y);
    
    if(bBody!=null) {
      diff.mult(0.5);
      PVector Rb = bBody.getR(bPointW);
      bBody.applyImpulse(PVector.mult(diff,-1),Rb);
    }
    
    PVector Ra = aBody.getR(aPointW);
    aBody.applyImpulse(diff,Ra);
  }
}
