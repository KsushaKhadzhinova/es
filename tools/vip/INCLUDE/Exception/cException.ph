/*****************************************************************************

		Copyright (c) 1984 - 2000 Prolog Development Center A/S

				Visual Prolog

 Project:
 FileName: cException.ph
 Purpose: Predicate definitions for cException.pro
 Written by: Thomas Linder Puls
 Comments: Exception handling system declaration

******************************************************************************/
constants % module Info
    cException_ModuleName = "com/visual-prolog/cException"

%%- com/visual-prolog/cException
% Exception handling based on raise/continue traces, implemented by means of
% errorexit/trap
% @desc An exception is an deviation from the "normal" execution path.
% In this tool exceptions are to be understood as related to and including errors.
% But we want to stress that this tool is intended to work on the assumption that:
%
%    Most programs are expected to cope with most "error" situations,
%    and continue the execution in some sensible way, even if such an "error"
%    situation occurs.
%
% And with that assumption in mind the word "error" seems to be too strong.
%
% For a better overall understanding of what role exceptions play, I would like
% to state a breif paradigme description:
%
% Given a certain problem, we create a program.  This program is structured into
% parts, which each solve a certain part of the problem.  In order to keep the
% program simple (and thus understandable and maintainable, not to mention
% possible to write in the first place) it is essential that the job each part
% performs is as simple as possible.  And here exceptions play a central role:
% In order to keep a certain part of the program simple, we allow it to state that
% it is impossible to solve it task (i.e. to fulfill its invariant), because some
% well defined exception occured.
%
% If a program part decides that it can not fulfill its invariant, it "raise" an
% exception.
%
% Whenever you call some predicate you can choose to "trap" exceptions raised
% as part of the execution of that predicate.
%
% When you trap an exception you can basically do one of two things, either
%
% - you can deal with the exception, and continu with some sensible path of
%   execution (we say you handle the execption), or
% - you can decide that the exception also makes it impossible for you to
%   complete your task
%
% In order to decide whether you can handle the exception or not, you have to
% be able to know details about the exception.  And consequently, you also have
% to be able to state details about the exception when you raise it.
%
% This information is stored in the exception system, and if you decide that
% you handle the exception you have to "clear" the exception, which will remove
% information related to the exception from the exception system.
%
% If you have trapped an exception and decided that you can not handle the
% exception, then you "continue" the exception.  To continue an exception is
% similar to raising an exception, but a continued exception adds information to
% an already raised exception.  In general this creates an exception "trace",
% which is a sequence, consisting of a "raise" and a number of "continues".
%
% By now we have defined the basic foundation of the exception system:  We
% start an exception trace by "raising" and exception, the exception is then
% "trapped" and the trace is "continued" zero or more times until it is finally
% "cleared" when the exception is handled.
%
% There are however a number of things that complicates matters further.
%
% First of all it might be the case that an other exception is raised during
% the handling of an exception, i.e. in the handler-part of a trap.  There is
% no problems with such a nested exception, as long as it is not propagated
% out of the handler-part of the trap.  The only excption that must ever be
% propagated out of the handler-part of a trap is the exception that was
% trapped by the trap, i.e. the handler-part may "continue" the original
% exception, but not propagate a new one.
%
% If this invariant is maintained then all exception traces are handled in a
% "stack" fasion.  Inner exceptions are always cleared before outer execptions
% are cleared ot continued.  The exception system will it self raise an exception
% if this stack principle is violated (resulting in an even more complex exception
% state).
%
% Another situation that might occur is that the programmer forget to clear,
% a handled exception.  If this is forgotten in a nested exception, then the
% result will most likely be a violation of the stack principle in the exception
% tool.  If on the other hand it happens for an outermost exception, then the
% result will simply be a trace left in the exception system.  In order to detect
% this kind of programming error it might thus be necessary to examine the
% state of the exception system in suitable places (for example at program
% termination).
%
% Yet another situation that can occur is that an exception is "continued" beyond
% the outermost trap.  I.e. no body was able to handle the exception, and
% therefore it is propagated all the way out of the program.  Visual Prolog makes
% it possible to install an "outermost" handler, and it is a good idea to examine
% the state of the exception system in such a handler.
%
% The last two situations, calls for examination of the complete state of the
% exception system.  Subsequently the exception system provides possibility
% to retrieve the complete state of the system.  It also has possibility to clear
% the complete state of the system.
%
% A "forever" running server program might thus regularly dump the state of the
% exception system to a log file and clear the state afterwards (so that subsequent
% dumps do not repeat previous dumps).
%
% Notice that it is out of the scope of the exception system itself to output its
% state.  Mainly to the exception system independent of the dump media and format.
%--

include "value\\cValue.ph"

