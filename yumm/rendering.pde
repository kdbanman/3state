int getColor(int state) {
  if (state == 0) return #4c9897;
  else if (state == 1) return #a48f50;
  else if (state == 2) return #7c110e;
  else return 0;
}

void renderHistory(int[][] history, InformationSpectrum[] spectralHistory, int historyIndex, int renderedHistory, int cellSize) {
  for (int i = 0; i < renderedHistory; i++) {
    int circularIndex = (historyIndex - i) % history.length;
    circularIndex = circularIndex < 0 ? history.length + circularIndex : circularIndex;
    renderLine(renderedHistory - i, history[circularIndex], cellSize);
    renderSpectrumLine(renderedHistory - i, spectralHistory[circularIndex], cellSize, history[0].length * cellSize);
  }
}

void renderLine(int line, int[] hab, int cellSize) {
  for (int j = 0; j < hab.length; j++) {
    fill(getColor(hab[j]));
    rect(j * cellSize, line * cellSize, cellSize, cellSize);
  }
}

void renderSpectrumLine(int line, InformationSpectrum spectrum, int cellSize, int horizOffset) {
  for (int j = spectrum.getMinBlockSize(); j <= spectrum.getMaxBlockSize(); j++) {
    int intensity = (int) (255.0 * ((float) spectrum.getBlockSizeFrequency(j)) / ((float) spectrum.getMaxBlockSize()));
    fill(intensity, intensity, intensity);
    int cellWidth = spectrum.isContiguous() ? cellSize * 2 : cellSize;
    rect(horizOffset + j * cellWidth, line * cellSize, cellWidth, cellSize);
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
          
          // render background squares
          int intensity = 43 + ruleFrequency[i][j][k] * 3;
          fill(intensity, intensity, intensity);
          rect(xOff - pauseCellSize / 2, yOff - pauseCellSize / 2, pauseCellSize * 4, pauseCellSize * 3, 4);
          fill(backCol);
          rect(xOff - pauseCellSize / 6, yOff - pauseCellSize / 6, 20 * pauseCellSize / 6, 14 * pauseCellSize / 6, 4);
          
          // render mouse highlight
          if (mouseX > xOff - pauseCellSize / 2 && mouseX < xOff + 7 * pauseCellSize / 2 &&
              mouseY > yOff - pauseCellSize / 2 && mouseY < yOff + 5 * pauseCellSize / 2) stroke(#FFFFFF);
              
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
          
          noStroke();
          
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

void renderCellViewScope() {
  int leftBound = mouseX - scopeWidth * cellSize < 0 ? 0 : mouseX - scopeWidth * cellSize;
  int rightBound = mouseX + scopeWidth * cellSize > cellViewWidth - 1 ? cellViewWidth - 1 : mouseX + scopeWidth * cellSize;
  int topBound = mouseY  - scopeHeight * cellSize < 0 ? 0 : mouseY - scopeHeight * cellSize;
  int bottomBound = mouseY + scopeHeight * cellSize > height - 1 ? height - 1 : mouseY + scopeHeight * cellSize;
  
  for (int i = leftBound; i <= rightBound; i++) {
    for (int j = topBound; j <= bottomBound; j++) {
      fill(pixels[i + width * j]);
      if (i == mouseX && j == mouseY) fill(backCol);
      rect(cellViewWidth + 2 * cellSize + (i - leftBound) * scopeMagnification, (j - mouseY) * scopeMagnification + mouseY, scopeMagnification, scopeMagnification, 1);
    }
  }
}
