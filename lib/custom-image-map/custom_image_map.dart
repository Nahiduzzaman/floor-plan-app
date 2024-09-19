import 'package:flutter/material.dart';

import 'image_map_object.dart';
import 'image_map_zoom_container.dart';

class CustomImageMap extends StatelessWidget {
  const CustomImageMap({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      child: ImageMapZoomContainer(
        zoomLevel: 0.5,
        imageProvider: Image.asset(
          "assets/map.png",
        ).image,
        objects: [
          ImageMapObject(
            child: Container(
              color: Colors.amberAccent,
            ),
            offset: const Offset(0, 0),
            size: const Size(10, 10),
          ),
        ],
      ),
    );
  }
}
