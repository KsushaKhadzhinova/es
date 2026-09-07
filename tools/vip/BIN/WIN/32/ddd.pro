/*****************************************************************************

		Copyright (c) My Company

 Project:  DDD
 FileName: DDD.PRO
 Purpose: No description
 Written by: Visual Prolog
 Comments:
******************************************************************************/

include "ddd.inc"

predicates
	
  nondeterm func(integer, integer,integer)
  
goal

  write("input number:"),
  readint(N),
  func(N,Y,0).
  
clauses

  func(0,Y, F):-Y=F.
  func(N,Y,F):-
  		N1=N-1,
  		F1=F-N,
  func(N1,Y,F1).

