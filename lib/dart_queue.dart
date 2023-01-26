import 'package:dart_queue/SynchronizedQueue.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

enum ProcessStatus { Success, Failed }

class LangoQueue {
  LangoQueue(this.max_workers, this.workerFunction) {
    // _bootWorkers();
  }

  var lock = Lock();
  final int max_workers;
  int current_workers = 0;

  final Future<ProcessStatus> Function(Map message) workerFunction;
  final _queue = SynchronizedQueue();
  var uuid = Uuid();

  //TODO - Add to queue
  void add(dynamic payload) async {
    //generate uuid
    final message = Map();
    message["payload"] = payload;
    message["status"] = MessageStatus.NotProcessed;
    message["id"] = uuid.v4();

    await _queue.add(message);
    await lock.synchronized(() {
      if (current_workers < max_workers) {
        current_workers += 1;
        _workerLoop();
      }
    });
  }

  void _workerLoop() async {
    final message = await _queue.getUnprocessedMessage();

    if (message == null) {
      print("No more messages to handle, exiting...");
      return;
    }
    var processStatus = ProcessStatus.Failed;
    try {
      processStatus = await workerFunction(message);
      // ignore: empty_catches
    } catch (e) {}
    switch (processStatus) {
      case ProcessStatus.Success:
        // TODO: update
        await _queue.setMessageStatus(message["id"], MessageStatus.Processed);
        break;
      case ProcessStatus.Failed:
        // TODO: Handle this case.
        await _queue.setMessageStatus(
            message["id"], MessageStatus.NotProcessed);
        break;
    }
    await lock.synchronized(() {
      current_workers -= 1;
      if (current_workers < max_workers) {
        _workerLoop();
      }
    });
  }
}
