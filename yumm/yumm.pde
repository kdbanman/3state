import infospect.InformationSpectrum;

color backCol = #3B3B3B;

int habSize = 50;
int cellSize = 4;
int historySize = 120;

int currentLine;
int maxLine;

boolean paused;
color[] pauseBuffer;
int pauseCellSize;
int menuX;
int menuY;
boolean pauseMenuDragging;

// cells are 0, 1, or 2
int[] hab;
int[] nextHab;
// history is a circular buffer of habitats
int[][] history;
int historyIndex;

InformationSpectrum[] spectralHistory;

// 27 possible nbrhood states
//  --> 7625597484987 possible rulesets
//  --> range is 0L to 7625597484986L
// this number might actually correspond reversed rule map...
// (this shit only works on 64 bit machines because it takes
// 43 bits to describe all 3 state outer totallistic 1D
// automata)
long initialRule = 214582522525L;
int[][][] nextMap;

void setup() {
  int cellViewWidth = habSize * cellSize;
  int spectrumViewWidth = (habSize - 2) * cellSize;
  
  int screenWidth = cellViewWidth + spectrumViewWidth;
  int screenHeight = cellSize * historySize;
  
  size(screenWidth, screenHeight);
  
  paused = false;
  pauseBuffer = new color[screenWidth * screenHeight];
  pauseCellSize = 15;
  menuX = 0;
  menuY = 0;
  pauseMenuDragging = false;
  
  history = new int[historySize][habSize];
  historyIndex = 0;
  randomizedSeed(history, historyIndex);
  
  spectralHistory = new InformationSpectrum[historySize];
  
  print("loading...");
  for (int i = 0; i < historySize; i++) {
    spectralHistory[i] = new InformationSpectrum(history[i]);
    print(".");
  }
  
  nextMap = new int[3][3][3];
  makeMap(nextMap, initialRule);
  
  noStroke();
  background(backCol);
  frameRate(24);
}
void renderHistory(int[][] history, InformationSpectrum[] spectralHistory, int historyIndex, int cellSize) {
  for (int i = 0; i < history.length; i++) {
    int circularIndex = (historyIndex + i + 2) % history.length;
    renderLine(i, history[circularIndex], cellSize);
    renderSpectrumLine(i, spectralHistory[circularIndex], cellSize, history[0].length * cellSize);
  }
}

void renderLine(int line, int[] hab, int cellSize) {
  for (int j = 0; j < hab.length; j++) {
    if (hab[j] == 0) fill(#E5E5E5);
    else if (hab[j] == 1) fill(#2E40FC);
    else if (hab[j] == 2) fill(#FCAE2E);
    rect(j * cellSize, line * cellSize, cellSize, cellSize);
  }
}

void renderSpectrumLine(int line, InformationSpectrum spectrum, int cellSize, int horizOffset) {
  for (int j = 2; j <= spectrum.getMaxBlockSize(); j++) {
    int intensity = (int) (255.0 * ((float) spectrum.getBlockSizeRepetitionCount(j)) / ((float) spectrum.getMaxBlockSize()));
    fill(intensity, intensity, intensity);
    rect(horizOffset + j * cellSize, line * cellSize, cellSize, cellSize);
  }
}

void draw() {
  
  if (!paused) {
    background(backCol);
  
    calculateNext(history, historyIndex, nextMap);
    analyzeNextSpectrum(history, spectralHistory, historyIndex);
    renderHistory(history,  spectralHistory, historyIndex, cellSize);
    historyIndex = (historyIndex + 1) % history.length;
  } else {
    
    for (int i = 0; i < pixels.length; i++) {
      pixels[i] = pauseBuffer[i];
    }
    updatePixels();
    
    fill(backCol);
    rect(menuX, menuY, 13*pauseCellSize, 28*pauseCellSize, 15);
    
    int xOff = menuX + pauseCellSize;
    int yOff = menuY + pauseCellSize;
    
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          // render neihborhood triple
          fill(getColor(i));
          rect(xOff, yOff, pauseCellSize, pauseCellSize, 4);
          
          fill(getColor(j));
          rect(xOff + pauseCellSize, yOff, pauseCellSize, pauseCellSize, 4);
          
          fill(getColor(k));
          rect(xOff + 2 * pauseCellSize, yOff, pauseCellSize, pauseCellSize, 4);
          
          // render rule
          fill(getColor(nextMap[i][j][k]));
          rect(xOff + pauseCellSize, yOff + pauseCellSize, pauseCellSize, pauseCellSize, 4);
          
          xOff += 4 * pauseCellSize;
        }
        yOff += 3 * pauseCellSize;
        xOff = menuX + pauseCellSize;
      }
    }
  }
}

