-module(game_role).
-author("Lunay").

-include("game_user.hrl").
-include("common_pb.hrl") .
-include("pt_10_pb.hrl").

-behaviour(gen_server).

%% callback function
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).

%% API
-export([start_link/1, stop/2]).
-define(SERVER, ?MODULE).
-define(SAVE_TIME, 5000).
-define(CHECK_ONLINE_TIME, 30000).
-define(CHECK_ONLINE_LIMIT, 3).

stop(Pid, Reson) ->
    Pid ! {stop, Reson}.

start_link([UserId, WsPid]) ->
    gen_server:start_link(?MODULE, [UserId, WsPid], []).

init([UserId, WsPid]) ->
%%    State = game_mn:get_user_state(UserId),
    process_flag(trap_exit, true),
    game_debug:debug(error,"with *State* init ! ~n~n", []),
    NewState = #{user_pid => self(), ws_pid => WsPid, user_id=>UserId, coin=>0, statem_pid=>none, check_online_count=>0},
%%    erlang:send_after(?SAVE_TIME, self(), save_user_state),
%%    erlang:send_after(?CHECK_ONLINE_TIME, self(), check_online),
    game_debug:debug(error,"with *State* init ! ~n~n", []),
    {ok, NewState, 0}.
    
handle_call(_Msg, _From, _State) ->
    game_debug:debug(error,"~n~n module *~p* unknow  *CALL* message:  ~p   which *From*:  ~p   with *State* ~p ~n~n", [?MODULE,_Msg, _From, _State]),
    {reply, _State}.

handle_cast({reconnect, WsPid}, #{user_id := UserId} = State) ->
    game_ws_util:ws_send(WsPid, #loginResp{result='SUCCEEDED', user_id = UserId}),
    {noreply, State#{ws_pid := WsPid}};

handle_cast({cmd_routing, Cmd, Bin}, State) ->
    game_debug:debug(error,"AAAAAAAAAAA~n"),
    game_ws_routing:cmd_routing2(Cmd, Bin, State),
    {noreply, State};

handle_cast({change_gold, ChangeGold}, #{coin := Coin} = State) ->
    {noreply, State#{coin := Coin+ChangeGold}};

handle_cast(_Msg, _State) ->
    game_debug:debug(error,"~n~n module *~p* unknow  *CAST* message:  ~p   with *State* ~p ~n~n", [?MODULE,_Msg, _State]),   
    {noreply, _State}.

handle_info({stop, Reson} , State) ->
    {stop, Reson, State#{statem_pid := none}};

handle_info(check_online, #{check_online_count := COC} = State) ->
    case COC >= ?CHECK_ONLINE_LIMIT of
        true ->
            {stop,normal,State};
        false -> 
            erlang:send_after(?CHECK_ONLINE_TIME, self(), check_online),
            {noreply, State#{check_online_count := COC+1}}
    end;

%% 等级初始化传回前端
handle_info(timeout, State) ->
    #{user_id := UserId,
      ws_pid := WsPid
    } = State,
%%    ets:insert(ets_user_online, #r_online{user_id = UserId, user_pid = self()}),
%%    玩家数据返回
    UserInfoMap = lib_account:get_account_info(UserId),
    game_debug:debug(error," UserInfoMap:  ~p~n", [UserInfoMap]),

    UserInfo_s2c = #pt_10000_s2c{ret = 1, data = #'RoleInfo'{
        user_id = UserId,
        name= maps:get(<<"name">>, UserInfoMap),
        coin= maps:get(<<"coin">>, UserInfoMap),
        status=maps:get(<<"status">>, UserInfoMap)
    }},
    ok = game_ws_util:ws_send(10000, WsPid, UserInfo_s2c),
    {noreply, State#{user_id=>UserId}};

handle_info(save_user_state, State) ->
%%    game_mn:save_user_state(State),
    erlang:send_after(?SAVE_TIME, self(), save_user_state),
    {noreply, State};

handle_info(_Msg, _State) ->
    game_debug:debug(error,"~n~n module *~p* unknow  *INFO* message:  ~p   with *State* ~p ~n~n", [?MODULE, _Msg, _State]),
    {noreply, _State}.
    
terminate(_Reson, #{user_id := UserId, user_pid := UserPid, ws_pid := WsPid} = State) ->
    case is_process_alive(WsPid) of
        true -> exit(WsPid, kill);
        false -> notdoing
    end,
    game_debug:debug(error,"wwwwwww user terminate by user_id: ~p, user_pid: ~p, ws_pid: ~p   wwwwwww ~n",[UserId, UserPid, WsPid]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
