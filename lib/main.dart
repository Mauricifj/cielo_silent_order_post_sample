import 'package:cielo_silent_order_post/cielo_silent_order_post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Silent Order Post Sample';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: SilentOrderPostForm(),
      ),
    );
  }
}

class SilentOrderPostForm extends StatefulWidget {
  @override
  SilentOrderPostFormState createState() {
    return SilentOrderPostFormState();
  }
}

class SilentOrderPostFormState extends State<SilentOrderPostForm> {
  final _formKey = GlobalKey<FormState>();
  final _controllerHolder = TextEditingController();
  final _controllerCardNumber = TextEditingController();
  final _controllerExpirationMonth = TextEditingController();
  final _controllerExpirationYear = TextEditingController();
  final _controllerSecurityCode = TextEditingController();
  bool _sending = false;

  final SilentOrderPost _sop = SilentOrderPost(
    merchantId: "a0be879c-d2c1-486b-ba0a-04b6d4d7028Z",
    environment: Environment.SANDBOX,
  );

  @override
  void dispose() {
    _controllerHolder.dispose();
    _controllerCardNumber.dispose();
    _controllerExpirationMonth.dispose();
    _controllerExpirationYear.dispose();
    _controllerSecurityCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
              child: Loading(),
              visible: _sending,
            ),
            Visibility(
              visible: !_sending,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _controllerHolder,
                      readOnly: _sending,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'Holder name',
                        suffixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Name can\'t be null';
                        }
                        if (value.length > 35) {
                          return 'Dom Pedro II, is that you?';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _controllerCardNumber,
                      maxLength: 16,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        suffixIcon: Icon(Icons.credit_card),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Card number can\'t be null';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _controllerExpirationMonth,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Expiration month',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Expiration month can\'t be null';
                        }
                        int month = int.parse(value);
                        if (month < 0 || month > 12) {
                          return 'Are you sure $value is a month?';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _controllerExpirationYear,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Expiration year',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Expiration year can\'t be null';
                        }
                        int year = int.parse(value);
                        if (year < DateTime.now().year) {
                          return 'Are you Marty McFly?';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _controllerSecurityCode,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Security code',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Security code can\'t be null';
                        }
                        if (value.length > 4) {
                          return 'Security code too big, is it correct?';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.maxFinite,
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        elevation: 8,
                        child: Text('SEND CARD DATA'),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if (!_sending) {
                              String holder = _controllerHolder.text;
                              String cardNumber = _controllerCardNumber.text;
                              String expirationDate =
                                  "${_controllerExpirationMonth.text}/${_controllerExpirationYear.text}";
                              String securityCode =
                                  _controllerSecurityCode.text;

                              SilentOrderPostRequest request =
                                  SilentOrderPostRequest(
                                holderName: holder,
                                rawNumber: cardNumber,
                                expirationDate: expirationDate,
                                securityCode: securityCode,
                              );

                              _formKey.currentState.reset();
                              sendCardData(request);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendCardData(SilentOrderPostRequest request) async {
    setState(() {
      _sending = true;
    });

    SilentOrderPostResult result = await _sop.sendCardData(request);

    setState(() {
      _sending = false;
    });

    print("STATUS-CODE: ${result?.statusCode}");

    if (result?.response != null) {
      print("PAYMENT-TOKEN: ${result.response.paymentToken}");
    }

    if (result?.error != null) {
      if (result.error.message != null) {
        print("ERROR-MESSAGE: ${result.error.message}");
      }

      if (result.error.modelState != null) {
        print("VALIDATIONS:");
        if (result.error.modelState.holderName.isNotEmpty) {
          print("  - HOLDER-NAME:");
          result.error.modelState.holderName?.forEach((message) {
            print("    - $message");
          });
        }
        if (result.error.modelState.rawNumber.isNotEmpty) {
          print("  - RAW-NUMBER:");
          result.error.modelState.rawNumber?.forEach((message) {
            print("    - $message");
          });
        }
        if (result.error.modelState.expiration.isNotEmpty) {
          print("  - EXPIRATION-DATE:");
          result.error.modelState.expiration?.forEach((message) {
            print("    - $message");
          });
        }
        if (result.error.modelState.securityCode.isNotEmpty) {
          print("  - SECURITY-CODE:");
          result.error.modelState.securityCode?.forEach((message) {
            print("    - $message");
          });
        }
      }
    }

    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ResultScreen(result: result)));
  }
}

class Loading extends StatelessWidget {
  final String message;

  Loading({this.message = "Loading..."});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.vertical,
      width: MediaQuery.of(context).size.width -
          MediaQuery.of(context).padding.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(message, style: TextStyle(fontSize: 16.0)),
          ),
        ],
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final SilentOrderPostResult result;

  ResultScreen({this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Result")), body: _showResult(result));
  }

  Widget _showResult(SilentOrderPostResult result) {
    if (result.response != null) {
      return Column(children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: [
                  Text(
                    "PAYMENT TOKEN:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(result?.response?.paymentToken),
                ],
              ),
            ),
          ),
        ),
      ]);
    }

    if (result.error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ERROR MESSAGE:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Center(child: Text(result?.error?.message)),
                  ]),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "VALIDATIONS:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (result.error.modelState?.holderName?.isNotEmpty)
                    _validationItem(
                        "Holder Name", result.error.modelState.holderName),
                  if (result.error.modelState?.rawNumber?.isNotEmpty)
                    _validationItem(
                        "Card Number", result.error.modelState.rawNumber),
                  if (result.error.modelState?.expiration?.isNotEmpty)
                    _validationItem(
                        "Expiration Date", result.error.modelState.expiration),
                  if (result.error.modelState?.securityCode?.isNotEmpty)
                    _validationItem(
                        "Security Code", result.error.modelState.securityCode),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Text("Unknown error", style: TextStyle(fontSize: 24)))
        ],
      ),
    );
  }

  Widget _validationItem(String itemName, List itemList) {
    return Column(children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: (itemList.length != null) ? itemList.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(itemList[index]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
