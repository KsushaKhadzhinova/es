/*****************************************************************************

		Copyright (c) 1984 - 2000 Prolog Development Center A/S

 Project:
 FileName: APIUTILS.PRO
 Purpose: Useful predicates that use OS API Calls
 Written by: Konstantin Ivanov & Compiler Group
 Comments:
******************************************************************************/

ifdef ws_win
  ifndef apicalls_con_included
    #Error apicalls.con must be included
  enddef
  ifndef types_dom_included
    #Error types_dom must be included
  enddef
  ifndef apicalls_dom_included
    #Error apicalls.dom must be included
  enddef
  ifndef apicalls_pre_included
    #Error apicalls.pre must be included
  enddef
  ifndef apicalls_pro_included
    #Error apicalls.pro must be included
  enddef
enddef

predicates

  procedure STRING numberFormat( DWORD Value ) - (i)

ifndef os_nt
  ifdef ws_win
    procedure STRING numberFormat1( STRING, STRING, STRING )
  enddef
enddef

clauses

  numberFormat( Value, Result ) :-
ifdef os_nt
  	SDig = api_GetLocaleInfo( api_LOCALE_USER_DEFAULT, api_LOCALE_IDIGITS ),
	str_int( SDig, IDig ),
	IDig <> 0, !,
  	SDec = api_GetLocaleInfo( api_LOCALE_USER_DEFAULT, api_LOCALE_SDECIMAL ),
	str_len( SDec, LSDec ),
	term_str( DWORD, Value, S ),
	S2 = api_GetNumberFormat( api_LOCALE_USER_DEFAULT, [0], S, 0 ),
	str_len( S2, L ),
	Pos = L-IDig-LSDec,
	substring( S2, 1, Pos, Result );

	term_str( DWORD, Value, S ),
	Result = api_GetNumberFormat( api_LOCALE_USER_DEFAULT, [0], S, 0 ).
elsedef
  ifdef ws_win
	term_str( DWORD, Value, String ),
	Delim = api_GetProfileString( "intl", "sThousand", "" ),
	str_len( String, Len ),
	X = Len mod 3,
	frontstr( X, String, Start, Rest ),
	Result = numberFormat1( Rest, Start, Delim ),!.
  numberFormat( _Value, "" ) :-errorexit(). % Should never be called !

	  numberFormat1( "", FString, _, FString ) :-!.
	  numberFormat1( String, "", Delim, FString ) :-
		frontstr( 3, String, Start1, Rest ),!,
		FString = numberFormat1( Rest, Start1, Delim ).
	  numberFormat1( String, Start, Delim, FString ) :-
		frontstr( 3, String, Element, Rest ),
		concat( Start, Delim, Start1 ),
		concat( Start1, Element, Start2 ),!,
		FString = numberFormat1( Rest, Start2, Delim ).
	  numberFormat1( _String, FString, _Delim, FString ) :-errorexit(). % Should never be called !
  elsedef
	term_str( DWORD, Value, Result ).
  enddef
enddef
