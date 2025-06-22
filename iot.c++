#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include <ESP32Servo.h>

// ===== KONFIGURASI SISTEM =====
const char* SSID = "iot";
const char* PASSWORD = "123456789";
const char* SUPABASE_URL = "https://zmfzszuzpthnoogsuuyg.supabase.co/rest/v1";
const char* API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptZnpzenV6cHRobm9vZ3N1dXlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyOTI1OTQsImV4cCI6MjA2MDg2ODU5NH0.YLfIjxdug2np5bchPtbE-MhAjYqlu-k-oADc6wpRmK8";

// ===== PIN CONFIGURATION =====
const uint8_t DHTPIN = 26;
const uint8_t DHTTYPE = DHT22;
const uint8_t RAIN_SENSOR_PIN = 27;
const uint8_t SOIL_SENSOR_PIN = 32;
const uint8_t FAN_PIN = 18;
const uint8_t SERVO_PIN = 33;
const uint8_t LAMP_PIN = 19;  // PEMANAS

// ===== GLOBAL OBJECTS =====
DHT dht(DHTPIN, DHTTYPE);
Servo myServo;
HTTPClient http;

// ===== SYSTEM VARIABLES =====
const int USER_ID = 1;
const float SOIL_MOISTURE_THRESHOLD = 14.0; // Threshold kadar air 14%

// Variabel untuk menyimpan konfigurasi dari database
float TEMP_THRESHOLD = 30.0;
String CURRENT_MODE = "auto";  // auto atau manual

// Variabel untuk mode MANUAL (dari database)
bool DB_STATUS_HUJAN = false;    // Status hujan dari database (untuk kontrol servo)
bool DB_STATUS_PEMANAS = false;  // Status pemanas dari database (untuk kontrol lampu)

// Variabel untuk tracking perubahan (untuk optimasi update database)
bool lastRainDetected = false;
bool lastPemanasStatus = false;
bool lastKipasStatus = false;
float lastTemperature = 0.0;
float lastHumidity = 0.0;
int lastSoilMoisture = 0;

// Variabel untuk notifikasi - tracking state changes
bool lastRainNotificationState = false;
bool lastHeaterNotificationState = false;
bool lastFanNotificationState = false;

// Timing variables
unsigned long lastSensorRead = 0;
unsigned long lastDBCheck = 0;
unsigned long lastDBUpdate = 0;
const unsigned long SENSOR_INTERVAL = 1000;   // Baca sensor setiap 1 detik
const unsigned long DB_CHECK_INTERVAL = 3000; // Cek database setiap 3 detik
const unsigned long DB_UPDATE_INTERVAL = 5000; // Update database setiap 5 detik

// ===== SENSOR DATA STRUCTURE =====
struct SensorData {
  float temperature = 0.0;
  float humidity = 0.0;
  int rainValue = 0;
  int soilValue = 0;
  float soilMoisturePercent = 0.0;  // Persentase kadar air
  bool rainDetected = false;    // Dari sensor fisik
  bool pemanasStatus = false;   // Status aktual lampu pemanas
  bool kipasStatus = false;     // Status aktual kipas
  bool atapTerbuka = true;      // Status aktual servo
  bool isValid = false;
};

SensorData currentData;

// ===== WIFI CONNECTION =====
bool connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) return true;
  
  Serial.println("🔌 Connecting to WiFi...");
  WiFi.begin(SSID, PASSWORD);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi Connected!");
    Serial.print("📡 IP Address: ");
    Serial.println(WiFi.localIP());
    return true;
  } else {
    Serial.println("\n❌ WiFi Connection Failed!");
    return false;
  }
}

