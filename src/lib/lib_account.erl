%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 1月 2020 2:02 下午
%%%-------------------------------------------------------------------
-module(lib_account).
-author("lunay").

%% API
-export([
  get_account_info/1
]).

get_account_info(UserId)->
  Tables = 'user',
  Fields = '*',
  WhereExpr = {user_id, '=', UserId},
  Extras = [{limit, 1}],
  S = {select, undefined, Fields, {from, Tables}, WhereExpr, Extras},
  {ok, UserInfo} = db_mysql:fetch_row(S),
  UserInfo.



