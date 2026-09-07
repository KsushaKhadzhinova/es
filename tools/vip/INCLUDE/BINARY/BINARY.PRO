/*****************************************************************************

		Copyright (c) 1984 - 2000 Prolog Development Center A/S

				Visual Prolog

 Project:
 FileName: BINARY.PRO
 Purpose: Some additive predicates for binary
 Written by: Compiler Group & Konstantin Ivanov
 Comments:

 อออออออออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออ
  Date Modified,บ By,  บ  Comments.
 อออออออออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออ
		บ      บ

******************************************************************************/
ifndef binary_pre_included
 #Error : file binary.pre must be included
enddef

ifndef error_con_included
 #Error : file error.con must be included
enddef

clauses
  mergeBinary( Head, Tail, Result ) :-
	Size_head = getbinarysize( Head ),
	Size_tail = getbinarysize( Tail ),
	Size_Result = Size_head + Size_tail,
	Result = makebinary( Size_Result ),
	movmem( Head, Result, Size_head ),
	Result_begaddr = cast( ULONG, Result ),
	Result_lastaddr = Result_begaddr + Size_head,
	Tail_ul = cast( ULONG, Tail ),
	movmem( Tail_ul, Result_lastaddr, Size_tail ).

  splitBinary( Source, LengthOfHead, $[00], $[00] ) :-
	Size_source  = getbinarysize( Source ),
	LengthOfHead > Size_source, !,
	run_Error( err_arrayindex ).
  splitBinary( Source, LengthOfHead, Head, Tail ) :-
	Size_source  = getbinarysize( Source ),
	LengthOfTail = Size_source - LengthOfHead,
	Head = makebinary( LengthOfHead ),
	Tail = makebinary( LengthOfTail ),
	movmem( Source, Head, LengthOfHead ),
	Source_begaddr = cast( ULONG,Source ),
	Source_lastaddr = Source_begaddr + LengthOfHead,
	Tail_ul = cast( ULONG, Tail ),
	movmem( Source_lastaddr, Tail_ul, LengthOfTail ).
