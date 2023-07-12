import 'package:flutter/material.dart';
import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';
import 'package:lecle_yoyo_player/src/model/m3u8.dart';

class VideoQualityPicker extends StatelessWidget {
  final List<M3U8Data> videoData;
  final bool showPicker;
  final double? positionRight;
  final double? positionTop;
  final double? positionLeft;
  final double? positionBottom;
  final VideoStyle videoStyle;
  final void Function(M3U8Data data)? onQualitySelected;

  const VideoQualityPicker({
    Key? key,
    required this.videoData,
    this.videoStyle = const VideoStyle(),
    this.showPicker = false,
    this.positionRight,
    this.positionTop,
    this.onQualitySelected,
    this.positionLeft,
    this.positionBottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showPicker,
      child: Positioned(
        right: positionRight,
        top: positionTop,
        left: positionLeft,
        bottom: positionBottom,
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: videoStyle.qualityOptionsMargin ??
                const EdgeInsets.only(
                  right: 8.0,
                  bottom: 75.0,
                ),
            decoration: BoxDecoration(
              color: videoStyle.qualityOptionsBgColor ?? Colors.grey,
              borderRadius:
                  videoStyle.qualityOptionsRadius ?? BorderRadius.circular(4.0),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                    videoData.length,
                    (index) => Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: index == 0
                                ? BorderRadius.only(
                                    topLeft: videoStyle
                                            .qualityOptionsRadius?.topLeft ??
                                        const Radius.circular(4.0),
                                    topRight: videoStyle
                                            .qualityOptionsRadius?.topRight ??
                                        const Radius.circular(4.0),
                                  )
                                : index == videoData.length - 1
                                    ? BorderRadius.only(
                                        bottomLeft: videoStyle
                                                .qualityOptionsRadius
                                                ?.bottomLeft ??
                                            const Radius.circular(4.0),
                                        bottomRight: videoStyle
                                                .qualityOptionsRadius
                                                ?.bottomRight ??
                                            const Radius.circular(4.0),
                                      )
                                    : BorderRadius.zero,
                            onTap: () {
                              onQualitySelected?.call(videoData[index]);
                            },
                            child: Container(
                              padding: videoStyle.qualityOptionsPadding ??
                                  const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                              alignment: Alignment.center,
                              width: videoStyle.qualityOptionWidth,
                              child: Text(
                                "${videoData[index].dataQuality}",
                                style: videoStyle.qualityOptionStyle,
                              ),
                            ),
                          ),
                        )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
