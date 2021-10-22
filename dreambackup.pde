/*what I need to happen:
- play
- record
- playback random recording
- """ triggered by a recording being left
- record on lift or button press (try any pin input first)
- ideally, light or audio indicators for recording */

import ddf.minim.*;
import processing.io.*;
import javax.sound.sampled.*;
import ddf.minim.ugens.*;
Mixer.Info[]mixerInfo;

Minim minim;
AudioInput in;
AudioRecorder recorder;
AudioPlayer player;
  String[] dreams = {"dream1.wav", "dream2.wav"};
  String fileName = "";
void setup()
{
  GPIO.pinMode(4, GPIO.INPUT_PULLUP);
  GPIO.attachInterrupt(4, this, "pinEvent", GPIO.FALLING);
  size(512, 200, P3D);
  
  minim = new Minim(this);
  
  //added from loading file sketch, sets the correct output for the audio
  mixerInfo = AudioSystem.getMixerInfo();
  for(int i = 0; i < mixerInfo.length; i++)
  {println(i + "=" + mixerInfo[i].getName());}
  Mixer mixer = AudioSystem.getMixer(mixerInfo[0]);
  minim.setOutputMixer(mixer);

  //preeeetty sure this is where the recording/mic line comes in
  in = minim.getLineIn();

  //I know this line works on its own:
  recorder = minim.createRecorder(in, "data/myrecording - "+new java.util.Date()+".wav");
  
  //mosher input
  //String fileName = "data/myrecording - "+new java.util.Date()+".wav";
  //recorder = minim.createRecorder(in, fileName);
  
  // to happen after recording, here I think dreams/songs replaces player? 
  //or it replaces "myrecording"?! idk
  //dreams = expand(dreams, dreams.length+1);
  //dreams[dreams.length-1] = fileName;
  
  //String[] songs = {"1.wav", "2.wav","3.wav","4.wav","5.wav","6.wav"};
  int rando = int(random(dreams.length));
  
  player = minim.loadFile(dreams[rando]);
  
}

void draw()
{
  background(0); 
  stroke(255);
  //keeping this - useful to see if audio is registering etc
  // draw the waveforms
  // the values returned by left.get() and right.get() will be between -1 and 1,
  // so we need to scale them up to see the waveform
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
    line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
  }
  
  if ( recorder.isRecording() )
  {
    text("Currently recording...", 5, 15);
  }
  else
  {
    text("Not recording.", 5, 15);
  }
}

void pinEvent(int pin)
{
  //String[] songs = {"1.wav", "2.wav","3.wav","4.wav","5.wav","6.wav"};
  int rando = int(random(dreams.length));
  if (GPIO.digitalRead(4) == GPIO.LOW) 
  {
    if ( recorder.isRecording() ) 
    {
      recorder.endRecord();
      recorder.save();
      println("Done saving.");
      delay(1000);
      player = minim.loadFile("cough.wav");
      player.play();
      delay(2000);
      dreams = expand(dreams, dreams.length+1);
      dreams[dreams.length-1] = fileName;
      //may want to add a static file, like "hmmm" or a throat clearing cough -yes, this- as the pause between
      player = minim.loadFile(dreams[rando]);
      player.play();
    }
    else 
    {
      //may need to change this to an "if" and add "else" - currently creates a new recording when sketch is run
      //may not be an issue if it only runs at start
      //could also set to play two tracks instead of one?
      //may not need rewind with random, will need it to drop the track and play a new one
      player.rewind();
      fileName = "data/myrecording - "+new java.util.Date()+".wav";
      recorder = minim.createRecorder(in, fileName);      
      recorder.beginRecord();
    }
  }
}
