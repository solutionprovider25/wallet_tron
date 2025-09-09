import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:wallet_tron/src/data/Content.dart';
import 'package:wallet_tron/src/data/walletRepo.dart';
import 'package:wallet_tron/src/data/enum.dart';
import 'package:wallet_tron/src/data/tokenfuncation.dart';

/// A utility class for performing actions related to Tron Wallet
class TronwalletAction {
  /// [network] specifies the Tron network to use (default is Nile testnet)
  static Future<Map<String, dynamic>> createAccount(
      {TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    String netw = await getNetwork(network);

    try {
      await webViewController!
          .evaluateJavascript(source: 'createAccount("$netw")');
      String chek = await checkOT();
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  /// Converts a given amount of TRX into its smallest unit, Sun
  static int getSun(num amount) {
    int result = 1;
    int baseValue = 10;
    for (int i = 0; i < 6; i++) {
      result = result * baseValue;
    }
    return (amount * result).toInt();
  }

  /// Validates if the given wallet address is a valid Tron address
  static bool isAddress({required String walletaddress}) {
    return isValidTronAddress(walletaddress);
  }

  /// Fetches the balance of a Tron wallet for the given address and network
  static Future<Map<String, dynamic>> getbalance(
      {required String walletaddress,
      TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      if (isValidTronAddress(walletaddress) == false) {
        throw const FormatException('Invalid tron Address');
      }
      String netw = await getNetwork(network);
      await webViewController!
          .evaluateJavascript(source: 'getbalance("$walletaddress,$netw")');
      String chek = await checkOT();
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  /// Fetches account information for the specified wallet address and network
  static Future<Map<String, dynamic>> getAccouninfo(
      {required String walletaddress,
      TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      if (isValidTronAddress(walletaddress) == false) {
        throw const FormatException('Invalid  tron Address');
      }
      String netw = await getNetwork(network);
      await webViewController!
          .evaluateJavascript(source: 'getAccount("$walletaddress","$netw")');
      String chek = await checkOT();
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  /// Sends TRX to a recipient's wallet address
  static Future<Map<String, dynamic>> sendTrx(
      {required String receiverAddress,
      required int amountinSun,
      required String privatekey,
      TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      if (isValidTronAddress(receiverAddress) == false) {
        throw const FormatException('Invalid tron Address');
      }
      String netw = await getNetwork(network);

      await webViewController!.evaluateJavascript(
          source:
              'Sendtrx("$privatekey","$receiverAddress","$amountinSun","$netw")');

      String chek = await checkOT();
      if (chek.toString().contains('result') == false) {
        throw chek;
      }
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  /// Fetches transaction information for a specific hash
  static Future<Map<String, dynamic>> getTransactionInfo(
      {required String hash,
      TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      String netw = await getNetwork(network);
      await webViewController!
          .evaluateJavascript(source: 'getTransactionInfo("$hash","$netw")');
      String chek = await checkOT();
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  /// Sends TRC-20 tokens to a recipient's wallet address

  static Future<Map<String, dynamic>> sendTRC20Token(
      {required String privatekey,
      required String contractAddresss,
      required String ownerAddress,
      required String receiverAddress,
      required int amountInContactType,
      TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      if (isValidTronAddress(contractAddresss) == false ||
          isValidTronAddress(ownerAddress) == false ||
          isValidTronAddress(receiverAddress) == false) {
        throw const FormatException('Invalid tron Address');
      }
      String netw = await getNetwork(network);
      var parameter = [
        {'type': 'address', 'value': receiverAddress},
        {'type': 'uint256', 'value': amountInContactType.toInt()}
      ];
      String result = convertToFormat(parameter);

      dynamic trigerr = await triggersmartContact(
          contract_address: contractAddresss,
          parametr: result,
          walletadress: ownerAddress,
          network: network);
      if (trigerr.toString().contains('ERROR')) {
        throw trigerr['ERROR'];
      }
      log("tigger $trigerr");
      await webViewController!.evaluateJavascript(
          source: 'SignBroad($trigerr,"$privatekey","$netw")');
      String chek = await checkOT();
      if (chek.toString().contains('result') == false) {
        throw chek;
      }
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  ///Freeze or Stake the trx for Resource (Bandwidth and Energy)
  static Future<Map<String, dynamic>> freezeBalance(
      {required String owneraddress,
      required int amountinSun,
      required String privatekey,
      required FreezeResource resource,
      TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      if (isValidTronAddress(owneraddress) == false) {
        throw const FormatException('Invalid tron Address');
      }
      String netw = await getNetwork(network);
      String reso = resource.name.toString();

      await webViewController!.evaluateJavascript(
          source:
              'freezeBalanceV2("$privatekey","$owneraddress","$amountinSun","$reso","$netw")');

      String chek = await checkOT();
      if (chek.toString().contains('result') == false) {
        throw chek;
      }
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  ///UnFreeze or UnStake the trx for Resource (Bandwidth and Energy)
  static Future<Map<String, dynamic>> unFreezeBalance(
      {required String owneraddress,
      required int amountinSun,
      required String privatekey,
      required FreezeResource resource,
      TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      if (isValidTronAddress(owneraddress) == false) {
        throw const FormatException('Invalid tron Address');
      }
      String netw = await getNetwork(network);
      String reso = resource.name.toString();

      await webViewController!.evaluateJavascript(
          source:
              'unfreezeBalanceV2("$privatekey","$owneraddress","$amountinSun","$reso","$netw")');

      String chek = await checkOT();
      if (chek.toString().contains('result') == false) {
        throw chek;
      }
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  ///Get the List of all SR
  static Future<Map<String, dynamic>> getSRList(
      {TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      var netw = await getSRlist(network: network);
      return SuccessMessage(json.encode(netw.toString()));
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  ///Apply the new SR of any network
  static Future<Map<String, dynamic>> applySR(
      {required String owneraddress,
      required String privatekey,
      required String url,
      TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      if (isValidTronAddress(owneraddress) == false) {
        throw const FormatException('Invalid tron Address');
      }
      String netw = await getNetwork(network);
      await webViewController!.evaluateJavascript(
          source: 'applyForSR("$privatekey","$owneraddress","$url","$netw")');

      String chek = await checkOT();
      if (chek.toString().contains('result') == false) {
        throw chek;
      }
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  ///Vote for SR .which can show on  the network
  static Future<Map<String, dynamic>> vote(
      {required String owneraddress,
      required String privatekey,
      required Map<String, int> votes,
      TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      if (isValidTronAddress(owneraddress) == false) {
        throw const FormatException('Invalid tron Address');
      }
      String netw = await getNetwork(network);

      await webViewController!.evaluateJavascript(
          source:
              'vote("$privatekey","$owneraddress",${jsonEncode(votes)},"$netw")');

      String chek = await checkOT();
      if (chek.toString().contains('result') == false) {
        throw chek;
      }
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  ///Vote for SR's Proposal in Community

  static Future<Map<String, dynamic>> voteProposal(
      {required String owneraddress,
      required String privatekey,
      required String proposalId,
      required bool hasApproval,
      TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      if (isValidTronAddress(owneraddress) == false) {
        throw const FormatException('Invalid tron Address');
      }
      String netw = await getNetwork(network);

      await webViewController!.evaluateJavascript(
          source:
              'voteProposal("$privatekey","$owneraddress",$proposalId,"$hasApproval","$netw")');

      String chek = await checkOT();
      if (chek.toString().contains('result') == false) {
        throw chek;
      }
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  ///Delete the SR Proposal into the Community
  static Future<Map<String, dynamic>> deleteProposal(
      {required String owneraddress,
      required String privatekey,
      required String proposalId,
      TronwalletNetwork network = TronwalletNetwork.Nile}) async {
    try {
      if (isValidTronAddress(owneraddress) == false) {
        throw const FormatException('Invalid tron Address');
      }
      String netw = await getNetwork(network);

      await webViewController!.evaluateJavascript(
          source:
              'deleteProposal("$privatekey","$owneraddress",$proposalId,"$netw")');

      String chek = await checkOT();
      if (chek.toString().contains('result') == false) {
        throw chek;
      }
      return SuccessMessage(chek);
    } catch (e) {
      return ErrorMessage(e);
    }
  }

  static Map<String, dynamic> ErrorMessage(dynamic data) => {"Error": data};
  static Map<String, dynamic> SuccessMessage(dynamic data) =>
      {"Response": data};
}
