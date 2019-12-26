%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Sep 2019 下午4:33
%%%-------------------------------------------------------------------
-module(tx).
-author("lunay").

%% API
-export([
	split/1,
	old_men/1,
	max2/1,
	min2/1,
	sum2/1,
	fold/3,
	map2/2,
	filter2/2,
	group_vals/1
	]).

%%奇数偶数分离方法
split(L) ->
	split(L, [], []).

split([H|T], Event, Odd) ->
	case H rem 2 of
		0 -> split(T, Event, [H|Odd]);
		1 -> split(T, [H|Event], Odd)
	end;

split([], Event, Odd) ->
	{Event, Odd}.

%%保留男性60岁以上
old_men(L) ->
	old_men(L, []).

old_men([], Acc) ->
	Acc;
old_men([Person = {male, Age} | People], Acc) when Age > 60 ->
	old_men(People, [Person|Acc]);

old_men([_|People], Acc) ->
	old_men(People, Acc).

%%找出列表中最大值
max2(L) ->
	max2(L, lists:nth(1, L)).

max2([], Max) -> Max;
max2([H|T], Max) when H > Max ->
	max2(T, H);
max2([_|T], Max) ->
	max2(T, Max).

%% 查找最小值
min2(L) ->
	min2(L, lists:nth(1, L)).

min2([], Min) ->
	Min;
min2([H|T], Min) when H < Min ->
	min2(T, H);
min2([_|T], Min) ->
	min2(T, Min).

%%计算所有元素的和
sum2(L) ->
	sum2(L, 0).
sum2([], S) ->
	S;
sum2([H|T], S) ->
	sum2(T, H + S).

%% 最大或者最小设置初始值以上方式不太合适, 要以第一个元素为初始值比价合适
%%　构建一下抽象

%% 仔细分析这个抽象
%% 这个抽象非常犀利,牛啊
fold( _ , Start, []) -> Start;
fold(F, Start, [H|T]) -> fold(F, F(H, Start), T).

reverse(L) ->
	fold(fun(X, Acc) -> [X|Acc] end, [], L).

map2(F, L) ->
	reverse(fold(fun(X, Acc) ->[F(X)|Acc] end, [], L)).

filter2(Pred, L) ->
	F = fun(X, Acc) ->
			case Pred(X) of
				true -> [X|Acc];
				false -> Acc
			end
		end,
	reverse(fold(F, [], L)).


sum3(L) ->
	F = fun(X, Acc) -> Acc + X end,
	fold(F, 0, L).

min3([H|T]) ->
	F = fun(A, B) when A > B -> B; (_, B) -> B end,
	fold(F, H, T).

group_vals(L) ->
	group_vals(L, []).

group_vals([], Acc) ->
	lists:reverse(Acc);
group_vals([A, B, X|Rest], Acc) ->
	group_vals(Rest, [{A,B,X} | Acc]).



















