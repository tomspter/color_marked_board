import 'package:dart_vlc/dart_vlc.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constant.dart';

class VideoPoints extends StatelessWidget {
  const VideoPoints({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => GenerateUrl(),
        builder: (context, child) {
          return Column(
            children: <Widget>[
              Consumer<GenerateUrl>(
                builder: (_, genUrl, child) {
                  return VideoComponent(url: genUrl.getUrl);
                },
              ),
              const InputArea()
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Button(child: const Text("播放视频"), onPressed: playVideo),
              //     Button(child: const Text("关闭视频"), onPressed: stopVideo)
              //   ],
              // ),
            ],
          );
        });
  }
}

class VideoComponent extends StatefulWidget {
  const VideoComponent({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  _VideoComponentState createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
  Player player =
      Player(id: 0, videoDimensions: const VideoDimensions(640, 360));

  @override
  void didUpdateWidget(VideoComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    player.open(Media.network(widget.url), autoStart: true);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2.0,
        child: Video(
            player: player, height: 360, width: 640, showControls: true));
  }
}

class InputArea extends StatefulWidget {
  const InputArea({Key? key}) : super(key: key);

  @override
  _InputAreaState createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {
  String? videoTypeBoxValue;
  String? channelBoxValue;
  String? cdnBoxValue;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();

  List<ComboboxItem<String>> _genComboboxItem(Map constantMap) {
    return constantMap.keys
        .map((k) => ComboboxItem<String>(
              child: Text(k),
              value: constantMap[k],
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 300,
          child: Combobox<String>(
            placeholder: const Text('视频类型'),
            items: _genComboboxItem(videoTypeConstant),
            value: videoTypeBoxValue,
            onChanged: (value) {
              if (value != null) setState(() => videoTypeBoxValue = value);
            },
          ),
        ),
        SizedBox(
          width: 300,
          child: Combobox<String>(
            placeholder: const Text('频道选择'),
            items: _genComboboxItem(channelConstant),
            value: channelBoxValue,
            onChanged: (value) {
              if (value != null) setState(() => channelBoxValue = value);
            },
          ),
        ),
        SizedBox(
          width: 300,
          child: Combobox<String>(
            placeholder: const Text('CDN选择'),
            items: _genComboboxItem(cdnConstant),
            value: cdnBoxValue,
            onChanged: (value) {
              if (value != null) setState(() => cdnBoxValue = value);
            },
          ),
        ),
        SizedBox(
          width: 240,
          child: TimePicker(
            header: '开始时间',
            selected: startTime,
            onChanged: (v) => setState(() => startTime = v),
          ),
        ),
        SizedBox(
          width: 240,
          child: TimePicker(
            header: '结束时间',
            selected: endTime,
            onChanged: (v) => setState(() => endTime = v),
          ),
        ),
        Button(child: const Text("提交"), onPressed: () => getPlayUrl(context))
      ],
    );
  }

  String _submitForm() {
    var timeFormat = DateFormat('yyyyMMDDHHmmss');
    var body = "";
    if (videoTypeBoxValue == 'RADIO_ONLINE' || videoTypeBoxValue == 'ONLINE') {
      body = "com.tjgd.develop.mobilez.WiseTV|$channelBoxValue|";
    } else if (videoTypeBoxValue == "ONLINE_BACK" ||
        videoTypeBoxValue == "ONLINE_SEEK" ||
        videoTypeBoxValue == "RADIO_BACK") {
      body =
          "com.tjgd.develop.mobilez.WiseTV|$channelBoxValue|${timeFormat.format(startTime)}|${timeFormat.format(startTime)}$cdnBoxValue";
    } else if (videoTypeBoxValue == 'RADIO_VOD' ||
        videoTypeBoxValue == 'RADIO_SERIAL' ||
        videoTypeBoxValue == 'SERIAL' ||
        videoTypeBoxValue == 'VOD') {
      body = "com.tjgd.develop.mobilez.WiseTV|$channelBoxValue|$cdnBoxValue";
    }
    return body;
  }

  void getPlayUrl(BuildContext context) async {
    GenerateUrl generateUrl = Provider.of<GenerateUrl>(context, listen: false);
    var dio = Dio();
    dio.interceptors.add(LogInterceptor(responseBody: false));
    print(_submitForm());
    try {
      Response res = await dio.post(
          "http://101.201.120.184:5050/dispatcher/playurl2/",
          data: _submitForm(),
          options: Options(
              headers: {'X-DeviceID': '1111'},
              contentType: Headers.formUrlEncodedContentType));
      print(res.data.toString());
      generateUrl.changeUrl(res.data['url']);
    } on DioError catch (e) {
      print(e.response);
    }
  }
}

class GenerateUrl extends ChangeNotifier {
  String _url = "";

  String get getUrl => _url;

  void changeUrl(newUrl) {
    print(newUrl);
    _url = newUrl;
    notifyListeners();
  }
}
