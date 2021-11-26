import java.util.*;

class Manifold {
  Body a, b;
  PVector normal = new PVector();
  ArrayList<PVector> contacts = new ArrayList<PVector>();
  float penetration = 0;
  float staticFriction = 0;
  float dynamicFriction = 0;
  float e;
  
  
  public Manifold(Body a,Body b) {
    this.a=a;
    this.b=b;
    
    e = min(a.restitution,b.restitution);
    staticFriction = sqrt( a.staticFriction * b.staticFriction );
    dynamicFriction = sqrt( a.dynamicFriction * b.dynamicFriction );
  }
  
  public String toString() {
    return "["
      +a+", "
      +b+", "
      +normal+", "
      +penetration+", "
      +contacts+", "
      +"]";
  }
  
  void resolveCollisions() {
    float numContacts = contacts.size();
    if(numContacts==0) return;
    
    if(a.getInverseMass()==0 && b.getInverseMass()==0) {
      a.velocity.set(0,0,0);
      b.velocity.set(0,0,0);
      return;
    }
        
    //println("M: "+toString());
    normal.normalize();
    
    for( PVector p : contacts ) {
      PVector Va = a.getCombinedVelocityAtPoint(p);
      PVector Vb = b.getCombinedVelocityAtPoint(p);
      PVector Vr = PVector.sub(Vb,Va);
      float contactVel = PVector.dot(Vr,normal);
      
      //println("Vr="+Vr);
      //println("contactVel="+contactVel);
      //println("normal="+normal);

      stroke(  0,  0,255);  circle(p.x,p.y,5);
      //stroke(  0,  0,255);  lineAPlusB(p, PVector.mult(normal,10));
      stroke(128,128,255);  lineAPlusB(p, PVector.mult(normal,contactVel));
      stroke(255,  0,  0);  lineAPlusB(p, Vb);
      stroke(  0,255,  0);  lineAPlusB(p, Va);
      
      if(contactVel>0) continue;
    
      PVector Ra = a.getR(p);
      PVector Rb = b.getR(p);
      float Ran = Ra.cross(normal).z;
      float Rbn = Rb.cross(normal).z;
      float inverseMassSum = a.getInverseMass() 
                           + b.getInverseMass() 
                           + sq(Ran) * a.getInverseMomentOfInertia() 
                           + sq(Rbn) * b.getInverseMomentOfInertia();

      float Jr = -(1.0f + e) * contactVel;
      //println("Ran="+Ran);
      //println("Rbn="+Rbn);
      //println("Jr="+Jr);
      Jr /= inverseMassSum;
      Jr /= numContacts;
      //println("inverseMassSum="+inverseMassSum);
      //println("Jr after="+Jr);
      
      a.applyImpulse( PVector.mult(normal,-Jr), Ra );
      b.applyImpulse( PVector.mult(normal, Jr), Rb );

      // Friction
      // tangentImpulse is at a right angle to normal
      PVector tangentImpulse = PVector.sub(Vr,PVector.mult(normal,PVector.dot(Vr,normal)));
      
      stroke(255,0,255);  lineAPlusB(p,tangentImpulse);
      
      tangentImpulse.normalize();
      
      float Jt = -Vr.dot(tangentImpulse);
      Jt /= inverseMassSum;
      Jt /= numContacts;

      float v = abs(Jt);
      
      //println("Jt="+Jt);
      //println("staticFriction="+staticFriction);
      
      if(v < 1e-6) continue;
      if(v < Jr*staticFriction) {
        //println("static");
        tangentImpulse.mult(Jt);
      } else {
        //println("dynamic");
        tangentImpulse.mult(-Jr*dynamicFriction);
      }
      a.applyImpulse( PVector.mult(tangentImpulse,-1), Ra);
      b.applyImpulse( tangentImpulse, Rb);
    }
  }
  
  void correctPosition() {
    float k_slop = 0.05f; // Penetration allowance
    float percent = 0.4f; // Penetration percentage to correct
    float numerator = max( penetration - k_slop, 0.0f );
    float denominator = a.getInverseMass() + b.getInverseMass();
    PVector correction = PVector.mult(this.normal, (numerator / denominator) * percent);
    a.position.sub( PVector.mult(correction, a.getInverseMass()) );
    b.position.add( PVector.mult(correction, b.getInverseMass()) );
  }
  
  void testCollision() {
    if(a instanceof BodyCircle) {
      if(b instanceof BodyCircle) {
        testCollisionCircleCircle(this,(BodyCircle)a,(BodyCircle)b);
      } else if(b instanceof BodyPolygon) {
        testCollisionCirclePolygon(this,(BodyCircle)a,(BodyPolygon)b);
      }
    } else if(a instanceof BodyPolygon) {
      if(b instanceof BodyCircle) {
        Body temp=a;
        a=b;
        b=temp;
        testCollisionCirclePolygon(this,(BodyCircle)a,(BodyPolygon)b);
      } else if(b instanceof BodyPolygon) {
        testCollisionPolygonPolygon(this,(BodyPolygon)a,(BodyPolygon)b);
      }
    }
  }
}
