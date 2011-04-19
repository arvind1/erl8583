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

%% @author CA Meijer
%% @copyright 2011 CA Meijer
%% @doc This module provides functions for marshalling and unmarshalling
%%      ISO 8583 messages into various encodings. To marshal or unmarshal
%%      a message, one must supply a list of options that specify
%%      modules that can be called to marshal or unmarshal the MTI, the
%%      bitmap, the message fields and, optionally, some wrapping in
%%      which the marshalled message is encapsulated.
%%
%%      Optionally, this marshaller can be passed a callback handler that
%%      specifies how messages are to be encoded (e.g. the 1987, 1993 or
%%      2003 specification or a proprietary specification). If no specific
%%      encoding rules are passed, the version indicated by the MTI is
%%      used.
-module(erl8583_marshaller).

%%
%% Include files
%%
%% @headerfile "../include/erl8583_types.hrl"
-include("erl8583_types.hrl").

%%
%% Records
%%
-record(marshal_options, {field_marshaller, 
						  bitmap_marshaller,
						  mti_marshaller,
						  init_marshaller, 
						  end_marshaller, 
						  encoding_rules}).

%% A module identifier and a module that implements some
%% marshalling function.
%%
%% @type marshal_handler() = {bitmap_marshaller, module()} |
%%	  {field_marshaller, module()} |
%%	  {mti_marshaller, module()} |
%%	  {init_marshaller, module()} |
%%	  {end_marshaller, module()} |
%%	  {encoding_rules, module()}. A callback function that implements
%%    functionality related to marshalling.<br/><br/> 
%%    A bitmap_marshaller must implement marshal_bitmap/1 and
%%    unmarshal_bitmap/1 functions.<br/>
%%    A field_marshaller must implement marshal_field/3 and unmarshal_field/3
%%    functions.
%%    An mti_marshaller must implement marshal_mti/1 and unmarshal_mti/1
%%    functions.<br/>
%%    A wrapping_marshaller must implement marshal_wrapping/2 and
%%    unmarshal_wrapping/2 functions.<br/>
%%    An encoding_rules marshaller must implement the get_encoding/1 function.
%%    <br/><br/>
%%    See the erl8583_marshaller_XXX modules for examples of modules that
%%    implement various marshalling functions.<br/><br/>
%%    See the erl8583_fields module for an example of an encoding_rules
%%    handler.
-type(marshal_handler() :: {bitmap_marshaller, module()} |
	  {field_marshaller, module()} |
	  {mti_marshaller, module()} |
	  {init_marshaller, module()} |
	  {end_marshaller, module()} |
	  {encoding_rules, module()}).

%%
%% Exported Functions
%%
-export([marshal/2, unmarshal/2]).

%%
%% API Functions
%%

%% @doc Marshals an ISO 8583 message into a byte sequence.
%%
%% @spec marshal(iso8583message(), list(marshal_handler())) -> list(byte())
-spec(marshal(iso8583message(), list(marshal_handler())) -> list(byte())).

