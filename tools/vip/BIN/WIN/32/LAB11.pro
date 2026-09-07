/*****************************************************************************

		Copyright (c) My Company

 Project:  LAB11
 FileName: LAB11.PRO
 Purpose: No description
 Written by: Visual Prolog
 Comments:
******************************************************************************/

include "lab11.inc"

predicates  
	nondeterm rasp  
	nondeterm znach(integer) 
clauses  
	rasp:-  znach(F1),   
		znach(F2),
		znach(F3),
		znach(H1),
		znach(H3),
		znach(M2),
		znach(M3),
		znach(M4),
		znach(I4),   
		F1+F2+F3=1,
		H1+H3=1,
		M2+M3+M4=1,
		I4=1,
		F1+H1=1,
		F2+M2=1,
		F3+M3+H3=1,
		M4+I4=1,
	write("F1=",F1," F2=",F2," F3=",F3," H1=",H1," H3=",H3," M2=",M2," M3=",M3," M4=",M4," I4=",I4, " ").
	znach(B):-B=0;B=1. goal  rasp. 

