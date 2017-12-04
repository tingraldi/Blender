#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>
#include <RBL_nRF8001.h>

// copied from Ethernet/src/utility/util.h
#define htons(x) ( ((x)<< 8 & 0xFF00) | \
                   ((x)>> 8 & 0x00FF) )
#define ntohs(x) htons(x)

#define htonl(x) ( ((x)<<24 & 0xFF000000UL) | \
                   ((x)<< 8 & 0x00FF0000UL) | \
                   ((x)>> 8 & 0x0000FF00UL) | \
                   ((x)>>24 & 0x000000FFUL) )
#define ntohl(x) htonl(x)

const int led = 13;
const int sensorPin = A0;
const byte valuePrefix = 'V';
char name[] = "Temperature Sensor";


void setup() {
  Serial.begin(9600);

  pinMode(led, OUTPUT);
  
  ble_set_name(name);
  ble_begin();
}


void blink() {
  digitalWrite(led, HIGH);
  delay(250);
  digitalWrite(led, LOW);
}

void ble_write_int(int val) {
  ble_write_bytes((byte *)&val, 2);
}

void sendTemperatureCounts() {
  int sensorVal = analogRead(sensorPin);

  Serial.print("Value: ");
  Serial.println(sensorVal);

  ble_write(valuePrefix);
  
  // Convert value to network byte order
  sensorVal = htons(sensorVal);
  ble_write_int(sensorVal);

  ble_do_events();
  blink();
}

/*
 * Packet structure
 * X [V1, V2, V3, ... VN] 
 * 
 *  X = Command prefix
 *  V1 through VN - payload
 *   
 * T - request temperature counts
 * 
 *     NO PAYLOAD
 */
void loop() {
  while(ble_available()) {
    byte cmd;
    cmd = ble_read();

    switch (cmd) {
      case 'T': {
          sendTemperatureCounts();
        }
        break;
      default:
        break;
    }
  }

  ble_do_events();
}