// ===== CEK KONFIGURASI DATABASE =====
bool checkDatabaseConfig() {
  if (!connectWiFi()) return false;

  // 1. Ambil konfigurasi suhu dan threshold
  String url = String(SUPABASE_URL) + "/Suhu?select=batasan_suhu,id_suhu&id_user=eq." + String(USER_ID);
  http.begin(url);
  http.addHeader("apikey", API_KEY);
  http.addHeader("Authorization", "Bearer " + String(API_KEY));
  http.setTimeout(3000);
  
  int httpCode = http.GET();
  bool hasChanges = false;
  int id_suhu = -1;
  
  if (httpCode == HTTP_CODE_OK) {
    String response = http.getString();
    StaticJsonDocument<512> doc;
    deserializeJson(doc, response);
    
    if (doc.size() > 0) {
      float newTempThreshold = doc[0]["batasan_suhu"].as<float>();
      id_suhu = doc[0]["id_suhu"].as<int>();
      
      if (abs(newTempThreshold - TEMP_THRESHOLD) > 0.1) {
        Serial.printf("🔄 Temp threshold changed: %.1f°C → %.1f°C\n", TEMP_THRESHOLD, newTempThreshold);
        TEMP_THRESHOLD = newTempThreshold;
        hasChanges = true;
      }
    }
  }
  http.end();
  
  // 2. Ambil mode dan status untuk manual
  if (id_suhu != -1) {
    http.begin(String(SUPABASE_URL) + "/Pengeringan?select=mode,status_hujan,status_pemanas&id_suhu=eq." + String(id_suhu));
    http.addHeader("apikey", API_KEY);
    http.addHeader("Authorization", "Bearer " + String(API_KEY));
    http.setTimeout(3000);
    
    httpCode = http.GET();
    if (httpCode == HTTP_CODE_OK) {
      String response = http.getString();
      StaticJsonDocument<512> doc;
      deserializeJson(doc, response);
      
      if (doc.size() > 0) {
        String newMode = doc[0]["mode"].as<String>();
        bool newStatusHujan = doc[0]["status_hujan"].as<bool>();
        bool newStatusPemanas = doc[0]["status_pemanas"].as<bool>();
        
        // Cek perubahan mode
        if (newMode != CURRENT_MODE) {
          Serial.println("🔄 Mode changed: " + CURRENT_MODE + " → " + newMode);
          CURRENT_MODE = newMode;
          hasChanges = true;
        }
        
        // Update status untuk mode manual
        if (newStatusHujan != DB_STATUS_HUJAN) {
          Serial.println("🔄 DB rain status: " + String(DB_STATUS_HUJAN) + " → " + String(newStatusHujan));
          DB_STATUS_HUJAN = newStatusHujan;
          hasChanges = true;
        }
        
        if (newStatusPemanas != DB_STATUS_PEMANAS) {
          Serial.println("🔄 DB heater status: " + String(DB_STATUS_PEMANAS) + " → " + String(newStatusPemanas));
          DB_STATUS_PEMANAS = newStatusPemanas;
          hasChanges = true;
        }
      }
    }
    http.end();
  }
  
  return hasChanges;
}

// ===== BACA SENSOR =====
bool readSensors() {
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();
  
  if (isnan(temp) || isnan(hum)) {
    Serial.println("❌ DHT sensor error!");
    currentData.isValid = false;
    return false;
  }
  
  currentData.temperature = temp;
  currentData.humidity = hum;
  currentData.rainValue = analogRead(RAIN_SENSOR_PIN); // Menggunakan digitalRead untuk sensor hujan
  currentData.soilValue = analogRead(SOIL_SENSOR_PIN);
  
  // Konversi soil sensor ke persentase (0-4095 -> 100%-0%)
  // Nilai tinggi = kering (0%), nilai rendah = basah (100%)
  currentData.soilMoisturePercent = map(constrain(currentData.soilValue, 0, 4095), 0, 4095, 100, 0);
  
  // ===== PERBAIKAN SENSOR HUJAN =====
  // Default HIGH (1) = tidak hujan, LOW (0) = hujan terdeteksi
  currentData.rainDetected = (currentData.rainValue == LOW); // LOW = hujan terdeteksi
  currentData.isValid = true;
  
  return true;
}

