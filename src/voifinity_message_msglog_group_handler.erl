-module(vofinity_message_msglog_group_handler).
-export([init/2
	,handle_req/3
        ,json_creation/3
        ]).
init(Req0, State) ->
  InputMethod = maps:get(method,Req0),
  InputPath = maps:get(path_info,Req0),
  handle_req(InputMethod,InputPath,Req0),
  {ok, Req0, State}.
handle_req(<<"GET">>,[<<"message_log">>,<<"group">>,Group_id], Req) ->
  case Data = mnesia:dirty_index_read(storemessage,Group_id,group_id) of
    [] ->
      cowboy_req:reply(404, Req);
    _ ->
      json_creation(Data,[],Req)
  end.
json_creation([],Accumulator,Req) ->
  Out = jsx:encode(Accumulator);

json_creation([H|T],Accumulator,Req) ->
  Message = jsx:decode(element(8,element(5,H))),
  From = proplists:get_value(<<"sender">>,element(2,hd(Message))),
  To = proplists:get_value(<<"from">>,element(2,hd(Message))),
  Datetime = proplists:get_value(<<"datetime">>,element(2,hd(Message))),
  Payload = proplists:get_value(<<"payload">>,element(2,hd(Message))),
  A=[{<<"from">>,From},{<<"To">>,To},{<<"datetime">>,Datetime},{<<"message">>,Payload}],
  json_creation(T,[A|Accumulator],Req).

