final int SIZE = 50;
final int STONE_SIZE = (int)(SIZE*0.7);
final int NONE = 0;
final int BLACK = 1;
final int WHITE = 2;

int[][] field;

// 盤面評価
int [][] value = {{120, -10, 20, 5, 5, 20, -10, 120},
                    {-10, -20, -5, -5, -5, -5, -20, -10},
                    {20, -5, 15, 3, 3, 15, -5, 20},
                   { 5, -15, 3, 3, 3, 3, -5, 5},
                    {5, -15, 3, 3, 3, 3, -5, 5},
                    {20, -5, 15, 3, 3, 15, -5, 20},
                    {-10, -20, -5, -5, -5, -5, -20, -10},
                  {120, -10, 20, 5, 5, 20, -10, 120}};
boolean[][] visited;
boolean black_turn = true;
int num;
int min_num = 10;

void setup() {
  size(400, 400);//8*SIZE,8*SIZE);
  field = new int[8][8];
  visited = new boolean [8][8];
  for (int i=0; i<8; ++i) {
    for (int j=0; j<8; ++j) {
      field[i][j] = NONE;
      visited[i][j] = false;
    }
  }
     
                    
  

  initialization();
}

void draw() {

  background(0, 128, 0);

  // lines
  stroke(0);
  for (int i=1; i<8; ++i) {
    line(i*SIZE, 0, i*SIZE, height);
    line(0, i*SIZE, width, i*SIZE);
  }


  // draw stones
  noStroke();
  for (int i=0; i<8; i++) {
    for (int j=0; j<8; j++) {

      if (field[i][j]==BLACK) {
        fill(0);  //color black
        ellipse((i*2+1)*SIZE/2, (j*2+1)*SIZE/2, STONE_SIZE, STONE_SIZE);
      } else if (field[i][j]==WHITE) {
        fill(255); // color white
        ellipse((i*2+1)*SIZE/2, (j*2+1)*SIZE/2, STONE_SIZE, STONE_SIZE);
      }
    }
  }
}

boolean inside(int x, int y) {
  if (x >= 0 && x<=7 && y>=0 && y<=7) {
    return true;
  } else return false;
}

// 各方向のチェックと石を返す処理
boolean check_direction(int x, int y, int vecx, int vecy) {
  if (inside(x+vecx, y+vecy)) {
    if (black_turn) {
      if (field[x+vecx][y+vecy] == NONE) {
        return false;
      } else if (field[x+vecx][y+vecy] == WHITE) {
        boolean reverse_able = check_direction(x+vecx, y+vecy, vecx, vecy);
        //println(reverse_able);
        //println("a：", vecx, vecy, ":", field[x+vecx][y+vecy], ",", x+vecx, y+vecy, ":", field[x][y] );
        if (reverse_able) {
          field[x+vecx][y+vecy] = BLACK;
        }
        return reverse_able;
      } else if (field[x+vecx][y+vecy] == BLACK && field[x][y] == WHITE) {
        //println("b：", x+vecx, y+vecy, ":", field[x+vecx][y+vecy], ",", x, y, ":", field[x][y]);
        field[x][y] = BLACK;
        return true;
      } else return false;
    } else {
      if (field[x+vecx][y+vecy] == NONE) {
        return false;
      } else if (field[x+vecx][y+vecy] == BLACK) {
        boolean reverse_able = check_direction(x+vecx, y+vecy, vecx, vecy);
        //print(reverse_able);
        if (reverse_able) {
          field[x+vecx][y+vecy] = WHITE;
        }
        return reverse_able;
      } else if (field[x+vecx][y+vecy] == WHITE && field[x][y] == BLACK) {
        field[x][y] = WHITE;
        return true;
      } else return false;
    }
  } else return false;
}

//置く場所があるだけを確認
boolean check_only_direction(int x, int y, int vecx, int vecy) {
  if (inside(x+vecx, y+vecy)) {
    if (black_turn) {
      if (field[x+vecx][y+vecy] == NONE) {
        return false;
      } else if (field[x+vecx][y+vecy] == WHITE) {
        return check_only_direction(x+vecx, y+vecy, vecx, vecy);
      } else if (field[x+vecx][y+vecy] == BLACK && field[x][y] == WHITE) {
        return true;
      } else return false;
    } else {
      if (field[x+vecx][y+vecy] == NONE) {
        return false;
      } else if (field[x+vecx][y+vecy] == BLACK) {
        return check_only_direction(x+vecx, y+vecy, vecx, vecy);
      } else if (field[x+vecx][y+vecy] == WHITE && field[x][y] == BLACK) {
        return true;
      } else return false;
    }
  } else return false;
} 

// 開放度
int check_open(int x, int y) {
  for (int i=-1; i<=1; i++) { 
    for (int j=-1; j<=1; j++) {
      if (inside(x+i, y+j)) {
        if (field[x+i][y+j] == NONE && !visited[x+i][y+j]) {
          num++;
;          visited[x+i][y+j] = true;
        }
      }
    }
  }
  return num;
}


boolean can_put_here(int x, int y) {
  boolean put = false;
  if (field[x][y]==NONE) {

    boolean left = check_direction(x, y, -1, 0);
    boolean right = check_direction(x, y, 1, 0);
    boolean top = check_direction(x, y, 0, -1);
    boolean under = check_direction(x, y, 0, 1);
    boolean left_top = check_direction(x, y, -1, -1);
    boolean right_top = check_direction(x, y, 1, -1);
    boolean left_under = check_direction(x, y, -1, 1);
    boolean right_under = check_direction(x, y, 1, 1);
    if (left||right||top||under||left_top||right_top||left_under||right_under) 
    {
      put = true;
    }
  } else return false;
  //print(put);
  return put;
}

