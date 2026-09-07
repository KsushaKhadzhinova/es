/* =====================================================================
   ЛАБОРАТОРНЫЕ РАБОТЫ №5 и №6 (делаются вместе).  Вариант 5.
   Тема: продукционная база знаний (лаб.5) + механизм обратного
   логического вывода и подсистема объяснений (лаб.6).

   ЗАДАНИЕ (вариант 5):
   Экспертная система "Наблюдение за вулканом" - оценивает угрозу
   извержения и советует действия (правила см. в LAB6_variant5.txt /
   ниже в комментарии, они перенесены в базу знаний volkan.dba):

     - N<10 землетрясений/сутки и грозы редко      -> извержение не угрожает
     - N<10 землетрясений/сутки, но грозы участились-> возможно извержение
                                                        в ближайший месяц
     - N>15 землетрясений/сутки                     -> извержение в
                                                        ближайшие 5 дней
     - 10<=N<=15 и есть изменения в составе газов   -> извержение в
                                                        ближайшие 10 дней
     - 10<=N<=15 и изменений в газах нет            -> извержение в
                                                        ближайшие 20 дней
     - вывод "10 дней"  -> нужна эвакуация
     - вывод "20 дней"  -> готовность к эвакуации
     - вывод "месяц"    -> усиленное наблюдение
     - вывод "не угрожает" -> действия не требуются
     - вывод "5 дней"   -> немедленная эвакуация (максимальная угроза;
                            это правило добавлено нами, т.к. в тексте
                            задания явно не сказано, что делать при самом
                            опасном прогнозе - см. пояснение в отчёте)

   ДОПОЛНИТЕЛЬНО по варианту 5 (это то, что отличает лаб.5 от базового
   примера в методичке): в меню должен быть пункт "как" - при обращении
   к нему на экран выводится СПИСОК ВСЕХ ПЕРЕМЕННЫХ, имеющихся в базе
   знаний (perem/2), пользователь выбирает одну из них, и ему выводится
   ПОЛНОЕ объяснение процесса вывода этой переменной (по какому правилу
   она получена и как получены переменные из условия этого правила -
   рекурсивно), либо сообщение, что значение введено пользователем.

   КАК УСТРОЕН ФАЙЛ (соответствие разделам методички):
     global domains / global facts (п.5.3) - описание базы знаний:
        rule(Номер, УсловнаяЧасть, Заключение)
        perem(Имя, ТекстЗапроса)       - описание переменной (п.5.3;
                                          в книге называется var, здесь
                                          переименовано в perem, как и
                                          предлагает сама методичка)
        goal_var(Имя)                  - целевая переменная
        znach(Имя, Значение)           - "текущая база данных" -
                                          значения, найденные в ходе
                                          КОНКРЕТНОЙ консультации
        istochnik(Имя, Откуда)         - ДОПОЛНИТЕЛЬНО для подсистемы
                                          объяснений (не из методички):
                                          запоминаем, откуда взялось
                                          каждое значение - введено
                                          пользователем (polzovatel) или
                                          получено по правилу N (pravilo(N))
     obr_vyvod / proverka / prov1 (п.6.2) - механизм обратного вывода
     kak / obyasni (доп. для варианта 5)  - подсистема объяснений
   ===================================================================== */

global domains
    uslovie = eq(string,string);
              ne(string,string);
              gt(string,string);
              lt(string,string);
              le(string,string);
              ge(string,string)
    usl = uslovie*
    zakl = assign(string,string)
    otkuda = polzovatel;
             pravilo(integer)

global facts
    rule(integer, usl, zakl)
    perem(string, string)
    goal_var(string)
    znach(string, string)
    istochnik(string, otkuda)

predicates
    nondeterm start
    nondeterm obrab(integer)

    nondeterm zagruzka
    nondeterm prosmotr_bz
    nondeterm pechat_peremennye
    nondeterm pechat_pravila

    nondeterm vyvod
    nondeterm obr_vyvod(string, string)
    nondeterm proverka(usl)
    nondeterm prov1(uslovie)

    nondeterm kak
    nondeterm pechat_spisok_peremennyh
    nondeterm obyasni(string, integer)
    nondeterm obyasni_uslovie_spisok(usl, integer)
    nondeterm otstup_pechat(integer)
    nondeterm pechat_uslovie_spisok(usl)
    nondeterm pechat_uslovie(uslovie)
    nondeterm uslovie_peremennaya(uslovie, string)
    nondeterm repeat

goal
    start.

