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
int rotate;
int stepForward;
int ring;

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
// Position Initial motor coordinates
  while(digitalRead(maxBackward) == HIGH){
  //Motor1 - Vexta
  Serial.println("Max Backwards Reached");
  myStepper1.step(-1);
  delay(500);
  }
  while(digitalRead(maxCCW) == HIGH){
  Serial.println("Max Rotation Reached");
  //Motor2 - Nema
  rotateDeg(-425, 1); 
  delay(100);
  }
  while(digitalRead(maxForward) == HIGH){
  //Motor1 - Vexta
  Serial.println("Max Forwards Reached");
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
          Serial.print("Theta = ");
          Serial.println(theta);
          rads = (3.1415/180)*(BoardRotate+adjust+theta); // convert degree to rads
          Serial.println("Move to ring 1 pos");
          shortDist = abs(r_1*cos(abs(rads))); 
          Serial.print("Short distance = ");
          Serial.println(shortDist);
          longDist = sqrt(R_2*R_2 + r_1*r_1*cos(rads)*cos(rads) - r_1*r_1);
          Serial.print("Long distance = ");
          Serial.println(longDist);
          //Motor1 - Vexta
          stepForward = -((r_1-shortDist) + (R_2-longDist));
          Serial.print("stepForward = ");
          Serial.println(stepForward);
          myStepper1.step(stepForward); // Moves robot forward
          delay(5);
          //Motor2 - Nema
          rotate = ((acos(longDist/R_2))*(180/3.14))/.0335; // gearbox .067 deg per step
          Serial.print("rotate = ");
          if (BoardRotate + theta < 180 || BoardRotate + theta > 360){
            Serial.println(-rotate);
            rotateDeg(-rotate, 1); 
          } else {
            Serial.println(rotate);
            rotateDeg(rotate, 1);  
          }
          delay(100);
      ring = 1;
      Serial.print("Done");
      break;

//-----------------------Move to ring 2 fish location---------------------------
      case '2':
          theta1 = 60; // CCW from center of board to fish
          theta2 = 185; // CCW from center of board to fish
          if (BoardRotate <= (90-theta1) || BoardRotate >= (270-theta1)){
            theta = theta1;
            adjust = 0;
          } else{
            theta = theta2;
            adjust = -180;
          }
          Serial.print("Theta = ");
          Serial.println(theta);
          rads = 3.1415*(BoardRotate+adjust+theta)/180;
          Serial.println("Move to ring 2 pos");
          shortDist = abs(r_2*cos(abs(rads)));
          Serial.print("Short distance = ");
          Serial.println(shortDist);
          longDist = sqrt(R_2*R_2 + r_2*r_2*cos(rads)*cos(rads) - r_2*r_2);
          Serial.print("Long distance = ");
          Serial.println(longDist);
           //Motor1 - Vexta
          stepForward = -((r_1-shortDist) + (R_2-longDist));
          Serial.print("stepForward = ");
          Serial.println(stepForward);
          myStepper1.step(stepForward); // Moves robot forward
          delay(5);
          //Motor2 - Nema
          rotate = ((acos(longDist/R_2))*(180/3.14))/.0335; // gearbox .067 deg per step
          Serial.print("rotate = ");
          if (BoardRotate + theta < 180 || BoardRotate + theta > 360){
            Serial.println(-rotate);
            rotateDeg(-rotate, 1); 
          } else {
            Serial.println(rotate);
            rotateDeg(rotate, 1);  
          }
          delay(100);
      ring = 2;
      Serial.print("Done");
      break;

//-----------------------Move to ring 3 fish location---------------------------
      case '3':
          theta1 = 348; // CCW from center of board to fish
          theta2 = 105; // CCW from center of board to fish
          if (BoardRotate <= (90-theta1) || BoardRotate >= (270-theta1)){
            theta = theta1;
            adjust = 0;
          } else{
            theta = theta2;
            adjust = -180;
          }
          Serial.print("Theta = ");
          Serial.println(theta);
          rads = 3.1415*(BoardRotate+adjust+theta)/180;
          Serial.println("Move to ring 3 pos");
          shortDist = abs(r_3*cos(abs(rads)));
          Serial.print("Short distance = ");
          Serial.println(shortDist);
          longDist = sqrt(R_2*R_2 + r_3*r_3*cos(rads)*cos(rads) - r_3*r_3);
          Serial.print("Long distance = ");
          Serial.println(longDist);
          //Motor1 - Vexta
          stepForward = -((r_1-shortDist) + (R_2-longDist));
          Serial.print("stepForward = ");
          Serial.println(stepForward);
          myStepper1.step(stepForward); // Moves robot forward
          delay(5);
          //Motor2 - Nema
          rotate = ((acos(longDist/R_2))*(180/3.14))/.0335; // gearbox .067 deg per step
          Serial.print("rotate = ");
          if (BoardRotate + theta < 180 || BoardRotate + theta > 360){
            Serial.println(-rotate);
            rotateDeg(-rotate, 1); 
          } else {
            Serial.println(rotate);
            rotateDeg(rotate, 1);  
          }
          delay(100);
      ring = 3;
      Serial.print("Done");
      break;

//-----------------------Move to ring 4 fish location---------------------------
      case '4':
          theta1 = 295; // CCW from center of board to fish
          theta2 = 175; // CCW from center of board to fish
          if (BoardRotate <= (90-theta1) || BoardRotate >= (270-theta1)){
            theta = theta1;
            adjust = 0;
          } else{
            theta = theta2;
            adjust = -180;
          }
          Serial.print("Theta = ");
          Serial.println(theta);
          rads = 3.1415*(BoardRotate+adjust+theta)/180;
          Serial.println("Move to ring 4 pos");
          shortDist = abs(r_4*cos(abs(rads)));
          Serial.print("Short distance = ");
          Serial.println(shortDist);
          longDist = sqrt(R_2*R_2 + r_4*r_4*cos(rads)*cos(rads) - r_4*r_4);
          Serial.print("Long distance = ");
          Serial.println(longDist);
           //Motor1 - Vexta
          stepForward = -((r_1-shortDist) + (R_2-longDist));
          Serial.print("stepForward = ");
          Serial.println(stepForward);
          myStepper1.step(stepForward); // Moves robot forward
          delay(5);
          //Motor2 - Nema
          rotate = ((acos(longDist/R_2))*(180/3.14))/.0335; // gearbox .0335 deg per step
          Serial.print("rotate = ");
          if (BoardRotate + theta < 180 || BoardRotate + theta > 360){
            Serial.println(-rotate);
            rotateDeg(-rotate, 1); 
          } else {
            Serial.println(rotate);
            rotateDeg(rotate, 1);  
          }
          delay(100);
      ring = 4;
      Serial.print("Done");
      break;

//-----------------------Catch fish------------------------------
      case '5':
        Serial.println("Catch a fish");
        //Servo - drop pole
        for (pos = 110; pos >= 10; pos -= 10) { // goes from 900 degrees to 0 degrees
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(15);                       // waits 15ms for the servo to reach the position
        }
        delay(1000); 
        //Servo - raise pole
         for (pos = 10; pos <= 120; pos += 10) { // goes from 0 degrees to 90 degrees
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(15);                       // waits 15ms for the servo to reach the position
        }
      Serial.print("Done");
      break;


//-----------------------DROP OFF FISH------------------------------
      case '6':
        //Motor2 - Nema rotate in degrees to drop fish
        Serial.print("rotate = ");
        Serial.println(rotate);
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
        delay(1000); 
        Serial.println("Drop of fish");
      Serial.print("Done");
      break;

//-----------------------Menu------------------------------
      case '7':
        Serial.println("------- MENU -------");
        Serial.println("Press 1 - Move to ring 1");
        Serial.println("Press 2 - Move to ring 2");
        Serial.println("Press 3 - Move to ring 3");
        Serial.println("Press 4 - Move to ring 4");
        Serial.println("Press 5 - Catch a fish");
        Serial.println("Press 6 - Drop of fish");        
        Serial.println("Press 9 - Reset robot");
        Serial.println("--------------------");
      Serial.print("Done");
      break;

//-----------------------Reset Position------------------------------
      case '9':
        while(digitalRead(maxBackward) == LOW){         
        Serial.println("Reset");
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
        Serial.println("Invalid option");
      Serial.print("Done");
      break;
    } // end: switch (rx_byte)
  } // end: if (Serial.available() > 0)
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
