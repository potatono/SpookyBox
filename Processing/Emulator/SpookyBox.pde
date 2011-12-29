 import processing.net.*;

// Image used under CC-Attribution license
// Image: 'my girl has a pretty blue eye' 
// www.flickr.com/photos/48716466@N00/494087896

boolean knobIsActive = false;
Knob knob1;
Knob knob2;
Knob knob3;
Button button1;
Button button2;
Button button3;
Button button4;
Server server;

void setup() {
  size(480,360);
  image(loadImage("skull.jpg"),0,0);
  smooth();
  strokeWeight(2);
 
  button1 = new Button(30,30,200,50,50);
  button2 = new Button(450,30,50,200,50);
  button3 = new Button(30,330,50,50,200);
  button4 = new Button(450,330,200,200,50); 
  knob1 = new Knob(100,180);
  knob2 = new Knob(240,180);
  knob3 = new Knob(380,180); 
  server = new Server(this,5204);
}

void draw() {
  // TODO FIXME HACK - This draws the initial knobs.  Each one has to be drawn in a different frame because they each use their own translation/rotation matrix
  if (frameCount == 1)
    knob1.draw();
  else if (frameCount == 2)
    knob2.draw();
  else if (frameCount == 3)
    knob3.draw();
    
  knob1.run();
  knob2.run();
  knob3.run();
  button1.run();
  button2.run();
  button3.run();
  button4.run();
  
  if (frameCount % 3 == 0) {
    server.write(255);
    server.write(255);
    server.write(255);    
    server.write(knob1.getValue() >> 8);
    server.write(knob1.getValue() & 0xFF);
    server.write(knob2.getValue() >> 8);
    server.write(knob2.getValue() & 0xFF);
    server.write(knob3.getValue() >> 8);
    server.write(knob3.getValue() & 0xFF);

    server.write(button1.getValue() ? 1 : 0);
    server.write(button2.getValue() ? 1 : 0);
    server.write(button3.getValue() ? 1 : 0);
    server.write(button4.getValue() ? 1 : 0);
/*
    println ("SERVER> knob1=" + knob1.getValue() + 
            " knob2=" + knob2.getValue() +
            " knob3=" + knob3.getValue() +
            " button1=" + (button1.getValue() ? 1 : 0) +
            " button2=" + button2.getValue() +
            " button3=" + button3.getValue() +
            " button4=" + button4.getValue());
*/            
  }
      
}

class Button {
  int x = 0;
  int y = 0;
  int r = 0;
  int g = 0;
  int b = 0;
  boolean isDown = false;
  
  Button(int x, int y, int r, int g, int b) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.g = g;
    this.b = b;
    draw();
  }
  
  public void draw() {
    if (isDown) {
      stroke(r,g,b);
      fill(r/2+50,g/2+50,b/2+50);
    }
    else {
      stroke(r,g,b);
      fill(r/2,g/2,b/2);
    }
    ellipseMode(CENTER);
    ellipse(x,y,40,40);
  }
  
  public boolean isMouseOver() {
    return mouseX >= x-20 && mouseX <= x+20 && mouseY >= y-20 && mouseY <= y+20;
  }
  
  public void run() {
      if (isDown) {
        if (!mousePressed) {
          isDown = false;
          draw();
        }
      }
      else if (isMouseOver() && mousePressed) {
        isDown = true;
        draw();
      }    
  }

  public boolean getValue() {
    return isDown;
  } 
}

class Knob {
  int x = 0;
  int y = 0;
  int value = 0;
  boolean isActive = false;
  int lastMouseX;
  
  Knob(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  public void draw() {
    ellipseMode(CENTER);
    if (isActive) {
      stroke(150);
      fill(100);
    }
    else {
      stroke(100);
      fill(50);
    }

    translate(x,y);
    rotate((value/1024.0)*(2*PI));
    ellipse(0,0,100,100);
    line(0,-50,0,-30);  
  }
  
  private boolean isMouseOver() {
    return mouseX >= x-50 && mouseX <= x+50 && mouseY >= y-50 && mouseY <= y+50;
  }
  
  public void run() {
    if (isActive) {
      if (!mousePressed) {
        knobIsActive = isActive = false;
        draw();
      }
      else {
        value += ((mouseX-lastMouseX)*3);
        if (value < 0)
          value = 0;
        else if (value > 1024)
          value = 1024;
        lastMouseX = mouseX;
        draw();
      }
    }
    else if (!knobIsActive && isMouseOver() && mousePressed) {
      lastMouseX = mouseX;
      knobIsActive = isActive = true;
    }
  }
  
  public int getValue() {
     return value;
  }
}
