import processing.net.*;
import com.nycresistor.processing.*;
import processing.video.*;

public static final int VIDEO_WIDTH = 640;
public static final int VIDEO_HEIGHT = 480;
public static final int VIDEO_TOP = 60;
public static final int VIDEO_LEFT = 0;
public static final int WINDOW_WIDTH = 640;
public static final int WINDOW_HEIGHT = 480 + 120;

public static final int MODE_PRECAPTURE = 0;
public static final int MODE_WAITCAPTURE = 1;
public static final int MODE_CAPTURE = 2;
public static final int MODE_SAVECAPTURE = 3;
public static final int MODE_SHUFFLE = 4;

Capture capture;
PImage currentImage;
PFont font;
long timer;
int currentMode = MODE_PRECAPTURE;
SpookyBox spookyBox;
PImage[] images = new PImage[128];
int imageCount = 0;
PImage frameBuffer;

void setup() {
   size(WINDOW_WIDTH,WINDOW_HEIGHT);
   println(Capture.list());
   capture = new Capture(this, 640, 480, 30);
   smooth();
   background(0);
   
   font = loadFont("FFFAtlantisBoldCondensed-48.vlw");
   spookyBox = new SpookyBox(this, SpookyBox.SERIAL);

   frameBuffer = createImage(VIDEO_WIDTH, VIDEO_HEIGHT, RGB);

   images[0] = loadImage("snap1.jpg");
   images[1] = loadImage("snap2.jpg");
   images[2] = loadImage("snap3.jpg");
   images[3] = loadImage("snap4.jpg");
   imageCount = 4;
   
   switchMode(MODE_SHUFFLE);
}

void draw() {
  if (currentMode == MODE_PRECAPTURE) {
    drawPreCapture();
  }
  else if (currentMode == MODE_WAITCAPTURE) {
    drawWaitForCapture();
  }
  else if (currentMode == MODE_CAPTURE) {
    drawCapture();
  }
  else if (currentMode == MODE_SAVECAPTURE) {
    drawSaveCapture();
  }
  else if (currentMode == MODE_SHUFFLE) {
    drawShuffle();
  }
}

void mirrorImage(PImage i) {
  i.loadPixels();
  int x;
  int y;
  color t;
  int ofs;
  int iofs;
  int half_video_width = int(i.width/2);
  
  for(y=0; y<i.height; y++) {
    for (x=0; x<half_video_width; x++) {
      ofs = y * i.width + x;
      iofs = y * i.width + (i.width - x - 1);
      
      t = i.pixels[iofs];
      i.pixels[iofs] = i.pixels[ofs];
      i.pixels[ofs] = t;
    }
  }
  
  i.updatePixels();
}

void drawCapturing() {
    if (capture.available()) {
    capture.read();
    mirrorImage(capture);

    image(capture,VIDEO_LEFT,VIDEO_TOP);

    ellipseMode(CENTER);
    fill(180,80);
    stroke(255,80);
    strokeWeight(8);
    ellipse(
      VIDEO_WIDTH/2+VIDEO_LEFT,
      VIDEO_HEIGHT/2+VIDEO_TOP,
      (float)Math.floor(VIDEO_WIDTH*0.5),
      (float)Math.floor(VIDEO_HEIGHT*0.8)
    );
    
    ellipse(
      VIDEO_WIDTH/2+VIDEO_LEFT - (float)Math.floor(VIDEO_WIDTH*0.5*0.25),
      VIDEO_HEIGHT/2+VIDEO_TOP - (float)Math.floor(VIDEO_HEIGHT*0.8*0.20),
      (float)Math.floor(VIDEO_WIDTH*0.08),
      (float)Math.floor(VIDEO_HEIGHT*0.1)
    );

    ellipse(
      VIDEO_WIDTH/2+VIDEO_LEFT + (float)Math.floor(VIDEO_WIDTH*0.5*0.25),
      VIDEO_HEIGHT/2+VIDEO_TOP - (float)Math.floor(VIDEO_HEIGHT*0.8*0.20),
      (float)Math.floor(VIDEO_WIDTH*0.08),
      (float)Math.floor(VIDEO_HEIGHT*0.1)
    );
    
    arc(
      VIDEO_WIDTH/2+VIDEO_LEFT,
      VIDEO_HEIGHT/2+VIDEO_TOP + (float)Math.floor(VIDEO_HEIGHT*0.8*0.20),
      (float)Math.floor(VIDEO_WIDTH*0.5*0.65),
      (float)Math.floor(VIDEO_HEIGHT*0.8*0.1),
      0,
      PI
    );

    arc( 
      VIDEO_WIDTH/2+VIDEO_LEFT,
      VIDEO_HEIGHT/2+VIDEO_TOP,
      (float)Math.floor(VIDEO_WIDTH*0.5*0.1),
      (float)Math.floor(VIDEO_HEIGHT*0.8*0.2),
      -PI/2,
      PI/2
    );  
  }
}

