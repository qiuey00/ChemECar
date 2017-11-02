
import processing.serial.*;

Serial myPort;

char mode; //mode = calibrating (c) or trial

String val, timeStamp, startTimeStamp;

Table table, table2;

boolean checkForceTest = false;
boolean stopped = true;
boolean started = false;
boolean finishCal = false;

boolean mouseClicked = false;
boolean contact = false;
boolean initialConnection = false;
boolean forceTest = false;
boolean initCal, initTrial; //calibrate and trial

int sensorData, startData;
int threshold = 900-200; //threshold of the lightsensor reading
int rowCount = 0;
int colCount = -5;
int calCount = 0; //Calibration is set to 0 AKA no calibration is done
int trialCount = 1; //trial is setup as trial #1 upon open
int setCount = 0; //Upon open 0 sets

StopWatch timer = new StopWatch();

Indicator status = new Indicator("Status:", 20, 40);
Indicator time = new Indicator("Time:", 20, 80);
Indicator light = new Indicator("Light", 20, 120);
Button calibrate = new Button("Calibrate", 20, 160);
Button newSet = new Button("New Set", 20, 200);

Button stop = new Button("Stop", 20, 240);
Indicator set = new Indicator("Set:", 20, 300);
Indicator trial = new Indicator("Trial:", 20, 340);
Indicator thresh = new Indicator("Threshold:", 20, 380);
Indicator force = new Indicator("Force:", 20, 420);

void setup()
{
  size(500, 500);
  timeStamp = getTimeStamp();
  
  table = new Table();

  //attempt to connect to Arduino through serial port
  try
  {  
    myPort = new Serial(this, Serial.list()[0], 9600); 
    myPort.bufferUntil('\n');
    initialConnection = true;
  }
  catch (Exception e)
  {
    status.value = "Arduino not connected! Scanning...";
  }
}

//Format of interface
void draw()
{
  update();
  background(0);
      
  status.draw();
  time.draw();
  light.draw();
  calibrate.draw();
  newSet.draw();
  stop.draw();
  set.draw();
  trial.draw();
  thresh.draw();
  force.draw();
}

void update()
{
  attemptContact();
  time.value = str(timer.getTime());
  light.value = str(sensorData);
  set.value = str(setCount);
  trial.value = str(trialCount);
  thresh.value = str(threshold);
  
  if(forceTest == false) {
    force.value = "Off";
  }
  else {
    force.value = "On";
  }
  
  if(sensorData == -50 && !forceTest) { //new trial // deleted checkforcetest
      forceTest = true;
  }
  else
  {
    forceTest = false;
  }
  
  if(finishCal && forceTest && !started) { //deleted !checkforcetest condition added force test
    started = true;
  }
   
  if(started){ // deleted stopp
    delay(500);
    mode = 't';
    println("trial");
    timer.reset();
    timer.start();
    startTimeStamp = getHourStamp();
    println(startTimeStamp);
    stop.clicked = false;
    calibrate.clicked = false;
    started = false;  //changed to true                WARNING CHANGED
    //stopped = false;
  }
   
  if (stop.isMouseClicked())
  {
    stopped = true;
    started = false;
    finishCal = true;
    forceTest = false;
    timer.stop();
    calibrate.clicked = false;
    if (mode == 't')
    {
      timer.stop();
      table.setInt(rowCount, 0, trialCount);
      table.setFloat(rowCount, 1, timer.getTime());
      trialCount++;
      rowCount++;
      
      saveTable(table, "data/" + timeStamp + ".csv"); //save excel sheet upon stop
    }
    mode = 's'; //mode s is stop
    myPort.write('s');
    myPort.write('c');
    timer.reset();
    saveTable(table, "data/" + timeStamp + ".csv");  //save excel sheet
    
  }
  else if (calibrate.isMouseClicked())
  {
    checkForceTest = true;
    
  }
  else if (newSet.isMouseClicked())
  {
    initTrial = false;
    setCount++;
    trialCount = 1;
  }
  
  if(checkForceTest && forceTest) {
    initCal = false;
    mode = 'c';  //callibration mode
    rowCount = 0;
    timer.start();
    startTimeStamp = getHourStamp();
    stop.clicked = false;
    checkForceTest = false;
    finishCal = false;
    println("calibrated");
    
  }
  
  switch (mode)
  {
    case 't':
      trial(); //trial function is made in functions tab
      break;
      
    case 'c':
      calibrate(); //calibration function made in functions tab
      break;
  }
}

void serialEvent(Serial myPort)
{
  val = myPort.readStringUntil('\n');
  //Attempt to connect with Arduino (arduino serial will send '/n')
  if (val != null) //start reading light sensor reading
  {
    val = trim(val);
    establishContact();
    sensorData = int(val);
  }
}

void mouseClicked()
{
  mouseClicked = true; 
}