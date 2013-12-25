

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
  spectralHistory[nextIndex] = new InformationSpectrum(history[nextIndex], spectralHistory[nextIndex].isContiguous());
}

void updateRuleFrequency(int[][][] ruleFrequency, int[][] history, int historyIndex) {
  for (int i = 0; i < 3; i ++) {
    for (int j = 0; j < 3; j++) {
      for (int k = 0; k < 3; k++) {
       ruleFrequency[i][j][k] = 4 * ruleFrequency[i][j][k] / 5;
      }
    }
  }
  for (int i = 0; i < history[0].length; i++) {
    int left = history[historyIndex][i];
    int mid = history[historyIndex][(i+1) % history[0].length];
    int right = history[historyIndex][(i+2) % history[0].length];
    ruleFrequency[left][mid][right] = ruleFrequency[left][mid][right] + 1;
  }
}
