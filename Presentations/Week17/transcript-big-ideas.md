
# Big Ideas

Reference: https://www.youtube.com/watch?v=nERXS3ssntw

hi I'm have your welcome and in the next
five minutes I'm going to give you the
five big ideas behind heidi evaluation
the first big idea is that our code is a
tree every expression an R has a
hierarchical structure which we can
visualize using some simple conventions
so here I'm going to use an orange
square to represent a function call the
first job of that call is the name of
the function and then the other children
are arguments so this tree represents a
call to a function if with argument X
the little Y and the number 1 now no
matter how our code how complicated our
code gets we can always express it in
this way the tree just gets deeper and
deeper and deeper now you might wonder
what about what about expressions like
this it doesn't look like we've got any
function calls here but actually our of
the surprising property that every our
expression can be written in the so
called prefix form where the name of the
function comes before its arguments so
here we have the assignment arrow and a
multiplication operator in front of the
argument so no matter how no matter what
our expression you're right you can
always write this isn't true the next
big idea is that you can capture that
tree by quoting that argument and here
I'm going to use two functions from the
are laying package extra an in expert so
expert captures your expressions the
developer you the developer of the
functions expressions it always gives
you back exactly what you gave it the
other peer function is in extra that is
going to quote the users expression it's
going to capture what the user user
passed to your function now this allows
us to introduce some new vocabulary we
can talk about arguments being evaluated
using the usual our rules or with they
can be quoted using captured using X Pro
in X Perl one of the related functions
from baiser so these quoting functions
are used throughout the tiny list in
particular because it gives us these
really amazing powers where we can write
deep liar code for example we rewrite
our code
and behind-the-scenes DB plier can
inspect that tree of code and figure out
how to translate it into sequel the
third big idea is that we can use the
opposite of quoting and quoting to build
up complex trees from smaller fragments
so what does this look like well first
of all it's capture this expression X
plus y and save into a variable and then
let's create some more complex
expressions using this and to do so
we're going to use the unquote an
operator pronounced bangbang so here we
have extra bangbang XY plus Z that is
going to generate the expression X plus
y plus C now what happens if we do one
over bangbang XY well because we're
manipulating trees here we're gonna get
the correct expression 1 over X plus y
not 1 over X plus y how does this work
let's take a very simple example here
I'm going to define this expression X is
just a plus B and then I'm going to
unquote it into this call to F basically
all we're doing is merging those two
trees together making a complex tree
from two simpler pieces the fourth big
idea is if you want to wrap a function
that quotes one or more of its arguments
you need to quote one or more of your
argument and then you need to add course
them this gives us a really simple but
powerful pattern if we want to wrap
around any functions in the tiny base
for example if you want to create a
scatterplot using the development
version of ggplot2 you here I'm going to
supply a data frame an X variable and a
Y variable I quote the X variable and
the y variable using in X Pro and then I
unquote them in the called a yes
similarly if I want to create my own
summarized function which computes the
mean and standard deviation of whatever
variable I call it with I quote that
variable using in extra and then I use
an quoting to when I call the function
that uses quoting and here because I'm
quoting works with trees I can insert
that variable name at any point in the
call now unfortunately this doesn't
quite work because one thing I haven't
talked about is the environment
in which those expressions are evaluated
and this is important when you start to
mingle variables from a data frame like
X in variables from the environment like
Y and here when you evaluate this you
would hope it will use the definition of
being defined here 100 but it does not
it's actually going to use a definition
in from up here in the incorrect
environment so to fix that we need to
learn one new idea the idea of a quota
which is a portmanteau of closure and
quotation which captures both the
expression and the environment in which
it should be evaluated so if I change my
mutate function from using in extra to
just using in quo I now career get the
correct result it now uses in from the
global environment not from the function
not from the environment inside the
function so five big ideas if you want
to understand tiny evaluation first of
all all our code is a tree no matter how
complex or no matter what type of our
code you write you can capture that tree
by quoting an argument or more than one
argument you can use an quoting to build
up complex trees from smaller fragments
if you want to wrap a function that
quotes one or more of the arguments you
need to quote your arguments and then
you need to unquote them when you pass
them along and finally to make that work
100% correctly rather than capturing an
expression you need to capture a closure
which is a combination of an expression
in its environment

