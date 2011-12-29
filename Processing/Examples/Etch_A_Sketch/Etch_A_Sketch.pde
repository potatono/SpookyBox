import com.nycresistor.processing.*;
import processing.serial.*;

SpookyBox spookybox;
int lastX = -1;
int lastY = -1;

void setup() {
  size(640,480);
  strokeWeight(4);
  smooth();
  background(204);

  spookybox = new SpookyBox(this,SpookyBox.SERIAL,Serial.list()[0],9600);
}

void draw() {
  int x=0;
  int y=0;
  
  if (spookybox.isButton1()) {
    background(204);
  }
  
  x = (int)Math.floor(spookybox.getKnob1()/1024.0 * 640);
  y = (int)Math.floor((1024-spookybox.getKnob3())/1024.0 * 480);
  
  strokeWeight(spookybox.getKnob2()/64);
  
  if (lastX>0 && lastY>0 && (Math.abs(lastX-x)>1 || Math.abs(lastY-y)>1)) {
    line(lastX,lastY,x,y);
  }
    
  lastX = x;
  lastY = y;
}
