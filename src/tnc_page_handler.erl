-module(tnc_page_handler).

-export([init/3]).

-export([content_types_provided/2]).
-export([welcome/2]).
-export([terminate/3]).

%% Init
init(_Transport, _Req, []) ->
	{upgrade, protocol, cowboy_rest}.

%% Callbacks
content_types_provided(Req, State) ->
	{[		
		{<<"text/html">>, welcome}	
	], Req, State}.

terminate(_Reason, _Req, _State) ->
	ok.

%% API
welcome(Req, State) ->
	Video_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=8&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_Video} = ibrowse:send_req(Video_Url,[],get,[],[]),
	ResponseParams_Video = jsx:decode(list_to_binary(Response_Video)),	
	[Params] = proplists:get_value(<<"articles">>, ResponseParams_Video),

	Popular_Videos_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=5&skip=10&format=short",
	{ok, "200", _, Response_Popular_Videos} = ibrowse:send_req(Popular_Videos_Url,[],get,[],[]),
	ResponseParams_Popular_Videos = jsx:decode(list_to_binary(Response_Popular_Videos)),	
	PopularVideosParams = proplists:get_value(<<"articles">>, ResponseParams_Popular_Videos),

	Politics_News_Url1 = "http://api.contentapi.ws/news?channel=us_politics&limit=5&skip=0&format=short",
	{ok, "200", _, Response_Politics_News1} = ibrowse:send_req(Politics_News_Url1,[],get,[],[]),
	ResponseParams_Politics_News1 = jsx:decode(list_to_binary(Response_Politics_News1)),	
	PoliticsNewsParams1 = proplists:get_value(<<"articles">>, ResponseParams_Politics_News1),

	% {ok, Body} = tnc_dtl:render(),
	{ok, Body} = tnc_dtl:render([{<<"videoParam">>, Params},{<<"popularvideos">>, PopularVideosParams},{<<"politicsnews">>, PoliticsNewsParams1}]),
    {Body, Req, State}
.