/*****************************************************************************

		Copyright (c) My Company

 Project:  XFCZ
 FileName: XFCZ.PRO
 Purpose: No description
 Written by: Visual Prolog
 Comments:
******************************************************************************/

include "xfcz.inc"

predicates

 nondeterm min(integer,integer)

clauses
min(A,B):- A<=B.
min(B,A):- B>A.
goal
write("A= "),readint(A),
write("B= "),readint(B),
min(A,B),write("Minimum=",A),nl
min(B,A),write("Minimum=",B),nl .