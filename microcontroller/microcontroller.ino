#include <Wire.h>               // I2C bus (LCD + SHT31)
#include <SPI.h>                // SPI bus (W5500)
#include <Ethernet.h>           // Ethernet stack for W5500
#include <ArduinoHttpClient.h>  // HTTP client
#include <Adafruit_SHT31.h>     // SHT31 sensor
#include <LiquidCrystal_I2C.h>  // 16x2 I2C LCD

//----------------Device Credentials----------------
const char* DEVICE_ID = "";
const char* AUTH_TOKEN = "";

//---------------Firmware Info--------------------
const char* FIRMWARE_VERSION = "";


//----------------Custom Message----------------
const char* MSG_LINE1 = "Server Watcher";
const char* MSG_LINE2 = "BY SDC MUJ";

//----------------Backend Endpoint----------------
const char* SERVER_HOST = "";
const int SERVER_PORT = 8000;
const char* INGEST_PATH = "";
const char* STATUS_PATH = "";

//---------------W5500 Pins---------------
#define W5500_RST 4
#define W5500_CS  5

//---------------Timings---------------
unsigned long lastSend = 0;
unsigned long lastSwitch = 0;
unsigned long lastStatusUpdate = 0;

const unsigned long SEND_INTERVAL = 2000; //2 sec to update
const unsigned long MESSAGE_INTERVAL = 20000; //20 sec to display custom message
const unsigned long STATUS_INTERVAL = 5000; //5 sec to send self diagnosis

bool showCustomMessage = false;

// --------------------Object Initializations --------------------
Adafruit_SHT31 sht31 = Adafruit_SHT31(); //SHT Sensor object
LiquidCrystal_I2C lcd(0x27, 16, 2); //LCD Object
EthernetClient ethClient; //Ethernet object

//-------------------Status Flags----------------------
bool sensor_ok = true;
bool ethernet_ok = true;
bool last_link_state = true;

//Ethernet Reset
void resetW5500() {
  pinMode(W5500_RST, OUTPUT);
  digitalWrite(W5500_RST, LOW);
  delay(100);
  digitalWrite(W5500_RST, HIGH);
  delay(200);
}

//Get MAC Address from ESP Board
void generateMac(byte* mac) {
  uint64_t chipid = ESP.getEfuseMac();

  mac[0] = 0x02; 
  mac[1] = (chipid >> 40) & 0xFF;
  mac[2] = (chipid >> 32) & 0xFF;
  mac[3] = (chipid >> 24) & 0xFF;
  mac[4] = (chipid >> 16) & 0xFF;
  mac[5] = (chipid >> 8)  & 0xFF;
}

void setup() {
  Serial.begin(115200);
  delay(1000);

  Wire.begin(21, 22); //I2C Init

  //LCD Startup
  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.print("Booting...");
  lcd.setCursor(0, 0);
  lcd.print(MSG_LINE1);
  lcd.setCursor(0, 1);
  lcd.print(MSG_LINE2);


  //Sensor Init
  if (!sht31.begin(0x44)) {
    sensor_ok = false;
    lcd.clear();
    lcd.print("Sensor Error");
  }

  if (sensor_ok) {
    lcd.clear();
    lcd.print("Sensor Working");
  }
  

  //Ethernet Init
  resetW5500();

  SPI.begin(18, 19, 23, W5500_CS);
  Ethernet.init(W5500_CS);

  byte mac[6];
  generateMac(mac);

  if (Ethernet.begin(mac) == 0) {
    lcd.clear();
    lcd.print("ETH DHCP FAIL");
    while (true);
  }

  lcd.clear();
  lcd.print("ETH Connected");

  Serial.print("IP Address: ");
  Serial.println(Ethernet.localIP());

  delay(1500);
  lcd.clear();
}

void loop() {
  unsigned long now = millis();

  bool link_up = (Ethernet.linkStatus() == LinkON);

  if (!link_up && last_link_state) {
    ethernet_ok = false;
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Ethernet");
    lcd.setCursor(0, 1);
    lcd.print("Disconnected");
  }

  if (link_up && !last_link_state) {
    ethernet_ok = true;
    lcd.clear();
    showCustomMessage = false;
  }

  last_link_state = link_up;

  //LCD Message Toggle
  if (now - lastSwitch >= MESSAGE_INTERVAL && ethernet_ok == true && sensor_ok == true) {
    lastSwitch = now;
    showCustomMessage = !showCustomMessage;

    lcd.clear();

    if (showCustomMessage) {
      lcd.setCursor(0, 0);
      lcd.print(MSG_LINE1);

      lcd.setCursor(0, 1);
      lcd.print(MSG_LINE2);
    }
  }

  //Sensor data + Post task
  if (now - lastSend >= SEND_INTERVAL) {
    lastSend = now;

    float temperature = sht31.readTemperature();
    float humidity    = sht31.readHumidity();

    if (isnan(temperature) || isnan(humidity)) {
      sensor_ok = false;
      lcd.clear();
      lcd.print("Sensor Error");
    } else {
      sensor_ok = true;
    }

    // Update LCD only if sensor screen is active
     if (!showCustomMessage && sensor_ok == true) {
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("T:");
      lcd.print(temperature, 1);
      lcd.print("C");
      lcd.setCursor(0, 1);
      lcd.print("H:");
      lcd.print(humidity, 1);
      lcd.print("%");
    }

    // ------------------ HTTP POST ------------------
    if (link_up && sensor_ok == true) {

      // ------------------ JSON PAYLOAD ------------------
      String payload = "{";
      payload += "\"device_id\":\"" + String(DEVICE_ID) + "\",";
      payload += "\"auth_token\":\"" + String(AUTH_TOKEN) + "\",";
      payload += "\"temperature\":" + String(temperature, 2) + ",";
      payload += "\"humidity\":" + String(humidity, 2);
      payload += "}";


      HttpClient ingestHttp(ethClient, SERVER_HOST, SERVER_PORT);
      ingestHttp.post(INGEST_PATH, "application/json", payload);
    } 
  }

  //--------------------Status Update-----------------
  if (now - lastStatusUpdate >= STATUS_INTERVAL) {
    lastStatusUpdate = now;

    String status = "{";
    status += "\"device_id\":\"" + String(DEVICE_ID) + "\",";
    status += "\"auth_token\":\"" + String(AUTH_TOKEN) + "\",";
    status += "\"firmware\":\"" + String(FIRMWARE_VERSION) + "\",";
    status += "\"uptime_sec\":" + String(now / 1000) + ",";
    status += "\"components\":{";
    status += "\"sensor\":\"" + String(sensor_ok ? "ok" : "dead") + "\",";
    status += "}";


    if (link_up) {
      HttpClient statusHttp(ethClient, SERVER_HOST, SERVER_PORT);
      statusHttp.post(STATUS_PATH, "application/json",status);
    }
  }
}