#ifndef ULTRASONIC_UTILS_H
#define ULTRASONIC_UTILS_H

#define TRIG_PIN 5
#define ECHO_PIN 18

void initUltrasonic() {
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  Serial.println("Ultrasonic sensor initialized");
}

// Return distance in cm
float readDistance() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH, 30000); // Timeout after 30ms
  float distance = duration * 0.034 / 2.0;
  return (distance > 0) ? distance : -1; // Return -1 if invalid
}

// Determine bottle status based on distance
String getBottleStatus(float distance) {
  if (distance < 0) return "Sensor Error";
  if (distance < 5) return "Bottle Full";
  if (distance <= 25) return "Ready to Dispense";
  return "No Bottle";
}

#endif