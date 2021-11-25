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
// by comparing the two drift can be calculated and compensated
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
  void resolveConstraint() {}
}


class SpringConstraint extends Constraint {  
  void resolveConstraint() {}
}
