#ifndef WATER_SENSOR_UTILS_H
#define WATER_SENSOR_UTILS_H

#define WATER_SENSOR_PIN 34  // ADC1 channel (adjust as needed)
#define WATER_THRESHOLD 500  // Adjust based on calibration

void initWaterSensor() {
  pinMode(WATER_SENSOR_PIN, INPUT);
  Serial.println("Water sensor initialized");
}

// Read raw analog value
int readWaterValue() {
  return analogRead(WATER_SENSOR_PIN);
}

// Return status message
String getWaterStatus(int value) {
  return (value > WATER_THRESHOLD) ? "Leak Detected" : "No Leak";
}

// Return boolean status for control logic
bool isLeakDetected(int value) {
  return value > WATER_THRESHOLD;
}

#endif
