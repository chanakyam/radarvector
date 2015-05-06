-module(news_page_handler).
-author("shree@ybrantdigital.com").

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
	{[{Name,Value}], Req2} = cowboy_req:bindings(Req),
	
	Url = string:concat("http://api.contentapi.ws/t?id=",binary_to_list(Value) ),
	% io:format("individual id --> ~p ~n",[Url]),
	{ok, "200", _, Response} = ibrowse:send_req(Url,[],get,[],[]),
	Res = string:sub_string(Response, 1, string:len(Response) -1 ),
	ParamsAllNews = jsx:decode(list_to_binary(Res)),

	Video_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=7&format=long",
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
	
	% {ok, Body} = news_page_dtl:render(Params),
	{ok, Body} = news_page_dtl:render([{<<"titles">>, ParamsAllNews}, {<<"category">>, binary_to_list(Value) },{<<"videoParam">>, Params},{<<"popularvideos">>, PopularVideosParams},{<<"politicsnews">>, PoliticsNewsParams1}]),
    {Body, Req2, State}.


