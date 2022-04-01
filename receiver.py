import socket
import codecs
import sys

from rtmidi.midiutil import open_midioutput
from rtmidi.midiconstants import NOTE_OFF, NOTE_ON, CONTROL_CHANGE

localPort   = 65000
bufferSize  = 1024

UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
UDPServerSocket.bind(('', localPort))

# Prompts user for MIDI input port, unless a valid port number or name
# is given as the first argument on the command line.
# API backend defaults to ALSA on Linux.
port = sys.argv[1] if len(sys.argv) > 1 else None

try:
    midiout, port_name = open_midioutput(port)
except (EOFError, KeyboardInterrupt):
    sys.exit()

note_on = [NOTE_ON, 60, 112]  # channel 1, middle C, velocity 112
note_off = [NOTE_OFF, 60, 0]

print("Ecoute du midi sur le port 65000")


while midiout:
    
    bytesAddressPair = UDPServerSocket.recvfrom(bufferSize)

    message = bytesAddressPair[0]

    address = bytesAddressPair[1]

    hexa = codecs.encode(message, 'hex')
    note = int(hexa[:2], 16)
    velocity = int(hexa[2:4], 16)
    controller = int(hexa[4:6], 16)
    
    if controller == 144:
        if velocity > 0:
            notetype = NOTE_ON
        else:
            notetype = NOTE_OFF
    elif controller == 176:
        notetype = CONTROL_CHANGE
    else:
        notetype = NOTE_OFF
    
    note_tosend = [notetype, note, velocity]
    print(note_tosend)
    midiout.send_message(note_tosend)

del midiout    

    
   