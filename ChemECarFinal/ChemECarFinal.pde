
import processing.serial.*;

Serial myPort;

char mode; //mode = calibrating (c) or trial

String val, timeStamp, startTimeStamp;

Table table, table2;

boolean checkForceTest = false;
boolean clickingKeys = false;
boolean stopped = true;
boolean started = false;
boolean finishCal = false;

boolean mouseClicked = false;
boolean contact = false;
boolean initialConnection = false;
boolean forceTest = false;
boolean initCal, initTrial; //calibrate and trial
float[] pastTimes = new float[1];
float[] pastTimes2 = new float[1];

String userThresh = "";

int sensorData, startData;
int threshold = 900-200; //threshold of the lightsensor reading
int rowCount = 0;
int colCount = -5;
int calCount = 0; //Calibration is set to 0 AKA no calibration is done
int trialCount = 1; //trial is setup as trial #1 upon open
int setCount = 0; //Upon open 0 sets
int rowCounter2 = 1;
int colCounter2 = 10;


StopWatch timer = new StopWatch();

Indicator status = new Indicator("Status:", 20, 40);
Indicator time = new Indicator("Time:", 20, 80);
Indicator light = new Indicator("Light", 20, 120);
Button calibrate = new Button("Calibrate", 20, 160);
Button calibrateUser = new Button("Input Cal", 150, 160);
Button newSet = new Button("New Set", 20, 200);

Button stop = new Button("Stop", 20, 240);
Button delete = new Button("Delete", 150, 240);
Indicator set = new Indicator("Set:", 20, 300);
Indicator trial = new Indicator("Trial: ", 20, 340);
Indicator thresh = new Indicator("Threshold: ", 20, 380);
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
  calibrateUser.draw();
  newSet.draw();
  stop.draw();
  set.draw();
  trial.draw();
  thresh.draw();
  force.draw();
  delete.draw();
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
    mode = 't';
    delay(350);
    println("trial");
    timer.reset();
    timer.start();
    startTimeStamp = getHourStamp();
    println(startTimeStamp);
    stop.clicked = false;
    calibrate.clicked = false;
    calibrateUser.clicked = false;
    started = false;  //changed to true                WARNING CHANGED
    //stopped = false;
  }
   
  if (stop.isMouseClicked())
  {
    if (clickingKeys){
      threshold = int(userThresh);
      userThresh = "";
    }
    stopped = true;
    started = false;
    finishCal = true;
    forceTest = false;
    clickingKeys=false;
    timer.stop();
    calibrate.clicked = false;
    calibrateUser.clicked = false;
    if (mode == 't')
    {
      timer.stop();
      //table.setInt(rowCount, 0, trialCount);
      //table.setFloat(rowCount, 1, timer.getTime());
      trialCount++;
      rowCount++;
      colCounter2+=3;
      rowCounter2 = 1;
      
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
  else if (calibrateUser.isMouseClicked()){
    clickingKeys = true;
    println("_______________________________this");
    
  }
  else if (delete.isMouseClicked()){
    //table = new Table();
    //trialCount = 1;
    //setCount = 0;
    //rowCount = 0;
    //colCount = -5;
    table.setString(rowCount,3,"VOID");
    println("deleated");
    rowCounter2++;
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

void keyPressed(){
  //if(keyCode==BACKSPACE){
  //    userThresh = userThresh.substring(0,userThresh.length()-1);
  //  }
  if (clickingKeys == true){
    userThresh += key;
    println (userThresh);
  }
}