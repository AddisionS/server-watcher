#include <Wire.h>
#include <Adafruit_SHT31.h>
#include <LiquidCrystal_I2C.h>
#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "BadWifi";
const char* password = "Seema@123";

const char* DEVICE_ID = "esp32_01";
const char* LOCATION  = "Server Room";

const char* SERVER_URL = "http://192.168.29.134:8000/data";

// ---------- SENSOR & LCD ----------
Adafruit_SHT31 sht31 = Adafruit_SHT31();
LiquidCrystal_I2C lcd(0x27, 16, 2);

unsigned long lastSend = 0;
const unsigned long SEND_INTERVAL = 2000; 

void setup() {
  Serial.begin(115200);
  delay(1000);

  Wire.begin(21, 22);

  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.print("Booting...");

  if (!sht31.begin(0x44)) {
    lcd.clear();
    lcd.print("SHT31 ERROR");
    Serial.println("❌ SHT31 not found");
    while (1) delay(10);
  }

  lcd.clear();
  lcd.print("Sensor OK");

  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  WiFi.begin(ssid, password);

  lcd.setCursor(0, 1);
  lcd.print("WiFi Connecting");

  Serial.print("Connecting WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  lcd.clear();
  lcd.print("WiFi Connected");
  delay(1000);
  lcd.clear();

  Serial.println("\n✅ WiFi connected");
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  if (millis() - lastSend >= SEND_INTERVAL) {
    lastSend = millis();

    float temperature = sht31.readTemperature();
    float humidity    = sht31.readHumidity();

    if (isnan(temperature) || isnan(humidity)) {
      lcd.clear();
      lcd.print("Sensor Read Err");
      Serial.println("❌ Sensor read failed");
      return;
    }

    lcd.setCursor(0, 0);
    lcd.print("Temp: ");
    lcd.print(temperature, 1);
    lcd.print(" C   ");

    lcd.setCursor(0, 1);
    lcd.print("Hum : ");
    lcd.print(humidity, 1);
    lcd.print(" %   ");

    // ---------- BACKEND POST ----------
    if (WiFi.status() == WL_CONNECTED) {
      HTTPClient http;
      http.begin(SERVER_URL);
      http.addHeader("Content-Type", "application/json");

      String payload = "{";
      payload += "\"device_id\":\"";
      payload += DEVICE_ID;
      payload += "\",\"location\":\"";
      payload += LOCATION;
      payload += "\",\"temperature\":";
      payload += temperature;
      payload += ",\"humidity\":";
      payload += humidity;
      payload += "}";

      int code = http.POST(payload);
      Serial.print("POST -> ");
      Serial.println(code);

      http.end();
    } else {
      lcd.clear();
      lcd.print("WiFi Lost");
      Serial.println("⚠️ WiFi disconnected");
    }
  }
}
