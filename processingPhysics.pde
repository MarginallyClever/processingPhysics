ArrayList<Body> bodies = new ArrayList<Body>();
long tLast;

void setup() {
  size(800,800);
  tLast = millis();
  
  for(int i=0;i<50;++i) {
    Body b = new Body();
    b.mass=random(1,20);
    b.radius=b.mass;
    b.position.set(random(800),random(800));
    b.velocity.set(random(50)-25,random(50)-25);
    bodies.add(b);
  }
}

void draw() {
  long now = millis();
  float dt = now-tLast;
  if(dt<30) return;
  tLast = now;

  dt*=0.001;
  
  background(255,255,255);
  
  for( Body b : bodies ) {
    //println(dt+"\t"+b.toString());
    b.addGravity();
    b.accelerate(dt);
    
    testForCollisionsWithWindowEdge(b);
    testForCollisionsWithOtherBodies(b);
    
    b.position = PVector.add(b.position,PVector.mult(b.velocity,dt));
    
    b.render();
  }
}


void testForCollisionsWithOtherBodies(Body me) {
  for( Body b : bodies ) {
    if(b==me) continue;
    PVector dp = PVector.sub(me.position,b.position);
    float distance = dp.mag();
    if(distance<me.radius+b.radius) {
      float bias = (me.radius+b.radius - distance)/2;
      PVector n = dp.normalize();
      PVector p = PVector.add(b.position,PVector.mult(n,b.radius));
      b.collide(p,n);
      me.collide(p,n);
      b.acceleration.add(PVector.mult(n,bias*b.mass));
      me.acceleration.add(PVector.mult(n,-bias*me.mass));
    }
  }
}


void testForCollisionsWithWindowEdge(Body b) {
  if(b.velocity.y>0) {
       if(b.position.y+b.radius>height) {
         b.collide(new PVector(b.position.x,height),new PVector(0,-1));
       }
    } else if(b.velocity.y<0) {
       if(b.position.y-b.radius<0) {
         b.collide(new PVector(b.position.x,0),new PVector(0,1));
       }
    }

    if(b.velocity.x>0) {
       if(b.position.x+b.radius>height) {
         b.collide(new PVector(width,b.position.y),new PVector(-1,0));
       }
    } else if(b.velocity.x<0) {
       if(b.position.x-b.radius<0) {
         b.collide(new PVector(0,b.position.y),new PVector(1,0));
       }
    }
}
