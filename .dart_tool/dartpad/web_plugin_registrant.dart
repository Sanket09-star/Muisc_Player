// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:audio_session/audio_session_web.dart';
import 'package:just_audio_web/just_audio_web.dart';
import 'package:on_audio_query_web/on_audio_query_web.dart';
import 'package:permission_handler_html/permission_handler_html.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  AudioSessionWeb.registerWith(registrar);
  JustAudioPlugin.registerWith(registrar);
  OnAudioQueryPlugin.registerWith(registrar);
  WebPermissionHandler.registerWith(registrar);
  registrar.registerMessageHandler();
}
