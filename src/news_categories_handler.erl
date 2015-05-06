-module(news_categories_handler).
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
	{Page, PageNumber} = cowboy_req:qs_val(<<"page">>, Req),
	SkipItems = (list_to_integer(binary_to_list(Page))-1) * 15,
	Url = case binary_to_list(Value) of 
		"World" ->
			%Category = "US",
			string:concat("http://api.contentapi.ws/news?channel=us_world&limit=25&format=short&skip=",integer_to_list(SkipItems));
			% gallyo_util:news_category_url("text_us_world","by_id_title_desc_thumb_date", list_to_integer(binary_to_list(Page)) );
		"US" ->
			%Category = "US",
			string:concat("http://api.contentapi.ws/news?channel=us_domestic&limit=25&format=short&skip=",integer_to_list(SkipItems));
			% gallyo_util:news_category_url("text_us_domestic","by_id_title_desc_thumb_date", list_to_integer(binary_to_list(Page)));
			
		"Politics" ->
			%Category = "Politics",
			string:concat("http://api.contentapi.ws/news?channel=us_politics&limit=25&format=short&skip=",integer_to_list(SkipItems));
			% gallyo_util:news_category_url("text_us_politics","by_id_title_desc_thumb_date", list_to_integer(binary_to_list(Page)));
			
		"Entertainment" ->
			%Category = "Entertainment",
			string:concat("http://api.contentapi.ws/news?channel=us_entertainment&limit=25&format=short&skip=",integer_to_list(SkipItems));
			% gallyo_util:news_category_url("text_us_entertainment","by_id_title_desc_thumb_date", list_to_integer(binary_to_list(Page)));
		
		"Markets" ->
			%Category = "Entertainment",
			string:concat("http://api.contentapi.ws/news?channel=us_markets&limit=25&format=short&skip=",integer_to_list(SkipItems));
			% gallyo_util:news_category_url("text_us_markets","by_id_title_desc_thumb_date", list_to_integer(binary_to_list(Page)));			

		"Money" ->
			%Category = "Entertainment",
			string:concat("http://api.contentapi.ws/news?channel=us_money&limit=25&format=short&skip=",integer_to_list(SkipItems));
			% gallyo_util:news_category_url("text_us_money","by_id_title_desc_thumb_date", list_to_integer(binary_to_list(Page)));			
		_ ->

			%Category = "None",
			lager:info("#########################None")

	end,

	% for videos

	Video_Url = case binary_to_list(Value) of 
		"World" ->
			%Category = "US",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=1&format=long";
		"US" ->
			%Category = "US",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=2&format=long";
			
		"Politics" ->
			%Category = "Politics",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=3&format=long";
			
		"Entertainment" ->
			%Category = "Entertainment",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=4&format=long";
		
		"Markets" ->
			%Category = "Entertainment",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=5&format=long";
		
		"Money" ->
			%Category = "Entertainment",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=6&format=long";
		_ ->

			%Category = "None",
			lager:info("#########################None")

	end,
	{ok, "200", _, Response} = ibrowse:send_req(Url,[],get,[],[]),
	ResponseParams = jsx:decode(list_to_binary(Response)),	
	ParamsAllNews = proplists:get_value(<<"articles">>, ResponseParams),

	% Video_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=0&format=long",
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
	
	{ok, Body} = news_categories_page_dtl:render([{<<"titles">>, ParamsAllNews}, {<<"category">>, binary_to_list(Value) },{<<"videoParam">>, Params},{<<"popularvideos">>, PopularVideosParams},{<<"politicsnews">>, PoliticsNewsParams1}]),
    {Body, Req2, State}.