import 'package:flutter_bottom_nav/common/common_util.dart';
import 'package:flutter_bottom_nav/core/repository/lead_repository.dart';

class CallServices{
  static Future <void> initialCall(String leadId) async{

   bool isPrivicy = await CommonUtil.isPrivacyFlag();

//String mobile =await LeadRepository.getMobile(leadId);



  }
}