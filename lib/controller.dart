import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_midi_command/flutter_midi_command_messages.dart';
import 'package:xterm/xterm.dart';
import 'package:xterm/flutter.dart';

class ControllerPage extends StatelessWidget {
  final MidiDevice device;

  ControllerPage(this.device);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MIDI UDP Broadcast'),
      ),
      body: MidiControls(device),
    );
  }
}

class MidiControls extends StatefulWidget {
  final MidiDevice device;

  MidiControls(this.device);

  @override
  MidiControlsState createState() {
    return new MidiControlsState();
  }
}

void sendtoserver(data) async {
  List<int> datalist = [data[1], data[2]];
  RawDatagramSocket.bind(InternetAddress.anyIPv4, 65000).then((RawDatagramSocket socket) {
    socket.broadcastEnabled = true;
    socket.send(datalist, InternetAddress('255.255.255.255'), 65000);
  });
}

class MidiControlsState extends State<MidiControls> {
  // StreamSubscription<String> _setupSubscription;
  StreamSubscription<MidiPacket>? _rxSubscription;
  MidiCommand _midiCommand = MidiCommand();
  final terminal = Terminal(maxLines: 10000);

  @override
  void initState() {
    _rxSubscription = _midiCommand.onMidiDataReceived?.listen((packet) {
      var data = packet.data;
      var timestamp = packet.timestamp;
      var device = packet.device;
      sendtoserver(data);
      terminal.write("Note: " + data[1].toString() + " Velocity: " + data[2].toString() + "\r\n");
    });

    super.initState();
  }

  void dispose() {
    // _setupSubscription?.cancel();
    _rxSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Text("MIDI through UDP port 65000"),
        Expanded(child: TerminalView(terminal: terminal, style: TerminalStyle(fontSize: 20))),
      ],
    ));
  }
}
