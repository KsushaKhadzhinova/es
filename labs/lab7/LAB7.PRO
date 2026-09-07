/* =====================================================================
   ЛАБОРАТОРНАЯ РАБОТА №7.  Вариант 5.
   Тема: методы и алгоритмы распознавания в экспертных системах.

   ЗАДАНИЕ (вариант 5): ЭС для выявления неисправностей линий
   электропередач по концентрации ацетилена (X1) и углеводородов (X2)
   в трансформаторном масле. Три вида неисправности: Н1, Н2, Н3.
   Обучающее множество (9 случаев, см. Es 7_8.docx):

       Класс   X1(ацетилен)  X2(углеводороды)
       Н1        22             13
       Н1        25             12
       Н1        24             14
       Н2         5             27
       Н2         8             24
       Н2        10             22
       Н3        26             28
       Н3        23             20
       Н3        17             26

   Распознаваемый объект: X1=24 (ацетилен), X2=18 (углеводороды).

   Программа делает ВСЁ, что требует задание (п. "Порядок выполнения
   работы" методички лаб.7):
     1) решающие функции на основе минимального расстояния (п.7.2);
     2) распознавание объекта этими функциями;
     3) разделяющие решающие функции по алгоритму восприятия (п.7.3.1)
        для ВСЕХ трёх пар классов (пара 1-2 подробно проверена ВРУЧНУЮ -
        расчёт приведён в комментарии ниже; пары 1-3 и 2-3 - только
        программой, как и требует вариант задания);
     4) распознавание объекта разделяющими функциями (п.7.3.2).

   Признаки НЕ приводились к безразмерному виду (в отличие от примера
   в методичке про склады): здесь оба признака - концентрации в одних
   и тех же единицах (%) и одного порядка величин, поэтому нормировка
   не требуется (это отдельно нужно отметить в отчёте).

   -------------------- РУЧНОЙ РАСЧЁТ D12 (для отчёта) -------------------
   Алгоритм восприятия (п.7.3.1), начальные веса W0=W1=W2=0, объекты
   перебираются по кругу H1,H1,H1,H2,H2,H2,...:

     (22,13) H1: D=0            -> неверно, W:=(1,22,13),  E=0
     (25,12) H1: D=707          -> верно,   E=1
     (24,14) H1: D=711          -> верно,   E=2
     (5,27)  H2: D=462          -> неверно, W:=(0,17,-14), E=0
     (8,24)  H2: D=-200         -> верно,   E=1
     (10,22) H2: D=-138         -> верно,   E=2
     (22,13) H1: D=192          -> верно,   E=3
     (25,12) H1: D=257          -> верно,   E=4
     (24,14) H1: D=212          -> верно,   E=5
     (5,27)  H2: D=-293         -> верно,   E=6 = общее число объектов - СТОП

   Итог:  D12 = 17*X1 - 14*X2  (W0=0)
   Проверка программой ниже должна дать ТЕ ЖЕ коэффициенты для пары 1-2.
   ===================================================================== */

domains
    tri = t(string, real, real)     /* класс, X1, X2 */
    spisok_ob = tri*

facts   /* локальная (не global) изменяемая "память" для алгоритма восприятия -
           тот же приём накопления значений через assert/retract, что и в
           лаб.3 (предикат summa, п.3.7 методички), только счётчиков два:
           ves         - текущие коэффициенты W0,W1,W2 разделяющей функции;
           schetchik   - сколько объектов ПОДРЯД распознано верно;
           ukazatel    - "указатель", какой по счёту объект берём следующим
                          (крутится по кругу от 0 до Vsego-1). */
    ves(real, real, real)
    schetchik(integer)
    ukazatel(integer)

predicates
    nondeterm start

    nondeterm obuch_h1(spisok_ob)
    nondeterm obuch_h2(spisok_ob)
    nondeterm obuch_h3(spisok_ob)

    nondeterm dlina(spisok_ob, integer)
    nondeterm summa_spiska(spisok_ob, real, real)
    nondeterm prototip(spisok_ob, real, real)

    nondeterm reshfunk_rasst(real, real, real, real, real)
    nondeterm vybor_klassa_rasst(real, real, real, string)

    nondeterm element_spiska(spisok_ob, integer, tri)
    nondeterm vzyat_obj(integer, spisok_ob, spisok_ob, integer, integer, real, real)
    nondeterm obrabotat_obj(integer, real, real)
    nondeterm proverit_i_korrekt(integer, real, real, real, real, real, real)
    nondeterm obuchit_cikl(spisok_ob, spisok_ob, integer, integer)
    nondeterm train_pair(spisok_ob, spisok_ob, real, real, real)

    nondeterm vybor_klassa_razdel(real, real, real, string)

goal
    start.

