import 'package:flutter/material.dart';

import 'image_map_viewport.dart';
import 'image_map_object.dart';

class ImageMapZoomContainer extends StatefulWidget {
  final double zoomLevel;
  final ImageProvider imageProvider;
  final List<ImageMapObject> objects;

  const ImageMapZoomContainer({
    super.key,
    this.zoomLevel = 1,
    required this.imageProvider,
    this.objects = const [],
  });

  @override
  State<StatefulWidget> createState() => ImageMapZoomContainerState();
}

class ImageMapZoomContainerState extends State<ImageMapZoomContainer> {
  late double _zoomLevel;
  late ImageProvider _imageProvider;
  late List<ImageMapObject> _objects;

  @override
  void initState() {
    super.initState();
    _zoomLevel = widget.zoomLevel;
    _imageProvider = widget.imageProvider;
    _objects = widget.objects;
  }

  @override
  void didUpdateWidget(ImageMapZoomContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != _imageProvider) _imageProvider = widget.imageProvider;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ImageMapViewport(
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
