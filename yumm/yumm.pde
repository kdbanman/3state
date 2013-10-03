color backCol = #3B3B3B;

//this shit only works on 64 bit machines because it takes
// 43 bits to describe all 3 state outer totallistic 1D
// automata
int screenWidth;
int screenHeight;
int cellSize;
int currentLine;
int maxLine;

boolean paused;
color[] pauseBuffer;
int pauseCellSize;

int habSize;

// cells are 0, 1, or 2
int[] hab;
int[] nextHab;

// 27 possible nbrhood states
//  --> 7625597484987 possible rulesets
//  --> range is 0L to 7625597484986L
// this number might actually correspond reversed rule map...
long initialRule = 214582522525L;
int[][][] nextMap;

void setup() {
  screenWidth = 500;
  screenHeight = 900;
  cellSize = 2;
  
  size(screenWidth, screenHeight);
  currentLine = 0;
  maxLine = screenHeight / cellSize - 1;
  habSize = screenWidth / cellSize;
  
  paused = false;
  pauseBuffer = new color[screenWidth * screenHeight];
  pauseCellSize = 30;
  
  hab = new int[habSize];
  seed();
  nextHab = new int[habSize];
  
  nextMap = new int[3][3][3];
  makeMap(nextMap, initialRule);
  
  noStroke();
  background(backCol);
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

void calculateNext(int[] hab, int[] nextHab, int[][][] nextMap) {
  //handle left and right edges toroidally
  nextHab[0] = nextMap[hab[hab.length-1]][hab[0]][hab[1]];
  nextHab[nextHab.length-1] = nextMap[hab[hab.length-2]][hab[hab.length-1]][hab[0]];
  
  for (int i = 1; i <= hab.length - 2; i++) {
    nextHab[i] = nextMap[hab[i-1]][hab[i]][hab[i+1]];
  }
}

void swapFromNext(int[] hab, int[] nextHab) {
  for (int i = 0; i < hab.length; i++) {
    hab[i] = nextHab[i];
  }
}

int getColor(int state) {
  if (state == 0) return #E5E5E5;
  else if (state == 1) return #2E40FC;
  else if (state == 2) return #FCAE2E;
  else return -1;
}

void renderLine(int line, int[] hab, int cellSize) {
  for (int i = 0; i < hab.length; i++) {
    if (hab[i] == 0) fill(#E5E5E5);
    else if (hab[i] == 1) fill(#2E40FC);
    else if (hab[i] == 2) fill(#FCAE2E);
    rect(i * cellSize, line * cellSize, cellSize, cellSize);
  }
}

void seed() {
  for (int i = 0; i < hab.length; i++) {
    hab[i] = 0;
  }
  hab[hab.length/2] = 1;
}

void newDraw() {
  currentLine = 0;
  background(#E5E5E5);
  frameRate(60);
}

void restart() {
  seed();
  newDraw();
}

void draw() {
  if (!paused) {
    calculateNext(hab, nextHab, nextMap);
    swapFromNext(hab, nextHab);
    
    if (currentLine <= maxLine) {
      renderLine(currentLine, hab, cellSize);
      currentLine++;
    } else {
      try {
        save(mapString() + ".tif");
      } catch (Exception e) {
        print("ERROR: save failed.");
      }
      restart();
    }
  } else {
    // NEIGHBORHOOD TRIPLE OFFSETS
    int xOff = pauseCellSize;
    int yOff = pauseCellSize;
    
    fill(backCol);
    rect(0, 0, 13*pauseCellSize, 28*pauseCellSize, 15);
    
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
        xOff = pauseCellSize;
      }
    }
  }
}

void mouseClicked() {
  if (paused) {
    if (mouseX > pauseCellSize && mouseX < 12*pauseCellSize &&
        mouseY > pauseCellSize && mouseY < 27*pauseCellSize) {
      int k = (mouseX - pauseCellSize) / (pauseCellSize * 4);
      int j = ((mouseY - pauseCellSize) / (pauseCellSize * 3)) % 3;
      int i = ((mouseY - pauseCellSize) / (pauseCellSize * 9)) % 3;
      
      nextMap[i][j][k] = (nextMap[i][j][k] + 1) % 3;
      
      println(mapString());
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    if (!paused) {
      loadPixels();
      for (int i = 0; i < pixels.length; i++) {
        pauseBuffer[i] = pixels[i];
      }
        
      paused = !paused;
    } else {
      for (int i = 0; i < pixels.length; i++) {
        pixels[i] = pauseBuffer[i];
      }
      updatePixels();
      
      paused = !paused;
    }
  } else if (!paused && (key == 'r' || key == 'R')) {
    restart();
  }
}
