import infospect.InformationSpectrum;

color backCol = #3B3B3B;

int habSize = 100;
int cellSize = 4;
int historySize = 200;

int pauseCellSize = 20;

int currentLine;
int maxLine;

boolean paused;
int menuX;
int menuY;
boolean pauseMenuDragging;

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
int[][][] nextMap;

void setup() {
  int cellViewWidth = habSize * cellSize;
  int spectrumViewWidth = (habSize - 2) * cellSize;
  
  int screenWidth = cellViewWidth + spectrumViewWidth;
  int screenHeight = cellSize * historySize;
  
  size(screenWidth, screenHeight);
  
  paused = false;
  int menuWidth = pauseCellSize * 13;
  menuX = screenWidth - menuWidth;
  menuY = 0;
  pauseMenuDragging = false;
  
  history = new int[historySize][habSize];
  historyIndex = 0;
  randomizedSeed(history, historyIndex);
  
  ruleFrequency = new int[3][3][3];
  
  spectralHistory = new InformationSpectrum[historySize];
  
  print("loading...");
  for (int i = 0; i < historySize; i++) {
    spectralHistory[i] = new InformationSpectrum(history[i]);
    print(".");
  }
  print("\n");
  
  nextMap = new int[3][3][3];
  makeMap(nextMap, initialRule);
  
  noStroke();
  background(backCol);
  frameRate(24);
}

void draw() {
  background(backCol);

  if (!paused) {
    updateRuleFrequency(ruleFrequency, history, historyIndex);
    calculateNext(history, historyIndex, nextMap);
    analyzeNextSpectrum(history, spectralHistory, historyIndex);
    historyIndex = (historyIndex + 1) % history.length;
  }
  renderHistory(history,  spectralHistory, historyIndex, cellSize);
  
  renderRuleMenu(ruleFrequency);
}

void mouseClicked() {
  int buttonsClickX = mouseX - menuX + pauseCellSize / 2;
  int buttonsClickY = mouseY - menuY + pauseCellSize / 2;
  
  if (buttonsClickX > pauseCellSize && buttonsClickX < 12*pauseCellSize &&
      buttonsClickY > pauseCellSize && buttonsClickY < 27*pauseCellSize) {
    int k = (buttonsClickX - pauseCellSize) / (pauseCellSize * 4);
    int j = ((buttonsClickY - pauseCellSize) / (pauseCellSize * 3)) % 3;
    int i = ((buttonsClickY - pauseCellSize) / (pauseCellSize * 9)) % 3;
    
    nextMap[i][j][k] = (nextMap[i][j][k] + 1) % 3;
    
    println(mapString());
  }
}

void mousePressed() {
  int menuClickX = mouseX - menuX;
  int menuClickY = mouseY - menuY;
  
  int dragBoxRadius = pauseCellSize;
  if (menuClickX > -dragBoxRadius && menuClickX < dragBoxRadius &&
      menuClickY > -dragBoxRadius && menuClickY < dragBoxRadius) {
        pauseMenuDragging = true;
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
    paused = !paused;
  } else if (!paused && key == 'r') {
    singletSeed(history, historyIndex);
  } else if (!paused && key == 'R') {
    randomizedSeed(history, historyIndex);
  }
}

