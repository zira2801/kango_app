import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:scan_barcode_app/bloc/auth/sign_up_bloc/sign_up_event.dart';
import 'package:scan_barcode_app/bloc/auth/sign_up_bloc/sign_up_state.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(SignUpInitial()) {
    on<SignUpButtonPressed>(_onSignUpButtonPressed);
  }

  Future<void> _onSignUpButtonPressed(
    SignUpButtonPressed event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());
    final response = await http.post(
      Uri.parse('$baseUrl$registerApi'),
      headers: ApiUtils.getHeaders(),
      body: jsonEncode({
        'is_customer': event.isCustomer,
        'user_name': event.email,
        'password': event.password,
        'confirm_password': event.confirmPassword,
        'user_company_name': event.companyName,
        'user_contact_name': event.contactName,
        'user_tax_code': event.taxCode,
        'user_phone': event.phone,
        'user_address_1': event.address1,
        'user_address_2': event.address2,
        'user_address_3': event.address3,
        'user_latitude': event.latitude,
        'user_longitude': event.longitude,
        'user_address': event.address4,
        'user_accountant_key': event.accountantKey,
        'user_logo': event.userLogo,
        'position_id': event.positionID,
        'branch_id': event.branchID,
      }),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        var textNoti = data['message'];
        emit(SignUpSuccess(responseText: textNoti['text']));
      } else {
        log("ERROR _onSignUpButtonPressed 1");
        // Parse JSON response
        Map<String, dynamic> responseMap = jsonDecode(response.body);

        // Extract errors
        Map<String, dynamic> errors = responseMap['errors'];
        // Define the keys and their new messages
        Map<String, String> updates = {
          'user_name': "Email này đã được sử dụng",
          'user_accountant_key': "Mã kế toán đã được sử dụng",
          'user_address_1': "Quốc gia không được để trống",
          // Add more keys and their new messages as needed
        };

        // Update specific error messages for the given keys
        updates.forEach((key, newMessage) {
          if (errors.containsKey(key)) {
            errors[key] = [newMessage];
          }
        });
        // Initialize an empty list to collect error messages
        List<String> errorMessages = [];

        // Iterate through the errors map and collect messages
        errors.forEach((key, value) {
          if (value is List) {
            errorMessages.addAll(value.map((msg) => msg.toString()).toList());
          }
        });

        // Join the error messages into a single string separated by new lines
        String errorMessageString = errorMessages.join(' \n ');

        // Print the resulting string
        log(errorMessageString);
        emit(SignUpFailure(errorText: errorMessageString));
      }
    } catch (error) {
      log("ERROR _onSignUpButtonPressed 2");

      if (error is http.ClientException) {
        emit(SignUpFailure(errorText: "Không thể kết nối đến máy chủ"));
      } else {
        emit(SignUpFailure(errorText: error.toString()));
      }
    }
  }
}
