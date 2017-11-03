import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ChemECarFinal extends PApplet {




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

public void setup()
{
  
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
public void draw()
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

public void update()
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

public void serialEvent(Serial myPort)
{
  val = myPort.readStringUntil('\n');
  //Attempt to connect with Arduino (arduino serial will send '/n')
  if (val != null) //start reading light sensor reading
  {
    val = trim(val);
    establishContact();
    sensorData = PApplet.parseInt(val);
  }
}

public void mouseClicked()
{
  mouseClicked = true; 
}


public String getTimeStamp() 
{
  
  String date = year() + "-" + month() + "-" + day() + " " + hour() + "h" 
  + minute() + "m" + second() + "s";
  
  return date;
}

public String getHourStamp() 
{
  
  String date = hour() + "h" 
  + minute() + "m" + second() + "s";
  
  return date;
}


public void establishContact()
{
  if (!contact) {
      
      if (val.equals("A"))
      {
        myPort.clear();
        contact = true;
        status.value = "Arduino connected!";
        println("contact");
        
      }
      else
      {
        status.value = "Arduino disconnected!";
      }
    }
}

public void attemptContact()
{
  if (!contact && initialConnection)
  {
    myPort.write('c'); //sends c to arduino, arduino sends back 'A'
  }
  
}

public void calibrate()
{
  
  String col1 = "Calibration";
  String col2 = str(calCount);
  String col3 = startTimeStamp;
  String col4 = " ";
  String col5 = " ";
  
  if (!initCal)
  {
    colCount += 5;
    calCount++;
    col1 = "Calibration";
    col2 = str(calCount);
    col3 = startTimeStamp;
    col4 = " ";
    col5 = " ";
    
    delay(500);
    startData = sensorData;
    
    table.addColumn(col1);
    table.addColumn(col2);
    table.addColumn(col3);
    table.addColumn(col4);
    table.addColumn(col5);

    
    table.setString(0, colCount, "Time, s");
    table.setString(0, colCount + 1, "Light");
    table.setString(0, colCount + 2, "Threshold");
    
    rowCount++;
    
    initCal = true;
  }
  else
  {
    
    table.setFloat(rowCount, colCount, timer.getTime());
    table.setInt(rowCount, colCount + 1, sensorData);
    table.setInt(rowCount, colCount + 2, (startData + sensorData)/2);
    threshold = (startData + sensorData)/2;
    rowCount++;
    delay(500);
  }
}

public void trial()
{
  //update excel sheet
  String col1 = "Set " + str(setCount);
  String col2 = startTimeStamp;
  String col3 = "Conc. KIO3, M";
  String col4 = "Conc. NAHSO4, M";
  String col5 = " ";
  
  if (!initTrial)
  {
    col1 = "Set " + str(setCount);
    col2 = startTimeStamp;
    col3 = "Conc. KIO3, M";
    col4 = "Conc. NAHSO4, M";
    col5 = " ";
    
    table.setString(rowCount, 0, col1);
    table.setString(rowCount, 1, col2);
    table.setString(rowCount, 2, col3);
    table.setString(rowCount, 3, col4);
    table.setString(rowCount, 4, col5);
    
    rowCount++;
    
    table.setString(rowCount, 0, "Trial");
    table.setString(rowCount, 1, "Time, s");
    
    
    rowCount++;
    
    initTrial = true;
  }
  
  else
  {
    if (sensorData <= threshold && timer.runningState == 1)
    {
      
      timer.stop();
      table.setInt(rowCount, 0, trialCount);
      table.setFloat(rowCount, 1, timer.getTime());
      trialCount++;
      rowCount++;
      
     } 
  }  
}



/* This section of the code creates the java interface */

public class Base
{
  int x, y;
  
  
  Base(int x, int y)
  {
    this.x = x;
    this.y = y;
  }
  
  public void draw()
  {

    
  }
  
  public void update()
  {
    
  }
  
  
}

public class Indicator extends Base
{
  String label;
  String value = "";
  
  Indicator(String label, int x, int y)
  {
   super(x, y);
   this.label = label;
   
  }
  
  public void draw()
  {
   super.draw();
   fill(255);
   text(label, x, y);
   text(value, x+100, y);
   
  }
  
  public void update()
  {
   super.update(); 
  }
}

public class Button extends Base
{
  String label;
  float labelWidth, labelHeight;
  boolean clicked = false;
  boolean mouseOver;
  
  
  Button(String label, int x, int y)
  {
   super(x, y); //x and y are the cutton's coordinates on the interface
   this.label = label;
   
   this.labelHeight = 20;
  }
  
  public void draw() //draw the button w/label
  {
   super.draw();
   this.labelWidth = textWidth(label);
   textSize(labelHeight);
   if (this.clicked)
   {
      
     fill(150); //if clicked shade button
     rect(x, y, labelWidth+5, labelHeight+5);
     fill(0);
     text(label, x+2.5f, y+labelHeight);

   }
   else
   {
     fill(255);
     rect(x, y, labelWidth+5, labelHeight+5);
     fill(0);
     text(label, x+2.5f, y+labelHeight);
   }
   
  }
  
  public void update()
  {
   super.update(); 

  }
  
  //boolean isMousePressed()
  //{
  //  if (mousePressed && mouseX >= x && mouseY >= y && mouseX <=(x+labelWidth+5) && mouseY <=(y+labelHeight+5))
  //  {
      
  //    return true;
      
  //  } 
  //  else
  //  {
  //    return false;
  //  }
    
  //}
  
  public boolean isMouseClicked()
  {
    //if said button is clicked return true to main tab's code (first tab)
    if(mouseClicked)
        
    {
      
      if (mouseX >= x && mouseY >= y && mouseX <=(x+labelWidth+5) && mouseY <=(y+labelHeight+5))
      {
        mouseClicked = false;
        this.clicked =true;
        return true;
      }
      else
      {
        return false;
      }
    }
    else
    {
      return false;
    }
  }
}


public class StopWatch 
{
  private static final int STATE_UNSTARTED = 0;
  private static final int STATE_RUNNING = 1;
  private static final int STATE_STOPPED = 2;

  private int runningState = STATE_UNSTARTED;
  
  private float startTime = -1;
  
  private float stopTime = -1;
  
  public StopWatch() 
  {
    super();
  }
  
  public void start() 
  {
    if (this.runningState == STATE_STOPPED)
    {
      throw new IllegalStateException("Stopwatch must be reset before being restarted.");
    }
    if (this.runningState != STATE_UNSTARTED)
    {
      
    }
    
    this.stopTime = -1;
    this.startTime = millis();
    this.runningState = STATE_RUNNING;
  }
  
  public void stop()
  {
    if (this.runningState != STATE_RUNNING)
    {
      
    }
    if (this.runningState == STATE_RUNNING)
    {
      this.stopTime = millis();
    }
    this.runningState = STATE_STOPPED;
  }
  
  public void reset()
  {
    this.runningState = STATE_UNSTARTED;
    this.startTime = -1;
    this.stopTime = -1;
  }
  
  public float getTime() 
  {
    if (this.runningState == STATE_STOPPED)
    {
      return (this.stopTime - this.startTime)/1000;
    } 
    else if (this.runningState == STATE_UNSTARTED)
    {
      return 0;
    }
    else if (this.runningState == STATE_RUNNING)
    {
      return (millis() - this.startTime)/1000;
    }
    else
    {
      return -1;
    }
  }
  
  public float getStartTime()
  {
    if (this.runningState == STATE_UNSTARTED)
    {
      throw new IllegalStateException("Stopwatch has not been started.");
    }
    return this.startTime;
  }
  
}
  public void settings() {  size(500, 500); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ChemECarFinal" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