// ===== KONTROL KIPAS (SELALU BERDASARKAN SUHU) =====
void kontrolKipas() {
  bool shouldFanOn = (currentData.temperature > TEMP_THRESHOLD);
  
  if (shouldFanOn != currentData.kipasStatus) {
    digitalWrite(FAN_PIN, shouldFanOn ? LOW : HIGH);  // Active LOW relay
    currentData.kipasStatus = shouldFanOn;
    
    Serial.printf("🌀 Fan %s (Temp: %.1f°C, Threshold: %.1f°C)\n", 
                  shouldFanOn ? "ON" : "OFF", 
                  currentData.temperature, TEMP_THRESHOLD);
  }
}

// ===== KONTROL ATAP DAN PEMANAS =====
void kontrolAtapDanPemanas() {
  bool shouldCloseRoof = false;
  bool shouldHeatOn = false;
  
  if (CURRENT_MODE == "auto") {
    // ===== MODE AUTO =====
    // Hujan berdasarkan SENSOR FISIK
    shouldCloseRoof = currentData.rainDetected;
    shouldHeatOn = currentData.rainDetected;  // Pemanas ON jika hujan terdeteksi sensor
    
    Serial.printf("📡 AUTO MODE - Rain sensor: %s (%s)\n", 
                  currentData.rainDetected ? "LOW" : "HIGH",
                  currentData.rainDetected ? "RAIN DETECTED" : "NO RAIN");
    
  } else if (CURRENT_MODE == "manual") {
    // ===== MODE MANUAL =====
    // Hujan berdasarkan STATUS DATABASE
    shouldCloseRoof = DB_STATUS_HUJAN;
    shouldHeatOn = DB_STATUS_PEMANAS;  // Pemanas berdasarkan status terpisah di database
    
    Serial.printf("🎮 MANUAL MODE - DB Rain: %s, DB Heater: %s\n", 
                  DB_STATUS_HUJAN ? "TRUE" : "FALSE",
                  DB_STATUS_PEMANAS ? "TRUE" : "FALSE");
  }
  
  // ===== LOGIKA KADAR AIR - MATIKAN PEMANAS JIKA KADAR AIR <= 14% =====
  if (shouldHeatOn && currentData.soilMoisturePercent <= SOIL_MOISTURE_THRESHOLD) {
    shouldHeatOn = false;
    Serial.printf("💧 Heater turned OFF - Soil moisture too low: %.1f%% (<= %.1f%%)\n", 
                  currentData.soilMoisturePercent, SOIL_MOISTURE_THRESHOLD);
  }
  
  // ===== KONTROL SERVO (ATAP) =====
  if (shouldCloseRoof != !currentData.atapTerbuka) {
    myServo.write(shouldCloseRoof ? 0 : 90);  // 0 = tutup, 90 = buka
    currentData.atapTerbuka = !shouldCloseRoof;
    Serial.printf("🏠 Roof %s\n", shouldCloseRoof ? "CLOSED" : "OPENED");
    delay(500); // Tunggu servo bergerak
  }
  
  // ===== KONTROL PEMANAS =====
  if (shouldHeatOn != currentData.pemanasStatus) {
    digitalWrite(LAMP_PIN, shouldHeatOn ? LOW : HIGH);  // Active LOW relay
    currentData.pemanasStatus = shouldHeatOn;
    Serial.printf("🔥 Heater %s\n", shouldHeatOn ? "ON" : "OFF");
  }
}

