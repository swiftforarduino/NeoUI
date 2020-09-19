# NeoUI
SwiftUI interface for the neopixel control program.

Description:
This is a SwiftUI app for working with the neopixel cabinet project
https://github.com/swiftforarduino/community/blob/master/work%20in%20progress/CP/bluetooth/bt%20cabinet2.swift4a/main.swift,
clone this repository to access it: https://github.com/swiftforarduino/community and open the folder "work in progress/CP/bluetooth"
where you will find the "bt cabinet2" swift for arduino project.



See the project in action:
([https://www.instagram.com/p/B_LRl79D8QH/?utm_source=ig_web_copy_link])



Hardware needed:
* neopixel strip
* arduino uno or compatible (e.g. https://store.arduino.cc/arduino-uno-rev3 or https://s4a-elements.com/products/lotus-seeeduino-v1-1)
* suitable USB cable for your board
* adafruit bluefruit shield
* suitable power supply for the neopixels (see the specifications for your neopixel product)
* wires to connect the neopixel to the arduino and power supply (see the specifications for your neopixel product)

Steps to set up the neopixel cabinet:
1) Download Swift for Arduino: https://www.swiftforarduino.com/free onto your Mac.
2) Download this source code and the source code for the "bt cabinet 2" project (link above).
3) Compile the "bt cabinet 2" project in Swift for Arduino.
4) Add the shield to your board and connect up all wires as described in the bt cabinet 2 header comments and turn the power on.
5) Connect your board via usb and upload the compiled "bt cabinet2" program onto your board (requires an s4a subscription, free trial available).
6) Setup Xcode on your Mac (if not already done so).
7) Compile this code and install onto your iPhone or iPad (requires a paid Apple Developer account).
8) The app will ask for permission for access to bluetooth when first run, in order to communicate with the adafruit shield.

You can now change the colour of the neopixels by dragging your finger across the spectrum or tapping on the colour you want.

Feel free to copy this code and make your own edits.
