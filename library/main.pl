/*  $Id$

    Part of SWI-Prolog

    Author:        Jan Wielemaker
    E-mail:        jan@swi.psy.uva.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 1985-2002, University of Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- module(prolog_main,
	  [ main/0
	  ]).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
This library is intended for supporting   PrologScript on Unix using the
#! magic sequence for scripts  using   commandline  options. Main/0 will
call main/1 passing a list of commandline   options.  Below is `echo' in
Prolog (adjust /usr/bin/pl to where SWI-Prolog is installed)

#!/usr/bin/pl -q -g main -s

main(Argv) :-
	echo(Argv).

echo([]) :- nl.
echo([Last]) :- !,
	write(Last), nl.
echo([H|T]) :-
	write(H), write(' '),
	echo(T).

NOTE: Xpce users should have a look at library(pce_main), which starts the
GUI and processes events until all windows have gone.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

:- module_transparent
	main/0.

%	main
%
%	Call main/1 using the passed command-line arguments.

main :-
	on_signal(int, _, prolog_main:interrupt),
	context_module(M),
	current_prolog_flag(argv, Argv),
	(   append(_, [--|Av], Argv)
	->  run_main(M, Av)
	;   run_main(M, [])
	).
	
%	run_main(+Module, +Args)
%
%	Run the main routine, guarding for exceptions and failure of the
%	main/1 routine

run_main(Module, Av) :-
	(   catch(call(Module:main, Av), E, true)
	->  (   var(E)
	    ->	halt(0)
	    ;	print_message(error, E),
		halt(1)
	    )
	;   print_message(error, goal_failed(main(Av))),
	    halt(1)
	).

%	interrupt(+Signal)
%
%	We received an interrupt.  This handler is installed using
%	on_signal/3.

interrupt(_Sig) :-
	halt(1).
		  
