-module(voifinity_message_account_handler).
-export([init/2
	      ,handle_req/3
        ,json_creation/3
        ]).
init(Req0, State) ->
  InputMethod = maps:get(method,Req0),
  InputPath = maps:get(path_info,Req0),
  handle_req(InputMethod,InputPath,Req0),
  {ok, Req0, State}.
handle_req(<<"GET">>,[<<"message_log">>,AccountId],Req) ->
  case Data= mnesia:dirty_index_read(storemessage,AccountId,accountid) of
    [] ->
      cowboy_req:reply(404, Req);
     _  ->
       json_creation(Data,[],Req)
   end.
json_creation([],Accumulator,Req) ->
  Out = jsx:encode(Accumulator),
  cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},Out,Req);
json_creation([H|T],Accumulator,Req) ->
  Message = element(2,hd(jsx:decode(element(8,element(5,H))))),
  json_creation(T,[Message|Accumulator],Req).
