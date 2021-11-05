
void testOneBallAndWall() {
  println("testOneBallAndWall()");
  reset();
  
  BodyCircle a = addCircle(40,5);  
  a.position.set(width/2-50,height/2-15);
  a.velocity.set(50,40);
  a.angularV.set(0,0,radians(10));
}

void testOneBoxAndWall() {
  println("testOneBallAndWall()");
  reset();
  
  BodyBox a = addBox(30*4,20*4,15);
  a.position.set(width/2-50,height/2-15);
  a.velocity.set(50,40);
  a.angularV.set(0,0,radians(10));
}

void testTwoBoxes() {
  println("testTwoBoxes()");
  reset();
  bodies.clear();
  
  BodyBox a = addBox(30*4,20*4,5);
  BodyBox b = addBox(30*4,40*4,10);
  
  a.position.set(width/2-100,height/2-15);
  b.position.set(width/2+100,height/2);
  a.velocity.set(15,0);
  b.velocity.set(0,0);
  a.angularV.set(0,0,radians(10));
  a.angularV.set(0,0,radians(-40));
}

void testTwoCircles() {
  println("testTwoCircles()");
  reset();
  
  BodyCircle a = addCircle(15,5);
  BodyCircle b = addCircle(30,10);
  
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
  
  BodyCircle a = addCircle(50,10);
  BodyBox b = addBox(5*20,10*20,20);
  b.updateRadius();
  b.myColor = color(128,0,0);

  a.position.set(width/2-90,height/2-60);
  b.position.set(width/2+50,height/2);
  a.velocity.set(35,0);
  b.velocity.set(0,0);
}


void testRandomShapes() {
  println("testRandomShapes()");
  reset();
  for(int i=0;i<20;++i) {
    if(i%2==0) {
      BodyCircle b = addCircle(random(5,30),random(1,6));
      b.position.set(random(width-b.radius*2)+b.radius,
                     random(height-b.radius*2)+b.radius);
    } else {
      BodyBox b = addBox(random(10,50),random(20,40),random(2,8));
      float larger = max(b.w,b.h);
      b.position.set(random(width-larger*2)+larger,
                     random(height-larger*2)+larger);
    }
    Body b = bodies.get(bodies.size()-1); 
    b.velocity.set(random(50)-25,random(50)-25);
    b.angularV.z=random(10)-5;
  }
}

BodyCircle addCircle(float r,float m) {
  BodyCircle b = new BodyCircle(r,m);
  bodies.add(b);
  return b;
}

BodyBox addBox(float w,float h,float m) {
  BodyBox b = new BodyBox(w,h,m);
  bodies.add(b);
  return b;
}
