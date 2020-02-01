%%%-------------------------------------------------------------------
%%% @author lunay
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 1月 2020 6:03 下午
%%%-------------------------------------------------------------------
-module(pp_account).
-author("lunay").
-include("pt_10_pb.hrl").
-include("game_user.hrl").
%% API
-export([handler/3]).

%%登录验证
handler(10000, #pt_10000_c2s{user_id=UserId}, #{ws_pid := WsPid} = WsState) ->
  game_debug:debug(info,"User_id: ~p ~n", [UserId]),
  UserInfo = lib_account:get_account_info(UserId),
  NewWsState = case maps:size(UserInfo) > 0 of
    true ->
      Ret = [],
      game_debug:debug(info,"Ret: ~p ~n", [Ret]),
      case Ret of
        [#r_online{user_id=UserId, user_pid=UserPid}] ->
          gen_server:call(UserPid, {reconnect, WsPid}),
          WsState#{logined := true, user_pid := UserPid, user_id=>UserId};
        [] ->
          RoleRet = supervisor:start_child(game_role_sup, [[UserId, WsPid]]),
          case RoleRet of
            {ok, UserPid} ->
              WsState#{logined => true, user_pid := UserPid, user_id=>UserId};
          _ ->
            WsState
          end;
        _ ->
          Ret
      end;
    false ->
      WsState
  end,
  game_debug:debug(info,"wwww:WsState: ~p wwwwwww ~n", [NewWsState]),
  NewWsState;

%%登录验证
handler(10001, #pt_10001_c2s{}, #{ws_pid := WsPid, user_id:=UserId} = State) ->
  UserInfoMap = lib_account:get_account_info(UserId),
  case maps:size(UserInfoMap) > 0 of
    true ->
      UserInfo_s2c = #pt_10001_s2c{ret = 1, data = #'RoleInfo'{
        user_id = UserId,
        name= maps:get(<<"name">>, UserInfoMap),
        coin= maps:get(<<"coin">>, UserInfoMap),
        status=maps:get(<<"status">>, UserInfoMap)
      }};
  false ->
      UserInfo_s2c = #pt_10001_s2c{ret=0, data=#'RoleInfo'{}}
  end,
  game_ws_util:ws_send(10001, WsPid, UserInfo_s2c).





