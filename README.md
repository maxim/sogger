Sogger
======

The word "sogger" was derived by ingeniously abbreviating "Stack Overflow Growler Written in Ruby During a Time of Procrastination When Doing Real Work has Become Unbearable". That is what it is.

Install
-------

    sudo gem install sogger
    
Run
---

Get growl all new questions.

    sogger
    
Growl questions with either ruby or ruby-on-rails tags.

    sogger ruby ruby-on-rails

When you run this command the app will take up your terminal session, and start monumentally logging into your life. That's cause it's unstable. Sometimes it segfaults pretty quickly, sometimes it manages to stay on for hours. Mostly depends on your luck. Please fix if you know how.

The Thing Is
------------

The thing is, currently I'm not very proficient in the area of threads, forking, race conditions, etc. This app has 2 threads. One downloads updates, one growls. Since it's a small app, it's not hard to fix whatever it is I screwed up, so please do if you like the idea.

Known Issues
------------

* It likes to segfault once in a while.
* RubyCocoa has issues with this app, probably because I use "meow" for growler. You'll see in the log.