// ===== KIRIM NOTIFIKASI =====
bool sendNotification(String message, String type = "info") {
  if (!connectWiFi()) return false;
  
  // Ambil id_pengeringan dari database
  int id_pengeringan = -1;
  http.begin(String(SUPABASE_URL) + "/Pengeringan?select=id_pengeringan&id_suhu=eq.1");
  http.addHeader("apikey", API_KEY);
  http.addHeader("Authorization", "Bearer " + String(API_KEY));
  
  int httpCode = http.GET();
  if (httpCode == HTTP_CODE_OK) {
    String response = http.getString();
    StaticJsonDocument<256> doc;
    deserializeJson(doc, response);
    if (doc.size() > 0) {
      id_pengeringan = doc[0]["id_pengeringan"];
    }
  }
  http.end();
  
  if (id_pengeringan == -1) {
    Serial.println("❌ Cannot get id_pengeringan for notification");
    return false;
  }
  
  StaticJsonDocument<512> notifDoc;
  notifDoc["id_pengeringan"] = id_pengeringan;
  notifDoc["pesan"] = message;
  notifDoc["title"] = "Smart Dry Box Alert";
  notifDoc["type"] = type;
  
  String notifBody;
  serializeJson(notifDoc, notifBody);
  
  http.begin(String(SUPABASE_URL) + "/Notifikasi");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", API_KEY);
  http.addHeader("Authorization", "Bearer " + String(API_KEY));
  http.setTimeout(5000);
  
  httpCode = http.POST(notifBody);
  bool success = (httpCode == HTTP_CODE_CREATED || httpCode == HTTP_CODE_OK);
  
  if (success) {
    Serial.println("✅ Notification sent: " + message);
  } else {
    Serial.printf("❌ Failed to send notification: %d\n", httpCode);
    Serial.println("Response: " + http.getString());
  }
  
  http.end();
  return success;
}

// ===== CEK DAN KIRIM NOTIFIKASI BERDASARKAN PERUBAHAN STATE =====
void checkAndSendNotifications() {
  // 1. ===== NOTIFIKASI HUJAN =====
  bool currentRainCondition = (CURRENT_MODE == "auto" && currentData.rainDetected) || 
                             (CURRENT_MODE == "manual" && DB_STATUS_HUJAN);
  
  if (currentRainCondition != lastRainNotificationState) {
    String rainMessage;
    String rainType;
    
    if (currentRainCondition) {
      rainMessage = String("🌧️ HUJAN TERDETEKSI! Atap ditutup otomatis. Suhu: ") + 
                   String(currentData.temperature, 1) + "°C, Kadar Air: " + 
                   String(currentData.soilMoisturePercent, 1) + "%";
      rainType = "warning";
    } else {
      rainMessage = String("☀️ Hujan berhenti. Atap dibuka kembali. Suhu: ") + 
                   String(currentData.temperature, 1) + "°C, Kadar Air: " + 
                   String(currentData.soilMoisturePercent, 1) + "%";
      rainType = "info";
    }
    
    sendNotification(rainMessage, rainType);
    lastRainNotificationState = currentRainCondition;
  }
  
  // 2. ===== NOTIFIKASI PEMANAS =====
  if (currentData.pemanasStatus != lastHeaterNotificationState) {
    String heaterMessage;
    String heaterType;
    
    if (currentData.pemanasStatus) {
      heaterMessage = String("🔥 PEMANAS DINYALAKAN! Suhu: ") + 
                     String(currentData.temperature, 1) + "°C, Kadar Air: " + 
                     String(currentData.soilMoisturePercent, 1) + "%";
      heaterType = "info";
    } else {
      // Cek alasan pemanas mati
      if (currentData.soilMoisturePercent <= SOIL_MOISTURE_THRESHOLD) {
        heaterMessage = String("💧 PEMANAS DIMATIKAN - Kadar air terlalu rendah: ") + 
                       String(currentData.soilMoisturePercent, 1) + "% (<= " + 
                       String(SOIL_MOISTURE_THRESHOLD, 1) + "%). Suhu: " + 
                       String(currentData.temperature, 1) + "°C";
        heaterType = "warning";
      } else {
        heaterMessage = String("🔥 PEMANAS DIMATIKAN. Suhu: ") + 
                       String(currentData.temperature, 1) + "°C, Kadar Air: " + 
                       String(currentData.soilMoisturePercent, 1) + "%";
        heaterType = "info";
      }
    }
    
    sendNotification(heaterMessage, heaterType);
    lastHeaterNotificationState = currentData.pemanasStatus;
  }
  
  // 3. ===== NOTIFIKASI KIPAS =====
  if (currentData.kipasStatus != lastFanNotificationState) {
    String fanMessage;
    String fanType;
    
    if (currentData.kipasStatus) {
      fanMessage = String("🌀 KIPAS DINYALAKAN - Suhu tinggi: ") + 
                  String(currentData.temperature, 1) + "°C (> " + 
                  String(TEMP_THRESHOLD, 1) + "°C). Kadar Air: " + 
                  String(currentData.soilMoisturePercent, 1) + "%";
      fanType = "warning";
    } else {
      fanMessage = String("🌀 KIPAS DIMATIKAN - Suhu normal: ") + 
                  String(currentData.temperature, 1) + "°C (<= " + 
                  String(TEMP_THRESHOLD, 1) + "°C). Kadar Air: " + 
                  String(currentData.soilMoisturePercent, 1) + "%";
      fanType = "info";
    }
    
    sendNotification(fanMessage, fanType);
    lastFanNotificationState = currentData.kipasStatus;
  }
}

