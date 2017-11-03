

String getTimeStamp() 
{
  
  String date = year() + "-" + month() + "-" + day() + " " + hour() + "h" 
  + minute() + "m" + second() + "s";
  
  return date;
}

String getHourStamp() 
{
  
  String date = hour() + "h" 
  + minute() + "m" + second() + "s";
  
  return date;
}


void establishContact()
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

void attemptContact()
{
  if (!contact && initialConnection)
  {
    myPort.write('c'); //sends c to arduino, arduino sends back 'A'
  }
  
}

void calibrate()
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
    //threshold = (startData + sensorData)/2;
    if (clickingKeys == true){
      threshold = int(userThresh);
      clickingKeys = false;
    } else {
        threshold = sensorData;
    }
    rowCount++;
    delay(500);
  }
}

void trial()
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
      pastTimes2 = append(pastTimes,timer.getTime());
      pastTimes = pastTimes2;
      printArray(pastTimes);
     } 
  }  
}