# [Mapped UTF-8 → UTF-16 range lookups FTW](http://rsms.me/2010/11/26/mapped-utf-8-utf-16-range-lookups-ftw.html)

I’m writing [a little OS X app](http://kodapp.com/) which among other
things highlights source code. To avoid re-inventing the wheel I’m using
[GNU
Source-highlight](http://www.gnu.org/software/src-highlite/)[\^1](Dynamically)
to tokenize the input data. However, [GNU
Source-highlight](http://www.gnu.org/software/src-highlite/) only accepts
UTF-8 and Cocoa strings are UTF-16 so conversion is needed, which can be
quite expensive.

My first implementation did something like this when an editing occurred
and highlighting was performed:

1.  Get the (UTF-16) range of the modified substring (using various
    algorithms, not covered here)
2.  [Convert the UTF-16 substring to a UTF-8 std::string
    representation](https://gist.github.com/716819)
3.  Feed the tokenizer with the UTF-8 string
4.  When the tokenizer returns a token range, [convert that range into a
    UTF-16 range](https://gist.github.com/716826) (but only if the
    original UTF-16 length differs from the UTF-8 length, i.e. if it is a
    multibyte string)

Highlighting the source of
[http://hunch.se/stuff/](http://hunch.se/stuff/) took a blazing **10
seconds** when compiled with optimizations and auto-vectorization. Not
even close to OK.

Any programmer—mathematician or not—realizes the high complexity of
this algorithm. For each time we find a new token, iterate over the
UTF-8 part of that edit and build a new range by considering UTF-8
bytes. A few simple optimizations (like [avoiding repeated constant
calculations](https://gist.github.com/716830)) brought the time down to
about 3.5 seconds for the same test case.

So I went to the theatre to see a play with a friend and clear my head.
This morning I realized what I already knew but didn’t want to accept before: I
need a way to lower the complexity of the algorithm. Hmm, an index
lookup table from UTF-8 to UTF-16 is probably the way to go.

After about 2 hours worth of googling, reading the [ICU
API](http://icu-project.org/apiref/icu4c/), scrubbing Apple dev docs and
almost desperately querying [Codesearch](http://codesearch.google.com/)
I gave up and rolled my own implementation. For my use case, the result
was a **14x real speed increase**—the same test which earlier took 10
seconds now only took 0.7 seconds (which given the particular test case
is good). Note that most of the 700 ms is spent on waiting for stupid
kernel-calling locks, only \~250 ms worth of user+system cycles is
actually used.

What I did was to convert UTF-16 into UTF-8 *and build a look-up table
at the same time*. Now what takes time is the damn kernel-calling spin
lock which is used by the Cocoa NSView hierarchy and boost (used by [GNU
Source-highlight](http://www.gnu.org/software/src-highlite/) for
regexp). 

I’m open-sourcing my solution under an MIT license:

<https://gist.github.com/716794>