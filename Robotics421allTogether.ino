#include <Stepper.h> //For Stepper "Motor 1" VEXTA
#include <Servo.h> //For Servo
#define DIR_PIN 4 //For Stepper "Motor 2" Nema 11
#define STEP_PIN 5 //For Motor 2

int maxBackward = 2; //Cannot slide back any further
int maxForward = 13; //Cannot slide forward any further
int maxCCW = 3; //Cannot rotate CCW any further, set 0 pos

Servo myservo;  // create servo object to control a servo
int pos = 110;    // variable to store the servo position

// change to fit number of steps per revolution for motor
const int stepsPerRevolution = 8;  

// initialize the stepper library on pins 8 through 11:
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
  
  // Motor1 - "Vexta" speed at 60 rpm:
  myStepper1.setSpeed(100);
  
  // initialize the serial port:
  Serial.begin(9600);
}

char rx_byte = 0; // input value from serial monitor

void loop() {
//--------------------------------------------
// Position Initial motor coordinates
  while(digitalRead(maxBackward) == HIGH){
  //Motor1 - Vexta
  Serial.println("moveBackward");
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
  Serial.println("maxBackward");
  myStepper1.step(stepsPerRevolution);
  delay(500);
  }
//--------------------------------------------
// Move motors specified by case choice
  if (Serial.available() > 0) {    // is a character available?
      rx_byte = Serial.read();

    switch (rx_byte) {
      case '1':
          Serial.println("Move to ring 1 pos");
          //Motor1 - Vexta
          myStepper1.step(-1); // Moves robot forward
          delay(5);
          //Motor2 - Nema
          rotateDeg(20, 1); 
          delay(100);
      break;
      
      case '2':
         Serial.println("Move to ring 2");
         //Motor1 - Vexta
         myStepper1.step(-18); // Moves robot forward
         delay(5);
         //Motor2 - Nema
         rotateDeg(120, 1); 
         delay(100);
      break;

      case '3':
         Serial.println("Move to ring 3");
         //Motor1 - Vexta
         myStepper1.step(-10); // Moves robot forward
         delay(5);
         //Motor2 - Nema
         rotateDeg(-410, 1); 
         delay(15);
         Serial.println("Move to ring 3");
      break;

      case '4':
         Serial.println("Move to ring 4");
         //Motor1 - Vexta
         myStepper1.step(-8); // Moves robot forward
         delay(1);
         //Motor2 - Nema
         rotateDeg(-140, 1); 
         delay(200);
         Serial.println("Move to ring 4");
      break;

      case '5':
        Serial.println("Catch a fish");
        //Servo - drop pole
        for (pos = 110; pos >= 0; pos -= 10) { // goes from 900 degrees to 0 degrees
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(15);                       // waits 15ms for the servo to reach the position
        }
        delay(150); 
        //Servo - raise pole
         for (pos = 0; pos <= 120; pos += 5) { // goes from 0 degrees to 90 degrees
          myservo.write(pos);              // tell servo to go to position in variable 'pos'
          delay(15);                       // waits 15ms for the servo to reach the position
        }
      break;

      case '6':
        //Motor2 - Nema rotate in degrees to drop fish
        rotateDeg(-2500, 1); 
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
        rotateDeg(2500, 1);  //reverse
        delay(1000); 
        Serial.println("Drop of fish");
      break;
      
      case '7':
        Serial.println("------- MENU -------");
        Serial.println("Press 1 - Move to ring 1");
        Serial.println("Press 2 - Move to ring 2");
        Serial.println("Press 3 - Move to ring 3");
        Serial.println("Press 4 - Move to ring 4");
        Serial.println("Press 5 - Catch a fish");
        Serial.println("Press 6 - Drop of fish");        
        Serial.println("Press 7 - This menu.");
        Serial.println("--------------------");
      break;

      case '9':
        while(digitalRead(maxBackward) == LOW){         
        Serial.println("Reset");
        //Motor1 - Vexta
        myStepper1.step(1); // Moves robot backward
        delay(1);
        }
        while(digitalRead(maxCCW) == LOW){
        //Motor2 - Nema
        rotateDeg(1, 1); 
        delay(15);
        }


      break;
      
      default:
        Serial.println("Invalid option");
      break;
    } // end: switch (rx_byte)
  } // end: if (Serial.available() > 0)
}






//Motor2 movement settings--------------------------------------------------------------
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
