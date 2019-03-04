-module(voifinity_message_msglog_user_handler).
-export([init/2
	,handle_req/3
        ,json_creation/3
        ]).
init(Req0, State) ->
  InputMethod = maps:get(method,Req0),
  InputPath = maps:get(path_info,Req0),
  handle_req(InputMethod,InputPath,Req0),
  {ok, Req0, State}.
handle_req(<<"GET">>,[<<"message_log">>,<<"user">>,UserId],Req) ->
  case Data= mnesia:dirty_index_read(storemessage,UserId,from) of
    [] ->
     % Out= [{<<"status">>,<<"no exists">>}],
      %jsx:encode(A)
      %cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>},Out,Req);
      cowboy_req:reply(404, Req);
     _  ->
       json_creation(Data,[],Req)
   end.
json_creation([],Accumulator,Req) ->
  Out = jsx:encode(Accumulator),
  cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},Out,Req);
json_creation([H|T],Accumulator,Req) ->
  Message = jsx:decode(element(8,element(5,H))),
  From = proplists:get_value(<<"from">>,element(2,hd(Message))),
  To = proplists:get_value(<<"clientId">>,element(2,hd(Message))),
  Datetime = proplists:get_value(<<"datetime">>,element(2,hd(Message))),
  Payload = proplists:get_value(<<"payload">>,element(2,hd(Message))),
  Msg=[{<<"from">>,From},{<<"To">>,To},{<<"datetime">>,Datetime},{<<"message">>,Payload}],
  json_creation(T,[Msg|Accumulator],Req).