void mouseClicked() {
  if (paused) {
    int menuClickX = mouseX - menuX;
    int menuClickY = mouseY - menuY;
    
    if (menuClickX > pauseCellSize && menuClickX < 12*pauseCellSize &&
        menuClickY > pauseCellSize && menuClickY < 27*pauseCellSize) {
      int k = (menuClickX - pauseCellSize) / (pauseCellSize * 4);
      int j = ((menuClickY - pauseCellSize) / (pauseCellSize * 3)) % 3;
      int i = ((menuClickY - pauseCellSize) / (pauseCellSize * 9)) % 3;
      
      nextMap[i][j][k] = (nextMap[i][j][k] + 1) % 3;
      
      println(mapString());
    }
  }
}

void mousePressed() {
  if (paused) {
    int menuClickX = mouseX - menuX;
    int menuClickY = mouseY - menuY;
    
    int dragBoxRadius = pauseCellSize;
    if (menuClickX > -dragBoxRadius && menuClickX < dragBoxRadius &&
        menuClickY > -dragBoxRadius && menuClickY < dragBoxRadius) {
          pauseMenuDragging = true;
    }
  }
}

void mouseReleased() {
  pauseMenuDragging = false;
}

void mouseDragged() {
  if (pauseMenuDragging) {
    menuX += mouseX - pmouseX;
    menuY += mouseY - pmouseY;
  }
}

void keyPressed() {
  if (key == ' ') {
    if (!paused) {
      loadPixels();
      for (int i = 0; i < pixels.length; i++) {
        pauseBuffer[i] = pixels[i];
      }
      
      menuX = 0;
      menuY = 0;
    
      paused = !paused;
    } else {
      for (int i = 0; i < pixels.length; i++) {
        pixels[i] = pauseBuffer[i];
      }
      updatePixels();
      
      paused = !paused;
    }
  } else if (!paused && key == 'r') {
    singletSeed(history, historyIndex);
  } else if (!paused && key == 'R') {
    randomizedSeed(history, historyIndex);
  }
}

void calculateNext(int[][] history, int historyIndex, int[][][] nextMap) {
  //handle history in a circular way
  int nextIndex = (historyIndex + 1) % history.length;
  int[] currentHab = history[historyIndex];
  int[] nextHab = history[nextIndex];
  
  //handle left and right edges toroidally
  nextHab[0] = nextMap[currentHab[currentHab.length-1]]
                      [currentHab[0]]
                      [currentHab[1]];
  nextHab[nextHab.length-1] = nextMap[currentHab[currentHab.length-2]]
                                     [currentHab[currentHab.length-1]]
                                     [currentHab[0]];
  
  for (int i = 1; i <= nextHab.length - 2; i++) {
    nextHab[i] = nextMap[currentHab[i-1]][currentHab[i]][currentHab[i+1]];
  }
}

void analyzeNextSpectrum(int[][] history, InformationSpectrum[] spectralHistory, int historyIndex) {
  //handle history in a circular way
  int nextIndex = (historyIndex + 1) % history.length;
  spectralHistory[nextIndex] = new InformationSpectrum(history[nextIndex]);
}

int getColor(int state) {
  if (state == 0) return #E5E5E5;
  else if (state == 1) return #2E40FC;
  else if (state == 2) return #FCAE2E;
  else return -1;
}

void singletSeed(int[][] history, int historyIndex) {
  for (int i = 0; i < history[historyIndex].length; i++) {
    history[historyIndex][i] = 0;
  }
  history[historyIndex][history[historyIndex].length/2] = 1;
}

void randomizedSeed(int[][] history, int historyIndex) {
  for (int i = 0; i < history[historyIndex].length; i++) {
    history[historyIndex][i] = (int) (Math.random() * 3);
  }
}

void makeMap(int[][][] map, long rule) {
  int i, j, k;
  i = j = k = 0;
  
  while (rule / 3L > 0) {
    map[i][j][k] = (int) (rule % 3L);
    rule = rule / 3L;
    k++;
    if (k > 2) {
      k = 0;
      j++;
    }
    if (j > 2) {
      j = 0;
      i++;
    }
    if (i > 2) {
      print("FUCKING PROBLEM");
      exit();
    }
  }
  
  k++;
  if (k > 2) {
    k = 0;
    j++;
  }
  if (j > 2) {
    j = 0;
    i++;
  }
  if (i <= 2) {
    map[i][j][k] = (int) (rule % 3L);
  }
  
  while (i<3 && j<3 && k<3) {
    map[i][j][k] = 0;
    
    k++;
    if (k > 2) {
      k = 0;
      j++;
    }
    if (j > 2) {
      j = 0;
      i++;
    }
  }
  
  println("\n" + mapString());
}

String mapString() {
  String ret = "";
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      for (int k = 0; k < 3; k++) {
        ret += nextMap[i][j][k];
      }
    }
  }
  return ret;
}
