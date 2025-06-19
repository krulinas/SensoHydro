#include <WiFi.h>
#include <HTTPClient.h>

#include "wifi_utils.h"
#include "eeprom_utils.h"
#include "dht_utils.h"
#include "ultrasonic_utils.h"
#include "water_utils.h"
#include "display_utils.h"
#include "web_server.h"

unsigned long lastSend = 0;

void setup() {
  Serial.begin(115200);

  initDHT();
  initUltrasonic();
  initWaterSensor();
  initDisplay();

  showStartupScreen();

  readCredentialsFromEEPROM();
  bool connected = connectToWiFi();

  if (connected) {
    showWiFiSuccessScreen();
  } else {
    startAccessPointMode();
    showAPModeScreen();
  }

  launchWebServer();
}

void sendSensorData() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin("http://tensorflowtitan.xyz/backends/insertdata.php");  // 🔗 Your PHP server
    http.addHeader("Content-Type", "application/x-www-form-urlencoded");

    float temp = readTemperature();
    float hum = readHumidity();
    float level = readDistance();
    int waterRaw = readWaterValue();
    String leak = isLeakDetected(waterRaw) ? "1" : "0";
    String relay = relayStatusString();

    String postData = "device_id=" + devid +
                      "&temperature=" + String(temp, 2) +
                      "&humidity=" + String(hum, 2) +
                      "&water_level=" + String(level, 2) +
                      "&leak_status=" + leak +
                      "&relay_state=" + relay;

    

    int httpCode = http.POST(postData);
    String response = http.getString();

    Serial.println("POST response code: " + String(httpCode));
    Serial.println("Server response: " + response);

    http.end();
  } else {
    Serial.println("WiFi not connected.");
  }
}

void loop() {
  handleWebRequests();  // Keep the web server responsive

  if (millis() - lastSend > 10000) {  // Send data every 10 seconds
    sendSensorData();
    lastSend = millis();
  }
}