// ===== CEK PERUBAHAN DATA =====
bool hasDataChanged() {
  return (currentData.rainDetected != lastRainDetected ||
          currentData.pemanasStatus != lastPemanasStatus ||
          currentData.kipasStatus != lastKipasStatus ||
          abs(currentData.temperature - lastTemperature) > 0.5 ||
          abs(currentData.humidity - lastHumidity) > 2.0 ||
          abs(currentData.soilValue - lastSoilMoisture) > 50);
}

// ===== UPDATE DATABASE =====
bool updateDatabase() {
  if (!connectWiFi()) return false;
  
  bool success = true;
  
  // 1. ===== UPDATE TABEL SUHU (DIPERBAIKI) =====
  StaticJsonDocument<256> suhuDoc;
  suhuDoc["current_temperatur"] = (int)(currentData.temperature);
  suhuDoc["batasan_suhu"] = TEMP_THRESHOLD;
  
  String suhuBody;
  serializeJson(suhuDoc, suhuBody);
  
  http.begin(String(SUPABASE_URL) + "/Suhu?id_user=eq." + USER_ID);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", API_KEY);
  http.addHeader("Authorization", "Bearer " + String(API_KEY));
  http.addHeader("Prefer", "return=minimal");
  http.setTimeout(5000);
  
  int httpCode = http.PATCH(suhuBody);
  if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_NO_CONTENT || httpCode == 204) {
    Serial.println("✅ Suhu table updated");
  } else {
    Serial.printf("❌ Failed to update Suhu table: %d\n", httpCode);
    Serial.println("Response: " + http.getString());
    success = false;
  }
  http.end();
  
  // 2. ===== UPDATE TABEL KADAR_AIR (HUMIDITY & SOIL) =====
  StaticJsonDocument<256> airDoc;
  airDoc["kadar_air"] = currentData.soilMoisturePercent; // Menggunakan persentase
  airDoc["status_kadar_air"] = (currentData.soilMoisturePercent > SOIL_MOISTURE_THRESHOLD);
  
  String airBody;
  serializeJson(airDoc, airBody);
  
  http.begin(String(SUPABASE_URL) + "/Kadar_Air?id_user=eq." + String(USER_ID));
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", API_KEY);
  http.addHeader("Authorization", "Bearer " + String(API_KEY));
  http.addHeader("Prefer", "return=minimal");
  http.setTimeout(5000);
  
  httpCode = http.PATCH(airBody);
  if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_NO_CONTENT || httpCode == 204) {
    Serial.println("✅ Kadar_Air table updated");
  } else {
    Serial.printf("❌ Failed to update Kadar_Air table: %d\n", httpCode);
    success = false;
  }
  http.end();
  
  // 3. ===== AMBIL ID_SUHU =====
  int id_suhu = -1;
  http.begin(String(SUPABASE_URL) + "/Suhu?select=id_suhu&id_user=eq." + String(USER_ID));
  http.addHeader("apikey", API_KEY);
  http.addHeader("Authorization", "Bearer " + String(API_KEY));
  
  httpCode = http.GET();
  if (httpCode == HTTP_CODE_OK) {
    String response = http.getString();
    StaticJsonDocument<256> doc;
    deserializeJson(doc, response);
    if (doc.size() > 0) {
      id_suhu = doc[0]["id_suhu"];
    }
  }
  http.end();
  
  // 4. ===== UPDATE TABEL PENGERINGAN =====
  if (id_suhu != -1) {
    StaticJsonDocument<256> pengeringanDoc;
    pengeringanDoc["mode"] = CURRENT_MODE;
    
    // Update status berdasarkan kondisi aktual hardware
    if (CURRENT_MODE == "auto") {
      // Untuk auto, update status hujan berdasarkan sensor
      pengeringanDoc["status_hujan"] = currentData.rainDetected;
      pengeringanDoc["status_pemanas"] = currentData.pemanasStatus;
    } else {
      // Untuk manual, biarkan status_hujan dan status_pemanas dari database
      pengeringanDoc["status_hujan"] = DB_STATUS_HUJAN;
      pengeringanDoc["status_pemanas"] = DB_STATUS_PEMANAS;
    }
    
    // Status aktual hardware
    pengeringanDoc["status_kipas"] = currentData.kipasStatus;
    
    String pengeringanBody;
    serializeJson(pengeringanDoc, pengeringanBody);
    
    http.begin(String(SUPABASE_URL) + "/Pengeringan?id_suhu=eq." + String(id_suhu));
    http.addHeader("Content-Type", "application/json");
    http.addHeader("apikey", API_KEY);
    http.addHeader("Authorization", "Bearer " + String(API_KEY));
    http.addHeader("Prefer", "return=minimal");
    http.setTimeout(5000);
    
    httpCode = http.PATCH(pengeringanBody);
    if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_NO_CONTENT || httpCode == 204) {
      Serial.println("✅ Pengeringan table updated");
    } else {
      Serial.printf("❌ Failed to update Pengeringan table: %d\n", httpCode);
      success = false;
    }
    http.end();
  }
  
  // 5. ===== CEK DAN KIRIM NOTIFIKASI =====
  checkAndSendNotifications();
  
  // Update tracking variables jika berhasil
  if (success) {
    lastRainDetected = currentData.rainDetected;
    lastPemanasStatus = currentData.pemanasStatus;
    lastKipasStatus = currentData.kipasStatus;
    lastTemperature = currentData.temperature;
    lastHumidity = currentData.humidity;
    lastSoilMoisture = currentData.soilValue;
  }
  
  return success;
}

