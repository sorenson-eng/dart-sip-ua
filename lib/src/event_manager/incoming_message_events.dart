import '../sip_message.dart';
import 'events.dart';

class EventBeforeIncomingRequestProcess extends EventType {
  /// This is meant for reading/munging valid requests before they are processed.
  /// Listener is assumed not to have replied to request.
  /// 
  /// Replying is not blocked, just highly discouraged. See MESSAGE, OPTIONS, 
  /// and INFO for SIP methods with listener reply support
  /// 
  /// **a valid request is one that has passed sanity, uri, and transaction 
  /// checks (i.e. a well formatted SIP request meant for the UA; 
  /// a retransmission, CANCEL with no matching INVITE, and other usch events are not caught)*
  EventBeforeIncomingRequestProcess({this.request});
  IncomingRequest? request;
}

class EventBeforeIncomingResponseProcess extends EventType {
  /// This fires for respones with a valid transaction and all ACKs.
  EventBeforeIncomingResponseProcess({this.response});
  IncomingResponse? response;
}
