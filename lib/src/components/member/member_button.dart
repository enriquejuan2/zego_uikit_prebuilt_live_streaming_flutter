// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil_zego/flutter_screenutil_zego.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/member/member_list_sheet.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class ZegoMemberButton extends StatefulWidget {
  const ZegoMemberButton({
    Key? key,
    this.avatarBuilder,
    this.itemBuilder,
    required this.isPluginEnabled,
    required this.hostManager,
    required this.connectManager,
    required this.popUpManager,
    required this.translationText,
  }) : super(key: key);

  final bool isPluginEnabled;
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoMemberListItemBuilder? itemBuilder;
  final ZegoLiveHostManager hostManager;
  final ZegoLiveConnectManager connectManager;
  final ZegoPopUpManager popUpManager;
  final ZegoTranslationText translationText;

  @override
  State<ZegoMemberButton> createState() => _ZegoMemberButtonState();
}

class _ZegoMemberButtonState extends State<ZegoMemberButton> {
  var redPointNotifier = ValueNotifier<bool>(false);
  var memberCountNotifier = ValueNotifier<int>(0);
  StreamSubscription<dynamic>? userListSubscription;

  @override
  void initState() {
    super.initState();

    memberCountNotifier.value = ZegoUIKit().getAllUsers().length;
    userListSubscription =
        ZegoUIKit().getUserListStream().listen(onUserListUpdated);

    widget.connectManager.requestCoHostUsersNotifier
        .addListener(onRequestCoHostUsersUpdated);
  }

  @override
  void dispose() {
    super.dispose();

    userListSubscription?.cancel();
    widget.connectManager.requestCoHostUsersNotifier
        .removeListener(onRequestCoHostUsersUpdated);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMemberListSheet(
          context: context,
          avatarBuilder: widget.avatarBuilder,
          itemBuilder: widget.itemBuilder,
          isPluginEnabled: widget.isPluginEnabled,
          hostManager: widget.hostManager,
          connectManager: widget.connectManager,
          popUpManager: widget.popUpManager,
          translationText: widget.translationText,
        );
      },
      child: Stack(
        children: [
          Container(
            width: 106.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: ZegoUIKitDefaultTheme.buttonBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(28.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon(),
                SizedBox(width: 6.r),
                memberCount(),
              ],
            ),
          ),
          redPoint(),
        ],
      ),
    );
  }

  Widget redPoint() {
    return ValueListenableBuilder(
      valueListenable: ZegoLiveStreamingPKBattleManager().state,
      builder: (context, pkBattleState, _) {
        final needHideCoHostWidget =
            pkBattleState == ZegoLiveStreamingPKBattleState.inPKBattle ||
                pkBattleState == ZegoLiveStreamingPKBattleState.loading;

        if (needHideCoHostWidget) {
          return Container();
        } else {
          return Positioned(
            top: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: redPointNotifier,
              builder: (context, visibility, _) {
                if (!visibility) {
                  return Container();
                }

                return Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  width: 20.r,
                  height: 20.r,
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget icon() {
    return SizedBox(
      width: 48.r,
      height: 48.r,
      child: const Icon(
        Icons.person,
        color: Colors.white,
      ),
    );
  }

  Widget memberCount() {
    return SizedBox(
      height: 56.r,
      child: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: memberCountNotifier,
          builder: (context, memberCount, child) {
            return Text(
              memberCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.r,
                fontWeight: FontWeight.w400,
              ),
            );
          },
        ),
      ),
    );
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    memberCountNotifier.value = users.length;
  }

  void onRequestCoHostUsersUpdated() {
    redPointNotifier.value =
        widget.connectManager.requestCoHostUsersNotifier.value.isNotEmpty;
  }
}
