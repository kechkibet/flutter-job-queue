

import 'dart:io';
import 'dart:math';

import 'package:dart_queue/dart_queue.dart';

void main(List<String> arguments) {
  Random random =  Random();

  var langoQueue = LangoQueue(2, (message) async {
    int randomNumber = random.nextInt(5);
    await Future.delayed(Duration(seconds: randomNumber));
    print("${message.toString()} - took ${randomNumber} seconds");
    return  ProcessStatus.Success;
  });


  List.generate(20, (index) => langoQueue.add('Hello World $index'));

}
