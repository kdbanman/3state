import infospect.InformationSpectrum;

color backCol = #1c1c1c;

int habSize = 60;
int cellSize = 5;
int renderedHistory = 160;

int pauseCellSize = 19;

int scopeMagnification = pauseCellSize / cellSize;
int scopeWidth = 8;
int scopeHeight = 6;

int framerate = 24;
int historySize = 160;

boolean contiguousSpectrum = true;

boolean freezeForError = false;

// cells are 0, 1, or 2
// history is a circular buffer of habitats
int[][] history;
int historyIndex;
int historyIndexBeforePause;

int[][][] ruleFrequency;

InformationSpectrum[] spectralHistory;
InformationSpectrum[] contiguousSpectralHistory;

int cellViewWidth;

boolean paused;
int menuX;
int menuY;
boolean menuDragging;

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
  contiguousSpectralHistory = new InformationSpectrum[historySize];
  
  //initialize spectra
  println("loading");
  int prev = 0;
  for (int i = 0; i < historySize; i++) {
    spectralHistory[i] = new InformationSpectrum(history[i], false);
    contiguousSpectralHistory[i] = new InformationSpectrum(history[i], true);
    
    // print progress
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
    analyzeNextSpectrum(history, contiguousSpectralHistory, historyIndex);
    historyIndex = (historyIndex + 1) % history.length;
  }
  //render
  if (contiguousSpectrum) {
    renderHistory(history,  contiguousSpectralHistory, historyIndex, renderedHistory, cellSize);
  } else {
    renderHistory(history,  spectralHistory, historyIndex, renderedHistory, cellSize);
  }
  
  // highlight history if it is moused over
  if (mouseX > cellViewWidth + 2 * cellSize) {
    int menuButtonsClickX = mouseX - menuX + pauseCellSize / 2;
    int menuButtonsClickY = mouseY - menuY + pauseCellSize / 2;
    if (menuButtonsClickX <= pauseCellSize || menuButtonsClickX >= 13*pauseCellSize ||
      menuButtonsClickY <= pauseCellSize || menuButtonsClickY >= 28*pauseCellSize) {
        fill(0x2200FF79);
        rect(cellViewWidth + 2 * cellSize, 0, width - (cellViewWidth + 2 * cellSize), height);
    }
  }
  
  // load pixels before menu has been rendered to look underneath it
  loadPixels();
  renderRuleMenu(ruleFrequency);
  
  if (mouseX < cellViewWidth && !menuDragging) {
    renderCellViewScope();
  }
}

void mouseClicked() {
  int menuButtonsClickX = mouseX - menuX + pauseCellSize / 2;
  int menuButtonsClickY = mouseY - menuY + pauseCellSize / 2;
  
  if (menuButtonsClickX > pauseCellSize && menuButtonsClickX < 13*pauseCellSize &&
      menuButtonsClickY > pauseCellSize && menuButtonsClickY < 28*pauseCellSize) {
    int k = (menuButtonsClickX - pauseCellSize) / (pauseCellSize * 4);
    int j = ((menuButtonsClickY - pauseCellSize) / (pauseCellSize * 3)) % 3;
    int i = ((menuButtonsClickY - pauseCellSize) / (pauseCellSize * 9)) % 3;
    
    nextMap[i][j][k] = (nextMap[i][j][k] + 1) % 3;
    
    println(mapString(nextMap));
  } else if (mouseX > cellViewWidth + 2 * cellSize ) {
    contiguousSpectrum = !contiguousSpectrum;
  }
}

void mousePressed() {
  int menuClickX = mouseX - menuX;
  int menuClickY = mouseY - menuY;
  
  // determine if the mouse was pressed within the menu drag handle
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

void mouseWheel(MouseEvent event) {
  if (paused) {
    
    int beforeScroll = historyIndex;
    historyIndex += ((int) event.getAmount()) % history.length;
    
    // clamp scroll to bottom of screen at index before pause
    if (beforeScroll <= historyIndexBeforePause && 
        historyIndex > historyIndexBeforePause)
          historyIndex = historyIndexBeforePause;
    
    //clamp scroll to top of screen at index before pause + 1
    int screenTopBeforeScroll = beforeScroll - renderedHistory;
    int screenTopAfterScroll = historyIndex - renderedHistory;
    
    if (screenTopBeforeScroll >= historyIndexBeforePause - history.length && 
        screenTopAfterScroll < historyIndexBeforePause - history.length)
          historyIndex = renderedHistory + historyIndexBeforePause - history.length;
  }
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
    
    if (paused) historyIndexBeforePause = historyIndex;
    else historyIndex = historyIndexBeforePause;
    
  } else if (!paused && (key == 'M' || key == 'm')) {
    singletSeed(history, historyIndex);
  } else if (!paused && (key == 'R' || key == 'r')) {
    randomizedSeed(history, historyIndex);
  }
}

