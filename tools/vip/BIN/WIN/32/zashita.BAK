/*****************************************************************************

		Copyright (c) My Company

 Project:  ZASHITA
 FileName: ZASHITA.PRO
 Purpose: No description
 Written by: Visual Prolog
 Comments:
******************************************************************************/

include "zashita.inc"

domains
li=integer*
predicates

  nondeterm zashita()
  nondeterm proizv(li, integer)
 

clauses

  zashita():-
  
  readterm(li,L),
  readchar(_),
  proizv(L, Proizv),
  write("Proizv", Proizv).
  proizv([], 1).
  proizv([X|Y], Proizv):-
  	proizv(Y, Proizv1),
  	Proizv = Proizv1 * X
  .

goal

  zashita().
