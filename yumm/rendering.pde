

int getColor(int state) {
//  if (state == 0) return #E5E5E5;
//  else if (state == 1) return #2E40FC;
//  else if (state == 2) return #FCAE2E;
  if (state == 0) return #EBFF9D;
  else if (state == 1) return #FFB79D;
  else if (state == 2) return #9DD9FF;
  else return -1;
}

void renderHistory(int[][] history, InformationSpectrum[] spectralHistory, int historyIndex, int cellSize) {
  for (int i = 0; i < history.length; i++) {
    int circularIndex = (historyIndex + i + 1) % history.length;
    renderLine(i, history[circularIndex], cellSize);
    renderSpectrumLine(i, spectralHistory[circularIndex], cellSize, history[0].length * cellSize);
  }
}

void renderLine(int line, int[] hab, int cellSize) {
  for (int j = 0; j < hab.length; j++) {
    fill(getColor(hab[j]));
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

void renderRuleMenu(int[][][] ruleFrequency) {
  fill(backCol);
    rect(menuX, menuY, 13*pauseCellSize, 28*pauseCellSize, 15);
          
    int xOff = menuX + pauseCellSize;
    int yOff = menuY + pauseCellSize;
    
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          
          // render background square
          int intensity = 43 + ruleFrequency[i][j][k] * 3;
          fill(intensity, intensity, intensity);
          rect(xOff - pauseCellSize / 2, yOff - pauseCellSize / 2, pauseCellSize * 4, pauseCellSize * 3, 4);
          
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
    
    // render drag handle
    fill(#C8C8C8);
    ellipse(menuX + pauseCellSize / 3, menuY + pauseCellSize / 3, 2 * pauseCellSize / 3, 2 * pauseCellSize / 3);
    fill(backCol);
    ellipse(menuX + pauseCellSize / 3, menuY + pauseCellSize / 3, pauseCellSize / 6, pauseCellSize / 2);
    ellipse(menuX + pauseCellSize / 3, menuY + pauseCellSize / 3, pauseCellSize / 2, pauseCellSize / 6);
}
