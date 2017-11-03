

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