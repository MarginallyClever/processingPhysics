
void testOneBallAndWall() {
  println("testOneBallAndWall()");
  reset();
  
  addCircle();
  BodyCircle a = (BodyCircle)bodies.get(bodies.size()-1);
  a.setMass(5);
  a.radius=40;
  
  a.position.set(width/2-50,height/2-15);
  a.velocity.set(50,40);
  a.angularV.set(0,0,radians(10));
}

void testOneBoxAndWall() {
  println("testOneBallAndWall()");
  reset();
  
  addBox();
  BodyBox a = (BodyBox)bodies.get(bodies.size()-1);
  a.setMass(15);
  a.width=30*4;
  a.height=20*4;
  
  a.position.set(width/2-50,height/2-15);
  a.velocity.set(50,40);
  a.angularV.set(0,0,radians(10));
}


void testTwoCircles() {
  println("testTwoCircles()");
  reset();
  
  addCircle();
  Body a = bodies.get(bodies.size()-1);
  ((BodyCircle)a).setMass(5);
  ((BodyCircle)a).radius=15;
  
  addCircle();
  Body b = bodies.get(bodies.size()-1);
  ((BodyCircle)b).setMass(10);
  ((BodyCircle)b).radius=30;
  
  a.position.set(width/2-50,height/2-15);
  b.position.set(width/2+50,height/2);
  a.velocity.set(15,0);
  b.velocity.set(0,0);
  a.angularV.set(0,0,radians(10));
  a.angularV.set(0,0,radians(-40));
}

void testOneBoxAndOneCircle() {
  println("testOneBoxAndOneCircle()");
  reset();
  addCircle();
  Body a = bodies.get(bodies.size()-1);
  ((BodyCircle)a).setMass(50);
  ((BodyCircle)a).radius=50;
  
  addBox();
  Body b = bodies.get(bodies.size()-1); 
  ((BodyBox)b).setMass(50);
  ((BodyBox)b).width=5*20;
  ((BodyBox)b).height=10*20;
  
  a.position.set(width/2-90,height/2-35);
  b.position.set(width/2+50,height/2);
  a.velocity.set(15,0);
  b.velocity.set(0,0);
}


void testRandomShapes() {
  println("testRandomShapes()");
  reset();
  for(int i=0;i<20;++i) {
    if(i%2==0) {
      addCircle();
    } else {
      addBox();
    }
    Body b = bodies.get(bodies.size()-1); 
    b.velocity.set(random(50)-25,random(50)-25);
    b.angularV.z=random(10)-5;
  }
}

void addCircle() {
  BodyCircle b = new BodyCircle();
  b.setMass(random(1,20));
  b.radius=b.getMass()/2;
  b.position.set(random(800-b.radius*2)+b.radius,
                 random(800-b.radius*2)+b.radius);
  bodies.add(b);
}

void addBox() {
  BodyBox b = new BodyBox();
  b.setMass(random(1,20));
  b.width = random(1,5);
  b.height = b.getMass()/b.width;
  b.width*=8;
  b.height*=8;
  float larger = max(b.width,b.height);
  b.position.set(random(800-larger*2)+larger,
                 random(800-larger*2)+larger);
  bodies.add(b);
}
