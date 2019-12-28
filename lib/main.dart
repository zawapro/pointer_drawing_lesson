import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 状態クラス　タッチされた点を記録する
class PointState extends ChangeNotifier {
  final _points = List<Offset>();

  // 変更不能なリストのビュー
  UnmodifiableListView<Offset> get points => UnmodifiableListView(_points);

  void add(Offset offset) {
    _points.add(offset);
    notifyListeners();
  }

  void clear() {
    _points.clear();
    notifyListeners();
  }
}

// ChangeNotifierProviderでアプリ全体をラップする
// その子WidgetはProvider.of()で状態にアクセスできる
void main() => runApp(ChangeNotifierProvider(
      create: (_) => PointState(),
      child: MaterialApp(
        title: 'Pointer drawing lesson',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: PointerDrawingWidget(title: 'Pointer drawing lesson'),
      ),
    ));

class PointerDrawingWidget extends StatelessWidget {
  PointerDrawingWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    // 状態の取得
    // 状態が変化したことにより、リビルドが必要なのはCustomPaintのみのため、
    // ここではlisten:falseを指定し、 Scaffold全体がリビルドされるのを回避する
    final pointState = Provider.of<PointState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GestureDetector(
        // TapDownイベントを検知
        onTapDown: (TapDownDetails details) {
          // タッチされた点を追加して状態を更新する
          pointState.add(details.localPosition);
        },
        // 状態のConsumer
        // 状態の変化が通知されると、リビルドされる
        child: Consumer<PointState>(
          builder: (BuildContext context, PointState value, Widget _) {
            // カスタムペイント
            return CustomPaint(
              painter: MyPainter(value.points),
              // タッチを有効にするため、childが必要
              child: Center(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // タッチした点をクリアする
        onPressed: pointState.clear,
        tooltip: 'Clear',
        child: Icon(Icons.clear),
      ),
    );
  }
}

// 描画クラス
class MyPainter extends CustomPainter {
  final List<Offset> _points;
  final _rectPaint = Paint()..color = Colors.blue;

  MyPainter(this._points);

  @override
  void paint(Canvas canvas, Size size) {
    // 記憶している点を描画する
    _points.forEach((offset) => canvas.drawRect(
        Rect.fromCenter(center: offset, width: 20.0, height: 20.0),
        _rectPaint));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
