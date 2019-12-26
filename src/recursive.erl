%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Sep 2019 下午6:26
%%%-------------------------------------------------------------------
-module(recursive).
-author("lunay").

%% API
-export([
	face/1,
	tail_duplicate/2,
	tail_face/1,
	tail_len/1,
	reverse/1,
	tail_reverse/1,
	sublist/2,
	tail_zip/2,
	quicksort/1,
	lc_quicksort/1
]).

%%非尾递归实现
face(N) when N == 0 -> 1;
face(N) when N > 0  -> N * face(N-1).

tail_face(N) ->
	tail_face(N, 1).

%%tail_face(0, _, Acc) ->
%%	Acc;
%%
%%tail_face(N, N, 1) when N > 0 ->
%%	tail_face(N-1, N,  N*1);
%%
%%tail_face(N, M, Acc) when N > 0 ->
%%	tail_face(N-1, M,  Acc*N).

tail_face(0, Acc) ->
	Acc;

tail_face(N, Acc) when N > 0 ->
	tail_face(N-1, N*Acc).


%% 非尾递归
%%duplicate(0, _)->
%%	[];
%%
%%duplicate(N, Term) when N > 0 ->
%%	[Term|duplicate(N-1, Term)].

%% 尾递归实现方式
tail_duplicate(N, Term) ->
	tail_duplicate(N, Term, []).

tail_duplicate(0, _, List) ->
	List;

tail_duplicate(N, Term, List) when N > 0 ->
	tail_duplicate(N-1, Term, [Term|List]).

%% 列表长度　非尾递归
%%len([]) -> 0;
%%len([_|T]) -> 1 + len(T).

%%
tail_len(List) ->
	tail_len(List, 0).

tail_len([], Acc) ->
	Acc;

tail_len([_|T], Acc) -> tail_len(T, Acc+1).

%%非尾递归
reverse([]) -> [];
reverse([H|T]) -> reverse(T) ++ [H].

%%尾递归
tail_reverse(Ht) ->
	tail_reverse(Ht, []).

tail_reverse([], Ret) ->
	Ret;

tail_reverse([H|T], Ret) ->
	tail_reverse(T, [H|Ret]).


sublist(L, N) ->
	sublist(L, N, []).

sublist(_, 0, Acc) ->
	tail_reverse(Acc);

sublist([], _, Acc) ->
	Acc;

sublist([H|T], N, Acc) ->
	sublist(T, N-1, [H|Acc]).

%%非尾递归
%%zip ([], _) -> [];
%%zip (_, []) -> [];
%%zip([X|Xs], [Y|Ys]) -> [{X,Y}|zip(Xs, Ys)].

%%尾递归实现
tail_zip(X, Y) ->
	tail_zip(X, Y, []).

tail_zip([], _, Ret) -> lists:reverse(Ret);
tail_zip(_, [], Ret) -> lists:reverse(Ret);

tail_zip([X|Xs], [Y|Ys], Ret) ->
	tail_zip(Xs, Ys, [{X,Y}|Ret]).

%% 快速排序
quicksort([]) -> [];
quicksort([Pivot|Rest]) ->
	{Smaller, Larger} = partition(Pivot, Rest, [], []),
	quicksort(Smaller) ++ [Pivot] ++ quicksort(Larger).

partition(_, [], Smaller, Larger) -> {Smaller, Larger};
partition(Pivot, [H|T], Smaller, Larger) ->
	if H =< Pivot -> partition(Pivot, T, [H|Smaller], Larger);
		H > Pivot -> partition(Pivot, T, Smaller, [H|Larger])
	end.

lc_quicksort([]) -> [];
lc_quicksort([Pivot|Rest]) ->
	lc_quicksort([Smaller || Smaller <- Rest, Smaller =< Pivot])
    ++ Pivot ++ lc_quicksort([Larger || Larger <- Rest, Larger > Pivot]).










