//this shit only works on 64 bit machines because it takes
// 43 bits to describe all 3 state outer totallistic 1D
// automata
int screenSize;
int cellSize;
int currentLine;
int maxLine;

int habSize;

// cells are 0, 1, or 2
int[] hab;
int[] nextHab;

// 27 possible nbrhood states
//  --> 7625597484987 possible rulesets
//  --> range is 0L to 7625597484986L
// this number might actually correspond reversed rule map...
long rule = 2445825251252L;
int[][][] nextMap;

void setup() {
  screenSize = 1000;
  cellSize = 5;
  
  size(screenSize, screenSize);
  currentLine = 0;
  maxLine = screenSize / cellSize - 1;
  habSize = screenSize / cellSize;
  
  hab = new int[habSize];
  hab[habSize/2] = 1;
  nextHab = new int[habSize];
  
  nextMap = new int[3][3][3];
  makeMap(nextMap, rule);
  
  noStroke();
  background(#E5E5E5);
}

void makeMap(int[][][] map, long rule) {
  int i, j, k;
  i = j = k = 0;
  
  while (rule / 3L > 0) {
    map[i][j][k] = (int) (rule % 3L);
    print(map[i][j][k]);
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
    print(map[i][j][k]);
  }
  
  while (i<3 && j<3 && k<3) {
    map[i][j][k] = 0;
    print(map[i][j][k]);
    
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

void renderLine(int line, int[] hab, int cellSize) {
  for (int i = 0; i < hab.length; i++) {
    if (hab[i] == 0) fill(#E5E5E5);
    else if (hab[i] == 1) fill(#2E40FC);
    else if (hab[i] == 2) fill(#FCAE2E);
    rect(i * cellSize, line * cellSize, cellSize, cellSize);
  }
}

void draw() {
  calculateNext(hab, nextHab, nextMap);
  swapFromNext(hab, nextHab);
  
  if (currentLine <= maxLine) {
    renderLine(currentLine, hab, cellSize);
    currentLine++;
  } else {
    frameRate(0);
  }
}
