#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>
#include <RBL_nRF8001.h>

const int rightForward = 2; // right motor - high for forward, low for reverse
const int rightReverse = 3; // right motor - high for reverse, low for forward
const int leftForward = 4; // left motor - high for forward, low for reverse
const int leftReverse = 5; // left motor - high for reverse, low for forward
const int piezoPin = 6;
const int rightMotorEnable = 10; // use analogWrite for PWM
const int leftMotorEnable = 11; // use analogWrite for PWM
const int LEDPin = 13;

const byte FORWARD = 1;
const byte REVERSE = 0;

void setMotorSpeed(int pin, int value) {
  analogWrite(pin, value);
}

void setHighAndLow(int inputA, int inputB) {
  digitalWrite(inputA, HIGH);
  digitalWrite(inputB, LOW);
}

void stopRight() {
  setMotorSpeed(rightMotorEnable, 0);
}

void stopLeft() {
  setMotorSpeed(leftMotorEnable, 0);  
}

void setRightMotorDirectionAndSpeed(byte direction, byte speed) {
  if (direction == FORWARD) {
    setHighAndLow(rightForward, rightReverse);
  } else {
    setHighAndLow(rightReverse, rightForward);
  }
  setMotorSpeed(rightMotorEnable, speed);
}

void setLeftMotorDirectionAndSpeed(byte direction, byte speed) {
  if (direction == FORWARD) {
    setHighAndLow(leftForward, leftReverse);
  } else {
    setHighAndLow(leftReverse, leftForward);
  }
  setMotorSpeed(leftMotorEnable, speed);
}

void allStop() {
  stopRight();
  stopLeft();
  setLED(0);
  endTone();
  Serial.println("STOP");
}

void setLED(int onOff) {
  digitalWrite(LEDPin, onOff);
}

void beginTone() {
  tone(piezoPin, 500);
}

void endTone() {
  noTone(piezoPin);
}

void setup() {
  Serial.begin(9600);
  // put your setup code here, to run once:
  pinMode(rightForward, OUTPUT);
  pinMode(rightReverse, OUTPUT);
  pinMode(leftForward, OUTPUT);
  pinMode(leftReverse, OUTPUT);
  
  pinMode(rightMotorEnable, OUTPUT);
  pinMode(leftMotorEnable, OUTPUT);

  pinMode(piezoPin, OUTPUT);
  pinMode(LEDPin, OUTPUT);

  ble_set_name("Tumbler");
  ble_begin();
  allStop();
} 

// limit len to 20
void ble_write_string(byte *bytes, uint8_t len) {
  for (int j = 0; j < len; j++) {
    ble_write(bytes[j]);
  }

  ble_do_events();
}

/*
 * Packet structure
 * X [V1, V2, V3, ... VN] 
 * 
 *  X = Command prefix
 *  V1 through VN - payload
 *  
 * F - command both motors
 * R - right motor
 * L - left motor
 *
 * All motor commands
 *   X V1 V2 
 * 
 *   V1 = 0 or 1 for reverse or forward
 *   V2 = between 0 and 255 for speed
 *   
 * T - emit tone
 * 
 *   TV
 *   
 *   V = 0 - off
 *   V = 1 - on
 *   
 * B - LED (Bulb)
 *    
 *    BV
 *    
 *    V = 0 - off
 *    V = 1 on
 *    
 * S - ALL STOP
 * 
 *    S
 */
void loop() {
  while(ble_available()) {
    byte cmd;
    cmd = ble_read();
    
    ble_write_string(&cmd, 1); // echo command back to central

    switch (cmd) {
      case 'S': {
          allStop();
        }
        break;
      
      case 'B': {
          byte onOff = ble_read();
          setLED(onOff);
        }        
        break;
      
      case 'T': {  
          byte onOff = ble_read();
          if (onOff) {
            beginTone();
          } else {
            endTone();
          }
        }  
        break;

      case 'F':
      case 'R':
      case 'L': {
          byte direction = ble_read();
          byte speed = ble_read();
          if (cmd == 'R' || cmd == 'F') {
             setRightMotorDirectionAndSpeed(direction, speed);
          }
          if (cmd == 'L' || cmd == 'F') {
             setLeftMotorDirectionAndSpeed(direction, speed);
          }
        }  
        break;
      default:
        break;
    }
  }

  ble_do_events();
}
