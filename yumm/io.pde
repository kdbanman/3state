void displayError() {
  background(0);
  fill(#FFFFFF);
  textAlign(CENTER);
  textSize(14);
  text("CORRUPT :(", width/2, height/2);
  text("click to resume", width/2, 2 * height/3);
  
  noLoop();
}