//開放度を調べてる
boolean check_only_open(int x, int y, int vecx, int vecy) {
  if (inside(x+vecx, y+vecy)) {
    if (field[x+vecx][y+vecy] == NONE) {
      return false;
    } else if (field[x+vecx][y+vecy] == BLACK) {
      boolean reverse_able = check_only_open(x+vecx, y+vecy, vecx, vecy);
      if (reverse_able) {
          check_open(x+vecx, y+vecy);
       //check_open(x+vecx, y+vecy);
      }
      return reverse_able;
    } else if (field[x+vecx][y+vecy] == WHITE && field[x][y] == BLACK) {
      return true;
    } else return false;
  } else return false;
} 


boolean only_open(int x, int y) {
  boolean put = false;
  if (field[x][y]==NONE) {

    boolean left = check_only_open(x, y, -1, 0);
    boolean right = check_only_open(x, y, 1, 0);
    boolean top = check_only_open(x, y, 0, -1);
    boolean under = check_only_open(x, y, 0, 1);
    boolean left_top = check_only_open(x, y, -1, -1);
    boolean right_top = check_only_open(x, y, 1, -1);
    boolean left_under = check_only_open(x, y, -1, 1);
    boolean right_under = check_only_open(x, y, 1, 1);
    if (left||right||top||under||left_top||right_top||left_under||right_under) 
    {
      put = true;
    }
  } else return false;
  //print(put);
  return put;
}

boolean check_only(int x, int y) {
  boolean put = false;
  if (field[x][y]==NONE) {

    boolean left = check_only_direction(x, y, -1, 0);
    boolean right = check_only_direction(x, y, 1, 0);
    boolean top = check_only_direction(x, y, 0, -1);
    boolean under = check_only_direction(x, y, 0, 1);
    boolean left_top = check_only_direction(x, y, -1, -1);
    boolean right_top = check_only_direction(x, y, 1, -1);
    boolean left_under = check_only_direction(x, y, -1, 1);
    boolean right_under = check_only_direction(x, y, 1, 1);
    if (left||right||top||under||left_top||right_top||left_under||right_under) 
    {
      put = true;
    }
  } else return false;
  //print(put);
  return put;
}

boolean can_put;

void mousePressed() {
  int x = mouseX/SIZE;
  int y = mouseY/SIZE;
  if (field[x][y]==NONE) {
    if (black_turn) {

      for (int i=0; i<8; i++) { 
        for (int j=0; j<8; j++) { 
          if (check_only(i, j)) {
           can_put = check_only(i, j);
          }
        }
      }

      if (can_put) {
        if (can_put_here(x, y) && black_turn) {
          field[x][y] = BLACK;
          black_turn = !black_turn;
        }
      } else {
        black_turn = !black_turn;
      }
    }
    auto_play();
    count_stone();
  }
}

int max_x;
int max_y;

void auto_play() {
  int max_value = -100;
  if (!black_turn) {
    boolean put = false;
    
    for (int i=0; i<8; i++) { 
      for (int j=0; j<8; j++) { 

        //print(put);
        if (check_only(i, j)) {
          put = check_only(i, j);
          for (int x=0; x<8; x++) { 
            for (int y=0; y<8; y++) {  
              visited[x][y] = false;
            }
          }
          
          num = 0;
          only_open(i, j);
          
          
          if (max_value < value[i][j] - num*3) {
            
            max_value = value[i][j] - num*3;
            max_x = i;
            max_y = j;
          }
        }
      }
    }

    if (!put) {
      black_turn = !black_turn;
    }

    //println(!black_turn, can_put_here(max_x, max_y));
    if (can_put_here(max_x, max_y) && !black_turn) {
      field[max_x][max_y] = WHITE;
      black_turn = !black_turn;
      return;
    }
  }
}

void count_stone() {
  int white_stone = 0;
  int black_stone = 0;
  for (int i=0; i<8; i++) { 
    for (int j=0; j<8; j++) {
      if (field[i][j] == WHITE) {
        white_stone ++;
      } else if (field[i][j] == BLACK) {
        black_stone ++;
      }
    }
  }
  println("黒:", black_stone, "白:", white_stone);
  return ;
}




void initialization() {
  field[3][3] = WHITE;
  field[4][4] = WHITE;
  field[3][4] = BLACK;
  field[4][3] = BLACK;
}


void example() {
  field[0][2] = BLACK;
  field[1][2] = WHITE;
  field[2][2] = WHITE;
  field[2][4] = BLACK;
  field[2][5] = BLACK;
  field[2][6] = WHITE;
  field[3][1] = WHITE;
  field[4][3] = BLACK;
  field[3][6] = BLACK;
  field[3][4] = WHITE;
  field[1][5] = WHITE;
  field[1][4] = BLACK;
  field[4][3] = WHITE;
  field[4][5] = WHITE;
  field[3][5] = WHITE;
  field[6][7] = BLACK;
  field[3][5] = BLACK;
  field[4][2] = BLACK;
  field[2][4] = BLACK;
  field[5][4] = WHITE;
}
int count = 1;

void keyPressed() {

  // Pのキーが入力された時に保存
  if (key == 'p' || key == 'P') {

    // デスクトップのパスを取得
    String path  = System.getProperty("user.home") + "/Desktop/othello_3/" + count + ".jpg";

    // 保存
    save(path);

    // 番号を加算
    count++;

    // ログ用途
    println("screen saved." + path);
  }
}