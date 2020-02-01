-module(game_ws_routing).
-author("Lunay").
-include("proto_pb.hrl").
-export([
    cmd_routing2/3
]).

cmd_routing2(Cmd, Bin, #{ws_pid := WsPid} = State) ->
    [H1, H2, _, _, _] = integer_to_list(Cmd),
    %%处理器模块
    ProtocolModule = list_to_atom("pt_"++[H1, H2]++"_pb"),
    RecordName = list_to_atom("pt_"++integer_to_list(Cmd) ++ "_c2s"),
    RecordData = ProtocolModule:decode_msg(Bin, RecordName),
    game_debug:debug(info,"wwwwwww WsPid : ~p, protobuf recevie: ~p ~n  wwwwwww", [WsPid, RecordData]),
    case [H1, H2] of
        %% 基础功能路由处理
        "10" ->
            pp_account:handler(Cmd, RecordData, State)
    end.
