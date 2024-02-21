import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:zoom_widget/zoom_widget.dart' as zoom;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

/* class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
} */

class MapObject {
  final Widget child;

  ///relative offset from the center of the map for this map object. From -1 to 1 in each dimension.
  final Offset offset;

  ///size of this object for the zoomLevel == 1
  final Size? size;

  MapObject({
    required this.child,
    required this.offset,
    this.size,
  });
}

class ImageViewport extends StatefulWidget {
  final double zoomLevel;
  final ImageProvider imageProvider;
  final List<MapObject>? objects;

  ImageViewport({
    required this.zoomLevel,
    required this.imageProvider,
    this.objects,
  });

  @override
  State<StatefulWidget> createState() => _ImageViewportState();
}

class _ImageViewportState extends State<ImageViewport> {
  late double _zoomLevel;
  late ImageProvider _imageProvider;
  late ui.Image _image;
  late bool _resolved;
  late Offset _centerOffset;
  late double _maxHorizontalDelta;
  late double _maxVerticalDelta;
  late Offset _normalized;
  late bool _denormalize = false;
  late Size _actualImageSize;
  late Size _viewportSize;
  late TransformationController transformationController;

  List<MapObject>? _objects;

  double abs(double value) {
    return value < 0 ? value * (-1) : value;
  }

  void _updateActualImageDimensions() {
    _actualImageSize = Size((_image.width / View.of(context).devicePixelRatio) * _zoomLevel,
        (_image.height / View.of(context).devicePixelRatio) * _zoomLevel);
  }

  @override
  void initState() {
    super.initState();
    transformationController = TransformationController();
    _zoomLevel = widget.zoomLevel;
    _imageProvider = widget.imageProvider;
    _resolved = false;
    _centerOffset = const Offset(0, 0);
    _objects = widget.objects;
  }

  void _resolveImageProvider() {
    ImageStream stream = _imageProvider.resolve(createLocalImageConfiguration(context));
    stream.addListener(ImageStreamListener((info, _) {
      _image = info.image;
      _resolved = true;
      _updateActualImageDimensions();
      setState(() {});
    }));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImageProvider();
  }

  @override
  void didUpdateWidget(ImageViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != _imageProvider) {
      _imageProvider = widget.imageProvider;
      _resolveImageProvider();
    }
    double normalizedDx = _maxHorizontalDelta == 0 ? 0 : _centerOffset.dx / _maxHorizontalDelta;
    double normalizedDy = _maxVerticalDelta == 0 ? 0 : _centerOffset.dy / _maxVerticalDelta;
    _normalized = Offset(normalizedDx, normalizedDy);
    _denormalize = true;
    _zoomLevel = widget.zoomLevel;
    _updateActualImageDimensions();
  }

  ///This is used to convert map objects relative global offsets from the map center
  ///to the local viewport offset from the top left viewport corner.
  Offset _globaltoLocalOffset(Offset value) {
    double hDelta = (_actualImageSize.width / 2) * value.dx;
    double vDelta = (_actualImageSize.height / 2) * value.dy;
    double dx = (hDelta - _centerOffset.dx) + (_viewportSize.width / 2);
    double dy = (vDelta - _centerOffset.dy) + (_viewportSize.height / 2);
    return Offset(dx, dy);
  }

  ///This is used to convert global coordinates of long press event on the map to relative global offsets from the map center
  Offset _localToGlobalOffset(Offset value) {
    double dx = value.dx - _viewportSize.width / 2;
    double dy = value.dy - _viewportSize.height / 2;
    double dh = dx + _centerOffset.dx;
    double dv = dy + _centerOffset.dy;
    return Offset(
      dh / (_actualImageSize.width / 2),
      dv / (_actualImageSize.height / 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    void handleDrag(DragUpdateDetails updateDetails) {
      Offset newOffset = _centerOffset.translate(-updateDetails.delta.dx, -updateDetails.delta.dy);
      if (abs(newOffset.dx) <= _maxHorizontalDelta && abs(newOffset.dy) <= _maxVerticalDelta)
        setState(() {
          _centerOffset = newOffset;
        });
    }

    void addMapObject(MapObject object) => setState(() {
          _objects?.add(object);
        });

    void removeMapObject(MapObject object) => setState(() {
          _objects?.remove(object);
        });

    List<Widget> buildObjects() {
      return _objects!
          .map(
            (MapObject object) => Positioned(
              left: _globaltoLocalOffset(object.offset).dx -
                  (object.size == null ? 0 : (object.size!.width * _zoomLevel) / 2),
              top: _globaltoLocalOffset(object.offset).dy -
                  (object.size == null ? 0 : (object.size!.height * _zoomLevel) / 2),
              child: GestureDetector(
                onTapUp: (TapUpDetails details) {
                  MapObject? info;
                  info = MapObject(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(
                        width: 1,
                      )),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            child: const Text("Remove"),
                            onTap: () {
                              removeMapObject(object);
                              removeMapObject(info!);
                            },
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                            ),
                            onPressed: () => removeMapObject(info!),
                          ),
                        ],
                      ),
                    ),
                    offset: object.offset,
                    size: null,
                  );
                  addMapObject(info);
                },
                child: Container(
                  width: object.size == null ? null : object.size!.width * _zoomLevel,
                  height: object.size == null ? null : object.size!.height * _zoomLevel,
                  child: object.child,
                ),
              ),
            ),
          )
          .toList();
    }

    return _resolved
        ? LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              _viewportSize = Size(min(constraints.maxWidth, _actualImageSize.width),
                  min(constraints.maxHeight, _actualImageSize.height));
              _maxHorizontalDelta = (_actualImageSize.width - _viewportSize.width) / 2;
              _maxVerticalDelta = (_actualImageSize.height - _viewportSize.height) / 2;
              bool reactOnHorizontalDrag = _maxHorizontalDelta > _maxVerticalDelta;
              bool reactOnPan = (_maxHorizontalDelta > 0 && _maxVerticalDelta > 0);
              if (_denormalize) {
                _centerOffset = Offset(_maxHorizontalDelta * _normalized.dx, _maxVerticalDelta * _normalized.dy);
                _denormalize = false;
              }

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                /* onScaleStart: (details) {
                  debugPrint(details.toString());
                  _zoomLevel = _zoomLevel + 0;
                },
                onScaleUpdate: (details) {
                  // debugPrint(details.toString());

                  Offset newOffset = _centerOffset.translate(-details.focalPointDelta.dx, -details.focalPointDelta.dy);
                  if (abs(newOffset.dx) <= _maxHorizontalDelta && abs(newOffset.dy) <= _maxVerticalDelta)
                    setState(() {
                      _zoomLevel = _zoomLevel + 0.003;
                      _centerOffset = newOffset;
                    });
                }, */
                onPanUpdate: reactOnPan ? handleDrag : null,
                onHorizontalDragUpdate: reactOnHorizontalDrag && !reactOnPan ? handleDrag : null,
                onVerticalDragUpdate: !reactOnHorizontalDrag && !reactOnPan ? handleDrag : null,
                onLongPressEnd: (LongPressEndDetails details) {
                  RenderBox? box = context.findRenderObject() as RenderBox;
                  Offset localPosition = box.globalToLocal(details.globalPosition);
                  Offset newObjectOffset = _localToGlobalOffset(localPosition);
                  MapObject newObject = MapObject(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        color: const Color.fromARGB(255, 110, 243, 33),
                      ),
                    ),
                    offset: newObjectOffset,
                    size: const Size(10, 10),
                  );
                  debugPrint('localPosition ${localPosition}');
                  debugPrint('newObjectOffset ${newObjectOffset}');
                  debugPrint('newObject ${newObject.offset}');
                  if (_objects!.isNotEmpty) {
                    removeMapObject(_objects!.first);
                  }
                  addMapObject(newObject);
                  debugPrint(_objects![0].offset.toString());
                },
                child: Stack(
                  children: <Widget>[
                        CustomPaint(
                          size: _viewportSize,
                          painter: MapPainter(_image, _zoomLevel, _centerOffset),
                        ),
                      ] +
                      buildObjects(),
                ),
              );
            },
          )
        : const SizedBox();
  }
}

