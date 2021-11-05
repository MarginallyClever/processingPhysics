import java.util.*;

float coefficientOfRestitution = 0.85;

class Manifold {
  Body a, b;
  PVector normal=new PVector();
  ArrayList<PVector> contacts = new ArrayList<PVector>();
  float penetration=0;
  
  public Manifold(Body a,Body b) {
    this.a=a;
    this.b=b;
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
        
    println("M: "+toString());
    
    for( PVector p : contacts ) {      
      PVector Va = a.getCombinedVelocityAtPoint(p);
      PVector Vb = b.getCombinedVelocityAtPoint(p);
      PVector Vr = PVector.sub(Vb,Va);
      float contactVel = PVector.dot(Vr,normal);
      
      println("Vr="+Vr);
      println("contactVel="+contactVel);

      stroke(  0,  0,255);  circle(p.x,p.y,5);
      //stroke(  0,  0,255);  line(p.x,p.y, p.x+normal.x*10,         p.y+normal.y*10);
      stroke(128,128,255);  line(p.x,p.y, p.x+normal.x*contactVel, p.y+normal.y*contactVel);
      stroke(255,  0,  0);  line(p.x,p.y, p.x+Vb.x,             p.y+Vb.y);
      stroke(  0,255,  0);  line(p.x,p.y, p.x+Va.x,             p.y+Va.y);
      
      if(contactVel>0) continue;
    
      PVector Ra = a.getR(p);
      PVector Rb = b.getR(p);
      float Ran = Ra.cross(normal).z;
      float Rbn = Rb.cross(normal).z;
      float inverseMassSum = a.getInverseMass() 
                            + b.getInverseMass() 
                            + sq(Ran) * a.getInverseMomentOfInertia() 
                            + sq(Rbn) * b.getInverseMomentOfInertia();
      
      float Jr = -(1.0f +coefficientOfRestitution) * contactVel;
      Jr /= inverseMassSum;
      Jr /= numContacts;

      println("inverseMassSum="+inverseMassSum);
      println("Jr="+Jr);
      
      a.applyImpulse( PVector.mult(normal,-Jr), Ra );
      b.applyImpulse( PVector.mult(normal, Jr), Rb );
    }
  }
  
  void correctPosition() {
    float k_slop = 0.05f; // Penetration allowance
    float percent = 0.4f; // Penetration percentage to correct
    float numerator = max( penetration - k_slop, 0.0f );
    float denominator = a.getInverseMass() + b.getInverseMass();
    PVector correction = PVector.mult(this.normal, (numerator / denominator) * percent);
    //a.position.sub( PVector.mult(correction, a.getInverseMass()) );
    //b.position.add( PVector.mult(correction, b.getInverseMass()) );
  }
}