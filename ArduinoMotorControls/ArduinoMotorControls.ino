#include <Stepper.h> //For Stepper "Motor 1" VEXTA
#include <Servo.h> //For Servo
#define DIR_PIN 4 //For Stepper "Motor 2" Nema 11
#define STEP_PIN 5 //For Motor 2

int maxBackward = 2; //Cannot slide back any further
int maxForward = 13; //Cannot slide forward any further
int maxCCW = 3; //Cannot rotate CCW any further, set 0 pos

//----------------------------------
//Rotation Variables
int BoardRotate = 0; // position of board rotation
int r_1 = 36; // Radius of outer ring  - ring 1 in motor steps
int r_2 = 24; // Radius of ring 2
int r_3 = 18; // Radius of ring 3
int r_4 = 11; // Radius of ring 4
int R_2 = 111; // Radius of robot arm
int theta;
int theta1;
int theta2;
int adjust;
double rads;
double shortDist; 
double longDist;
double h;
int settleAfterMove;
int rotate;
int stepForward;
int dropTime; //A drop time set by each ring.
int ring;
bool isReady;
bool alreadySent;

Servo myservo;  // create servo object to control a servo
int pos = 90;    // variable to store the servo position

// change to fit number of steps per revolution for motor
const int stepsPerRevolution = 8;  

// initialize the Vexta stepper library on pins 8 through 11:
Stepper myStepper1(stepsPerRevolution, 8, 9, 10, 11);

void setup() {
// Button setup
  pinMode(maxBackward, LOW); //turn on pull-down resistor
  pinMode(maxForward, LOW); //turn on pull-down resistor
  pinMode(maxCCW, HIGH); //turn on pull-up resistors
  
// Servo on pin 12 
  myservo.attach(12);

// Motor 2 - "Nima" stepper from easy driver to pins 4 and 5 
  pinMode(DIR_PIN, OUTPUT); // attach Stepper motor2 - pin 4
  pinMode(STEP_PIN, OUTPUT); // attach the stepper motor2 - pin 5
  
  // Motor1 - "Vexta" speed at 600 rpm:
  myStepper1.setSpeed(600);
  
  // initialize the serial port:
  Serial.begin(9600);
}

char rx_byte = 0; // input value from serial monitor

