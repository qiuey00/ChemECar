// FOR STOP REACTION TESTING PURPOSES ONLY
// DO NOT USE FOR COMPETITION

// To store the current mode of the experiment given by the Java program.
// Not really necessary but the program is expecting it.
char mode;

// To store photsensor reading.
int sensorReading;
// Store the analog reading from the FSR resistor divider
int fsrReading;    

// Pin for transistor switch for transmitting HIGH or LOW to turn on or off the circuit.
// This is not really needed for experimentation but could be attached to an LED in place
// of the chemical battery to give a visible and physical notification that the stop reaction is finished.
int switchPin = 3;

// Pin for receiving photosensor readings. pin a0
int sensorPin = 0;
// The FSR and 10K pulldown are connected to pin a1
int fsrPin = 1;     

// To store LIGHT threshold.
int lightThres = 100; //404
//To store FORCE threshold
int forceThres = 300; 

boolean start;
//boolean done;
boolean forceTest;

void setup() 
{
  // Put your setup code here, to run once:
 
  // Setting up switch pin to send signal == OUTPUT.
  pinMode(switchPin, OUTPUT); 
  
  // Open up usb port connection at a data rate of 9600 baud
  Serial.begin(9600);


}

void loop() {
  // Put your main code here, to run repeatedly:
  
  // Check if any data is coming through the usb port.
  // Not really necessary but the old java program expects it.
  if (Serial.available() > 0)
  {
    
    mode = Serial.read();

    if (mode == 'c')
    {
      Serial.println("A");
    }
    
  }

  // Get the reading from the photosensor.
  sensorReading = analogRead(sensorPin)*2;
  //Serial.println(sensorReading);
  //delay(1000);
  //Get reading from force sensor.
  fsrReading = analogRead(fsrPin); 
  //Serial.println(fsrReading);
  //Show force sensor reading in Java code

  //digitalWrite(switchPin, HIGH);
  
  switch (mode)
  {
    // For testing mode.
    case 'c':
      //digitalWrite(switchPin, LOW);
      if (fsrReading >= forceThres)
      {
        Serial.println(-50);
        start = true;
      }
      if (start == true)
      {
        Serial.println(sensorReading);
        
      }
      break;
    
    case 's':
      start = false;
      break;

    // Default to competition mode if not connected to a computer.
    default:
      
    // Set the threshold if threshold is set.
      if (lightThres == 0) 
      {
        lightThres = sensorReading - 30;
      }

      // Turn on the circuit to the chemical battery or testing LED.
      if (fsrReading >= forceThres)
      {
        forceTest = true;
      }
//      else if ((forceTest==false)&&(700 <= sensorReading <= 705)) //go automatically when sensing delivery system
//      {
//        forceTest = true;
//      }
      else
      {
        forceTest = false;
        digitalWrite(switchPin, LOW);
      }

      while (forceTest == true)
      {
        digitalWrite(switchPin, HIGH);
        sensorReading = analogRead(sensorPin);
        // If sensorReading is below or equal to the threshold, turn off the circuit.
        if (sensorReading <= lightThres)
        {
          // Turn off the circuit to the chemical battery or testing LED.
          digitalWrite(switchPin, LOW);
          forceTest = false;
        } 
      }
      break;
  }
  
}

