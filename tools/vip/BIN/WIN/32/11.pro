/*****************************************************************************

		Copyright (c) My Company

 Project:  11
 FileName: 11.PRO
 Purpose: No description
 Written by: Visual Prolog
 Comments:
******************************************************************************/

    predicates
 nondeterm         equation
 nondeterm        znach(integer)
            
                              goal
                                          equation.
             clauses
                   
                 equation:-
                                     znach(X1),
                                     znach(X2),
                                     znach(X3),
                                     znach(X4),
                                     znach(X5),
                                    X2+X3+X4<=2,
                                    X2+X4+X5<=1,
                                    X3+X4+X5>=1,
                                    X1+X5<=1,
write("X1=",X1," X2=",X2," X3=",X3," X4=",X4," X5=",X5).                     

znach(0). 
znach(1).
