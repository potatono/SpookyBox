#define DEBUG 0
#define VERSION_2 0
#define KNOB_REVERSE 1
#define BUTTON_REVERSE 1
#define PIN_KNOB_1 0
#define PIN_KNOB_2 1
#define PIN_KNOB_3 2
#define PIN_BUTTON_1 4
#define PIN_BUTTON_2 5
#define PIN_BUTTON_3 3
#define PIN_BUTTON_4 2

int knob1 = 0;
int knob2 = 0;
int knob3 = 0;
int button1 = 0;
int button2 = 0;
int button3 = 0;
int button4 = 0;

int lastKnob1 = -1;
int lastKnob2 = -1;
int lastKnob3 = -1;
int lastButton1 = 0;
int lastButton2 = 0;
int lastButton3 = 0;
int lastButton4 = 0;

int i = 0;
int delta1 = 0;
int delta2 = 0;
int delta3 = 0;

void setup() {
  Serial.begin(9600);
  pinMode(PIN_BUTTON_1,INPUT);
  pinMode(PIN_BUTTON_2,INPUT);
  pinMode(PIN_BUTTON_3,INPUT);
}

void loop() {
   knob1 = knob2 = knob3 = 0;
   for (i=0; i<10; i++) {
      knob1 += analogRead(PIN_KNOB_1);
      knob2 += analogRead(PIN_KNOB_2);
      knob3 += analogRead(PIN_KNOB_3);
   }
   knob1 = knob1/10;
   knob2 = knob2/10;
   knob3 = knob3/10;
   
   if (KNOB_REVERSE) {
     knob1 = 1023-knob1;
     knob2 = 1023-knob2;
     knob3 = 1023-knob3;
   }
   
   if (lastKnob1 < 0) lastKnob1 = knob1;
   if (lastKnob2 < 0) lastKnob2 = knob2;
   if (lastKnob3 < 0) lastKnob3 = knob3;
   
   delta1 = abs(lastKnob1-knob1);
   delta2 = abs(lastKnob2-knob2);
   delta3 = abs(lastKnob3-knob3);
   
   // Prevent bouncing
   if (delta1 == 1) knob1 = lastKnob1;   
   if (delta2 == 1) knob2 = lastKnob2;
   if (delta3 == 1) knob3 = lastKnob3;
   
   // Prevent jumping
   if (delta1 > 100) {
     knob1 = lastKnob1;
     lastKnob1 = -1;
   }   
   if (delta2 > 100) {
     knob2 = lastKnob2;
     lastKnob2 = -1;
   }
   if (delta3 > 100) {
     knob3 = lastKnob3;
     lastKnob3 = -1;
   }
   
   button1 = digitalRead(PIN_BUTTON_1) && 1;
   button2 = digitalRead(PIN_BUTTON_2) && 1;
   button3 = digitalRead(PIN_BUTTON_3) && 1;
   button4 = digitalRead(PIN_BUTTON_4) && 1;

   if (BUTTON_REVERSE) {
     button1 = 1 - button1;
     button2 = 1 - button2;
     button3 = 1 - button3;
     button4 = 1 - button4;
   }   
   
   sendData(knob1,knob2,knob3,button1,button2,button3,button4);
   
   //delay(100);
}

void sendData(int knob1, int knob2, int knob3, int button1, int button2, int button3, int button4) {
  int buttons = 0;
#if DEBUG
  Serial.print("k1=");
  Serial.print(knob1);
  Serial.print(" (");
  Serial.print(knob1>>8);
  Serial.print(" ");
  Serial.print(knob1&0xFF);
  Serial.print(") k2=");
  Serial.print(knob2);
  Serial.print(" (");
  Serial.print(knob2>>8);
  Serial.print(" ");
  Serial.print(knob2&0xFF);
  Serial.print(") k3=");
  Serial.print(knob3);
  Serial.print(" (");
  Serial.print(knob3>>8);
  Serial.print(" ");
  Serial.print(knob3&0xFF);
  Serial.print(") b1=");
  Serial.print(button1);
  Serial.print(" b2=");
  Serial.print(button2);
  Serial.print(" b3=");
  Serial.print(button3);
  Serial.print(" b4=");
  Serial.print(button4);
  Serial.println();
#else
#if VERSION_2
   if (knob1 != lastKnob1) {   
     Serial.print((char)(0x80 | (even(knob1)<<6) | (knob1 >> 7)));
     Serial.print((char)(knob1 & 0x7F));
   }
   
   if (knob2 != lastKnob2) {
     Serial.print((char)(0x80 | (even(knob2)<<6) | (1<<4) | (knob2 >> 7)));
     Serial.print((char)(knob2 & 0x7F));
   }
   
   if (knob3 != lastKnob3) {
     Serial.print((char)(0x80 | (even(knob3)<<6) | (2<<4) | (knob3 >> 7)));
     Serial.print((char)(knob3 & 0x7F));
   }

   if (button1 != lastButton1 ||
       button2 != lastButton2 ||
       button3 != lastButton3 ||
       button4 != lastButton4
    ) {
      buttons = (button1 << 3) | 
        (button2 << 2) | 
        (button3 << 1) | 
        button4;

      Serial.print((char)(0x80 | 
        (even(buttons)<<6) | 
        (3<<4) | buttons
      ));
    }   
    
    if (Serial.available() > 0) {
      if (Serial.read() == 255) {
#endif
       Serial.print((char)255);
       Serial.print((char)255);
       Serial.print((char)255);
       Serial.print((char)(knob1>>8));
       Serial.print((char)(knob1&0xFF));
       Serial.print((char)(knob2>>8));
       Serial.print((char)(knob2&0xFF));
       Serial.print((char)(knob3>>8));
       Serial.print((char)(knob3&0xFF));
       Serial.print((char)button1);
       Serial.print((char)button2);
       Serial.print((char)button3);
       Serial.print((char)button4);
       Serial.println();
#if VERSION_2
      }
    }
#endif
#endif

    if (lastKnob1 >= 0) lastKnob1 = knob1;
    if (lastKnob2 >= 0) lastKnob2 = knob2;
    if (lastKnob3 >= 0) lastKnob3 = knob3;
    lastButton1 = button1;
    lastButton2 = button2;
    lastButton3 = button3;
    lastButton4 = button4;
}

int even(int n) {
  return (n % 2) == 0;
}

