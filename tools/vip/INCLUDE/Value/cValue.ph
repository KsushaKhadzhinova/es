/*****************************************************************************

		Copyright (c) 1984 - 2000 Prolog Development Center A/S

				Visual Prolog

 Project:
 FileName: cValue.ph
 Purpose: Value domain declaraion for cException.pro
 Written by: Thomas Linder Puls
 Comments: Domain for exception handling system

******************************************************************************/
class cValue
    domains
        value =
            integer(integer Value);
            real(real Value);
            long(long Value);
            string(string Value);
            null_value

         record = value*
         record_list = record*

         namedValue =
             namedValue(string Name, value Value)

         namedValue_list = namedValue*
endclass cValue