clauses
    /* ---------------------- ОБУЧАЮЩЕЕ МНОЖЕСТВО -------------------------- */
    /* Три отдельных списка (по одному на класс) - удобно и для расчёта
       прототипов (среднее по классу), и для обучения разделяющих функций
       (нужно явно указывать, какие два класса сравниваем). */
    obuch_h1([t("Н1",22,13), t("Н1",25,12), t("Н1",24,14)]).
    obuch_h2([t("Н2",5,27),  t("Н2",8,24),  t("Н2",10,22)]).
    obuch_h3([t("Н3",26,28), t("Н3",23,20), t("Н3",17,26)]).

    /* --------------------------- ГЛАВНЫЙ СЦЕНАРИЙ ------------------------- */
    start:-
        write("=== Лаб.7, вариант 5: диагностика ЛЭП по решающим функциям ==="), nl,
        NovX1 = 24, NovX2 = 18,
        write("Распознаваемый объект: X1(ацетилен)=", NovX1,
              "  X2(углеводороды)=", NovX2), nl, nl,

        /* ---------- ЧАСТЬ 1-2: решающие функции минимального расстояния ---- */
        write("--- Часть 1-2: решающие функции на основе минимального расстояния ---"), nl,
        obuch_h1(L1), obuch_h2(L2), obuch_h3(L3),
        prototip(L1, P1x, P1y), prototip(L2, P2x, P2y), prototip(L3, P3x, P3y),
        write("Прототип Н1 (среднее по классу): (", P1x, ", ", P1y, ")"), nl,
        write("Прототип Н2 (среднее по классу): (", P2x, ", ", P2y, ")"), nl,
        write("Прототип Н3 (среднее по классу): (", P3x, ", ", P3y, ")"), nl,
        reshfunk_rasst(NovX1, NovX2, P1x, P1y, D1),
        reshfunk_rasst(NovX1, NovX2, P2x, P2y, D2),
        reshfunk_rasst(NovX1, NovX2, P3x, P3y, D3),
        write("D1 = ", D1, "   D2 = ", D2, "   D3 = ", D3), nl,
        vybor_klassa_rasst(D1, D2, D3, Klass1),
        write("=> По минимальному расстоянию объект отнесён к классу: ", Klass1), nl,
        nl, write("Нажмите любую клавишу для продолжения..."), readchar(_), nl,

        /* ---------- ЧАСТЬ 3-4: разделяющие функции (алгоритм восприятия) --- */
        write("--- Часть 3-4: разделяющие решающие функции (алгоритм восприятия) ---"), nl,
        train_pair(L1, L2, W0_12, W1_12, W2_12),
        write("D12 = ", W1_12, "*X1 + (", W2_12, ")*X2 + (", W0_12, ")   [проверьте с ручным расчётом в комментарии в начале файла!]"), nl,
        train_pair(L1, L3, W0_13, W1_13, W2_13),
        write("D13 = ", W1_13, "*X1 + (", W2_13, ")*X2 + (", W0_13, ")   [вычислено программой]"), nl,
        train_pair(L2, L3, W0_23, W1_23, W2_23),
        write("D23 = ", W1_23, "*X1 + (", W2_23, ")*X2 + (", W0_23, ")   [вычислено программой]"), nl,

        D12 = W0_12 + W1_12*NovX1 + W2_12*NovX2,
        D13 = W0_13 + W1_13*NovX1 + W2_13*NovX2,
        D23 = W0_23 + W1_23*NovX1 + W2_23*NovX2,
        write("Для нашего объекта: D12=", D12, "  D13=", D13, "  D23=", D23), nl,
        vybor_klassa_razdel(D12, D13, D23, Klass2),
        write("=> По разделяющим функциям объект отнесён к классу: ", Klass2), nl,
        readchar(_).

    /* ==================== ВСПОМОГАТЕЛЬНЫЕ ПРЕДИКАТЫ ====================== */

    /* Длина списка и сумма X1,X2 по списку - обычная рекурсия по списку,
       приём из лаб.2 (голова/хвост, п.2.2-2.4 методички). */
    dlina([], 0):- !.
    dlina([_|T], N):- dlina(T, N1), N = N1+1.

    summa_spiska([], 0, 0):- !.
    summa_spiska([t(_,X1,X2)|T], S1, S2):-
        summa_spiska(T, S1t, S2t),
        S1 = S1t + X1,
        S2 = S2t + X2.

    /* Прототип класса = (сумма X1)/(кол-во), (сумма X2)/(кол-во) - формула
       из примера про склады, п.7.2 методички. */
    prototip(Spisok, Sr1, Sr2):-
        summa_spiska(Spisok, S1, S2),
        dlina(Spisok, N),
        Sr1 = S1 / N,
        Sr2 = S2 / N.

    /* Решающая функция на основе минимального расстояния (формула п.7.2):
       Di = 2*(X1*Pi1+X2*Pi2) - (Pi1*Pi1+Pi2*Pi2) */
    reshfunk_rasst(X1, X2, P1, P2, D):-
        D = 2*(X1*P1 + X2*P2) - (P1*P1 + P2*P2).

    /* Объект относится к классу с максимальным значением Di. */
    vybor_klassa_rasst(D1, D2, D3, "Н1"):- D1 >= D2, D1 >= D3, !.
    vybor_klassa_rasst(D1, D2, D3, "Н2"):- D2 >= D1, D2 >= D3, !.
    vybor_klassa_rasst(_, _, _, "Н3").

    /* --------- Обучение разделяющей (линейной) функции: алгоритм
       восприятия, п.7.3.1 методички. Spisok1 - "положительный" класс
       (функция должна быть >0), Spisok2 - "отрицательный" (функция <0). */
    train_pair(Spisok1, Spisok2, W0, W1, W2):-
        retractall(ves(_,_,_)), assert(ves(0,0,0)),
        retractall(schetchik(_)), assert(schetchik(0)),
        retractall(ukazatel(_)), assert(ukazatel(0)),
        dlina(Spisok1, N1), dlina(Spisok2, N2), Vsego = N1+N2,
        obuchit_cikl(Spisok1, Spisok2, Vsego, N1),
        ves(W0, W1, W2), !.

    /* Останов: E (счётчик подряд верно распознанных) достиг общего числа
       объектов обучающего множества - значит, функция верна для всех. */
    obuchit_cikl(_, _, Vsego, _):-
        schetchik(E), E >= Vsego, !.
    /* Иначе берём очередной объект (по кругу) и обрабатываем его. */
    obuchit_cikl(Spisok1, Spisok2, Vsego, N1):-
        ukazatel(U),
        Indeks = U mod Vsego,
        vzyat_obj(Indeks, Spisok1, Spisok2, N1, Storona, X1, X2),
        U1 = U + 1,
        retractall(ukazatel(_)), assert(ukazatel(U1)),
        obrabotat_obj(Storona, X1, X2),
        obuchit_cikl(Spisok1, Spisok2, Vsego, N1).

    /* Индекс < N1 -> объект из первого списка (Storona=1),
       иначе - из второго списка, с поправкой индекса (Storona=2). */
    vzyat_obj(Indeks, Spisok1, _, N1, 1, X1, X2):-
        Indeks < N1, !,
        element_spiska(Spisok1, Indeks, t(_,X1,X2)).
    vzyat_obj(Indeks, _, Spisok2, N1, 2, X1, X2):-
        Indeks2 = Indeks - N1,
        element_spiska(Spisok2, Indeks2, t(_,X1,X2)).

    element_spiska([H|_], 0, H):- !.
    element_spiska([_|T], N, El):- N > 0, N1 = N-1, element_spiska(T, N1, El).

    /* Проверка объекта решающей функцией и, если нужно, коррекция весов
       (в точности шаг 4 алгоритма восприятия, п.7.3.1 методички):
         - объект из "первого" класса, D>0            -> верно, E:=E+1
         - объект из "второго" класса, D<0            -> верно, E:=E+1
         - объект из "первого" класса, D<=0 (неверно)  -> W:=W+(1,X1,X2), E:=0
         - объект из "второго" класса, D>=0 (неверно)  -> W:=W-(1,X1,X2), E:=0 */
    obrabotat_obj(Storona, X1, X2):-
        ves(W0, W1, W2),
        D = W0 + W1*X1 + W2*X2,
        proverit_i_korrekt(Storona, D, X1, X2, W0, W1, W2).

    proverit_i_korrekt(1, D, _, _, _, _, _):-
        D > 0, !,
        schetchik(E), E1 = E+1, retractall(schetchik(_)), assert(schetchik(E1)).
    proverit_i_korrekt(2, D, _, _, _, _, _):-
        D < 0, !,
        schetchik(E), E1 = E+1, retractall(schetchik(_)), assert(schetchik(E1)).
    proverit_i_korrekt(1, _, X1, X2, W0, W1, W2):-
        !,
        W0n = W0+1, W1n = W1+X1, W2n = W2+X2,
        retractall(ves(_,_,_)), assert(ves(W0n,W1n,W2n)),
        retractall(schetchik(_)), assert(schetchik(0)).
    proverit_i_korrekt(2, _, X1, X2, W0, W1, W2):-
        W0n = W0-1, W1n = W1-X1, W2n = W2-X2,
        retractall(ves(_,_,_)), assert(ves(W0n,W1n,W2n)),
        retractall(schetchik(_)), assert(schetchik(0)).

    /* Итоговое распознавание по разделяющим функциям (правило (*), п.7.3.2):
       объект относится к классу k, если Dki>0 для ВСЕХ остальных классов i.
       D12,D13,D23 передаются "как есть" (D21=-D12, D31=-D13, D32=-D23). */
    vybor_klassa_razdel(D12, D13, _D23, "Н1"):- D12 > 0, D13 > 0, !.
    vybor_klassa_razdel(D12, _D13, D23, "Н2"):- D12 < 0, D23 > 0, !.
    vybor_klassa_razdel(_D12, D13, D23, "Н3"):- D13 < 0, D23 < 0, !.
    vybor_klassa_razdel(_, _, _, "не определён (объект не удалось однозначно отнести ни к одному классу)").
