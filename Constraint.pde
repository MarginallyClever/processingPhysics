abstract class Constraint {
  // the first body in the constraint (must be at least one)
  Body aBody;
  // the point in the body - relative to aBody - where the constraint happens.
  PVector aPoint = new PVector();
  
  abstract void resolveConstraint();
}


// this body is pinned at one point.
class PinConstraint extends Constraint {
  void resolveConstraint() {
    PVector aPointW = new PVector();
    
  }
}


// this object cannot move, it is locked to the world.
class FixedConstraint extends Constraint {
  void resolveConstraint() {}
}


// two bodies that pinned to each other
class HingeConstraint extends Constraint {  
  Body bBody;
  PVector bPoint = new PVector();
  
  void resolveConstraint() {}
}


class SpringConstraint extends Constraint {
  Body bBody;
  PVector bPoint = new PVector();
  
  void resolveConstraint() {}
}
