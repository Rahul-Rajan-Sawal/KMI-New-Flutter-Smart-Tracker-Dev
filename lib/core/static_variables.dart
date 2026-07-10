class StaticVariables {
  //BaseUrl and HostName For Production
  // static const String baseUrl =
  //     "https://iceservices.brobotinsurance.com/RGI_LMS_WRAPERAPI/api/lms";
  // static const String ContentURL =
  //     "https://iceservices.reliancegeneral.co.in/RGI_LMS_WRAPERAPI/mFiles/";
  // static const String baseUrl =
  //     "https://iceservices.brobotinsurance.com/RGI_LMS_WRAPERAPI/api/lms";
  //      static const String ContentURL = "https://iceservices.reliancegeneral.co.in/RGI_LMS_WRAPERAPI/mFiles/";

  // static const String hostName = "iceservices.brobotinsurance.com";

  // BaseUrl and HostName For UAT
  static const String baseUrl =
      "https://mservices.brobotinsurance.com/LMSWEBAPIUAT/api/lms";
  static const String hostName = "mservices.brobotinsurance.com";
  static const String ContentURL =
      "https://mservices.brobotinsurance.com/LMSWEBAPIUAT/mFiles/";

  static const String getCallDownTime = "GetCallDownTime";

  static const String getApiValues = "GetApiValues";
  static const String authenticateUser = "AuthenticateUser_WithAppVersion",
      getSearchData = "GetSearchData",
      GetDashboardData = "GetDashboardData",
      SearchAgent = "SearchAgent",
      GetLeadDetails = "GetLeadDetails",
      MarkPrimaryContact = "MarkPrimaryContact",
      SubmitAgntContact = "SubmitAgntContact",
      SubmitCustContact = "SubmitCustContact",
      bridgeCallDtls = "bridgeCallDtls",
      GetMstMapping = "GetMstMapping",
      getLastActivityForLead = "GetLastActivityForLead",
      UpdateActivity = "UpdateActivity",
      GetCalendarData = "GetCalendarData",
      GetAllAssignedLeads = "GetAllAssignedLeads",
      GetDashboardParam = "GetDashboardParam",
      GetLeadDataForUser = "GetLeadDataForUser",
      CreateLeadFromMob = "CreateLeadFromMob",
      GetDataForDashboard = "GetDataForDashboard";

  static const String BridgeCallDtls = "BridgeCallDtls";
  static const String SearchLead = "SearchLead";

  static String lastSyncDate = DateTime.now().toString();
  //static const String appVersion = "23"; //prod
  static const String appVersion = "17"; //uat
  static const String prefsName = "MY_PREFS";

  static const String bootstrapAesKey = "M!croT3mp@123456";
  static const String initVector = "1Init@1234567890";

  static String? cipherServer;
  static String? pkcs5Padding;
  static String? apiKey;
  static String? cipher;
  static String? dbKey;
  static String? authorization;
  static String? callerPass;
  // static String? SrvcReqDtlCode;

  //static String CallerPass = "";
  static String TokenId = "";
  static String mSAPCode = "";
  static String mBranchName = "";
  static String mUserName = "";
  static String mDesignation = "";
  static String mTeam = "";
  static String callerId = "NiftyLmsAndroid";

  static const DbName = "LMS.db";
  static const DbVersion = 2;
}
