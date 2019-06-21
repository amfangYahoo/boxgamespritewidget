import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:spritewidget/spritewidget.dart';

class BoxGame extends NodeWithSize {

  // Game screen nodes
  Node _gameScreen;
  VirtualJoystick _joystick;

  BoxNode _box;

  double _scroll = 0.0;

  BoxGame() : super(new Size(320.0, 320.0)){

    userInteractionEnabled = true;
    handleMultiplePointers = false;

    _gameScreen = new Node();
    addChild(_gameScreen);

    _joystick = new VirtualJoystick();
    _gameScreen.addChild(_joystick);

    _box = new BoxNode();
    _gameScreen.addChild(_box);

  }
  
  @override
  bool handleEvent(SpriteBoxEvent event) {
//    Offset localPosition = convertPointToNodeSpace(Offset(_box.boxRect.top, _box.boxRect.left));
//    print("localPosition:"+localPosition.toString());
    if (event.type == PointerDownEvent) {

      Offset newPoint = convertPointToNodeSpace(event.boxPosition);

      /*
       * 由于_gameScreen作为主Node，初始化为new Offset(0.0, spriteBox.visibleArea.height)，
       * 所以在对点击的位置判断是，需要把_box的位置也添加相同的偏移进行对比。
       */
      if(newPoint.dx > _box.boxRect.left &&
          newPoint.dx < _box.boxRect.left + 30 &&
          newPoint.dy > _box.boxRect.top + spriteBox.visibleArea.height &&
          newPoint.dy < _box.boxRect.top + spriteBox.visibleArea.height + 30){
        _box.onTapDown();
      }else{
        return false;
      }
    }
    return true;
  }

  @override
  void spriteBoxPerformedLayout() {
    _gameScreen.position = new Offset(0.0, spriteBox.visibleArea.height);
  }

  void update(double dt) {

    _box.applyThrust(_joystick.value);

  }
}

class BoxNode extends Node {

  bool hasWon = false;
  Rect boxRect;

  BoxNode() {
    userInteractionEnabled = true;
    handleMultiplePointers = false;
    position = new Offset(0, 0);
  }

  @override
  void paint(Canvas canvas) {
    /*
     * 基本上来讲，如果child的中点就是parent的size的中点减去偏移（前提是child的position初始化为new Offset(0, 0)。
     */
    boxRect = Rect.fromLTWH(
        spriteBox.visibleArea.height / 2 - 15,
        - spriteBox.visibleArea.height / 2 - 75,
        30,
        30,
    );
//    print("boxRect:"+boxRect.toString());
    Paint boxPaint = Paint();
    boxPaint.color = Color(0xffffffff);

    if (hasWon) {
      boxPaint.color = Color(0xff00ff00);
    } else {
      boxPaint.color = Color(0xffffffff);
    }

    canvas.drawRect(boxRect, boxPaint);
  }

  void onTapDown() {
    hasWon = !hasWon;
  }

  void applyThrust(Offset joystickValue) {

    Offset oldPos = position;
    Offset target = new Offset(joystickValue.dx * 160.0, joystickValue.dy * 220.0);
    double filterFactor = 0.2;

    position = new Offset(
        GameMath.filter(oldPos.dx, target.dx, filterFactor),
        GameMath.filter(oldPos.dy, target.dy, filterFactor));
  }
}

class BoxTest extends Node {
  @override
  void paint(Canvas canvas) {

    double radius = spriteBox.visibleArea.height / 4;
    canvas.drawCircle(
      new Offset(
          spriteBox.visibleArea.height / 2,
          - spriteBox.visibleArea.height * 3 / 4
      ),
      radius,
      new Paint()..color = Color(0xff00ff00),
    );
    print("pwidth:"+spriteBox.visibleArea.width.toString()+" -- pheight:"+spriteBox.visibleArea.height.toString());
    canvas.drawRect(
      Rect.fromLTWH(
        160 - spriteBox.visibleArea.width / 2,
        - spriteBox.visibleArea.height / 2,
        spriteBox.visibleArea.width / 2,
        spriteBox.visibleArea.height / 2,
      ),
      new Paint()..color = Color(0xff00ffff),
    );
  }
}