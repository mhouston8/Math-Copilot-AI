import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../config.dart';

class RevenueCatService {
  Future<void> initialize({String? appUserId}) async {
    final configured = await Purchases.isConfigured;
    if (configured) return;

    await Purchases.setLogLevel(LogLevel.info);
    await Purchases.configure(
      PurchasesConfiguration(revenueCatApiKey)..appUserID = appUserId,
    );
  }

  Future<Offerings> getOfferings() async {
    return Purchases.getOfferings();
  }

  Future<CustomerInfo> getCustomerInfo() async {
    return Purchases.getCustomerInfo();
  }

  Future<CustomerInfo> purchasePackage(Package packageToPurchase) async {
    final result = await Purchases.purchase(
      PurchaseParams.package(packageToPurchase),
    );
    return result.customerInfo;
  }

  Future<PaywallResult> presentTemplatePaywall({
    Offering? offering,
    bool displayCloseButton = true,
  }) async {
    return RevenueCatUI.presentPaywall(
      offering: offering,
      displayCloseButton: displayCloseButton,
    );
  }

  Future<PaywallResult> presentTemplatePaywallIfNeeded({
    required String entitlementId,
    Offering? offering,
    bool displayCloseButton = true,
  }) async {
    return RevenueCatUI.presentPaywallIfNeeded(
      entitlementId,
      offering: offering,
      displayCloseButton: displayCloseButton,
    );
  }

  Future<CustomerInfo> restorePurchases() async {
    return Purchases.restorePurchases();
  }

  Future<CustomerInfo> logOut() async {
    return Purchases.logOut();
  }

  Future<LogInResult> logIn(String appUserId) async {
    return Purchases.logIn(appUserId);
  }

  Future<bool> hasActiveEntitlement(String entitlementId) async {
    final customerInfo = await getCustomerInfo();
    return customerInfo.entitlements.active.containsKey(entitlementId);
  }
}
