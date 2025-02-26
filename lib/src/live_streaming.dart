// Dart imports:
import 'dart:async';
import 'dart:core';
import 'dart:developer';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_page.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/permissions.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/preview_page.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class ZegoUIKitPrebuiltLiveStreaming extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreaming({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    this.controller,
    this.onDispose,
    @Deprecated('Since 2.4.1') this.appDesignSize,
  }) : super(key: key);

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appID you obtained from console.zegocloud.com
  final String appSign;

  /// local user info
  final String userID;
  final String userName;

  /// You can customize the liveName arbitrarily,
  /// just need to know: users who use the same liveName can talk with each other.
  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final ZegoUIKitPrebuiltLiveStreamingController? controller;

  final VoidCallback? onDispose;

  final Size? appDesignSize;

  @override
  State<ZegoUIKitPrebuiltLiveStreaming> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingState();
}

class _ZegoUIKitPrebuiltLiveStreamingState
    extends State<ZegoUIKitPrebuiltLiveStreaming> with WidgetsBindingObserver {
  List<StreamSubscription<dynamic>?> subscriptions = [];
  final popUpManager = ZegoPopUpManager();

  var readyNotifier = ValueNotifier<bool>(false);
  var startedByLocalNotifier = ValueNotifier<bool>(false);
  late final ZegoLiveHostManager hostManager;
  late final ZegoLiveStatusManager liveStatusManager;
  ZegoPrebuiltPlugins? plugins;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addObserver(this);

    ZegoUIKit().getZegoUIKitVersion().then((version) {
      log('version: zego_uikit_prebuilt_live_streaming: 2.4.4; $version');
    });

    if (!widget.config.previewConfig.showPreviewForHost) {
      startedByLocalNotifier.value = true;
    }

    hostManager = ZegoLiveHostManager(config: widget.config);
    liveStatusManager = ZegoLiveStatusManager(
      hostManager: hostManager,
      config: widget.config,
    );

    if (widget.config.plugins.isNotEmpty) {
      plugins = ZegoPrebuiltPlugins(
        appID: widget.appID,
        appSign: widget.appSign,
        userID: widget.userID,
        userName: widget.userName,
        roomID: widget.liveID,
        plugins: widget.config.plugins,
      );
    }
    plugins?.init();

    if (widget.config.plugins.isNotEmpty) {
      ZegoLiveStreamingPKBattleManager().init(
        hostManager: hostManager,
        liveStatusNotifier: liveStatusManager.notifier,
        config: widget.config,
        translationText: widget.config.translationText,
        startedByLocalNotifier: startedByLocalNotifier,
        contextQuery: () => context,
      );
    }

    subscriptions.add(
        ZegoUIKit().getMeRemovedFromRoomStream().listen(onMeRemovedFromRoom));

    initToast();
    initContext();
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance?.removeObserver(this);
    ZegoLiveStreamingPKBattleManager().uninit();

    plugins?.uninit();

    hostManager.uninit();
    liveStatusManager.uninit();

    uninitContext();

    widget.config.onLiveStreamingStateUpdate?.call(ZegoLiveStreamingState.idle);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    widget.onDispose?.call();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    ZegoLoggerService.logInfo(
      'didChangeAppLifecycleState $state',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );

    switch (state) {
      case AppLifecycleState.resumed:
        plugins?.tryReLogin();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.config.onLeaveConfirmation ??= onLeaveConfirmation;

    return hostManager.isHost
        ? ValueListenableBuilder<ZegoUIKitUser?>(
            valueListenable: hostManager.notifier,
            builder: (context, host, _) {
              /// local is host, but host updated
              if (hostManager.isHost) {
                return ValueListenableBuilder<bool>(
                    valueListenable: startedByLocalNotifier,
                    builder: (context, isLiveStarted, _) {
                      return isLiveStarted ? livePage() : previewPage();
                    });
              } else {
                return livePage();
              }
            })
        : livePage();
  }

  Future<void> initPermissions() async {
    var isCameraGranted = true;
    var isMicrophoneGranted = true;
    if (widget.config.turnOnCameraWhenJoining) {
      isCameraGranted = await requestPermission(Permission.camera);
    }
    if (widget.config.turnOnMicrophoneWhenJoining) {
      isMicrophoneGranted = await requestPermission(Permission.microphone);
    }

    if (!isCameraGranted) {
      await showAppSettingsDialog(
        context: context,
        rootNavigator: widget.config.rootNavigator,
        dialogInfo:
            widget.config.translationText.cameraPermissionSettingDialogInfo,
      );
    }
    if (!isMicrophoneGranted) {
      await showAppSettingsDialog(
        context: context,
        rootNavigator: widget.config.rootNavigator,
        dialogInfo:
            widget.config.translationText.microphonePermissionSettingDialogInfo,
      );
    }
  }

  void initContext() {
    assert(widget.userID.isNotEmpty);
    assert(widget.userName.isNotEmpty);
    assert(widget.appID > 0);
    assert(widget.appSign.isNotEmpty);

    initPermissions().then((value) {
      ZegoUIKit().login(widget.userID, widget.userName);

      ZegoUIKit()
          .init(
            appID: widget.appID,
            appSign: widget.appSign,
            scenario: ZegoScenario.Broadcast,
          )
          .then(onContextInit);
    });
  }

  void onContextInit(_) {
    final useBeautyEffect = widget.config.bottomMenuBarConfig.hostButtons
            .contains(ZegoMenuBarButtonName.beautyEffectButton) ||
        widget.config.bottomMenuBarConfig.coHostButtons
            .contains(ZegoMenuBarButtonName.beautyEffectButton);

    if (useBeautyEffect) {
      ZegoUIKit()
          .startEffectsEnv()
          .then((value) => ZegoUIKit().enableBeauty(true));
    }

    ZegoUIKit()
      ..useFrontFacingCamera(true)
      ..updateVideoViewMode(
          widget.config.audioVideoViewConfig.useVideoViewAspectFill)
      ..enableVideoMirroring(widget.config.audioVideoViewConfig.isVideoMirror)
      ..turnCameraOn(widget.config.turnOnCameraWhenJoining)
      ..turnMicrophoneOn(widget.config.turnOnMicrophoneWhenJoining)
      ..setAudioOutputToSpeaker(widget.config.useSpeakerWhenJoining);

    ZegoUIKit()
        .joinRoom(
      widget.liveID,
      markAsLargeRoom: widget.config.markAsLargeRoom,
    )
        .then((result) async {
      await onRoomLogin(result);
    });
  }

  Future<void> onRoomLogin(ZegoRoomLoginResult result) async {
    assert(result.errorCode == 0);

    if (result.errorCode != 0) {
      ZegoLoggerService.logInfo(
        'failed to login room:${result.errorCode},${result.extendedData}',
        tag: 'live streaming',
        subTag: 'prebuilt',
      );
    }

    await hostManager.init();
    await liveStatusManager.init();

    readyNotifier.value = true;
  }

  Future<void> uninitContext() async {
    // var useBeautyEffect = widget.config.bottomMenuBarConfig.buttons
    //     .contains(ZegoMenuBarButtonName.beautyEffectButton);
    // if (useBeautyEffect) {
    //   await ZegoUIKit().stopEffectsEnv();
    // }

    await ZegoUIKit().resetSoundEffect();
    await ZegoUIKit().resetBeautyEffect();

    await ZegoUIKit().leaveRoom();

    // await ZegoUIKit().uninit();
  }

  void initToast() {
    ZegoToast.instance.init(contextQuery: () {
      return context;
    });
  }

  Future<bool> onLeaveConfirmation(BuildContext context) async {
    if (widget.config.confirmDialogInfo == null) {
      return true;
    }

    return showLiveDialog(
      context: context,
      rootNavigator: widget.config.rootNavigator,
      title: widget.config.confirmDialogInfo!.title,
      content: widget.config.confirmDialogInfo!.message,
      leftButtonText: widget.config.confirmDialogInfo!.cancelButtonName,
      leftButtonCallback: () {
        //  pop this dialog
        Navigator.of(
          context,
          rootNavigator: widget.config.rootNavigator,
        ).pop(false);
      },
      rightButtonText: widget.config.confirmDialogInfo!.confirmButtonName,
      rightButtonCallback: () {
        //  pop this dialog
        Navigator.of(
          context,
          rootNavigator: widget.config.rootNavigator,
        ).pop(true);
      },
    );
  }

  void onMeRemovedFromRoom(String fromUserID) {
    ZegoLoggerService.logInfo(
      'local user removed by $fromUserID',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );

    /// hide co-host end request dialog
    if (hostManager.connectManager?.isEndCoHostDialogVisible ?? false) {
      hostManager.connectManager!.isEndCoHostDialogVisible = false;
      Navigator.of(
        context,
        rootNavigator: widget.config.rootNavigator,
      ).pop();
    }

    /// hide invite join co-host dialog
    if (hostManager.connectManager?.isInviteToJoinCoHostDlgVisible ?? false) {
      hostManager.connectManager!.isInviteToJoinCoHostDlgVisible = false;
      Navigator.of(
        context,
        rootNavigator: widget.config.rootNavigator,
      ).pop();
    }

    ///more button, member list, chat dialog
    popUpManager.autoPop(context, widget.config.rootNavigator);

    if (null != widget.config.onMeRemovedFromRoom) {
      widget.config.onMeRemovedFromRoom!.call(fromUserID);
    } else {
      //  pop this dialog
      Navigator.of(
        context,
        rootNavigator: widget.config.rootNavigator,
      ).pop(true);
    }
  }

  Widget previewPage() {
    return ZegoPreviewPage(
      appID: widget.appID,
      appSign: widget.appSign,
      userID: widget.userID,
      userName: widget.userName,
      liveID: widget.liveID,
      liveStreamingConfig: widget.config,
      startedNotifier: startedByLocalNotifier,
      hostManager: hostManager,
      liveStreamingPageReady: readyNotifier,
      config: widget.config.previewConfig,
    );
  }

  Widget livePage() {
    return ZegoLivePage(
      appID: widget.appID,
      appSign: widget.appSign,
      userID: widget.userID,
      userName: widget.userName,
      liveID: widget.liveID,
      config: widget.config,
      hostManager: hostManager,
      liveStatusManager: liveStatusManager,
      popUpManager: popUpManager,
      plugins: plugins,
      controller: widget.controller,
    );
  }
}
