//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import connectivity_plus
import package_info_plus
import shared_preferences_foundation
import sqflite_sqlcipher
import url_launcher_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  ConnectivityPlusPlugin.register(with: registry.registrar(forPlugin: "ConnectivityPlusPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqfliteSqlCipherPlugin.register(with: registry.registrar(forPlugin: "SqfliteSqlCipherPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
}
