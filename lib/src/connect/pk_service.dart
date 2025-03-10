// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoLiveStreamingPKService {
  void startWith(String roomID, String userID) {
    throw UnimplementedError();
  }

  void stop() {
    throw UnimplementedError();
  }

  void muteRemoteAudio({required bool mute}) {
    throw UnimplementedError();
  }

  String get remoteRoomID {
    throw UnimplementedError();
  }

  ZegoUIKitUser get remoteUser {
    throw UnimplementedError();
  }

  Stream<ZegoPKRelayCDNStateUpdateEvent> getPKRelayCDNStateUpdateEvent() {
    throw UnimplementedError();
  }
}

extension ZegoUIKitPKInvitation on ZegoLiveStreamingPKService {
  void sendInvitation(String userID) {
    throw UnimplementedError();
  }

  Stream<ZegoIncomingPKInvitationAcceptedEvent>
      getIncomingPKInvitationAcceptedEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoIncomingPKInvitationRejectedEvent>
      getIncomingPKInvitationRejectedEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoIncomingPKInvitationReceivedEvent>
      getIncomingPKInvitationReceivedEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoIncomingPKInvitationCancelledEvent>
      getIncomingPKInvitationCancelledEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoIncomingPKInvitationTimeoutEvent>
      getIncomingPKInvitationTimeoutEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoOutgoingPKInvitationAcceptedEvent>
      getOutgoingPKInvitationAcceptedEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoOutgoingPKInvitationRejectedEvent>
      getOutgoingPKInvitationRejectedEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoOutgoingPKInvitationTimeoutEvent>
      getOutgoingPKInvitationTimeoutEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoOutgoingPKInvitationSendedEvent>
      getOutgoingPKInvitationSendedEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoOutgoingPKInvitationCanceledEvent>
      getOutgoingPKInvitationCanceledEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoPKStartedEvent> getPKStartedEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoPKEndedEvent> getPKEndedEventStream() {
    throw UnimplementedError();
  }

  Stream<ZegoPKViewAvaliableEvent> getPKViewAvaliableEventStream() {
    throw UnimplementedError();
  }
}

class ZegoIncomingPKInvitationReceivedEvent {
  const ZegoIncomingPKInvitationReceivedEvent({
    required this.invitationID,
    required this.inviterID,
    required this.timeoutSecond,
    required this.extendedData,
  });

  final String invitationID;
  final String inviterID;
  final int timeoutSecond;
  final String extendedData;

  @override
  String toString() => '{invitationID: $invitationID, '
      'inviterID: $inviterID, '
      'timeoutSecond: $timeoutSecond, '
      'extendedData: $extendedData}';
}

class ZegoIncomingPKInvitationCancelledEvent {
  const ZegoIncomingPKInvitationCancelledEvent({
    required this.invitationID,
    required this.inviterID,
    required this.extendedData,
  });

  final String invitationID;
  final String inviterID;
  final String extendedData;

  @override
  String toString() => '{invitationID: $invitationID, '
      'inviterID: $inviterID, '
      'extendedData: $extendedData}';
}

class ZegoOutgoingPKInvitationAcceptedEvent {
  const ZegoOutgoingPKInvitationAcceptedEvent({
    required this.invitationID,
    required this.inviteeID,
    required this.extendedData,
  });

  final String invitationID;
  final String inviteeID;
  final String extendedData;

  @override
  String toString() => '{invitationID: $invitationID, '
      'inviteeID: $inviteeID, '
      'extendedData: $extendedData}';
}

class ZegoOutgoingPKInvitationRejectedEvent {
  const ZegoOutgoingPKInvitationRejectedEvent({
    required this.invitationID,
    required this.inviteeID,
    required this.extendedData,
  });

  final String invitationID;
  final String inviteeID;
  final String extendedData;

  @override
  String toString() => '{invitationID: $invitationID, '
      'inviteeID: $inviteeID, '
      'extendedData: $extendedData}';
}

class ZegoIncomingPKInvitationTimeoutEvent {
  const ZegoIncomingPKInvitationTimeoutEvent({required this.invitationID});

  final String invitationID;

  @override
  String toString() => '{invitationID: $invitationID}';
}

class ZegoOutgoingPKInvitationTimeoutEvent {
  const ZegoOutgoingPKInvitationTimeoutEvent({
    required this.invitationID,
    required this.invitees,
  });

  final String invitationID;
  final List<String> invitees;

  @override
  String toString() => '{invitationID: $invitationID, invitees: $invitees}';
}

class ZegoIncomingPKInvitationAcceptedEvent {}

class ZegoIncomingPKInvitationRejectedEvent {}

class ZegoOutgoingPKInvitationSendedEvent {}

class ZegoOutgoingPKInvitationCanceledEvent {}

class ZegoPKStartedEvent {}

class ZegoPKEndedEvent {}

class ZegoPKViewAvaliableEvent {}

class ZegoPKRelayCDNStateUpdateEvent {}
