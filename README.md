# FireMonkey-Fonts
Dynamically Loaded Fonts in Firemonkey on WIndows

I think I have an answer how to do this, which was only possible because of a LOT of help by Roy Nelson of Embarcadero's support staff who pointed me in the right direction.

I have verified that this works with Berlin 10.1 (without the Anniversary Patch applied) on Windows 10, 64 bit but I don't guarantee that will will work on all compiler versions/Windows versions and any insight other people have to offer would be very interesting to hear.

First off, I think the (currently) insurmountable issue starts with trying to use **AddFontMemResourceEx** as that produces fonts that are not enumerable and for Firemonkey to convert an installed TrueType Font to a graphically rendered D2D font--which is what it actually uses--it has to first be able to find it.

Replacing **AddFontMemResourceEx** with **AddFontResource** with a temp font file you write from the resource solves that problem, but it's not enough.  After it's installed you need to force the TextLayout rendering engine to rebuild its font list which you can do with calling two lines from the **FMX.Canvas.D2D.pas** unit.

    UnregisterCanvasClasses; //this tells it to forget everything it knows
    RegisterCanvasClasses; //this tells it to learn it again based on the current state of this system, which now includes our dynamically loaded font.