// ===== TAMPILKAN STATUS =====
void displayStatus() {
  Serial.println("========== SYSTEM STATUS ==========");
  Serial.printf("Mode         : %s\n", CURRENT_MODE.c_str());
  Serial.printf("Temperature  : %.1f°C (Threshold: %.1f°C)\n", currentData.temperature, TEMP_THRESHOLD);
  Serial.printf("Humidity     : %.1f%%\n", currentData.humidity);
  Serial.printf("Rain Sensor  : %s (%s)\n", 
                currentData.rainDetected ? "LOW" : "HIGH",
                currentData.rainDetected ? "RAIN DETECTED" : "NO RAIN");
  Serial.printf("Soil Sensor  : %d (%.1f%% moisture)\n", 
                currentData.soilValue, currentData.soilMoisturePercent);
  Serial.printf("Soil Status  : %s (Threshold: %.1f%%)\n",
                currentData.soilMoisturePercent > SOIL_MOISTURE_THRESHOLD ? "OK" : "TOO DRY",
                SOIL_MOISTURE_THRESHOLD);
  Serial.printf("Roof         : %s\n", currentData.atapTerbuka ? "OPEN" : "CLOSED");
  Serial.printf("Heater       : %s\n", currentData.pemanasStatus ? "ON" : "OFF");
  Serial.printf("Fan          : %s\n", currentData.kipasStatus ? "ON" : "OFF");
  Serial.printf("WiFi         : %s\n", WiFi.status() == WL_CONNECTED ? "CONNECTED" : "DISCONNECTED");
  
  if (CURRENT_MODE == "manual") {
    Serial.printf("DB Rain      : %s\n", DB_STATUS_HUJAN ? "TRUE" : "FALSE");
    Serial.printf("DB Heater    : %s\n", DB_STATUS_PEMANAS ? "TRUE" : "FALSE");
  }
  Serial.println("===================================");
}

