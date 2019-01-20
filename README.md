# gtm_load_timer

GTMLoadTimer is a framework to instrument Objective C +load calls to see how they are contributing to your
application startup time.

## How to use GTMLoadTimer

1. Add a dependency on either the GTMLoadTimer-macOS or GTMLoadTimer-iOS framework to your project.
1. Do a build and verify that the framework is copied into the Frameworks directory of your application bundle.
1. Build the "Instrument" target of the GTMLoadTimer project.
1. Go to the Finder and "open" the GTMLoadTimer.instrdst package you just built. It should ask to install into
    Instruments.
1. Create a new "blank" instrument in Instruments and add the "+load messages" instrument.
1. Record your app with your instrument.


The data that you are probably most interested in is the `+load messages` graph which will show you timings for
each of the `+load` messages that the framework has swizzled.
The "swizzler" track is just to make you aware of the overhead of using GTMLoadTimer.

**_Please do not ship GTMLoadTimer in your applications._**

As far as I know there is nothing that GTMLoadTimer does that breaks any of Apple's rules with regards to the 
AppStore in that it only uses public APIs. That being said, all it will do is slow down launch time for your end users
which is not cool.

What would be cool is if Apple built this functionality into libObjc directly so that GTMLoadTimer wasn't needed at all.
If you feel the same, please file a radar to let Apple know you care. Feel free to reference my radar on this issue 
(47260318).

## Level of support
This is not an officially supported Google product.
