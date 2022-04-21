// Init LCD

// one int -1 is null
// if -1 change to 0/1
// if 0/1 do logic, if same then overwrite, 
// if different then out or in (+ or - count)

#include <Wire.h>

int prev = -1; // null
int opened = 0; // false

LiquidCrystal lcd(14, 15, 16, 17, 3, 2);

void setup() {
    lcd.begin(16, 2);
    lcd.noDisplay();
}

void loop() {
    // check for signs from other arduinos
    if (opened) {

    }
}