% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License. You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
% License for the specific language governing permissions and limitations under
% the License.

%% Author: carl
%% Created: 06 Mar 2011
%% Description: TODO: Add description to marshaller_ascii_field
-module(marshaller_ascii_field).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([marshal/2, marshal_data_element/2, unmarshal/2, unmarshal_data_element/2]).

%%
%% API Functions
%%
marshal_data_element({n, llvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 2) ++ Value;
marshal_data_element({n, lllvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 3) ++ Value;
marshal_data_element({ns, llvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 2) ++ Value;
marshal_data_element({an, llvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 2) ++ Value;
marshal_data_element({an, lllvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 3) ++ Value;
marshal_data_element({ans, llvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 2) ++ Value;
marshal_data_element({ans, lllvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 3) ++ Value;
marshal_data_element({n, fixed, Length}, Value) when length(Value) =< Length ->
	IntValue = list_to_integer(Value),
	convert:integer_to_string(IntValue, Length);
marshal_data_element({an, fixed, Length}, Value) when length(Value) =< Length ->
	convert:pad_with_trailing_spaces(Value, Length);
marshal_data_element({ans, fixed, Length}, Value) when length(Value) =< Length ->
	convert:pad_with_trailing_spaces(Value, Length);
marshal_data_element({x_n, fixed, Length}, [Head | Value]) when Head =:= $C orelse Head =:= $D ->
	IntValue = list_to_integer(Value),
	[Head] ++ convert:integer_to_string(IntValue, Length);
marshal_data_element({z, llvar, Length}, Value) when length(Value) =< Length ->
	convert:integer_to_string(length(Value), 2) ++ Value;
marshal_data_element({b, Length}, Value) when size(Value) =:= Length ->
	convert:binary_to_ascii_hex(Value).

unmarshal_data_element({n, llvar, _MaxLength}, Fields) ->
	{N, Rest} = lists:split(2, Fields),
	lists:split(list_to_integer(N), Rest);
unmarshal_data_element({n, lllvar, _MaxLength}, Fields) ->
	{N, Rest} = lists:split(3, Fields),
	lists:split(list_to_integer(N), Rest);
unmarshal_data_element({ns, llvar, _MaxLength}, Fields) ->
	{N, Rest} = lists:split(2, Fields),
	lists:split(list_to_integer(N), Rest);
unmarshal_data_element({an, llvar, _MaxLength}, Fields) ->
	{N, Rest} = lists:split(2, Fields),
	lists:split(list_to_integer(N), Rest);
unmarshal_data_element({an, lllvar, _MaxLength}, Fields) ->
	{N, Rest} = lists:split(3, Fields),
	lists:split(list_to_integer(N), Rest);
unmarshal_data_element({ans, llvar, _MaxLength}, Fields) ->
	{N, Rest} = lists:split(2, Fields),
	lists:split(list_to_integer(N), Rest);
unmarshal_data_element({ans, lllvar, _MaxLength}, Fields) ->
	{N, Rest} = lists:split(3, Fields),
	lists:split(list_to_integer(N), Rest);
unmarshal_data_element({n, fixed, Length}, Fields) ->
	lists:split(Length, Fields);
unmarshal_data_element({an, fixed, Length}, Fields) ->
	lists:split(Length, Fields);
unmarshal_data_element({ans, fixed, Length}, Fields) ->
	lists:split(Length, Fields);
unmarshal_data_element({x_n, fixed, Length}, [Head|Tail]) when Head =:= $C orelse Head =:= $D ->
	lists:split(Length+1, [Head|Tail]);
unmarshal_data_element({z, llvar, _MaxLength}, Fields) ->
	{N, Rest} = lists:split(2, Fields),
	lists:split(list_to_integer(N), Rest);
unmarshal_data_element({b, Length}, Fields) ->
	{ValueStr, Rest} = lists:split(2 * Length, Fields),
	Value = convert:ascii_hex_to_binary(ValueStr),
	{Value, Rest}.

marshal(FieldId, Value) ->
	Pattern = iso8583_fields:get_encoding(FieldId),
	marshal_data_element(Pattern, Value).

unmarshal(FieldId, Fields) ->
	Pattern = iso8583_fields:get_encoding(FieldId),
	unmarshal_data_element(Pattern, Fields).



%%
%% Local Functions
%%

