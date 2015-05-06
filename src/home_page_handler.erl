-module(home_page_handler).
-author("chanakyam@koderoom.com").

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
	Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=0&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[Params] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	World_News_Url = "http://api.contentapi.ws/news?channel=us_world&limit=10&skip=0&format=short",
	{ok, "200", _, Response_World_News} = ibrowse:send_req(World_News_Url,[],get,[],[]),
	ResponseParams_World_News = jsx:decode(list_to_binary(Response_World_News)),	
	WorldNewsParams = proplists:get_value(<<"articles">>, ResponseParams_World_News),

	US_News_Url = "http://api.contentapi.ws/news?channel=us_domestic&limit=10&skip=0&format=short",
	{ok, "200", _, Response_US_News} = ibrowse:send_req(US_News_Url,[],get,[],[]),
	ResponseParams_US_News = jsx:decode(list_to_binary(Response_US_News)),	
	USNewsParams = proplists:get_value(<<"articles">>, ResponseParams_US_News),

	Politics_News_Url = "http://api.contentapi.ws/news?channel=us_politics&limit=8&skip=0&format=short",
	{ok, "200", _, Response_Politics_News} = ibrowse:send_req(Politics_News_Url,[],get,[],[]),
	ResponseParams_Politics_News = jsx:decode(list_to_binary(Response_Politics_News)),	
	PoliticsNewsParams = proplists:get_value(<<"articles">>, ResponseParams_Politics_News),

	Politics_News_Url1 = "http://api.contentapi.ws/news?channel=us_politics&limit=3&skip=0&format=short",
	{ok, "200", _, Response_Politics_News1} = ibrowse:send_req(Politics_News_Url1,[],get,[],[]),
	ResponseParams_Politics_News1 = jsx:decode(list_to_binary(Response_Politics_News1)),	
	PoliticsNewsParams1 = proplists:get_value(<<"articles">>, ResponseParams_Politics_News1),

	Top_Videos_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=4&skip=1&format=short",
	{ok, "200", _, Response_Top_Videos} = ibrowse:send_req(Top_Videos_Url,[],get,[],[]),
	ResponseParams_Top_Videos = jsx:decode(list_to_binary(Response_Top_Videos)),	
	TopVideosParams = proplists:get_value(<<"articles">>, ResponseParams_Top_Videos),

	Popular_Videos_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=3&skip=10&format=short",
	{ok, "200", _, Response_Popular_Videos} = ibrowse:send_req(Popular_Videos_Url,[],get,[],[]),
	ResponseParams_Popular_Videos = jsx:decode(list_to_binary(Response_Popular_Videos)),	
	PopularVideosParams = proplists:get_value(<<"articles">>, ResponseParams_Popular_Videos),

	{ok, Body} = index_dtl:render([{<<"videoParam">>,Params},{<<"worldnews">>,WorldNewsParams},{<<"usnews">>,USNewsParams},{<<"politicsnews">>,PoliticsNewsParams},{<<"politicsnews1">>,PoliticsNewsParams1},{<<"topvideos">>,TopVideosParams},{<<"popularvideos">>,PopularVideosParams}]),
    {Body, Req, State}.
