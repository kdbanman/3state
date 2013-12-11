

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