// ===== SETUP =====
void setup() {
  Serial.begin(115200);
  Serial.println("\n🚀 Smart Dry Box - Improved with Soil Moisture Control v3.0");
  
  // Pin setup
  pinMode(RAIN_SENSOR_PIN, INPUT_PULLUP); // Sensor hujan digital dengan pull-up
  pinMode(FAN_PIN, OUTPUT);
  pinMode(LAMP_PIN, OUTPUT);
  
  // Initial states - semua OFF
  digitalWrite(FAN_PIN, HIGH);   // Fan OFF (active low)
  digitalWrite(LAMP_PIN, HIGH);  // Heater OFF (active low)
  
  // Sensor initialization
  dht.begin();
  myServo.setPeriodHertz(50);
  myServo.attach(SERVO_PIN, 500, 2400);
  myServo.write(90); // Default roof OPEN
  currentData.atapTerbuka = true;
  
  // WiFi connection
  connectWiFi();
  
  // Load initial configuration
  checkDatabaseConfig();
  
  Serial.println("✅ System ready!");
  Serial.println("📝 Rain Sensor: HIGH=No Rain, LOW=Rain Detected");
  Serial.printf("💧 Soil Moisture Threshold: %.1f%%\n", SOIL_MOISTURE_THRESHOLD);
  Serial.println("🔄 HTTP Polling enabled for database sync");
  Serial.println("🔔 Enhanced notifications enabled for all state changes");
}

// ===== MAIN LOOP =====
void loop() {
  unsigned long now = millis();
  
  // 1. ===== BACA SENSOR =====
  if (now - lastSensorRead >= SENSOR_INTERVAL) {
    if (readSensors()) {
      // Kontrol kipas (selalu berdasarkan suhu)
      kontrolKipas();
      
      // Kontrol atap dan pemanas (auto/manual + logika kadar air)
      kontrolAtapDanPemanas();
    }
    lastSensorRead = now;
  }
  
  // 2. ===== CEK DATABASE (untuk perubahan konfigurasi) =====
  if (now - lastDBCheck >= DB_CHECK_INTERVAL) {
    if (checkDatabaseConfig()) {
      Serial.println("⚡ Database config changed!");
      // Langsung terapkan perubahan
      if (CURRENT_MODE == "manual") {
        kontrolAtapDanPemanas();
      }
    }
    lastDBCheck = now;
  }
  
  // 3. ===== UPDATE DATABASE =====
  if (now - lastDBUpdate >= DB_UPDATE_INTERVAL) {
    if (currentData.isValid) {
      Serial.println("📤 Updating database...");
      
      if (updateDatabase()) {
        Serial.println("✅ Database updated successfully");
      } else {
        Serial.println("❌ Database update failed");
      }
      
      // Tampilkan status
      displayStatus();
    }
    lastDBUpdate = now;
  }
  
  delay(100); // Stability delay
}