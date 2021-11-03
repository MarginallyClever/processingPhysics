ArrayList<Body> bodies = new ArrayList<Body>();
long tLast;

void setup() {
  size(800,800);
  tLast = millis();
  noFill();
  
  testOneBoxAndOneCircle();
  //testRandomShapes();
}

void testOneBoxAndOneCircle() {
  addCircle();
  Body a = bodies.get(bodies.size()-1);
  ((BodyCircle)a).mass=5;
  ((BodyCircle)a).radius=15;
  
  addBox();
  Body b = bodies.get(bodies.size()-1); 
  ((BodyBox)b).mass=5;
  ((BodyBox)b).width=5*4;
  ((BodyBox)b).height=10*4;
  
  a.position.set(width/2-50,height/2);
  b.position.set(width/2+50,height/2);
  a.velocity.set(5,0);
  b.velocity.set(-5,0);
  a.angularV=10;
  b.angularV=-40;
}


void testRandomShapes() {
  for(int i=0;i<2;++i) {
    if(i%2==0) {
      addCircle();
    } else {
      //addCircle();
      addBox();
    }
    Body b = bodies.get(bodies.size()-1); 
    b.velocity.set(random(50)-25,random(50)-25);
    b.angularV=random(10)-5;
  }
}

void addCircle() {
  BodyCircle b = new BodyCircle();
  b.mass=random(1,20);
  b.radius=b.mass;
  b.position.set(random(800-b.radius*2)+b.radius,
                 random(800-b.radius*2)+b.radius);
  bodies.add(b);
}

void addBox() {
  BodyBox b = new BodyBox();
  b.mass=random(1,20);
  b.width = random(1,5);
  b.height = b.mass/b.width;
  b.width*=8;
  b.height*=8;
  float larger = max(b.width,b.height);
  b.position.set(random(800-larger*2)+larger,
                 random(800-larger*2)+larger);
  bodies.add(b);
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
    //b.addGravity();
    b.accelerate(dt);
  }

  testForCollisions();
    
  for( Body b : bodies ) {
    b.move(dt);
    b.render();
  }
}