
import 'package:synchronized/synchronized.dart';

enum MessageStatus {
  NotProcessed,
  Processing,
  Processed
}

class SynchronizedQueue{
  final _queue = [];
  var lock = Lock();

  add(message) async{
    await lock.synchronized(() async {
      _queue.add(message);
    });
  }


  dynamic getUnprocessedMessage() async {
    return await lock.synchronized(() async {
      var firstWhere = _queue.firstWhere((element) => element["status"] == MessageStatus.NotProcessed, orElse: () => null);
      if(firstWhere == null) return null;
      final index = _queue.indexWhere((element) => element["id"] == firstWhere["id"]);
      _queue[index]["status"] = MessageStatus.Processing;
      return firstWhere;
    });
  }

  dynamic setMessageStatus(String messageId, MessageStatus messageStatus) async {
    return await lock.synchronized(() async {
      final index = _queue.indexWhere((element) => element["id"] == messageId);
      _queue[index]["status"] = messageStatus;
    });
  }
}