marshal(Message, MarshalHandlers) ->
	OptionsRecord = parse_options(MarshalHandlers, #marshal_options{}),
	Message1 = init_marshalling(OptionsRecord, Message),
	Marshalled1 = encode_mti(OptionsRecord, Message1),
	{MarshalledBitmap, Message2} = encode_bitmap(OptionsRecord, Message1),
	Marshalled2 = Marshalled1 ++ MarshalledBitmap,
	Marshalled3 = Marshalled2 ++ encode_fields(OptionsRecord, Message2),
	end_marshalling(OptionsRecord, Message2, Marshalled3).

%% @doc Unmarshals a byte sequence into an ISO 8583 message.
%%
%% @spec unmarshal(list(byte()), list(marshal_handler())) -> iso8583message()
-spec(unmarshal(list(byte()), list(marshal_handler())) -> iso8583message()).
unmarshal(Marshalled, MarshalHandlers) ->
	OptionsRecord = parse_options(MarshalHandlers, #marshal_options{}),
	{Message0, Marshalled1} = init_unmarshalling(OptionsRecord, erl8583_message:new(), Marshalled),
	{Message1, Marshalled2} = decode_mti(OptionsRecord, Marshalled1, Message0),
	{FieldIds, Marshalled3} = decode_bitmap(OptionsRecord, Marshalled2),
	decode_fields(FieldIds, Message1, OptionsRecord, Marshalled3).

%%
%% Local Functions
%%
parse_options([], OptionsRecord) ->
	OptionsRecord;
parse_options([{field_marshaller, Marshaller}|Tail], OptionsRecord) ->
	parse_options(Tail, OptionsRecord#marshal_options{field_marshaller=Marshaller});
parse_options([{bitmap_marshaller, Marshaller}|Tail], OptionsRecord) ->
	parse_options(Tail, OptionsRecord#marshal_options{bitmap_marshaller=Marshaller});
parse_options([{mti_marshaller, Marshaller}|Tail], OptionsRecord) ->
	parse_options(Tail, OptionsRecord#marshal_options{mti_marshaller=Marshaller});
parse_options([{init_marshaller, Marshaller}|Tail], OptionsRecord) ->
	parse_options(Tail, OptionsRecord#marshal_options{init_marshaller=Marshaller});
parse_options([{end_marshaller, Marshaller}|Tail], OptionsRecord) ->
	parse_options(Tail, OptionsRecord#marshal_options{end_marshaller=Marshaller});
parse_options([{encoding_rules, Rules}|Tail], OptionsRecord) ->
	parse_options(Tail, OptionsRecord#marshal_options{encoding_rules=Rules}).

get_encoding_rules(Options, Message) ->
	if
		Options#marshal_options.encoding_rules =/= undefined ->
			Options#marshal_options.encoding_rules;
		Options#marshal_options.encoding_rules =:= undefined ->
			case erl8583_message:get_fields(Message) of
				[0|_Fields] ->
					Mti = erl8583_message:get(0, Message),
					[Version|_MtiRest] = Mti,
					case Version of
						$0 ->
							erl8583_fields;
						$1 ->
							erl8583_fields_1993;
						$2 ->
							erl8583_fields_2003
					end;
				_ ->
					undefined
			end
	end.

encode_mti(Options, Message) ->
	MtiMarshalModule = Options#marshal_options.mti_marshaller,
	if
		MtiMarshalModule =:= undefined ->
			[];
		MtiMarshalModule =/= undefined ->
			case erl8583_message:get_fields(Message) of
				[0|_Fields] ->
					MtiMarshalModule:marshal_mti(erl8583_message:get(0,Message));
				_ ->
					[]
			end
	end.

decode_mti(Options, Marshalled, Message) ->
	MtiMarshalModule = Options#marshal_options.mti_marshaller,
	if
		MtiMarshalModule =:= undefined ->
			{Message, Marshalled};
		MtiMarshalModule =/= undefined ->
			{FieldValue, Rest} = MtiMarshalModule:unmarshal_mti(Marshalled),
			{erl8583_message:set(0, FieldValue, Message), Rest}
	end.
	
encode_bitmap(Options, Message) ->
	BitmapMarshalModule = Options#marshal_options.bitmap_marshaller,
	if
		BitmapMarshalModule =:= undefined ->
			{[], Message};
		BitmapMarshalModule =/= undefined ->			
			BitmapMarshalModule:marshal_bitmap(Message)
	end.

decode_bitmap(Options, Marshalled) ->
	BitmapMarshalModule = Options#marshal_options.bitmap_marshaller,
	if
		BitmapMarshalModule =:= undefined ->
			{[], Marshalled};
		BitmapMarshalModule =/= undefined ->			
			BitmapMarshalModule:unmarshal_bitmap(Marshalled)
	end.

encode_fields(Options, Message) ->
	Fields = erl8583_message:get_fields(Message) -- [0],
	EncodingRules = get_encoding_rules(Options, Message),
	FieldMarshalModule = Options#marshal_options.field_marshaller,
	if
		FieldMarshalModule =:= undefined ->
			[];
		FieldMarshalModule =/= undefined ->
			encode(Fields, Message, FieldMarshalModule, EncodingRules) 
	end.
	
encode(Fields, Msg, FieldMarshaller, EncodingRules) ->
	encode(Fields, Msg, [], FieldMarshaller, EncodingRules).

encode([], _Msg, Result, _FieldMarshaller, _EncodingRules) ->
	lists:reverse(Result);
encode([FieldId|Tail], Msg, Result, FieldMarshaller, EncodingRules) ->
	Value = erl8583_message:get(FieldId, Msg),
	EncodedValue = FieldMarshaller:marshal_field(FieldId, Value, EncodingRules),
	encode(Tail, Msg, lists:reverse(EncodedValue) ++ Result, FieldMarshaller, EncodingRules).

decode_fields([], Message, _OptionsRecord, _Marshalled) ->
	Message;
decode_fields([FieldId|Tail], Message, Options, Marshalled) ->
	EncodingRules = get_encoding_rules(Options, Message),
	FieldMarshalModule = Options#marshal_options.field_marshaller,
	if
		FieldMarshalModule =:= undefined ->
			Message;
		FieldMarshalModule =/= undefined ->
			{FieldValue, Rest, FieldsToUnmarshal} = FieldMarshalModule:unmarshal_field(FieldId, Marshalled, EncodingRules),
			decode_fields(Tail ++ FieldsToUnmarshal, erl8583_message:set(FieldId, FieldValue, Message), 
						  Options, Rest) 
	end.

end_marshalling(Options, Message, Marshalled) ->
	EndMarshalModule = Options#marshal_options.end_marshaller,
	if
		EndMarshalModule =:= undefined ->
			Marshalled;
		EndMarshalModule =/= undefined ->
			EndMarshalModule:marshal_end(Message, Marshalled) 
	end.

init_marshalling(Options, Message) ->
	InitMarshalModule = Options#marshal_options.init_marshaller,
	if
		InitMarshalModule =:= undefined ->
			Message;
		InitMarshalModule =/= undefined ->
			InitMarshalModule:marshal_init(Message) 
	end.

init_unmarshalling(Options, Marshalled, Message) ->
	WrapperMarshalModule = Options#marshal_options.init_marshaller,
	if
		WrapperMarshalModule =:= undefined ->
			{Marshalled, Message};
		WrapperMarshalModule =/= undefined ->
			WrapperMarshalModule:unmarshal_init(Marshalled, Message) 
	end.
