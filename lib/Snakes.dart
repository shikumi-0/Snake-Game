import 'dart:math';
import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class Snake extends StatefulWidget {
  @override
  _SnakeState createState() => _SnakeState();
}

class _SnakeState extends State<Snake> {
  int speed = 6;
  final int squarePerRow = 20;
  final int squarePerCol = 40;
  final fontStyle = TextStyle(color: Colors.white, fontSize: 30);
  var randomGenerator = Random();
  var snake = [
    [0, 1],
    [0, 0]
  ];
  var food = [0, 2];
  var direction = 'up';
  var isPlaying = false;

// To Start game
  void startGame() {
//      set the speed of the snake
    var duration = Duration(milliseconds: speed * 50);
//      snake starting from the center
    snake = [
      [(squarePerRow / 2).floor(), (squarePerCol / 2).floor()]
    ];
    snake.add([snake.first[0], snake.first[1] - 1]);
//      create food again
    createFood();
    isPlaying = true;
    Timer.periodic(duration, (Timer timer) {
      moveSnake();
      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
    });
  }

// Generating food randomly
  void createFood() {
    food = [
      randomGenerator.nextInt(squarePerRow),
      randomGenerator.nextInt(squarePerCol),
    ];
  }

// To move snake
  void moveSnake() {
    setState(() {
      switch (direction) {
        case 'up':
          snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          break;

        case 'down':
          snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          break;

        case 'right':
          snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          break;
        case 'left':
          snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          break;
      }
      if (snake.first[0] != food[0] || snake.first[1] != food[1]) {
        snake.removeLast();
      } else {
        createFood();
      }
    });
  }

// to check game status

  bool checkGameOver() {
    if (!isPlaying ||
        snake.first[1] < 0 ||
        snake.first[1] >= squarePerCol ||
        snake.first[0] < 0 ||
        snake.first[0] > squarePerRow) {
      return true;
    }

    for (var i = 1; i < snake.length; ++i) {
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1])
        return true;
    }
    return false;
  }

//  method to end game
  void endGame() {
    isPlaying = false;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Score: ${snake.length - 2}',
              style: TextStyle(fontSize: 20),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Color(0xffb61827).withOpacity(0.5)),
                    color: Colors.transparent),
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (direction != 'up' && details.delta.dy > 0) {
                      direction = 'down';
                    } else if (direction != 'down' && details.delta.dy < 0) {
                      direction = 'up';
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (direction != 'left' && details.delta.dx > 0) {
                      direction = 'right';
                    } else if (direction != 'right' && details.delta.dx < 0) {
                      direction = 'left';
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: squarePerRow / (squarePerCol + 2),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: squarePerRow),
                      itemBuilder: (BuildContext context, int index) {
                        var color;
                        var x = index % squarePerRow;
                        var y = (index / squarePerRow).floor();
                        bool isSnakeBody = false;
                        for (var pos in snake) {
                          if (pos[0] == x && pos[1] == y) {
                            isSnakeBody = true;
                            break;
                          }
                        }
                        if (snake.first[0] == x && snake.first[1] == y) {
                          color = Color(0xff18ffff);
                        } else if (isSnakeBody) {
                          color = Color(0xff76ffff);
                        } else if (food[0] == x && food[1] == y) {
                          color = Colors.red;
                        } else {
                          color = Colors.transparent;
                        }
                        return Container(
                          margin: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        );
                      },
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: squarePerRow * squarePerCol,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                          color:
                              isPlaying ? Color(0xffff5252) : Color(0xff4db6ac),
                          borderRadius: BorderRadius.circular(5)),
                      child: FlatButton(
                        onPressed: () {
                          if (isPlaying) {
                            isPlaying = false;
                          } else {
                            startGame();
                          }
                        },
                        child: Text(isPlaying ? 'End' : 'Start',
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Text(
                      'Score: ${snake.length - 2}',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Column(
                      children: [
                        Text(
                          'Speed',
                          style: TextStyle(color: Colors.white),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                                icon: Icon(Icons.keyboard_arrow_up,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    if (speed > 1) {
                                      speed--;
                                      print(speed);
                                    }
                                  });
                                }),
                            IconButton(
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    speed++;
                                    print(speed);
                                  });
                                }),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
