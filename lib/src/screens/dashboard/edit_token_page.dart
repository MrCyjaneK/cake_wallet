import 'package:cake_wallet/generated/i18n.dart';
import 'package:cake_wallet/src/screens/base_page.dart';
import 'package:cake_wallet/src/widgets/address_text_field.dart';
import 'package:cake_wallet/src/widgets/base_text_form_field.dart';
import 'package:cake_wallet/src/widgets/checkbox_widget.dart';
import 'package:cake_wallet/src/widgets/primary_button.dart';
import 'package:cake_wallet/src/widgets/scollable_with_bottom_section.dart';
import 'package:cake_wallet/view_model/dashboard/home_settings_view_model.dart';
import 'package:cw_core/erc20_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditTokenPage extends BasePage {
  EditTokenPage({Key? key, required this.homeSettingsViewModel, this.erc20token});

  final HomeSettingsViewModel homeSettingsViewModel;
  final Erc20Token? erc20token;

  @override
  String? get title => S.current.edit_token;

  @override
  Widget body(BuildContext context) {
    return EditTokenPageBody(
      homeSettingsViewModel: homeSettingsViewModel,
      erc20token: erc20token,
    );
  }
}

class EditTokenPageBody extends StatefulWidget {
  const EditTokenPageBody({Key? key, required this.homeSettingsViewModel, this.erc20token})
      : super(key: key);

  final HomeSettingsViewModel homeSettingsViewModel;
  final Erc20Token? erc20token;

  @override
  State<EditTokenPageBody> createState() => _EditTokenPageBodyState();
}

class _EditTokenPageBodyState extends State<EditTokenPageBody> {
  final TextEditingController _contractAddressController = TextEditingController();
  final TextEditingController _tokenNameController = TextEditingController();
  final TextEditingController _tokenSymbolController = TextEditingController();
  final TextEditingController _tokenDecimalController = TextEditingController();

  final FocusNode _contractAddressFocusNode = FocusNode();
  final FocusNode _tokenNameFocusNode = FocusNode();
  final FocusNode _tokenSymbolFocusNode = FocusNode();
  final FocusNode _tokenDecimalFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _showDisclaimer = false;
  bool _disclaimerChecked = false;

  @override
  void initState() {
    super.initState();

    if (widget.erc20token != null) {
      _contractAddressController.text = widget.erc20token!.contractAddress;
      _tokenNameController.text = widget.erc20token!.name;
      _tokenSymbolController.text = widget.erc20token!.symbol;
      _tokenDecimalController.text = widget.erc20token!.decimal.toString();
    }

    _contractAddressFocusNode.addListener(() {
      if (!_contractAddressFocusNode.hasFocus) {
        _getTokenInfo(_contractAddressController.text);
      }

      final contractAddress = _contractAddressController.text;
      if (contractAddress.isNotEmpty && contractAddress != widget.erc20token?.contractAddress) {
        setState(() {
          _showDisclaimer = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ScrollableWithBottomSection(
        contentPadding: EdgeInsets.zero,
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 28),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentTextTheme.bodySmall!.color!,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/restore_keys.png'),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).warning,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryTextTheme.titleLarge!.color!,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              S.of(context).add_token_warning,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).primaryTextTheme.labelSmall!.color!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              _tokenForm(),
            ],
          ),
        ),
        bottomSectionPadding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
        bottomSection: Column(
          children: [
            if (_showDisclaimer) ...[
              CheckboxWidget(
                value: _disclaimerChecked,
                caption: S.of(context).add_token_disclaimer_check,
                onChanged: (value) {
                  _disclaimerChecked = value;
                },
              ),
              SizedBox(height: 20),
            ],
            Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryButton(
                    onPressed: () async {
                      if (widget.erc20token != null) {
                        await widget.homeSettingsViewModel.deleteErc20Token(widget.erc20token!);
                      }
                      Navigator.pop(context);
                    },
                    text: widget.erc20token != null ? S.of(context).delete : S.of(context).cancel,
                    color: Colors.red,
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          (!_showDisclaimer || _disclaimerChecked)) {
                        await widget.homeSettingsViewModel.addErc20Token(Erc20Token(
                          name: _tokenNameController.text,
                          symbol: _tokenSymbolController.text,
                          contractAddress: _contractAddressController.text,
                          decimal: int.parse(_tokenDecimalController.text),
                        ));
                        Navigator.pop(context);
                      }
                    },
                    text: S.of(context).save,
                    color: Theme.of(context).accentTextTheme.bodyLarge!.color!,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _getTokenInfo(String? address) async {
    if (address?.isNotEmpty ?? false) {
      final token = await widget.homeSettingsViewModel.getErc20Token(address!);

      if (token != null) {
        if (_tokenNameController.text.isEmpty) _tokenNameController.text = token.name;
        if (_tokenSymbolController.text.isEmpty) _tokenSymbolController.text = token.symbol;
        if (_tokenDecimalController.text.isEmpty)
          _tokenDecimalController.text = token.decimal.toString();
      }
    }
  }

  Future<void> _pasteText() async {
    final value = await Clipboard.getData('text/plain');

    if (value?.text?.isNotEmpty ?? false) {
      _contractAddressController.text = value!.text!;

      _getTokenInfo(_contractAddressController.text);
      setState(() {
        _showDisclaimer = true;
      });
    }
  }

  Widget _tokenForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AddressTextField(
            controller: _contractAddressController,
            focusNode: _contractAddressFocusNode,
            placeholder: S.of(context).token_contract_address,
            options: [AddressTextFieldOption.paste],
            buttonColor: Theme.of(context).hintColor,
            validator: (text) {
              if (text?.isNotEmpty ?? false) {
                return null;
              }

              return 'S.of(context).field_required';
            },
            onPushPasteButton: (_) {
              _pasteText();
            },
          ),
          const SizedBox(height: 8),
          BaseTextFormField(
            controller: _tokenNameController,
            focusNode: _tokenNameFocusNode,
            onSubmit: (_) => FocusScope.of(context).requestFocus(_tokenSymbolFocusNode),
            textInputAction: TextInputAction.next,
            hintText: S.of(context).token_name,
            validator: (text) {
              if (text?.isNotEmpty ?? false) {
                return null;
              }

              return S.of(context).field_required;
            },
          ),
          const SizedBox(height: 8),
          BaseTextFormField(
            controller: _tokenSymbolController,
            focusNode: _tokenSymbolFocusNode,
            onSubmit: (_) => FocusScope.of(context).requestFocus(_tokenDecimalFocusNode),
            textInputAction: TextInputAction.next,
            hintText: S.of(context).token_symbol,
            validator: (text) {
              if (text?.isNotEmpty ?? false) {
                return null;
              }

              return S.of(context).field_required;
            },
          ),
          const SizedBox(height: 8),
          BaseTextFormField(
            controller: _tokenDecimalController,
            focusNode: _tokenDecimalFocusNode,
            textInputAction: TextInputAction.done,
            hintText: S.of(context).token_decimal,
            validator: (text) {
              if (text?.isEmpty ?? true) {
                return S.of(context).field_required;
              }
              if (int.tryParse(text!) == null) {
                // TODO: add localization
                return 'S.of(context).invalid_input';
              }

              return null;
            },
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}