void loop() {
//--------------------------------------------
settleAfterMove = 200;
// Position Initial motor coordinates
  while(digitalRead(maxBackward) == HIGH){
  //Motor1 - Vexta
  myStepper1.step(-1);
  delay(500);
  }
  while(digitalRead(maxCCW) == HIGH){
  //Motor2 - Nema
  rotateDeg(-425, 1); 
  delay(100);
  }
  while(digitalRead(maxForward) == HIGH){
  //Motor1 - Vexta
  myStepper1.step(1);
  delay(500);
  }
//--------------------------------------------
// Move motors specified by case choice
  if (Serial.available() > 0) {    // is a character available?
      rx_byte = Serial.read();
      
    switch (rx_byte) {
//-----------------------Move to ring 1 fish location---------------------------     
      case '1':
          Serial.println("Busy");
          dropTime = 300;
          isReady = false;
          alreadySent = false;
          // set theta based on which side of board robots on
          theta1 = 35; // CCW from center of board to fish
          theta2 = 225; // CCW from center of board to fish
          if (BoardRotate <= (90-theta1) || BoardRotate >= (270-theta1)){
            theta = theta1;
            adjust = 0;
          } else{
            theta = theta2;
            adjust = -180;
          }
          rads = (3.1415/180)*(BoardRotate+adjust+theta); // convert degree to rads
          shortDist = abs(r_1*cos(abs(rads))); 
          longDist = sqrt(R_2*R_2 + r_1*r_1*cos(rads)*cos(rads) - r_1*r_1);
          //Motor1 - Vexta
          stepForward = -((r_1-shortDist) + (R_2-longDist));
          myStepper1.step(stepForward); // Moves robot forward
          delay(5);
          //Motor2 - Nema
          rotate = ((acos(longDist/R_2))*(180/3.14))/.0335; // gearbox .067 deg per step
          if (BoardRotate + theta < 180 || BoardRotate + theta > 360){
            rotateDeg(-rotate, 1); 
          } else {
            rotateDeg(rotate, 1);  
          }
          delay(settleAfterMove);
      ring = 1;
      break;

//-----------------------Move to ring 2 fish location---------------------------
      case '2':
          Serial.println("Busy");
          dropTime = 600;
          isReady = false;
          alreadySent = false;
          theta1 = 60; // CCW from center of board to fish
          theta2 = 185; // CCW from center of board to fish
          if (BoardRotate <= (90-theta1) || BoardRotate >= (270-theta1)){
            theta = theta1;
            adjust = 0;
          } else{
            theta = theta2;
            adjust = -180;
          }
          rads = 3.1415*(BoardRotate+adjust+theta)/180;
          shortDist = abs(r_2*cos(abs(rads)));
          longDist = sqrt(R_2*R_2 + r_2*r_2*cos(rads)*cos(rads) - r_2*r_2);
           //Motor1 - Vexta
          stepForward = -((r_1-shortDist) + (R_2-longDist));
          myStepper1.step(stepForward); // Moves robot forward
          delay(5);
          //Motor2 - Nema
          rotate = ((acos(longDist/R_2))*(180/3.14))/.0335; // gearbox .067 deg per step
          if (BoardRotate + theta < 180 || BoardRotate + theta > 360){
            rotateDeg(-rotate, 1); 
          } else {
            rotateDeg(rotate, 1);  
          }
          delay(settleAfterMove);
      ring = 2;
      break;

//-----------------------Move to ring 3 fish location---------------------------
      case '3':
          dropTime = 700;
          Serial.println("Busy");
          isReady = false;
          alreadySent = false;
          theta1 = 348; // CCW from center of board to fish
          theta2 = 105; // CCW from center of board to fish
          if (BoardRotate <= (90-theta1) || BoardRotate >= (270-theta1)){
            theta = theta1;
            adjust = 0;
          } else{
            theta = theta2;
            adjust = -180;
          }
          rads = 3.1415*(BoardRotate+adjust+theta)/180;
          shortDist = abs(r_3*cos(abs(rads)));
          longDist = sqrt(R_2*R_2 + r_3*r_3*cos(rads)*cos(rads) - r_3*r_3);
          //Motor1 - Vexta
          stepForward = -((r_1-shortDist) + (R_2-longDist));
          myStepper1.step(stepForward); // Moves robot forward
          delay(5);
          //Motor2 - Nema
          rotate = ((acos(longDist/R_2))*(180/3.14))/.0335; // gearbox .067 deg per step
          if (BoardRotate + theta < 180 || BoardRotate + theta > 360){
            rotateDeg(-rotate, 1); 
          } else {
            rotateDeg(rotate, 1);  
          }
          delay(settleAfterMove);
      ring = 3;
      break;

//-----------------------Move to ring 4 fish location---------------------------
      case '4':
          dropTime = 800;
          Serial.println("Busy");
          isReady = false;
          alreadySent = false;
          theta1 = 295; // CCW from center of board to fish
          theta2 = 175; // CCW from center of board to fish
          if (BoardRotate <= (90-theta1) || BoardRotate >= (270-theta1)){
            theta = theta1;
            adjust = 0;
          } else{
            theta = theta2;
            adjust = -180;
          }
          rads = 3.1415*(BoardRotate+adjust+theta)/180;
          shortDist = abs(r_4*cos(abs(rads)));
          longDist = sqrt(R_2*R_2 + r_4*r_4*cos(rads)*cos(rads) - r_4*r_4);
           //Motor1 - Vexta
          stepForward = -((r_1-shortDist) + (R_2-longDist));
          myStepper1.step(stepForward); // Moves robot forward
          delay(5);
          //Motor2 - Nema
          rotate = ((acos(longDist/R_2))*(180/3.14))/.0335; // gearbox .0335 deg per step
          if (BoardRotate + theta < 180 || BoardRotate + theta > 360){
            rotateDeg(-rotate, 1); 
          } else {
            rotateDeg(rotate, 1);  
          }
          delay(settleAfterMove);
      ring = 4;
      break;

//-----------------------Catch fish------------------------------
      case '5':
        Serial.println("Busy");
        isReady = false;
        alreadySent = false;
        //Servo - drop pole
        for (pos = 110; pos >= 10; pos -= 10) { // goes from 90 degrees to 0 degrees
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(15);                       // waits 15ms for the servo to reach the position
        }
        delay(dropTime); 
        //Servo - raise pole
         for (pos = 10; pos <= 120; pos += 4) { // goes from 0 degrees to 90 degrees
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(15);                       // waits 15ms for the servo to reach the position
        }
      break;


//-----------------------DROP OFF FISH------------------------------
      case '6':
        Serial.println("Busy");
        isReady = false;
        alreadySent = false;
        //Motor2 - Nema rotate in degrees to drop fish
        rotateDeg((-2500+rotate), 1); 
        delay(100);
        //Servo - drop pole
        for (pos = 90; pos >= 0; pos -= 10) { // goes from 900 degrees to 0 degrees
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(15);                       // waits 15ms for the servo to reach the position
        }
        //Servo - drop pole
        for (pos = 150; pos >= 90; pos -= 1) { // goes from 900 degrees to 0 degrees
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(15);                       // waits 15ms for the servo to reach the position
        }
        //Servo - raise pole
        for (pos = 90; pos <= 150; pos += 1) { // goes from 0 degrees to 90 degrees
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(15);                       // waits 15ms for the servo to reach the position
        }
        //Servo - raise pole
        for (pos = 0; pos <= 90; pos += 10) { // goes from 0 degrees to 90 degrees
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(15);                       // waits 15ms for the servo to reach the position
        }
        //Motor2 - Nema rotate back to catch another fish
        rotateDeg((2500-rotate), 1);  //reverse
        delay(1100); 
      break;

//-------------------------------------------------------------------
      case '7':
        //Nothing so far
      break;

//-----------------------Reset Position------------------------------
      case '9':
        Serial.println("Busy");
        isReady = false;
        alreadySent = false;
        while(digitalRead(maxBackward) == LOW){         
        //Motor1 - Vexta
        myStepper1.step(1); // Moves robot backward
        delay(1);
        }
        while(digitalRead(maxCCW) == LOW){
        //Motor2 - Nema
        rotateDeg(8, 1); 
        delay(15);
        }
      break;
      
      default:
        //Do nothing
      break;
    } // end: switch (rx_byte)
  } // end: if (Serial.available() > 0)
  else 
  {
    isReady = true;  
  }

  if (isReady && !alreadySent)
  {
    alreadySent = true;
    Serial.println("Ready");
  }
}






//----------------Motor2 movement function-------------------------------
void rotateDeg(float deg, float speed){ 
  //rotate a specific number of degrees (negitive for reverse movement)
  //speed is any number from .01 -> 1 with 1 being fastest - Slower is stronger
  int dir = (deg > 0)? HIGH:LOW;
  digitalWrite(DIR_PIN,dir); 

  int steps = abs(deg)*(1/0.225);
  float usDelay = (1/speed) * 80;

  for(int i=0; i < steps; i++){ 
    digitalWrite(STEP_PIN, HIGH); 
    delayMicroseconds(usDelay); 

    digitalWrite(STEP_PIN, LOW); 
    delayMicroseconds(usDelay); 
  } 
}
