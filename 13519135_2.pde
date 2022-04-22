// Init LCD

// one int -1 is null
// if -1 change to 0/1
// if 0/1 do logic, if same then overwrite, 
// if different then out or in (+ or - count)

#include <LiquidCrystal.h>
#include <Wire.h>

#define PUSH_BUTTON 10
#define LED 4
#define PIR_0 12
#define PIR_1 11
#define NULL -1

int prev = NULL; // null
int opened = 0; // false

int button_state = 0;

int count_inside = 0;

LiquidCrystal lcd(14, 15, 16, 17, 3, 2);

void setup() {
    Wire.begin(1);
    Wire.onReceive(change_state);
    Wire.onRequest(send_button_state);
    Serial.begin(9600);
    lcd.begin(16, 2);
    update_lcd();
    pinMode(PUSH_BUTTON, INPUT); // push button
    pinMode(LED, OUTPUT);
    pinMode(PIR_0, INPUT);
    pinMode(PIR_1, INPUT);
}

void loop() {
    if (count_inside > 0) digitalWrite(LED, HIGH);
    else digitalWrite(LED, LOW);
    if (opened) {
        Serial.println("TESTING OPENED");
        int pir_0 = digitalRead(PIR_0);
        if (pir_0 == HIGH) {
            if (prev == NULL) {
                prev = 0;
            } else if (prev == 1) {
                (count_inside > 0) ? count_inside-- : count_inside;
                prev = NULL;
                update_lcd();
            }
        } else {
            int pir_1 = digitalRead(PIR_1);
            if (pir_1 == HIGH) {
                if (prev == NULL) {
                    prev = 1;
                } else if (prev == 0) {
                    count_inside++;
                    prev = NULL;
                    update_lcd();
                }
            }
        }
    } else { // if not opened, check for button input
        button_state = digitalRead(PUSH_BUTTON);
    }
}

void change_state(int how_many) {
    opened = Wire.read();
    prev = NULL;
}

void send_button_state() {
    Wire.write(button_state);
    button_state = 0;
}

void update_lcd() {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(String("INSIDE: ") + String(count_inside));
}