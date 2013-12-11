
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
