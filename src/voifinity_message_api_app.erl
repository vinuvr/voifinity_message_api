%%%-------------------------------------------------------------------
%%%%% @doc projectnew public API
%%%%% @end
%%%%%%-------------------------------------------------------------------
-module(voifinity_message_api_app).
-behaviour(application).
%% Application callbacks
-export([start/2,stop/1]).
%%====================================================================
%%%% API
%%%%%====================================================================
%%%
start(_StartType, _StartArgs) ->
  Dispatch = cowboy_router:compile([         
            {'_', [
                {"/delete_message/[...]",voifinity_message_deletemsg_handler, []},
                {"/account/[...]",voifinity_message_account_handler, []},
                {"/group/[...]",voifinity_message_group_handler, []},
                {"/user/[...]", voifinity_message_user_handler, []},
                {"/media/[...]",voifinity_message_fileupload_handler, []}
                  ]}     
            ]), 
  {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 9080}],
        #{env => #{dispatch => Dispatch}}),
  voifinity_message_api_sup:start_link().
%%--------------------------------------------------------------------
stop(_State) ->
  ok.
%%====================================================================
%%%% Internal functions
%%%%%====================================================================

