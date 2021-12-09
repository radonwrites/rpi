/*what I need to happen:
- play
- record
- playback random recording
- """ triggered by a recording being left
- record on lift or button press (try any pin input first)
- ideally, light or audio indicators for recording */

import ddf.minim.*;
import javax.sound.sampled.*;
import ddf.minim.ugens.*;
Mixer.Info[]mixerInfo;

int count = 3;
int index = 0;

  //got this from forum.arduino.cc/index.php?topic=96456.0
AudioPlayer [] player = new AudioPlayer[count];

void setup()
{
  size(512, 200, P3D);
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  mixerInfo = AudioSystem.getMixerInfo();
  for(int i = 0; i < mixerInfo.length; i++)
  {println(i + "=" + mixerInfo[i].getName());}
  Mixer mixer = AudioSystem.getMixer(mixerInfo[0]);
  minim.setOutputMixer(mixer);
  
  // loadFile will look in all the same places as loadImage does.
  // this means you can find files that are in the data folder and the 
  // sketch folder. you can also pass an absolute path, or a URL.
  player[0] = minim.loadFile("groove.mp3");
  player[1] = minim.loadFile("record1.wav");
  player[2] = minim.loadFile("record2.wav");
  
  //I think mosher wrote this?
  String[] songs = {"groove.mp3"};
  
  index = random(0, count);
}

void draw()
{
  background(0);
  stroke(255);
  
  // draw the waveforms
  // the values returned by left.get() and right.get() will be between -1 and 1,
  // so we need to scale them up to see the waveform
  // note that if the file is MONO, left.get() and right.get() will return the same value
  for(int i = 0; i < player.bufferSize() - 1; i++)
  {
    float x1 = map( i, 0, player.bufferSize(), 0, width );
    float x2 = map( i+1, 0, player.bufferSize(), 0, width );
    line( x1, 50 + player.left.get(i)*50, x2, 50 + player.left.get(i+1)*50 );
    line( x1, 150 + player.right.get(i)*50, x2, 150 + player.right.get(i+1)*50 );
  }
  
  
  //recortd a song 
  /*
    String newSongFileName = "sdfarewfwef.mp3";
  songs = expand(songs, songs.length+1);
  songs[songs.length-1] = fileName;
  
  
  
  //rando
  int rando = int(random(songs.length));
  
  */
  
  // don't care about these:
  // draw a line to show where in the song playback is currently located
  float posx = map(player.position(), 0, player.length(), 0, width);
  stroke(0,200,0);
  line(posx, 0, posx, height);
  
  if ( player.isPlaying() )
  {
    text("Press any key to pause playback.", 10, 20 );
  }
  else
  {
    text("Press any key to start playback.", 10, 20 );
  }
}

void keyPressed()
{
  if ( player.isPlaying() )
  {
    player.pause();
  }
  // if the player is at the end of the file,
  // we have to rewind it before telling it to play again
  else if ( player.position() == player.length() )
  {
    player.rewind();
    player.play();
  }
  else
  {
    player.play();
  }
}
