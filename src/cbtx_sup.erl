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

    ChildSpecs = [
        %% MySQL pools
        mysql_poolboy:child_spec(pool, PoolOptions, MySqlOptions)
    ],
    {ok, {{one_for_one, 10, 10}, ChildSpecs}}.

%%====================================================================
%% Internal functions
%%====================================================================
