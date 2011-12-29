import processing.net.*;
import processing.serial.*;
import com.nycresistor.processing.*;
 
SpookyBox mySpookyBox;
 
void setup() {
  //frameRate(5);
  // When connecting an actual device, you would use SpookyBox.SERIAL
  //mySpookyBox = new SpookyBox(this, SpookyBox.NETWORK);
 
  // NOTE, If you want to override the network or serial port settings you can
  // use a constructor like this:
  // mySpookyBox = new SpookyBox(this, SpookyBox.NETWORK, "192.168.1.50", 8080);
  //println(Serial.list());
  mySpookyBox = new SpookyBox(this, SpookyBox.SERIAL, Serial.list()[0], 9600);
}
 
void draw() {
  // Knobs return 0-1024.  Buttons return true or false.
/*
  println("knob1=" + mySpookyBox.getKnob1() +
    " knob2=" + mySpookyBox.getKnob2() + 
    " knob3=" + mySpookyBox.getKnob3() +
    " button1=" + mySpookyBox.isButton1() +
    " button2=" + mySpookyBox.isButton2() +
    " button3=" + mySpookyBox.isButton3() +
    " button4=" + mySpookyBox.isButton4()
  );
*/
}
