#include <LiquidCrystal.h>
#include <Keypad.h>
#include <Wire.h>

String inputted = String();
String changed_password = String();
int changed = 0;

const byte n_rows = 4;
const byte n_cols = 4;

char keymap[n_rows][n_cols] = {
    {'1', '2', '3', 'A'},
    {'4', '5', '6', 'B'},
    {'7', '8', '9', 'C'},
    {'*', '0', '#', 'D'}
};

// Keypad connections
byte row_pins[n_rows] = {12, 11, 10, 9};
byte col_pins[n_cols] = {8, 7, 6, 5};

// Init LCD
LiquidCrystal lcd(14, 15, 16, 17, 3, 2);

// Init keypad
Keypad my_keypad = Keypad(makeKeymap(keymap), 
    row_pins, col_pins, n_rows, n_cols);

void setup() {
    Wire.begin(2);
    Wire.onRequest(send_pass);
    Serial.begin(9600);
    lcd.begin(16, 2);
    lcd.display();
    write_line(0, String("CHANGE PASSWORD"));
}

void loop() {
    char keypressed = my_keypad.getKey();
    if (keypressed != NO_KEY) {
        if (keypressed != 'A' && keypressed != 'B' && keypressed != 'C' 
            && keypressed != 'D' && keypressed != '*' && keypressed != '#')
                inputted += keypressed;
        if (inputted.length() == 4) {
            lcd.clear();
            write_line(0, String("PASS CHANGED"));
            changed = 1;
            changed_password = inputted;
            inputted = String();
        }
        write_line(1, inputted);
    }
}

void send_pass() {
    if (!changed) {
        Wire.write(0);
        return;
    }
    Wire.write(1);
    Wire.write(changed_password.c_str()); // 4 bytes
    changed = 0;
}

void clear_line(int x) {
    lcd.setCursor(0, x);
    lcd.print("                     ");
}

void write_line(int row, String sentence) {
    clear_line(row);
    lcd.setCursor(0, row);
    lcd.print(sentence);
}