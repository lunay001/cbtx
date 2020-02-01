%%%-------------------------------------------------------------------
%% @doc cbtx top level supervisor.
%% @end
%%%-------------------------------------------------------------------
-module(cbtx_sup).
-include("common.hrl").
-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: #{id => Id, start => {M, F, A}}
%% Optional keys are restart, shutdown, type, modules.
%% Before OTP 18 tuples must be used to specify a child. e.g.
%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    PoolOptions  = [{size, ?DB_MYSQL_POOL_SIZE}, {max_overflow, ?DB_MYSQL_POOL_MAX}],
    MySqlOptions = [{user, ?DB_MYSQL_USER}, {password, ?DB_MYSQL_PASSWD}, {database, ?DB_MYSQL_DATABASE},
        {prepare, [{t1, "SELECT * FROM t1 WHERE id=?"}]}],

    %%用户角色监控树
    Game_Role_Sup_Specs = {game_role_sup, {game_role_sup, start_link, []},
        permanent, 2000, supervisor, [game_role_sup]
        },
    %%ets监控树
    Game_Ets_Sup_Specs = {game_ets_sup, {game_ets_sup, start_link, []},
        permanent, 2000, supervisor, [game_ets_sup]
    },
    ChildSpecs = [
        %% MySQL连接池监控树
        mysql_poolboy:child_spec(?DB_MYSQL_POOL, PoolOptions, MySqlOptions)
        ,Game_Role_Sup_Specs
        ,Game_Ets_Sup_Specs
    ],
    {ok, {{one_for_one, 10, 10}, ChildSpecs}}.

%%====================================================================
%% Internal functions
%%====================================================================