clauses
    /* repeat - НЕ встроенный предикат этого диалекта Пролога, его нужно
       определить самим (методичка, п.1.6.2). */
    repeat.
    repeat:- repeat.

    /* ------------------------------ МЕНЮ -------------------------------- */
    start:-
        repeat,
        nl,
        write("=== ЭС: угроза извержения вулкана (лаб.5-6, вариант 5) ==="), nl,
        write("1 - загрузка базы знаний"), nl,
        write("2 - просмотр базы знаний"), nl,
        write("3 - консультация"), nl,
        write("4 - как (подсистема объяснений)"), nl,
        write("99 - выход"), nl,
        write("Введите номер: "), readint(N),
        obrab(N).

    obrab(1):- zagruzka, !, fail.
    obrab(2):- prosmotr_bz, !, fail.
    obrab(3):- vyvod, !, fail.
    obrab(4):- kak, !, fail.
    obrab(99):- write("Выход."), nl.
    obrab(_):- write("Нет такого пункта меню."), nl, fail.

    /* --------------------- 1. ЗАГРУЗКА БАЗЫ ЗНАНИЙ (п.3.3, п.5.5) -------
       retractall убирает из памяти факты предыдущей загрузки (rule,
       perem, goal_var), чтобы они не задваивались при повторной загрузке. */
    zagruzka:-
        write("Введите имя файла базы знаний (например, volkan.dba): "),
        readln(F),
        retractall(rule(_,_,_)),
        retractall(perem(_,_)),
        retractall(goal_var(_)),
        consult(F), !,
        write("База знаний загружена: ", F), nl.
    zagruzka:-
        write("Загрузка отменена."), nl.

    /* --------------------- 2. ПРОСМОТР БАЗЫ ЗНАНИЙ ----------------------- */
    prosmotr_bz:-
        write("--- Переменные ---"), nl,
        pechat_peremennye,
        write("--- Правила ---"), nl,
        pechat_pravila,
        goal_var(G),
        write("--- Целевая переменная: ", G, " ---"), nl.

    pechat_peremennye:-
        perem(Name, Zapros),
        write(Name, "  (запрос: '", Zapros, "')"), nl,
        fail.
    pechat_peremennye.

    pechat_pravila:-
        rule(N, Usl, assign(V,Val)),
        write("Правило ", N, ": ЕСЛИ "), pechat_uslovie_spisok(Usl),
        write(" ТО ", V, "=", Val), nl,
        fail.
    pechat_pravila.

    /* --------------------- 3. КОНСУЛЬТАЦИЯ (п.6.2 методички) -------------
       Это ЯДРО лаб.6 - механизм обратного логического вывода. Работает
       ТОЧНО как описано в методичке: узнаём имя целевой переменной
       (goal_var), пытаемся определить её значение (obr_vyvod). */
    vyvod:-
        retractall(znach(_,_)),
        retractall(istochnik(_,_)),
        goal_var(G),
        obr_vyvod(G, Result),
        nl, write("Решение: ", Result), nl,
        write("(подробности вывода можно посмотреть через пункт меню 'как')"), nl,
        !.
    vyvod:-
        nl, write("Цель не найдена: данных недостаточно, либо они противоречивы."), nl.

    /* obr_vyvod(G,Result) - определить значение переменной G.
       Три клоза (в точности по методичке, п.6.2):
       1) значение уже известно (найдено раньше в этой же консультации);
       2) переменную нужно спросить у пользователя (есть текст запроса);
       3) значение нужно вывести по какому-либо правилу базы знаний.
       ДОБАВЛЕНО (не из методички): assert(istochnik(...)) в клозах 2 и 3 -
       запоминаем, ОТКУДА взялось значение, чтобы потом это можно было
       объяснить пользователю (пункт меню "как", см. ниже). */
    obr_vyvod(G, Result):-
        znach(G, Result), !.

    obr_vyvod(G, Result):-
        perem(G, Zapros), Zapros <> "",
        write(Zapros), readln(Result),
        assert(znach(G, Result)),
        assert(istochnik(G, polzovatel)), !.

    obr_vyvod(G, Result):-
        rule(N, Usl, assign(G, Result)),
        proverka(Usl),
        assert(znach(G, Result)),
        assert(istochnik(G, pravilo(N))), !.

    /* proverka/prov1 - проверка условной части правила (список условий,
       объединённых операцией "И"). В точности по методичке, п.6.2.
       Для числовых сравнений (gt/lt/ge/le) используется стандартный
       предикат str_real, переводящий строку в вещественное число,
       так как в базе знаний все величины хранятся как строки. */
    proverka([]):- !.
    proverka(Usl):-
        Usl = [H|T],
        prov1(H),
        proverka(T).

    prov1(Uslovie):-
        Uslovie = eq(Perem,Vel), !,
        obr_vyvod(Perem, X),
        X = Vel.
    prov1(Uslovie):-
        Uslovie = ne(Perem,Vel), !,
        obr_vyvod(Perem, X),
        X <> Vel.
    prov1(Uslovie):-
        Uslovie = gt(Perem,Vel), !,
        obr_vyvod(Perem, X),
        str_real(Vel, NVel), str_real(X, NX),
        NX > NVel.
    prov1(Uslovie):-
        Uslovie = lt(Perem,Vel), !,
        obr_vyvod(Perem, X),
        str_real(Vel, NVel), str_real(X, NX),
        NX < NVel.
    prov1(Uslovie):-
        Uslovie = ge(Perem,Vel), !,
        obr_vyvod(Perem, X),
        str_real(Vel, NVel), str_real(X, NX),
        NX >= NVel.
    prov1(Uslovie):-
        Uslovie = le(Perem,Vel),
        obr_vyvod(Perem, X),
        str_real(Vel, NVel), str_real(X, NX),
        NX <= NVel.

    /* --------------------- 4. "КАК" - ПОДСИСТЕМА ОБЪЯСНЕНИЙ ---------------
       Это то, что специфично именно для варианта 5 (см. Es5z.docx):
       выводим список ВСЕХ переменных базы знаний (perem/2 хранит их
       все, включая и "внутренние", без текста запроса), пользователь
       вводит имя одной из них, и печатается полное объяснение того,
       как она была получена в ходе ПОСЛЕДНЕЙ проведённой консультации
       (пункт меню 3). Если консультация ещё не проводилась (или эта
       переменная в ней не понадобилась) - явно сообщаем об этом. */
    kak:-
        nl, write("Список всех переменных базы знаний:"), nl,
        pechat_spisok_peremennyh,
        nl, write("Введите имя переменной для объяснения: "), readln(V),
        obyasni(V, 0),
        nl, write("Нажмите любую клавишу..."), readchar(_).

    pechat_spisok_peremennyh:-
        perem(Name, _), write(" - ", Name), nl, fail.
    pechat_spisok_peremennyh.

    /* obyasni(V,Otstup) - Otstup (отступ) нужен только для красивого
       вложенного вывода, когда объяснение одной переменной ссылается
       на объяснение другой (переменные из условия сработавшего правила). */
    obyasni(V, Otstup):-
        istochnik(V, polzovatel), !,
        znach(V, Val),
        otstup_pechat(Otstup),
        write(V, " = ", Val, "   (введено пользователем)"), nl.
    obyasni(V, Otstup):-
        istochnik(V, pravilo(N)), !,
        znach(V, Val),
        rule(N, Usl, assign(V,Val)),
        otstup_pechat(Otstup),
        write(V, " = ", Val, "   (получено по правилу ", N, "):"), nl,
        otstup_pechat(Otstup), write("  ЕСЛИ "), pechat_uslovie_spisok(Usl),
        write(" ТО ", V, "=", Val), nl,
        Otstup1 = Otstup + 1,
        obyasni_uslovie_spisok(Usl, Otstup1).
    obyasni(V, Otstup):-
        otstup_pechat(Otstup),
        write("Переменная ", V, " не участвовала в последней консультации ",
              "(значение не определялось; либо имя переменной введено неверно)."), nl.

    obyasni_uslovie_spisok([], _):- !.
    obyasni_uslovie_spisok([H|T], Otstup):-
        uslovie_peremennaya(H, Var),
        obyasni(Var, Otstup),
        obyasni_uslovie_spisok(T, Otstup).

    otstup_pechat(0):- !.
    otstup_pechat(N):- N > 0, write("    "), N1 = N-1, otstup_pechat(N1).

    /* -------------------- вспомогательная печать условий ----------------- */
    pechat_uslovie_spisok([H]):- !, pechat_uslovie(H).
    pechat_uslovie_spisok([H|T]):- pechat_uslovie(H), write(" И "), pechat_uslovie_spisok(T).

    pechat_uslovie(eq(V,Z)):- !, write(V,"=",Z).
    pechat_uslovie(ne(V,Z)):- !, write(V,"<>",Z).
    pechat_uslovie(gt(V,Z)):- !, write(V,">",Z).
    pechat_uslovie(lt(V,Z)):- !, write(V,"<",Z).
    pechat_uslovie(ge(V,Z)):- !, write(V,">=",Z).
    pechat_uslovie(le(V,Z)):- write(V,"<=",Z).

    uslovie_peremennaya(eq(V,_),V):- !.
    uslovie_peremennaya(ne(V,_),V):- !.
    uslovie_peremennaya(gt(V,_),V):- !.
    uslovie_peremennaya(lt(V,_),V):- !.
    uslovie_peremennaya(ge(V,_),V):- !.
    uslovie_peremennaya(le(V,_),V).