void drawPreCapture() {
  drawCapturing();
 
  topMessage("GET IN MY FACE!", color(30,255,30), color(pulsing()));
  bottomMessage("PRESS A BUTTON", color(255,30,30), color(255-pulsing()));
  
  if (spookyBox.wasButton1() || spookyBox.wasButton2() || spookyBox.wasButton3() || spookyBox.wasButton4())
    switchMode(MODE_WAITCAPTURE);
}

void drawWaitForCapture() {
  drawCapturing();
  
  int seconds = 3 - int((millis() - timer) / 1000);

  if (millis()-timer > 3250) {
    switchMode(MODE_CAPTURE);
  }
  else if (seconds < 1) {
    fill(255);
    rect(0,0,WINDOW_WIDTH,WINDOW_HEIGHT);
  }
  else {
    topMessage("STAND STILL!", color(30,255,30), color(pulsing()));
    bottomMessage(
      seconds + "    " + seconds + "    " + seconds + "    " + seconds + "    " + seconds,
      color(255,30,30), 
      color(255-pulsing())
    );
  }
}

void drawCapture() {
  image(currentImage,VIDEO_LEFT,VIDEO_TOP);
  topMessage("CLICK!", color(255), color(0));
  bottomMessage("CLICK!", color(255), color(0));
  
  int c = 255 - (int)Math.floor((millis()-timer)/2000.0*255);
  
  fill(255,c);
  noStroke();
  rect(0,0,WINDOW_WIDTH,WINDOW_HEIGHT);
  
  if (millis() - timer > 2000) {
    switchMode(MODE_SAVECAPTURE);
  }
}  

void drawSaveCapture() {
  image(currentImage,VIDEO_LEFT,VIDEO_TOP);
  topMessage("mid BTN = KEEP IT!", color(30,255,30), color(pulsing(5)));
  bottomMessage("BOTTOM BTN = DUMP IT!", color(255,30,30), color(pulsing(5)));
  
  if (spookyBox.wasButton1() || spookyBox.wasButton2()) {
    saveCurrentImage();
        
    switchMode(imageCount < 2 ? MODE_PRECAPTURE : MODE_SHUFFLE);
  }
  else if (spookyBox.wasButton3() || spookyBox.wasButton4()) {
    switchMode(imageCount < 2 ? MODE_PRECAPTURE : MODE_SHUFFLE);
  }
}