constants % exceptions, messages and fields
    cException_error_nonLast = 1
    cException_errorMsg_nonLast = "Attempt to clear or continue a non-last exception"
        % id that was attempted cleared/continued
        cException_field_id = "id"

    % Unknown errors have their own error code
    cException_errorMsg_UnknownError = "Unknown error"

    % Fields for external errors
        % Error code
        cException_field_code = "code"
        % short help description
        cException_field_help = "help"
        % long description
        cException_field_description = "description"


constants % this is used for unknown modules (i.e. external errors)
    cException_unknownModuleName = "unknown"
    cException_unknownMajorVersion = 0
    cException_unknownMinorVersion = 0
    cException_unknownVersionYear = 2000
    cException_unknownVersionMonth = 1
    cException_unknownVersionDate = 1

constants % module constants
    % exceptionId's below firstTraceId are error codes, above they are exception trace ids
    firstTraceId = 100000

class cException
    %%- moduleInfoPredicate
    % module information and identification
    % @desc Each module should define a public module info predicate
    % This predicate plays two roles:
    %
    % 1. It provides version information about the module
    % 2. The predicate itself is used as a module identifier
    %
    % All predicate values are unique, so even if two modules should have the same
    % module information, they will still have distinct module info predicates.  Therefore,
    % the module info predicates can be used as module identifier.
    %--
    domains
        moduleInfoPredicate =
            procedure (
                string ModuleName,
                integer MajorVersion,
                integer MinorVersion,
                integer Year,
                integer Month,
                integer Date)
            - (o,o,o,o,o,o)


    %%- moduleInfo : moduleInfoPredicate
    % module info predicate for exception system itself
    %--
    static predicates
        moduleInfo : moduleInfoPredicate


    %%- unknownModuleInfo : moduleInfoPredicate
    % module info predicate used for unknown exceptions (i.e. raised by an unknown module)
    % @desc unknownModuleInfo is used as module identfier for exceptions detected by the
    % exception system, but which are not raised by means of the exception system.
    % Typically system errors and exceptions/errors raised according to other
    % ("old style") principles
    %--
    static predicates
        unknownModuleInfo : moduleInfoPredicate


    %%- exceptionId
    % ids of exception traces
    % @desc
    %--
    domains
        exceptionId = integer

    %%- exceptionId
    % ids of exception traces
    %--
    domains
        errorCode = integer

    % interrogate exception state
    domains
        kind =
            raiseKind();
            continueKind();
            externalKind()

        position =
            position(string FileName, string IncludeFile, integer Position)

       timeStamp =
           timeStamp(integer Year, integer Month, integer Day,
               integer Hours, integer Minutes, integer Seconds, integer HS)

        descriptor =
            descriptor(
                exceptionId ExceptionId,
                moduleInfoPredicate ModuleInfoPredicate,
                errorCode ErrorCode,
                string Description,
                cValue::namedValue_list ExtraInfo,
                kind Kind,
                timeStamp TimeStamp,
                position Position)

    % raise exception
    static predicates
        raise(
            moduleInfoPredicate ModuleInfoPredicate,
            errorCode Code,
            string Description)
        - erroneous (i,i,i)
        raise(
            moduleInfoPredicate ModuleInfoPredicate,
            errorCode Code,
            string Description,
            cValue::namedValue_list ExtraInfo)
        - erroneous (i,i,i,i)

    % continue/reraise exception
    static predicates
        continue(
            exceptionId ExceptionIdOrCode,
            moduleInfoPredicate ModuleInfoPredicate,
            errorCode ErrorCode,
            string Description)
        - erroneous (i,i,i,i)
        continue(
            exceptionId ExceptionIdOrCode,
            moduleInfoPredicate ModuleInfoPredicate,
            errorCode ErrorCode,
            string Description,
            cValue::namedValue_list ExtraInfo)
        - erroneous (i,i,i,i,i)

        % plain reraise (should only be used, where trapping was done solely to release resources)
        continue(
            exceptionId ExceptionIdOrCode)
        - erroneous (i)

    % clear exception
    static predicates
        clear(exceptionId ExceptionId)
        - procedure (i)

    % interrogate the exception state
    static predicates
        % check for certain exception
        descriptor getDescriptor_det(
            exceptionId ExceptionId,
            moduleInfoPredicate ModuleInfoPredicate,
            errorCode Code)
        - determ (i,i,i)

        % get a whole exception trace
        descriptor getDescriptor_nd(
            exceptionId ExceptionId)
        - nondeterm (i)

        % get an exception trace, filtedred for a specific module.
        % I.e. get those entries in a certain trace that relates to a certain module
        descriptor getDescriptor_nd(
            exceptionId ExceptionId,
            moduleInfoPredicate ModuleInfoPredicate)
        - nondeterm (i,i)

        % get the whole exception state, i.e. all traces.
        descriptor getAllTraces_nd()
        - nondeterm ()

    static predicates
        clearExceptionState() - procedure ()
endclass cException
