


import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {



  init() async {
    if(Platform.isIOS){
        PermissionStatus status = await Permission.photos.status;
        checkStatusPhotos(status);
    }
    else
      {
        PermissionStatus storage = await Permission.storage.status;
        checkStatusStorage(storage);
      }

  }

  Future<PermissionStatus> checkStatusPhotos(PermissionStatus permissionStatus) async{
    switch (permissionStatus){
      case PermissionStatus.permanentlyDenied: return Future.error("L'accès des photos est refusé");
      case PermissionStatus.denied: return Permission.photos.request();
      case PermissionStatus.restricted: return Permission.photos.request();
      case PermissionStatus.limited: return Permission.photos.request();
      case PermissionStatus.granted: return Permission.photos.request();
      default: return Future.error("Aucun stauts présent");
    }

  }

  checkStatusStorage(PermissionStatus permissionStatus){
    switch (permissionStatus){
      case PermissionStatus.permanentlyDenied: return Future.error("L'accès des photos est refusé");
      case PermissionStatus.denied: return Permission.storage.request();
      case PermissionStatus.restricted: return Permission.storage.request();
      case PermissionStatus.limited: return Permission.storage.request();
      case PermissionStatus.granted: return Permission.storage.request();
      default: return Future.error("Aucun stauts présent");
    }

  }


}