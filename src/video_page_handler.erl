-module(video_page_handler).
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
	{[{Id,VideoId}], Req2} = cowboy_req:bindings(Req),

	Url = string:concat("http://api.contentapi.ws/v?id=",binary_to_list(VideoId) ),

	{ok, "200", _, Response} = ibrowse:send_req(Url,[],get,[],[]),
	Res = string:sub_string(Response, 1, string:len(Response) -1 ),
	Params = jsx:decode(list_to_binary(Res)),

	Popular_Videos_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=3&skip=10&format=short",
	{ok, "200", _, Response_Popular_Videos} = ibrowse:send_req(Popular_Videos_Url,[],get,[],[]),
	ResponseParams_Popular_Videos = jsx:decode(list_to_binary(Response_Popular_Videos)),	
	PopularVideosParams = proplists:get_value(<<"articles">>, ResponseParams_Popular_Videos),

	Politics_News_Url1 = "http://api.contentapi.ws/news?channel=us_politics&limit=3&skip=0&format=short",
	{ok, "200", _, Response_Politics_News1} = ibrowse:send_req(Politics_News_Url1,[],get,[],[]),
	ResponseParams_Politics_News1 = jsx:decode(list_to_binary(Response_Politics_News1)),	
	PoliticsNewsParams1 = proplists:get_value(<<"articles">>, ResponseParams_Politics_News1),

	Top_Videos_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=6&skip=1&format=short",
	{ok, "200", _, Response_Top_Videos} = ibrowse:send_req(Top_Videos_Url,[],get,[],[]),
	ResponseParams_Top_Videos = jsx:decode(list_to_binary(Response_Top_Videos)),	
	TopVideosParams = proplists:get_value(<<"articles">>, ResponseParams_Top_Videos),

	US_News_Url = "http://api.contentapi.ws/news?channel=us_domestic&limit=5&skip=0&format=short",
	{ok, "200", _, Response_US_News} = ibrowse:send_req(US_News_Url,[],get,[],[]),
	ResponseParams_US_News = jsx:decode(list_to_binary(Response_US_News)),	
	USNewsParams = proplists:get_value(<<"articles">>, ResponseParams_US_News),

	% {ok, Body} = video_page_dtl:render(Params),
	{ok, Body} = video_page_dtl:render([{<<"news">>, Params}, {<<"popularvideos">>,PopularVideosParams},{<<"politicsnews">>,PoliticsNewsParams1},{<<"topvideos">>,TopVideosParams},{<<"usnews">>,USNewsParams}]),
    {Body, Req2, State}.


 