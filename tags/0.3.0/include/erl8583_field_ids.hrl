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

%% Defines identifiers for ISO 8583 fields.
-define(MTI, 0).
-define(BITMAP_EXTENDED, 1).
-define(PAN, 2).
-define(PROC_CODE, 3).
-define(AMOUNT_TRAN, 4).
-define(AMOUNT_SETTLE, 5).
-define(AMOUNT_CARDHOLDER_BILLING, 6).
-define(TRANSMISSION_DATE_TIME, 7).
-define(AMOUNT_CARDHOLDER_BILLING_FEE, 8).
-define(CONVERSION_RATE_SETTLE, 9).
-define(CONVERSION_RATE_CARDHOLDER_BILLING, 10).
-define(SYSTEMS_TRACE_AUDIT_NUMBER, 11).

% 1987 declaration for field 12
-define(TIME_LOCAL_TRAN, 12).
% 1993 declaration for field 12
-define(DATE_AND_TIME_LOCAL_TRAN, 12).

% 1987 declaration for field 12
-define(DATE_LOCAL_TRAN, 13).
% 1993 declaration for field 13
-define(DATE_EFF, 13).

-define(DATE_EXP, 14).
-define(DATE_SETTLE, 15).
-define(DATE_CONVERSION, 16).
-define(DATE_CAPTURE, 17).
-define(MERCHANT_TYPE, 18).
-define(ACQUIRER_COUNTRY_CODE, 19).
-define(PAN_EXT_COUNTRY_CODE, 20).
-define(FORWARDING_INST_COUNTRY_CODE, 21).

% 1987 declaration for field 22
-define(POS_ENTRY_MODE, 22).
% 1993 declaration for field 22
-define(POS_DATA_CODE, 22).

-define(CARD_SEQUENCE_NUMBER, 23).

% 1987 declaration for field 24
-define(NETWORK_INTERNATIONAL_ID, 24).
% 1993 declaration for field 24
-define(FUNCTION_CODE, 24).

% 1987 declaration for field 25
-define(POS_CONDITION_CODE, 25).
% 1993 declaration for field 25
-define(MESSAGE_REASON_CODE, 25).

% 1987 declaration for field 26
-define(POS_CAPTURE_CODE, 26).
% 1993 declaration for field 26
-define(CARD_ACCEPTOR_BUSINESS_CODE, 26).

-define(AUTHORIZING_ID_RESP_LEN, 27).
-define(AMOUNT_TRAN_FEE, 28).
-define(AMOUNT_SETTLE_FEE, 29).

% 1987 declaration for field 30
-define(AMOUNT_TRAN_PROCESSING_FEE, 30).
% 1993 declaration for field 30
-define(AMOUNT_ORIGINAL, 30).

% 1987 declaration for field 31
-define(AMOUNT_SETTLE_PROCESSING_FEE, 31).
% 1993 declaration for field 31
-define(ACQUIRER_REFERENCE_DATA, 31).

-define(ACQUIRING_INST_ID_CODE, 32).
-define(FORWARDING_INST_ID_CODE, 33).
-define(PAN_EXTENDED, 34).
-define(TRACK_2_DATA, 35).
-define(TRACK_3_DATA, 36).
-define(RETRIEVAL_REF_NUM, 37).
-define(AUTHORIZATION_ID_RESP, 38).
-define(RESP_CODE, 39).
-define(SERVICE_RESTRICTION_CODE, 40).
-define(CARD_ACCEPTOR_TERMINAL_ID, 41).
-define(CARD_ACCEPTOR_ID_CODE, 42).
-define(CARD_ACCEPTOR_NAME_LOCATION, 43).
-define(ADDITIONAL_RESP_DATA, 44).
-define(TRACK_1_DATA, 45).
-define(ADDITIONAL_DATA_ISO, 46).
-define(ADDITIONAL_DATA_NATIONAL, 47).
-define(ADDITIONAL_DATA_PRIVATE, 48).
-define(CURRENCY_CODE_TRAN, 49).
-define(CURRENCY_CODE_SETTLE, 50).
-define(CURRENCY_CODE_CARDHOLDER_BILLING, 51).
-define(PERSONAL_ID_NUMBER_DATA, 52).
-define(SECURITY_RELATED_CONTROL_INFO, 53).
-define(ADDITIONAL_AMOUNTS, 54).

% 1987 definition for field 55
-define(RESERVED_ISO1, 55).
% 1993 definition for field 55
-define(ICC_SYSTEM_RELATED_DATA, 55).

% 1987 definition for field 56
-define(RESERVED_ISO2, 56).
% 1993 definition for field 56
-define(ORIGINAL_DATA_ELEMENTS_1993, 56).

-define(RESERVED_NATIONAL1, 57).
-define(RESERVED_NATIONAL2, 58).
-define(RESERVED_NATIONAL3, 59).
-define(RESERVED_PRIVATE1, 60).
-define(RESERVED_PRIVATE2, 61).
-define(RESERVED_PRIVATE3, 62).
-define(RESERVED_PRIVATE4, 63).
-define(MESSAGE_AUTHENTICATION_CODE, 64).
-define(SETTLE_CODE, 66).
-define(EXTENDED_PAYMENT_CODE, 67).
-define(RECEIVING_INSTITUTION_COUNTRY_CODE, 68).
-define(SETTLE_INSTITUTION_COUNTRY_CODE, 69).
-define(NETWORK_MANAGEMENT_INFORMATION_CODE, 70).
-define(MESSAGE_NUMBER, 71).
-define(MESSAGE_NUMBER_LAST, 72).
-define(DATE_ACTION, 73).
-define(CREDITS_NUMBER, 74).
-define(CREDITS_REVERSAL_NUMBER, 75).
-define(DEBITS_NUMBER, 76).
-define(DEBITS_REVERSAL_NUMBER, 77).
-define(TRANSFER_NUMBER, 78).
-define(TRANSFER_NUMBER_REVERSAL, 79).
-define(INQUIRIES_NUMBER, 80).
-define(AUTHORIZATIONS_NUMBER, 81).
-define(CREDITS_PROCESSING_FEE_AMOUNT, 82).
-define(CREDITS_TRANSACTION_FEE_AMOUNT, 83).
-define(DEBITS_PROCESSING_FEE_AMOUNT, 84).
-define(DEBITS_TRANSACTION_FEE_AMOUNT, 85).
-define(CREDITS_AMOUNT, 86).
-define(CREDITS_REVERSAL_AMOUNT, 87).
-define(DEBITS_AMOUNT, 88).
-define(DEBITS_REVERSAL_AMOUNT, 89).
-define(ORIGINAL_DATA_ELEMENTS, 90).
-define(FILE_UPDATE_CODE, 91).
-define(FILE_SECURITY_CODE, 92).
-define(RESP_INDICATOR, 93).
-define(SERVICE_INDICATOR, 94).
-define(REPLACEMENT_AMOUNTS, 95).
-define(MESSAGE_SECURITY_CODE, 96).
-define(AMOUNT_NET_SETTLE, 97).
-define(PAYEE, 98).
-define(SETTLE_INSTITUTION_ID_CODE, 99).
-define(RECEIVING_INSTITUTION_ID_CODE, 100).
-define(FILE_NAME, 101).
-define(ACCOUNT_ID1, 102).
-define(ACCOUNT_ID2, 103).
-define(TRAN_DESCRIPTION, 104).
-define(MESSAGE_AUTHENTICATION_CODE2, 128).


