#include <LiquidCrystal.h>
#include <Keypad.h>
#include <Servo.h>
#include <Wire.h>

const byte n_rows = 4;
const byte n_cols = 4;
const long interval = 1000; // 1 second
const int countdown_value = 15; // 15 second timer
const int cooldown_value = 10; // 10 second cooldown
const int opened_value = 10; // 10 second opened timer

String password = String("1234");
String inputted = String();

unsigned long previous_millis = 0;
unsigned long previous_cooldown_millis = 0;
unsigned long previous_opened_millis = 0;
int countdown_timer = countdown_value;
int cooldown_timer = cooldown_value;
int opened_timer = opened_value;
int cooldown = 0; // boolean cooldown
int unlocked = 0;
int input_mode = 0;
int opened = 0;

int open_angle = 180;
int closed_angle = 90;

char keymap[n_rows][n_cols] = {
    {'1', '2', '3', 'A'},
    {'4', '5', '6', 'B'},
    {'7', '8', '9', 'C'},
    {'*', '0', '#', 'D'}
};

// Keypad connections
byte row_pins[n_rows] = {12, 11, 10, 9};
byte col_pins[n_cols] = {8, 7, 6, 5};

// Init keypad
Keypad myKeypad = Keypad(makeKeymap(keymap), 
    row_pins, col_pins, n_rows, n_cols);

// Init LCD
LiquidCrystal lcd(14, 15, 16, 17, 3, 2);

Servo micro_servo;

void setup() {
    Serial.begin(9600);
    lcd.begin(16, 2);
    lcd.noDisplay();
    micro_servo.attach(4, 500, 2500);
    Wire.begin(1);
}

void loop() {
    unsigned long current_millis = millis();

    // check input from arduino 2 here

    if (unlocked) {
        if (!opened) { // opening
            micro_servo.write(open_angle);
            opened = 1;
            previous_opened_millis = current_millis;
        } else {
            if (current_millis - previous_opened_millis >= interval) {
                previous_opened_millis = current_millis;
                opened_timer--;
                if (opened_timer == -1) {
                    opened_timer = opened_value;
                    micro_servo.write(closed_angle);
                    reset_millis(current_millis);
                    reset_timers();
                    clear_line(0);
                    opened = 0;
                    unlocked = 0;
                }
                clear_line(1);
            }
        }
        lcd.setCursor(0, 1);
        lcd.print(String("COUNTDOWN: ") + String(opened_timer));
        // check input from arduino 2 here
        // control door from here
        return;
    }

    if (cooldown) {
        if (current_millis - previous_cooldown_millis >= interval) {
            previous_cooldown_millis = current_millis;
            cooldown_timer--;
            if (cooldown_timer == -1) {
                cooldown_timer = cooldown_value;
                previous_millis = current_millis;
                cooldown = 0;
                lcd.clear();
                return;
            }
            clear_line(1);
            lcd.setCursor(0, 1);
            lcd.print(String(cooldown_timer));
        }
        return;
    }
    {'1', '2', '3', 'A'},
    {'4', '5', '6', 'B'},
    {'7', '8', '9', 'C'},
    {'*', '0', '#', 'D'}
    char keypressed = myKeypad.getKey();
    if (keypressed != NO_KEY) {
        if (!input_mode) {
            if (keypressed == 'A') { // button to start prompt
                lcd.display();
                input_mode = 1;
                previous_millis = current_millis;
            }
        } else {
            if (inputted.length() == 0) clear_line(0);
            if (keypressed != 'A' && keypressed != 'B' && keypressed != 'C' 
                && keypressed != 'D' && keypressed != '*' 
                && keypressed != '#')
                inputted += keypressed;
            if (inputted.length() == 4) {
                clear_line(0);
                if (inputted == password) {
                    lcd.clear();
                    lcd.setCursor(0, 0);
                    lcd.print("UNLOCKED");
                    unlocked = 1;
                    inputted = String();
                    return;
                } else {
                    lcd.setCursor(0, 0);
                    lcd.print("INCORRECT PASS");
                    inputted = String();
                }
            } else {
                lcd.setCursor(0, 0);
                lcd.print(inputted);
            }
        }
    }

    if (input_mode && current_millis - previous_millis >= interval) {
        previous_millis = current_millis;
        countdown_timer--;
        if (countdown_timer == -1) {
            countdown_timer = countdown_value;
            previous_cooldown_millis = current_millis;
            cooldown = 1;
            lcd.clear();
            lcd.setCursor(0, 0);
            lcd.print("COOLDOWN");
            lcd.setCursor(0, 1);
            lcd.print(String(cooldown_timer));
            return;
        }
        clear_line(1);
    }

    lcd.setCursor(0, 1);
    lcd.print(String("COUNTDOWN: ") + String(countdown_timer));
}

void clear_line(int x) {
    lcd.setCursor(0, x);
    lcd.print("                     ");
}

void reset_timers() {
    countdown_timer = countdown_value;
    cooldown_timer = cooldown_value;
    opened_timer = opened_value;
}

void reset_millis(unsigned long current_millis) {
    previous_millis = current_millis;
    previous_cooldown_millis = current_millis;
    previous_opened_millis = current_millis;
}