# Lander

Reference: https://www.youtube.com/watch?v=g1h-YDWVRLc

so today I wanted to talk about a
lobster which is the new package that
I've been working on as part of the
second edition of advanced style so one
of the big changes in this next addition
is there's a bunch more diagrams because
I think they really help you understand
what's going on with that and of course
in the book there's like a bunch of like
diagrams that I spend like hours drawing
by hand which is great for the stuff
that's in the book but then how do you
go and then apply how do you use those
same ideas with your own code so today
I'm going to show you some the tools of
a lobster that basically tools for
creating command line visualizations of
kind of interesting things in the our
language interesting and challenging
things about the our language so we're
going to talk about three big ideas
today the distinction between names and
values in our with the riff function the
fact that in our code all our code you
can think of as a tree with the ast
function and then finally I'll talk a
little bit about some of the sort of
something I just recently came to
understand about trace backs or call
stacks and are and how they're not
actually just a linear stack they're
actually a tree and I think that's gonna
have some profound implications for
making more useful error messages in our
now lobster is still only on github but
you know I am serious about it because
it has a logo and just the logo
hopefully makes it obvious that the
inspiration for the name is these are
kind of functions like the STR function
and bass are so STR displays the
structure of any our object and kind of
a tree like fashion all of the functions
and lobst or many of the functions and
lobster try and do a save the similar
thing like create a little visualization
and all the console tree that describes
some kind of object in our in most of
all at least for the first two topics
these correspond to chapters and the
advanced are I'll put these links up
again at the end but if you want to
learn more about any of these topics you
can go and read the chapters advanced
stuff but I'm gonna start with a little
quiz for you all so I want you to run
this our code and you're here I've run
the
line I have created a victor with a
million random normal at random uniforms
and I found out its size which is about
8 megabytes so what I want you to do now
is run the rest of the code in your head
and see what it outputs and then like
talk it over with your neighbor see if
you've got get to the same answer or not
see what do you you've got one minute to
run this code starting now
okay times up so let's do it just a
quick show of hands how many predicted
that the answer for this was gonna be
about 24 megabytes and and how many
people thought well I think it probably
is 24 megabytes but if the answer was so
simple Headley wouldn't have like tried
to trick me like this yeah so if we
actually let's - let's run this code in
our and Jared told me is extremely
dangerous to run our code live and a
talk but I'm gonna do it anyway so just
to verify this a million random uniforms
that's at a uniform in ours a double a
double takes up eight bytes and we've
got a million of them so it's about
eight million bytes plus a little bit
which I'm not gonna talk about today and
actually we're no we're not gonna run
that uh I guess I I'm gonna copy and
paste if I run this it's actually just
it's still eight megabytes and a little
bit and we'll see why that is very
shortly and then what happens if I
modify one of the values in that list
well now all of a sudden it's now
sixteen megabytes so what the heck is
going on here it's easiest to understand
with some pictures and to kind of
understand what the assignment arrow is
actually doing the assignment arrow is
not creating an object the VI unit
function is creating the object what the
assignment arrow is doing is associating
this object or this value with a name
and this is like our analysis are
basically like a reference so it's kind
of like a pointer I'm not gonna use
pointer because that kind of conveys
some like specific technical meaning
which is not true now but it's like a
reference a name references about you in
fact like many references can point to
one object so when you assign one object
to another object or that's not really
what you're doing right when you use the
assignment area multiple times you're
actually just referencing the same value
from multiple names so now when you if
you've done this an hour like now you
can kind of ask this question well how
big is a well a is going to be
same sizes X right it's about eight
megabytes how bigger a and B together
well kind of strangely but they're both
eight megabytes right to the size of two
references and are like the size of a
and the size of B together does not
equal the size of a plus the size of B
so this kind of like non transitivity
makes reasoning about how big an object
is an are quite challenging and we can
kind of verify that with some our code
so one thing the object object
underscore size function which comes
from Lobster does you can give up
multiple objects and it tells you the
total size of those objects so you can
see a and B individually eight megabytes
are not also add megabytes together
before I go and should I make anyone
read this code okay or I need to make it
a little bigger make it a little bigger
that's about that's about as big as I
can go and you can still actually see
what I'm doing okay so you can have
multiple names pointing or referencing
the same value and that's also true of
lists so when you create a list I does
not copy all of the things into that
list it just references them where they
lie so now when we say well how big is X
well that's about eight megabytes
how big is why that's also about eight
megabytes so let's make that a little
bit more precise hopefully if I remember
the order and this is what we're
supposed to do this so if we look at the
size of Y minus the size of X we can see
that's 72 bytes and kind of
interestingly that's exactly the same
size as a list a list of three empty
elements so the size of that list is the
size of X plus the size of a list and
the size of a list is basically a bunch
of pointers in this kind of like if you
like a pointer you might happen to know
it was like eight bytes and so three
times eight is 20 km in a row that's
leaning me a bad direction
cuz that's not gonna work out I uh let's
get back to this oops
you know most is like a little bit of
over here on our objects because they
have to store some kind of other
information which is about 40 bytes and
I can't remember exactly why it's not
ending up 40 bytes there okay so we also
have another tool oops let's just rerun
this so you know you don't have me to
draw all these diagrams for you by hand
when you're trying to understand what's
going on with your objects so Lobster
comes with us riff function and what a
riff attempts to do is tell you like the
structure of your object and how it like
references other objects so we can see
here we have a list and each object in
our has this kind of each value in our
has this sort of identify there's
address and this is basically where that
object lives in memory which is doesn't
really mean anything because every time
you start it's gonna occupy a different
part of memory on your computer but
within a session this allows us to kind
of identify a value rather than a name
and so we can see here we have this list
it's name it's its addresses I'm not
gonna say the whole thing but it's just
0 X 7 be--if cetera and then inside this
list we have a double which is this
address and then the other components of
the list are just that same object
repeated again so you can see as well as
the address there's also this kind of
local address so you can see that this
is the object to and these other two
elements of the list point back to that
object so what happens when you modify
an object in the list well an are
modifying an object creates a copy so
this sort of happens in two steps so if
I'm going to modify the first element of
Y well first of all I was going to
create the X modified to what the first
value changed and then it's basically
going to change
references so now if we ask like how big
is X Y Lakes is still about 8 megabytes
this victor is about 8 megabytes and so
the size of Y is gonna be this Victor
Plus this victor plus a little bit of
accounting over hit so it's gonna be
about 16 gigabytes and so what happens
if we modify X well the same things
going to happen I was going to create a
new victor that is modified and then
it's going to change we exploit stew so
kind of all the time like we never Uther
almost always whenever you think you're
modifying something a now you're
actually modifying a copy with one
little exception which I'll get to
shortly now what happens when you if you
want to remove these objects well in our
you can call REM and what our in does is
removes the names it removes the
references to those values RM doesn't
actually delete the object or the values
themselves so that's the job of the
garbage collector and what the garbage
collector does is every so often like
either when you need more memory or just
every so many kind of victor creations
are going to go through and look for all
of the objects that have no references
pointing to them and it's going to clear
them out so you can use that memory
again so in this case it's going to look
through it's gonna find while there's
two objects that nothing points to this
victor at the top and this list down the
bottom and it's going to delete those
and then it's going to realize well now
there's two new vectors that I have
everything pointing to them and it's
going to get rid of those as well so
when you remove an object in our kept it
happens and two passes first you remove
the remove the references and then later
on kind of stochastically the garbage
collector is going to come along and
actually delete those objects and free
up the memory for you but there's kind
of one exception to this rule because
then every time you modified an object
and are it created a copy I would be
like incredibly slow like IRAs not like
a fast language as it is but I've had to
create a new victor copy every single
time you modify something would be
astronomically slow so like if if you
had a victor like this
and you modified it and you modified it
again right this you end up with you
don't end up with three copies of that
Viktor so R has this optimization so
that if it knows that the Viktor only
has one name it only has one reference
pointing to it it will modify it in
place so this kind of keeps the
performance of our at life sort of a
reasonable level it has the special
optimization because if only one thing
is pointing to an object like it doesn't
really matter if you modify it in place
from the outside view outside world it's
exactly the same as if you had created a
copy and then change the reference to it
because there's only that one reference
and we can kind of one way to do that in
to see what's going on which I'm going
to briefly do something crazy and I'm
gonna use the terminal pane in our
studio and I am gonna run our inside of
that for a reason which I'm going to
explain shortly now this is like a
little bit this a little bit this is a
little bit insane and you can do some
there's this really old dev tools
function called dev tools what do they
call it
oh it's I'm not inside of a package
that's sad but you can't actually use
dev tools to cool bash which will open a
bash shell inside this then you can call
our and side that it gets very confusing
actually I think you can just do this
how's this gonna work yeah so now I'm
running bash I'm running our inside our
Studios terminal inside that I'm running
bash and then inside that I can run off
that's that's a really bad idea though
so I'm not gonna do it
okay so Becca nah I'm gonna create a
victor
I'm gonna call trace meme and what this
does is it just prints out the address
of that object and now whenever that
object gets copied it is going to print
out something like this that that
objects just got copied oops and I
accidentally used the wrong keyboard
shortcut so I'm going to run this in my
art terminal and you see when I'm
modifying that victor no copies are
occurring because there's only one thing
pointed to it if I did this I keep using
the wrong keyboard shortcut if I did
this there's now two of these now two
names pointing to that same victor if I
change it it's gonna have to create a
copy and it only has to do that once
right because now there is only one
thing pointing to that new object now
unfortunately if you run the same code
in our studio you will get confused
because it looks like when you're
modifying it it's actually creating a
copy well it is actually creating a copy
and that's because of one really helpful
feature in our studio which is the
environment pane and so the environment
pane creates like another reference to
this object so that when you're
experimenting with us interactively in
our studio it's always gonna create a
copy now you might wonder like is this
gonna make a studio make all of my code
catastrophic lis slow no because most of
the time you're not like doing a bunch
of modifications at the top level that's
inside a function or on side a for loop
and ask to you doesn't see that object
it doesn't put in the environment pane
so it's not it's not a big deal
okay so tres ma'am allows you to see
whenever an object gets copied and
because of the rules for like wind so
that this is all this the seem
straightforward but the big complication
is that when R is kind of counting how
many references are pointing to an
object it can only count up to two two
basically so it knows if there are zero
references one reference or if there are
many references so that means if you
have like three references to an object
and you delete two of them
I cannot kind of figure out that there's
only one left so maybe that might happen
in a future version of our but that
basically means like it's very difficult
for you to predict when a copy will
occur or not so if you're ever wondering
if you're ever trying to optimize
performance at this level like use trace
Miam don't try and think it through just
see exactly what happens okay so it's
kind of the first big idea that there's
an in are there's this really important
distinction between names and values you
might think that assignment or calling a
function is going to copy your vector
that's not going to be the case the
objects and our only copied when you
modify them the next thing I want to
talk about is this kind of powerful idea
that makes it really easy to write our
code that writes our code and that's
this idea that an are all code is a tree
and what do I mean by that I mean
basically you can draw any our
expression in a tree like this I'm gonna
draw this function call as an orange
square and then the first child is the
name of the function that's called and
in the subsequent the subsequent
children are the arguments to that
function X the letter Y and the number
one and no matter how complicated your
our code is you can always draw it in
this form as this tree like structure
there's one little wrinkle though
because here I've drawn this this is
kind of the type of code you call with
the functions that you have written in R
this is called a prefix function call
because the name of the function comes
first before its arguments but there are
other function calls in R that are not
there do not look like there
so a very common class of those calls
are called in fix function calls where
the name of the function comes in
between its arguments so two two
commonly used functions that are in fix
functions the assignment arrow the thing
that's being assigned to is on the Left
it's the value that's being assigned is
on the right and multiplication like the
this is the multiplication function
comes in between its arguments and it
turns out an eye you can rewrite any
function call and are no matter how
weird it looks in this prefix form where
the name of the function comes first now
if the name of the function is something
weird like a Simon arrow or
multiplication here they're putting it
between backticks but you can rewrite
any our expression in this way and so
again you can just read this tree like
we did before we've got two function
calls the first function call is the
assignment arrow it's going to assign
the reference Y to the value which is
the result of computing X times y so
let's have a look at that so just like
with riff the the first example there is
a function and lobster which helps you
draw these diagrams called AST it's
called AST because in computer science
the name for these trees is abstract
syntax trees now every single
programming language has an abstract
syntax tree but as unusual and across
programming languages to be able to
access that tree directly but you can't
an R which makes it pretty neat so I'm
just going to show you the AB the ast
output for that first function and it
just tries to try to draw that tree as
closely as it can in the console you can
see that orange squares the function
call the first argument is the function
being the first child as the function
being called then we have the arguments
X the little Y and the number one and no
matter how complicated there gets let's
make it a little bit more complicated
oops now I've got too many parentheses
it'll just draw that tree for you it'll
also draw it for you you know even if
anew when you've got expressions that do
not immediately look like they're in
this form that the way the name of the
function is not the first thing so this
kind of allows us to like dig in a
little bit the how ours grammar works so
like when you add two numbers together
the plus function takes two arguments so
there's kind of two ways that our might
interpret this right it could do one
plus two and then add on three or it
could do one plus two plus three now
this doesn't matter most of the time
right because it doesn't matter for
addition it doesn't matter which order
you do it in but this is like really
important for packages where addition no
longer has this property so for example
in ggplot2 we use plus the order in
which you do the addition is actually
really important and is one reason why
the plus is not a great fit for GT Pro -
that's a different question it's a
different talk so when we when we print
this with ast you can see there's a
function called a plus the first
argument of that is another quarter plus
which is one plus two so this is the way
you describe this as R as lift
associative because it does the things
on the Left first the only exception to
that is like exponentiation which is
right associative it does the things on
the right first and it allows us to see
kind of other quirks of our like if you
do not x and y that is not going to do
not X and then see if that's and why
it's going to do is x and y and then
take the opposite of that this I think
is kind of one reason that there isn't
like a built-in like some people like
what a not in I guess you could I don't
know some people do something like this
well then you just write it like this
seems kind of pointless it also allows
us to see to dig into like other things
in in our that look even less like
function calls and multiplication and
assignment like so what about an if
statement how was that a function well
we can ask ast to draw that and it turns
out the F chord F is a function with
three arguments the first argument is
the condition the second argument is
what the return of the condition is true
and the third argument is what the
return of the condition is false well
similarly like one of the arguments to
the four function well the arguments the
four function are the name of the thing
that you're indexing over that the value
of the thing that you're indexing over
and in the body of the for loop or like
what is the function function what does
that do well the function function is a
function with three arguments so the
first argument is the arguments the
function the second argument is the body
of the function and the third argument
is the source riff which is the text of
the function and that's what enables you
when you print out a function you see
though all the comments and stuff inside
the function those are not normally
captured by the abstract syntax tree
because they're not syntax that's just
human readable stuff the ast just
captures stuff that arc is about so so
why should you care about this I think
one reason is this is an important part
of Tidy evaluation so tidy evaluation is
a toolkit that allows you to program
with packages like ggplot2 and deep liar
and it's powered by the Erlang function
our line package one of the cool
functions and the R Lang package is this
extra pack extra function what that does
is it basically captures what you give
it it just returns exactly the code that
you gave it but it also support an
quoting with this crazy bang bang
operator so the bang bang is called the
uncoding operator it's pronounced bang
bang obviously as
said like five times now but what it
does is easiest to see when once you
understand the code as a tree it's
really easy to draw what bang-bang does
so what Peng bang does is we have one
code tree here and one code tree here
the bangbang kind of defines like a hole
which we just insert that other tree
into so bangbang allows us to build up
complex trees from simple pieces so I've
explained that very very quickly and now
I'm going to give you all a challenge to
see if you can run this our code in your
head so see if you can figure out
predict what this is going to return
based on that extremely quick
description you have one minute starting
now
okay times up so what is this first call
gonna return just going to be X plus y
right because the expert just captures
what you gave it what about the second
one it should be pretty easy to
hopefully write X plus y plus Z you've
combined their first expression with the
second one what about the last one this
is a little challenging right because it
could return 1 over X 1 over X plus y or
1 over X plus y right it's hard to say
it's easier to show but it does actually
return the second one because we're
dealing with these trees those
parentheses kind of get inserted
automatically and and correctly and this
is kind of one of the reasons why I
think thinking about trees when you're
creating code in this way it's much
better than thinking about strings and
pasting strings together like an animal
because it preserves this important tree
like structure of the code so that's
another important aspect of our like you
can represent all code as a tree and the
thing that makes the every language does
that the thing that makes our special is
you can actually like capture that tree
it's a first-class type of object and I
even capture that tree and you can work
with it and that's what powers like
that's what allows D player to take your
our code and translate that into sequel
because inside DB play and actually like
computes on the tree of our code and
translates that to something else this
is sort of to me like one of the reasons
like it doesn't actually matter that our
is kind of relatively slow compared to
other programming languages because I
doesn't have to be fast it just makes
friends with other environments and you
can easily translate our code to those
other environments the one last thing I
wanted to talk about is something I only
discovered very recently just this idea
that call stacks or trace backs are not
actually stacks they're actually trees
so the kind of motivation is sort of
like is this basically
so I've created some function some
victor eyes function that I'm going to
use with ggplot2 and like deep in the
bowels of that function there's an error
and now when I use this inside ggplot2
and I print out the trace back it's kind
of hard to see like where my coders and
where ggplot2 coders like it's hard to
see like where is that where the source
of that problem like the the bit I
actually care about is kind of like my
code the if called G equal eight and in
that caused an error now I kind of
wanted to show you like what that would
look like with my proposed tools but
unfortunately it just this revealed a
bug and the way that works so we're
going to kind of work our way up with
some simple examples so it lobster
provides the CST function that stands
for call stack tree basically and so
this is kind of equivalent to trace back
but what's gonna do is it's gonna
display this in a tree like way and for
a simple function call like this you
know if cause JG calls HHH calls the CST
function you just see that as like a
tree with one state of one branch
basically if we every tree only has one
child so when there's when when
everything is eagerly evaluated it's
really simple things get more
complicated when you start using
functions that kind of let their worth
we're lazy evaluation comes in so I'm
going to use the identity function
before I will claim I think the identity
function is the simplest function in
base are you give it an argument X and
it simply returns that argument right
there's nothing well there's almost
nothing simpler than a function could do
but what this is what this is going to
cause is this this is gonna be like
lazily evaluated right because in our
function arguments are only evaluated
win then when they're needed in which
case this case is needed right away but
it adds some kind of complication to
that call stack tree so I'm going to
call identity identity if and see what
happens
and now we actually get this tree like
structure so we see identity calls and
the evaluation of this is only kind of
going to be triggered inside this
function so we get a new branch and then
we see our code at the end and like when
you start mixing like tries into the
pudding tries on the mix things start to
get more and more complicated and if
you've ever tried to debug a code that's
inside a try-catch you'll have noticed
like the trace pack includes all of
these weird parts these are these
details about how try-catch is
implemented that you are not you do not
actually care about because they're not
in your code and this tree like
structure makes it very easy to say well
the thing that you're actually
interested in is always like the
terminal branch of this tree and so my
hope is like with this understanding
this will allow us to make much much
simpler call stack much much more useful
trace back messages in our studio and in
the tidy base and I wanted to kind of
like one illustrate like one extreme
aspect of that and this is a call stack
generated from inside SHINee which so if
you've ever tried to debug like shiny
card shiny it's code is challenging to
debug because your code is embedded in
this much bigger framework for like
handling when your code should be
evaluated and if you like a look at the
full trace back and this is drawn as a
tree which makes it even which makes it
like at least feasible to understand but
you'll see like it's quite complicated
right like if there's like we're still
like going this still isn't even at my
my code yet we're still going and this
is actually the bit that you care about
like inside the rend up the render plot
you've called is the stop function this
is arrow that's that's this bit is what
you actually care about this is the bit
of your code that is important not the
rest of the Chinese infrastructure to
run your code and that's really when
you're just looking at the stack trace
linearly it's really hard to identify
that this ism this is the important bit
but it turns out like
to display it as a tree and think about
as a tree it's like really easy to say
now well in this case it's kind of a
stick and bright it's the second
terminal branch from the end and we can
hopefully in a future version of shiny
well I drill down and when you have an
error message you will see your era that
your code that caused the year and not
all of the infrastructure and shiny has
already done a bunch of work which is
this kind of stack trace on stuff which
to try and kind of make the stack trace
a little bit more manageable but this
sort of realization that this the stack
trace is actually a tree I think it's
gonna help profoundly like throughout
the tidy verse throughout in our studio
and shiny make error messages much much
or the tray specs more informative so
you can see exactly we are the problem
lies not what is all the other code
that's run your code that's eventually
caused the error so to sum up I've kind
of shown you how that's a terrible
showing you learn three by Handsome you
fix that okay so I have shown you three
big ideas that the previous title was I
you have learned three big ideas but I
thought that might be a little
aggressive given that I just showed them
to you very briefly but I have
definitely shown you three ideas I'm not
going to make any assertions about
whether you have understood them or
learned them or not but I think three
big ideas and this is not even in the
order in which I presented them
to see my process live here I spent so
much time learning is perfectly up so
three big ideas the first big idea I
think is the most important that like if
you can kind of separate the idea of
names or references from objects or
values you will be able to build up a
much more accurate mental model of like
what operations are going to be
expensive in your R code and by and
large the things that are expensive are
modifying objects not passing them to
functions or putting them on lists so if
you want to understand that in more
detail that that's the Rif function in
lobster which prints out kind of the
first time you see each value in an
object in a list or a set of lists or
set of objects and then shows you that
you're not actually copying things
you're just pointing to them or
referencing them the next big idea isn't
that are and is that all our code is a
tree so our code forms this thing called
the abstract syntax tree or AST for
short
you can display that with the lobster
AST function and that is anything
important to kind of understand that
basic idea if you want to use tidy
evaluation because that's what allows
you to safely insert your variable or
your expression and the big more
complicated expressions preserving
correct operator precedence and so on
it's also what allows me to create tools
like DB plier which lets you translate
our code to sequel code and finally it
took a little bit about this idea that
call stacks or trees I think that's
gonna be kind of like most important for
like me and other developers at our
studio because we can use this to create
you know better more informative trace
backs when you hit in the ER so
altogether I think these feed these
three things are three things that make
are a little bit different to other
programming languages there are very few
other programming languages that well
there's so some programming do make this
distinction between names and values and
other
do allow you to access code as a tree
and very few programming languages have
lazy evaluation but the combination of
these three things I think like makes
are special to me and that that's like
one of the things like kind of like I
personally get a huge amount of
satisfaction about learning this sort of
stuff about the our language and to me
like you know a lot of people look at
our and they like if they've experience
with other programming languages maybe
like they throw up a little bit in your
mouth because our is legitimately
different to other programming languages
but to me that that difference is
unambiguously a strength not a weakness
and sure many of these features do
actually make are like they kind of
fundamentally limit the computational
performance of our they mean that our is
never gonna be like as fast as Python or
as fast as C++ but they also mean that
that distinction is not actually that
important like our is a language that
has optimized for human performance not
computer performance and when you are
working with larger datasets
particularly the sickand features a huge
strength because you just leave your
data where it is you leave data in a
system that is designed specifically for
working with large datasets in the
high-performance way and then you write
our code and an our package translates
your our code to whatever that other
system understands and so you get the
seamless workflow where you can do very
rapid exploration of in-memory data with
our and then when you need to scale up
you talk to some other specialized
system thank you
you
you