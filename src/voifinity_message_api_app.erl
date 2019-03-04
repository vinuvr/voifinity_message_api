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
                {"/user/delete_message/[...]",voifinity_message_deletemsg_handler, []},
                {"/message_log/account/[...]",voifinity_message_msglog_account_handler, []},
                {"/message_log/group/[...]",vofinity_message_msglog_group_handler, []},
                {"/message_log/user/[...]", voifinity_message_msglog_user_handler, []},
                {"/group_details/[...]",voifinity_message_group_details_handler, []},
                {"/media/[...]",voifinity_message_fileupload_handler, []},
                  ]}     
            ]), 
%  Dispatch = cowboy_router:compile([
%            {'_', [{"/[...]", emqx_api_handler, []}]}
%             ]),
  {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 9080}],
        #{env => #{dispatch => Dispatch}}
  ),
   voifinity_message_api_sup:start_link().

%%--------------------------------------------------------------------


stop(_State) ->
  ok.



%%====================================================================
%%%% Internal functions
%%%%%====================================================================

