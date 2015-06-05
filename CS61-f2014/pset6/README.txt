README for CS 61 Problem Set 6
------------------------------
YOU MUST FILL OUT THIS FILE BEFORE SUBMITTING!

YOUR NAME: Jeremy Watson
YOUR HUID: 80819757

(Optional, for partner)
YOUR NAME:
YOUR HUID:

RACE CONDITIONS
---------------
Write a SHORT paragraph here explaining your strategy for avoiding
race conditions. No more than 400 words please.

I first tried to minimize cases where a thread had to interact or depend
on anything outside of itself. A wait conditional keeps each thread in
sequence, and thread locks around the use of order sensitive code sections
(modifying the thread table and thread count) ensures that key operations
are atomic.


OTHER COLLABORATORS AND CITATIONS (if any):



KNOWN BUGS (if any):



NOTES FOR THE GRADER (if any):



EXTRA CREDIT ATTEMPTED (if any):