class MapPainter extends CustomPainter {
  final ui.Image image;
  final double zoomLevel;
  final Offset centerOffset;

  MapPainter(this.image, this.zoomLevel, this.centerOffset);

  @override
  void paint(Canvas canvas, Size size) {
    double pixelRatio = window.devicePixelRatio;
    Size sizeInDevicePixels = Size(size.width * pixelRatio, size.height * pixelRatio);
    Paint paint = Paint();
    paint.style = PaintingStyle.fill;
    Offset centerOffsetInDevicePixels = centerOffset.scale(pixelRatio / zoomLevel, pixelRatio / zoomLevel);
    Offset centerInDevicePixels = Offset(image.width / 2, image.height / 2)
        .translate(centerOffsetInDevicePixels.dx, centerOffsetInDevicePixels.dy);
    Offset topLeft = centerInDevicePixels.translate(
        -sizeInDevicePixels.width / (2 * zoomLevel), -sizeInDevicePixels.height / (2 * zoomLevel));
    Offset rightBottom = centerInDevicePixels.translate(
        sizeInDevicePixels.width / (2 * zoomLevel), sizeInDevicePixels.height / (2 * zoomLevel));
    canvas.drawImageRect(
      image,
      Rect.fromPoints(topLeft, rightBottom),
      Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ZoomContainer extends StatefulWidget {
  final double zoomLevel;
  final ImageProvider imageProvider;
  final List<MapObject> objects;

  const ZoomContainer({
    super.key,
    this.zoomLevel = 1,
    required this.imageProvider,
    this.objects = const [],
  });

  @override
  State<StatefulWidget> createState() => ZoomContainerState();
}

class ZoomContainerState extends State<ZoomContainer> {
  late double _zoomLevel;
  late ImageProvider _imageProvider;
  late List<MapObject> _objects;

  @override
  void initState() {
    super.initState();
    _zoomLevel = widget.zoomLevel;
    _imageProvider = widget.imageProvider;
    _objects = widget.objects;
  }

  @override
  void didUpdateWidget(ZoomContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != _imageProvider) _imageProvider = widget.imageProvider;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ImageViewport(
          zoomLevel: _zoomLevel,
          imageProvider: _imageProvider,
          objects: _objects,
        ),
        Row(
          children: <Widget>[
            IconButton(
              color: Colors.red,
              icon: const Icon(Icons.zoom_in),
              onPressed: () {
                setState(() {
                  _zoomLevel = _zoomLevel * 2;
                });
              },
            ),
            const SizedBox(
              width: 5,
            ),
            IconButton(
              color: Colors.red,
              icon: const Icon(Icons.zoom_out),
              onPressed: () {
                setState(() {
                  _zoomLevel = _zoomLevel / 2;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Move the map"),
      ),
      body: Container(
        height: 350,
        child: ZoomContainer(
          zoomLevel: 0.5,
          imageProvider: Image.asset(
            "assets/map.png",
          ).image,
          objects: [
            MapObject(
              child: Container(
                color: Colors.amberAccent,
              ),
              offset: const Offset(0, 0),
              size: const Size(10, 10),
            ),
          ],
        ),
      ),
    );
  }
}
