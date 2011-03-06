%% Author: carl
%% Created: 06 Mar 2011
%% Description: TODO: Add description to marshaller_xml_field
-module(marshaller_xml_field).

%%
%% Include files
%%
-include_lib("xmerl/include/xmerl.hrl").

%%
%% Exported Functions
%%
-export([marshal/2, unmarshal/2]).

%%
%% API Functions
%%
marshal(FieldId, Value) when is_list(Value)->
	Id = integer_to_list(FieldId),
	"<field id=\"" ++ Id ++ "\" value=\"" ++ Value ++ "\" />";
marshal(FieldId, Value) when is_binary(Value) ->
	Id = integer_to_list(FieldId),
	"<field id=\"" ++ 
		Id ++ 
		"\" value=\"" ++ 
		convert:binary_to_ascii_hex(Value) ++
		"\" type=\"binary\" />";	
marshal(FieldId, Value) ->
	Id = integer_to_list(FieldId),
	"<isomsg id=\"" ++ 
		Id ++ 
		"\"" ++
		encode_attributes(iso8583_message:get_attributes(Value)) ++
		">" ++
		marshal_fields(iso8583_message:to_list(Value), "") ++ 
		"</isomsg>".

unmarshal(_FieldId, FieldElement) ->
	Attributes = FieldElement#xmlElement.attributes,
	AttributesList = attributes_to_list(Attributes, []),
	Id = get_attribute_value("id", AttributesList),
	case FieldElement#xmlElement.name of
		field ->
			ValueStr = get_attribute_value("value", AttributesList),
			case is_attribute("type", AttributesList) of
				false ->
					ValueStr;
				true ->
					"binary" = get_attribute_value("type", AttributesList),
					convert:ascii_hex_to_binary(ValueStr)
			end;
		isomsg ->
			AttrsExceptId = AttributesList -- [{"id", Id}],
			ChildNodes = FieldElement#xmlElement.content,
			marshaller_xml:unmarshal(ChildNodes, iso8583_message:new(AttrsExceptId), ?MODULE)
	end.	


%%
%% Local Functions
%%
encode_attributes(List) ->
	encode_attributes(List, "").

encode_attributes([], Result) ->
	Result;
encode_attributes([{Key, Value} | Tail], Result) ->
	encode_attributes(Tail, " " ++ Key ++ "=\"" ++ Value ++ "\"" ++  Result).

attributes_to_list([], Result) ->
	Result;
attributes_to_list([H|T], Result) ->
	Id = atom_to_list(H#xmlAttribute.name),
	Value = H#xmlAttribute.value,
	attributes_to_list(T, [{Id, Value} | Result]).

is_attribute(_Id, []) ->
	false;
is_attribute(Id, [{Id, _}|_Tail]) ->
	true;
is_attribute(Id, [_Head|Tail]) ->
	is_attribute(Id, Tail).

get_attribute_value(Key, [{Key, Value} | _Tail]) ->
	Value;
get_attribute_value(Key, [_Head|Tail]) ->
	get_attribute_value(Key, Tail).

marshal_fields([], Result) ->
	Result;
marshal_fields([{FieldId, Value}|Tail], Result) ->
	MarshalledValue = marshal(FieldId, Value),
	marshal_fields(Tail, MarshalledValue ++ Result).