void drawShuffle() {
  int knobSliceSize = 1024/imageCount;
  
  int topRightImageNumber = int(spookyBox.getKnob1() / 1024.0 * (imageCount - 1));
  int topLeftImageNumber = topRightImageNumber + 1;
  int topOffset = int((spookyBox.getKnob1() % knobSliceSize) / (knobSliceSize * 1.0) * VIDEO_WIDTH);

  int midRightImageNumber = int(spookyBox.getKnob2() / 1025.0 * (imageCount - 1));
  int midLeftImageNumber = midRightImageNumber + 1;
  float midOffsetDistance = spookyBox.getKnob2() - midRightImageNumber * knobSliceSize * 1.0;
  int midOffset = int(midOffsetDistance / knobSliceSize * VIDEO_WIDTH);

  int botRightImageNumber = int(spookyBox.getKnob3() / 1024.0 * (imageCount - 1));
  int botLeftImageNumber = botRightImageNumber + 1;
  int botOffset = int((spookyBox.getKnob3() % knobSliceSize) / (knobSliceSize * 1.0) * VIDEO_WIDTH);

  println("knob2=" + spookyBox.getKnob2() + " midOffsetDistance=" + midOffsetDistance + " knobSliceSize="+knobSliceSize+" midLeftImageNumber="+midLeftImageNumber+" midRightImageNumber="+midRightImageNumber+" midOffset="+midOffset);
  
  PImage topLeftImage = images[topLeftImageNumber];
  PImage topRightImage = images[topRightImageNumber];
  PImage midLeftImage = images[midLeftImageNumber];
  PImage midRightImage = images[midRightImageNumber];
  PImage botLeftImage = images[botLeftImageNumber];
  PImage botRightImage = images[botRightImageNumber];

  frameBuffer.copy(topLeftImage,
    0,
    0,
    topOffset,
    int(VIDEO_HEIGHT * 0.4),
    0,
    0,
    topOffset,
    int(VIDEO_HEIGHT * 0.4)
  );
  
  frameBuffer.copy(topRightImage,
    topOffset,
    0,
    VIDEO_WIDTH-topOffset,
    int(VIDEO_HEIGHT * 0.4),
    topOffset,
    0,
    VIDEO_WIDTH-topOffset,
    int(VIDEO_HEIGHT * 0.4)
  );
  
  frameBuffer.copy(midLeftImage,
    0,
    int(VIDEO_HEIGHT * 0.4),
    midOffset,
    int(VIDEO_HEIGHT * 0.2),
    0,
    int(VIDEO_HEIGHT * 0.4),
    midOffset,
    int(VIDEO_HEIGHT * 0.2)
  );
  
  frameBuffer.copy(midRightImage,
    midOffset,
    int(VIDEO_HEIGHT * 0.4),
    VIDEO_WIDTH-midOffset,
    int(VIDEO_HEIGHT * 0.2),
    midOffset,
    int(VIDEO_HEIGHT * 0.4),
    VIDEO_WIDTH-midOffset,
    int(VIDEO_HEIGHT * 0.2)
  );

  frameBuffer.copy(botLeftImage,
    0,
    int(VIDEO_HEIGHT * 0.6),
    botOffset,
    int(VIDEO_HEIGHT * 0.4),
    0,
    int(VIDEO_HEIGHT * 0.6),
    botOffset,
    int(VIDEO_HEIGHT * 0.4)
  );
  
  frameBuffer.copy(botRightImage,
    botOffset,
    int(VIDEO_HEIGHT * 0.6),
    VIDEO_WIDTH-botOffset,
    int(VIDEO_HEIGHT * 0.4),
    botOffset,
    int(VIDEO_HEIGHT * 0.6),
    VIDEO_WIDTH-botOffset,
    int(VIDEO_HEIGHT * 0.4)
  );
  
  image(frameBuffer,VIDEO_LEFT,VIDEO_TOP);
  
  strokeWeight(4);
  stroke(255,80);
  line(0,VIDEO_TOP+int(VIDEO_HEIGHT * 0.4),VIDEO_WIDTH,VIDEO_TOP+int(VIDEO_HEIGHT * 0.4));
  line(0,VIDEO_TOP+int(VIDEO_HEIGHT * 0.6),VIDEO_WIDTH,VIDEO_TOP+int(VIDEO_HEIGHT * 0.6));
  line(topOffset,VIDEO_TOP+4,topOffset,VIDEO_TOP+int(VIDEO_HEIGHT * 0.4));
  line(midOffset,VIDEO_TOP+int(VIDEO_HEIGHT * 0.4),midOffset,VIDEO_TOP+int(VIDEO_HEIGHT * 0.6));
  line(botOffset,VIDEO_TOP+int(VIDEO_HEIGHT * 0.6),botOffset,VIDEO_TOP+VIDEO_HEIGHT-4);
  
  topMessage("TOP BTN 2 TAKE PIC", color(255,255,30), pulsing(10));
  bottomMessage("BOTTOM BTN 2 TWEET", color(30,255,30), pulsing(10));
  
  if (spookyBox.wasButton1() || spookyBox.wasButton2()) {
     switchMode(MODE_PRECAPTURE);
  }
  
}

void saveCurrentImage() {
  if (imageCount < images.length) {
    images[imageCount] = currentImage;
    imageCount++;
    currentImage.save("data/snap"+imageCount+".jpg");
  }
  else {
    images[int(random(images.length))] = currentImage;
  }
}

int pulsing(float d) {
  return (int)Math.floor(127 + 127*Math.sin(radians(millis() / d % 360)));
}

int pulsing() {
  return pulsing(2);
}

void topMessage(String s, color backColor, color foreColor) {
  fill(backColor);
  noStroke();
  rect(0,0,WINDOW_WIDTH,(int)VIDEO_TOP);
  fill(foreColor);
  textFont(font,48);
  textAlign(CENTER, CENTER);
  text(s,0,0,WINDOW_WIDTH,VIDEO_TOP);
}

void bottomMessage(String s, color backColor, color foreColor) {
  int h = int(WINDOW_HEIGHT-VIDEO_TOP-VIDEO_HEIGHT);
  int y = WINDOW_HEIGHT - h;
  
  fill(backColor);
  noStroke();
  rect(0,y,WINDOW_WIDTH,h);
  fill(foreColor);
  textFont(font,48);
  textAlign(CENTER, CENTER);
  text(s,0,y,WINDOW_WIDTH,h);
}

void switchMode(int mode) {
  currentMode = mode;
  
  if (mode == MODE_WAITCAPTURE) {
    timer = millis();
  }
  else if (mode == MODE_CAPTURE) {
    timer = millis();
    currentImage = createImage(int(VIDEO_WIDTH), int(VIDEO_HEIGHT), RGB);
    currentImage.copy((PImage)capture,0,0,int(VIDEO_WIDTH),int(VIDEO_HEIGHT),0,0,int(VIDEO_WIDTH),int(VIDEO_HEIGHT));
  }
}

