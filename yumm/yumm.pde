import infospect.InformationSpectrum;

color backCol = #1c1c1c;

int habSize = 80;
int cellSize = 5;
int renderedHistory = 160;

int pauseCellSize = 19;

int scopeMagnification = pauseCellSize / cellSize;
int scopeWidth = 8;
int scopeHeight = 6;

int framerate = 24;
int historySize = 500;

boolean contiguousSpectrum = true;

int cellViewWidth;

boolean paused;
int menuX;
int menuY;
boolean menuDragging;

// cells are 0, 1, or 2
// history is a circular buffer of habitats
int[][] history;
int historyIndex;

int[][][] ruleFrequency;

InformationSpectrum[] spectralHistory;

// 27 possible nbrhood states
//  --> 7625597484987 possible rulesets
//  --> range is 0L to 7625597484986L
// this number might actually correspond reversed rule map...
// (this shit only works on 64 bit machines because it takes
// 43 bits to describe all 3 state outer totallistic 1D
// automata)
long initialRule = 214582522525L;
String stringInitialRule = "221221121220202201101122120";
int[][][] nextMap;

boolean freezeForError = false;

void setup() {
  cellViewWidth = habSize * cellSize;
  int spectrumViewWidth = (habSize - 2) * cellSize;
  
  int screenWidth = cellViewWidth + spectrumViewWidth;
  int screenHeight = cellSize * renderedHistory;
  
  size(screenWidth, screenHeight);
  
  paused = false;
  int menuWidth = pauseCellSize * 13;
  menuX = screenWidth - menuWidth;
  menuY = 0;
  menuDragging = false;
  
  history = new int[historySize][habSize];
  historyIndex = 0;
  randomizedSeed(history, historyIndex);
  
  ruleFrequency = new int[3][3][3];
  
  spectralHistory = new InformationSpectrum[historySize];
  
  println("loading");
  int prev = 0;
  for (int i = 0; i < historySize; i++) {
    spectralHistory[i] = new InformationSpectrum(history[i], contiguousSpectrum);
    if (int(float(i) / float(historySize) * 10) > prev) {
      prev++;
      println(prev * 10 + "%");
    }
  }
  println("100%");
  
  nextMap = new int[3][3][3];
  makeMap(nextMap, initialRule);
  //makeMapBase3(nextMap, stringInitialRule);
  
  noStroke();
  background(backCol);
  frameRate(framerate);
}

void draw() {
  background(backCol);

  // iterate and analyze
  if (!paused) {
    updateRuleFrequency(ruleFrequency, history, historyIndex);
    calculateNext(history, historyIndex, nextMap);
    analyzeNextSpectrum(history, spectralHistory, historyIndex);
    historyIndex = (historyIndex + 1) % history.length;
  }
  //render
  renderHistory(history,  spectralHistory, historyIndex, renderedHistory, cellSize);
  // load pixels before menu has been rendered to look underneath it
  loadPixels();
  renderRuleMenu(ruleFrequency);
  
  if (mouseX < cellViewWidth && !menuDragging) {
    renderCellViewScope();
  }
}

void mouseClicked() {
  loop();
  
  int buttonsClickX = mouseX - menuX + pauseCellSize / 2;
  int buttonsClickY = mouseY - menuY + pauseCellSize / 2;
  
  if (buttonsClickX > pauseCellSize && buttonsClickX < 13*pauseCellSize &&
      buttonsClickY > pauseCellSize && buttonsClickY < 28*pauseCellSize) {
    int k = (buttonsClickX - pauseCellSize) / (pauseCellSize * 4);
    int j = ((buttonsClickY - pauseCellSize) / (pauseCellSize * 3)) % 3;
    int i = ((buttonsClickY - pauseCellSize) / (pauseCellSize * 9)) % 3;
    
    nextMap[i][j][k] = (nextMap[i][j][k] + 1) % 3;
    
    println(mapString(nextMap));
  }
}

void mousePressed() {
  int menuClickX = mouseX - menuX;
  int menuClickY = mouseY - menuY;
  
  int dragBoxRadius = pauseCellSize;
  if (menuClickX > -dragBoxRadius && menuClickX < dragBoxRadius &&
      menuClickY > -dragBoxRadius && menuClickY < dragBoxRadius) {
        menuDragging = true;
  }
}

void mouseReleased() {
  menuDragging = false;
}

void mouseDragged() {
  if (menuDragging) {
    menuX += mouseX - pmouseX;
    menuY += mouseY - pmouseY;
  }
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  } else if (!paused && (key == 'M' || key == 'm')) {
    singletSeed(history, historyIndex);
  } else if (!paused && (key == 'R' || key == 'r')) {
    randomizedSeed(history, historyIndex);
    println("here");
  }
}

