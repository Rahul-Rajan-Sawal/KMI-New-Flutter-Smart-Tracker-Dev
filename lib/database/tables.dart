class DbTables {
  static const createUserTable = '''
    CREATE TABLE IF NOT EXISTS iUser(
        	SrNo integer primary key autoincrement,
        	UserId varchar,
        	UserName varchar,
        	UserEmailID varchar,
        	PhoneNo varchar,
        	UserPin varchar,
        	AuthType varchar,
        	LastAccessDate varchar,
        	RememberLogin varchar,
        	Password varchar,
        	UserStatus varchar,
        	memcode varchar,
        	Bizsrc varchar,
        	Chncls varchar,
        	CmsUnitCode varchar,
        	BranchName varchar,
        	Createddtim varchar,
        	Createdby varchar,
        	change_ver varchar,
        	TokenId varchar,
          UserType varchar,
          DashboardUpdatedDate varchar,
          CalendarUpdatedDate varchar,
          MobileNo varchar,
          EmailID varchar,
          Privacy_Flag varchar,
          Schedule_Days varchar,
          Ren_Rem_Days varchar,
          BridgeCallToTime varchar,
          BridgeCallFromTime varchar,
          BridgeCallDownTime varchar
        );
  ''';

  static const dropUserTable = '''
    DROP TABLE IF EXISTS iUser
  ''';

  static const createTbl_DashboardData_Mob = '''
    CREATE TABLE IF NOT EXISTS DashboardData_Mob(
            RecId integer primary key autoincrement,
            UserId TEXT,
            AgentCode TEXT,
            AgentName TEXT,
            HNINCode TEXT,
            HNINName TEXT,
            LOBCode TEXT,
            ProdCode TEXT,
            NCBFlag TEXT,
            date TEXT,
            DateInLong LONG,
            TotalLeads TEXT,
            WIPLeads TEXT,
            LeadConverted TEXT,
            LeadLost TEXT,
            Lead_Converted TEXT,
            Premium_Collected TEXT,
            Policy_Issued TEXT,
            Call_Back TEXT,
            Appointment_Fixed TEXT,
            Non_Contactable TEXT,
            Lost_To_Competition TEXT,
            Customer_Not_Interested TEXT,
            Customer_Not_Responding TEXT,
            ParkLead TEXT,
            FollowUp TEXT,
            LeadType TEXT,
            BizType TEXT,
            MarcketType TEXT,
            PolicyChanel TEXT,
            BMCMCode TEXT,
            ircCode TEXT,
            ircname TEXT,
            RNType TEXT,
            NetODPremium TEXT,
            NetTPPremium TEXT,
            RNblockReason TEXT,
            ProductGroup TEXT,
            ProductSubCategory TEXT,
            NILDep TEXT,
            Category TEXT,
            FuelType TEXT,
            VehicleType TEXT,
            SeatingCapacity TEXT,
            AgeGroup TEXT,
            FamilySize TEXT,
            SumInsuredBand TEXT,
            PreExiting TEXT,
            Occupancy TEXT,
            SumInsured TEXT,
            LifeGroup TEXT,
            Zone TEXT,
            Region TEXT,
            RenewalYearCount TEXT,
            Preferred TEXT,
            Activity TEXT,
            SubActivity TEXT,
            Amount TEXT,
            SMName TEXT,
            SMBranch TEXT,
            SMBranchName TEXT,
            CreatedBy TEXT,
            CreateDTime TEXT,
            UpdatedBy TEXT,
            UpdatedDtime TEXT,
            MothYear TEXT,
            ReferenceNo varchar,
            SyncStatus varchar
          );
''';

  static const dropDashboardData_Mob = '''
    DROP TABLE IF EXISTS DashboardData_Mob
  ''';

  static const dropTeamDashboardData_Mob = '''
    DROP TABLE IF EXISTS TeamDashboardData_Mob
  ''';

  static const createTbl_TeamDashboardData_Mob = '''
    CREATE TABLE IF NOT EXISTS TeamDashboardData_Mob(
            RecId integer primary key autoincrement,
            RMCode TEXT,
            UserId TEXT,
            ActivityCode TEXT,
            SubActivityCode TEXT,
            TotalLeads TEXT,
            WIPLeads TEXT,
            LeadConverted TEXT,
            LeadLost TEXT,
            Lead_Converted TEXT,
            Activity TEXT,
            SubActivity TEXT,
            Premium_Collected TEXT,
            Policy_Issued TEXT,
            Call_Back TEXT,
            Appointment_Fixed TEXT,
            Non_Contactable TEXT,
            Lost_To_Competition TEXT,
            Customer_Not_Interested TEXT,
            Customer_Not_Responding TEXT,
            ParkLead TEXT,
            FollowUp TEXT,
            Amount TEXT,
            MonthYear TEXT,
            LeadType TEXT,
            CreatedBy TEXT,
            CreateDTime TEXT,
            UpdatedBy TEXT,
            UpdatedDtime TEXT,
            ReferenceNo varchar,
            SyncStatus varchar);
''';

  static const createTbl_CalendarData_Mob = '''
    CREATE TABLE IF NOT EXISTS CalendarData_Mob(
            RecId integer primary key autoincrement,
            UserId TEXT,
            AgentCode TEXT,
            AgentName TEXT,
            HNINCode TEXT,
            HNINName TEXT,
            LOBCode TEXT,
            ProdCode TEXT,
            NCBFlag TEXT,
            date TEXT,
            DateInLong LONG,
            TotalLeads TEXT,
            WIPLeads TEXT,
            LeadConverted TEXT,
            LeadLost TEXT,
            LeadType TEXT,
            BizType TEXT,
            MarcketType TEXT,
            PolicyChanel TEXT,
            BMCMCode TEXT,
            ircCode TEXT,
            ircname TEXT,
            RNType TEXT,
            NetODPremium TEXT,
            NetTPPremium TEXT,
            RNblockReason TEXT,
            ProductGroup TEXT,
            ProductSubCategory TEXT,
            NILDep TEXT,
            Category TEXT,
            FuelType TEXT,
            VehicleType TEXT,
            SeatingCapacity TEXT,
            AgeGroup TEXT,
            FamilySize TEXT,
            SumInsuredBand TEXT,
            PreExiting TEXT,
            Occupancy TEXT,
            SumInsured TEXT,
            LifeGroup TEXT,
            Zone TEXT,
            Region TEXT,
            RenewalYearCount TEXT,
            Preferred TEXT,
            SMName TEXT,
            SMBranch TEXT,
            SMBranchName TEXT,
            CreatedBy TEXT,
            CreateDTime TEXT,
            UpdatedBy TEXT,
            UpdatedDtime TEXT,
            mdate varchar,
            ReferenceNo varchar,
            SyncStatus varchar);
''';

  static const dropCalendarData_Mob = '''
    DROP TABLE IF EXISTS CalendarData_Mob
  ''';

  static const LeadDetails = '''
CREATE TABLE IF NOT EXISTS LeadDetails(
    RecId integer primary key autoincrement,
    SrvcReqDtlCode varchar,
    SrvcGrpCode varchar,
    CltCode varchar,
    AgentCode varchar,
    UserId varchar,
    ReqChannelId varchar,
    ReqChannel varchar,
    LOBCode varchar,
    LOB varchar,
    ProdCode varchar,
    ProdName varchar,
    CRMStatus varchar,
    LMSStatusDesc varchar,
    WFStatus varchar,
    WFStatDesc varchar,
    LeadSource varchar,
    LeadSourceDesc varchar,
    LeadSubSource varchar,
    LeadSubSourceDesc varchar,
    BusinessType varchar,
    BusinessTypeDesc varchar,
    LeadQueue varchar,
    LeadQueueDesc varchar,
    leadAmt varchar,
    TypeFlag varchar,
    LeadTypeDesc varchar,
    LeadStatusCode varchar,
    ActivityStatus varchar,
    CustPriority varchar,
    CustPriorityDesc varchar,
    SaleType varchar,
    SaleTypeDesc varchar,
    CreatedBy varchar,
    CreateDTim varchar,
    UpdatedBy varchar,
    UpdateDTim varchar,
    Remark varchar,
    ProposalNo varchar,
    PolicyNo varchar,
    SumInsured varchar,
    PolicyStatus varchar,
    PolicyStartDate varchar,
    PolicyEndDate varchar,
    IssBranchCode varchar,
    IssBranchName varchar,
    InstallmentPrem varchar,
    PrevPolicyNo varchar,
    PrevPolicyInsCompName varchar,
    ProdClassCode varchar,
    ProdClassName varchar,
    ChassisNo varchar,
    EngineNo varchar,
    RegistrationNo varchar,
    Make varchar,
    Model varchar,
    PlanName varchar,
    AgentName varchar,
    HNINCode varchar,
    HNINName varchar,
    PolNCB varchar,
    Name varchar,
    MobileTel varchar,
    WorkTel varchar,
    Email varchar,
    AddrType varchar,
    Addr1 varchar,
    Addr2 varchar,
    Addr3 varchar,
    CityCode varchar,
    DistrictCode varchar,
    StateCode varchar,
    PinCode varchar,
    CountryCode varchar,
    Area varchar,
    isInserted varchar,
    IsUpdated varchar,
    TempSrvcReqDtlCode varchar,
    SyncStatus varchar,
    isWarmTransfer varchar,
    SrvcCommentType varchar,
    SrvcComments varchar,
    SrvcFromDTim varchar,
    Breaking varchar,
    LeadRating varchar,
    isOwner varchar,
    OwnerName varchar,
    AssignedTo varchar,
    AssignedToName varchar,
    CustTypeDesc varchar,
    LeadAging varchar,
    TelesaleActivity varchar,
    TelesaleActivityDoneBy varchar,
    TelesaleActivityDate varchar,
    TelesaleRemark varchar,
    LeadType TEXT,
    BizType TEXT,
    MarcketType TEXT,
    PolicyChanel TEXT,
    BMCMCode TEXT,
    ircCode TEXT,
    ircname TEXT,
    RNType TEXT,
    NetODPremium TEXT,
    NetTPPremium TEXT,
    RNblockReason TEXT,
    ProductGroup TEXT,
    ProductSubCategory TEXT,
    NILDep TEXT,
    Category TEXT,
    FuelType TEXT,
    VehicleType TEXT,
    SeatingCapacity TEXT,
    AgeGroup TEXT,
    FamilySize TEXT,
    SumInsuredBand TEXT,
    PreExiting TEXT,
    Occupancy TEXT,
    LifeGroup TEXT,
    Zone TEXT,
    Region TEXT,
    RenewalYearCount TEXT,
    Preferred TEXT,
    Activity TEXT,
    SubActivity TEXT,
    Amount TEXT,
    SMCode TEXT,
    SMName TEXT,
    SMBranch TEXT,
    SMBranchName TEXT,
    NCBFlag TEXT,
    MothYear TEXT,
    RenewalPaymentLink TEXT
);
 
''';

  static const dropLeadDetails = '''
  DROP TABLE IF EXISTS LeadDetails
''';

  static const dropLMSLeadActivityTracker = '''
  DROP TABLE IF EXISTS LMSLeadActivityTracker
''';

  static const lmsLeadActivityTracker = '''
CREATE TABLE IF NOT EXISTS LMSLeadActivityTracker(
    RecId integer primary key autoincrement,
    CltCode varchar,
    SrvcReqDtlCode varchar,
    ActivityCode varchar,
    SubActivityCode varchar,
    AppointmentDate varchar,
    Hour varchar,
    Minute varchar,
    AppointmentAddrss varchar,
    AppThrough varchar,
    ResThrough varchar,
    RescheduleDate varchar,
    RescheduleAddrss varchar,
    ParkedLead varchar,
    ProposalNo varchar,
    IssuedPolicyNo varchar,
    PremiumCollected varchar,
    AppReason varchar,
    SubReason varchar,
    DuplicateLeadId varchar,
    ComptitorID varchar,
    LocationDtls varchar,
    NonContble varchar,
    NotIntrest varchar,
    PhoneNumber varchar,
    CreateBy varchar,
    CreateDTim varchar,
    UpdateBy varchar,
    UpdateDTim varchar,
    IsActive varchar,
    oriPREMCOL varchar,
    MakenModel varchar,
    ExpiryDate varchar,
    CallBackDate varchar,
    TelesaleActivity varchar,
    TelesaleActivityDate varchar,
    InfectionID varchar,
    TicketNo varchar,
    QuoteNo varchar,
    LcReason varchar,
    LcSubReason varchar,
    Age varchar,
    RtoLoc varchar,
    Price varchar,
    YOM varchar,
    PED varchar,
    Feature varchar,
    Area varchar,
    PHC_NO varchar,
    ProductType varchar,
    Lan varchar,
    PostPQuery varchar,
    NotEligible varchar,
    Reason varchar,
    RsReason varchar,
    ModelValue varchar,
    NonContactableDtm varchar,
    CallBackDateRenewal varchar,
    NonConRes varchar,
    ChequeNo varchar,
    ChequeDate varchar,
    ChequeBankName varchar,
    RegistrationNo varchar,
    RenewalLeadLostReason varchar,
    PolicyAlreadyRenewedReason varchar,
    ParkedLeadDateTime varchar,
    FollowupDt varchar,
    QutationDt varchar,
    ddlAct16Subreason varchar,
    txt416 varchar,
    txtAD16 varchar,
    txtPN16 varchar,
    txt316 varchar,
    ddlMakeModel516 varchar,
    ddlModel616 varchar,
    txt716 varchar,
    txt816 varchar,
    ddlAppReasonTrack5 varchar,
    ddlSubReason varchar,
    txtDuplicateLeadId varchar,
    ddlCompetitorList varchar,
    txtLocationDtls varchar,
    txtTctNoact5 varchar,
    txtAge varchar,
    txtArea2 varchar,
    ddlRTOLoc varchar,
    txtPhcNo varchar,
    txtPrice varchar,
    txtPrdType varchar,
    txtYOM varchar,
    txtPed2 varchar,
    txtLanguage varchar,
    ddlMakeModelact5 varchar,
    txtReason5 varchar,
    txtCallBakDateTime19 varchar,
    txtPN19 varchar,
    txt319 varchar,
    txtRMSAppointmentDate varchar,
    txtRMSCallBackDate varchar,
    ddlRMSNonContactableReason varchar,
    txtRMSChequeNo varchar,
    ddlRMSRenewalLeadLostReason varchar,
    ddlRMSPolicyAlreadyRenewedReason varchar,
    txtRMSMobileNo varchar,
    txtAppointmentDate27 varchar,
    txtRescheduletDate28 varchar,
    ddlAppReasonTrack29 varchar,
    txtPolicyNo30 varchar,
    txtParkedLead31 varchar,
    txtFollowup32 varchar,
    txtQutation33 varchar,
    nInstrumentType varchar,
    nLcPolicyNumber varchar,
    nScPolicyNumber varchar,
    nScInstrumentNo varchar,
    nScInstrumentAmt varchar,
    nCallBackDate varchar,
    nExpectedClosureDate varchar,
    nLostCompDueTo varchar,
    nLlPolicyNoCompetition varchar,
    nCmpNameCompetition varchar,
    nNewPolEndDate varchar,
    internalcomment varchar,
    SyncStatus varchar,
    InstType varchar,
    LstComDueTo varchar,
    NewPolEndDate varchar,
    Remark varchar,
    TempSrvcReqDtlCode varchar
);
 
''';

  static const CreateTbl_CBFrmMSTLOB = '''
CREATE TABLE IF NOT EXISTS CBFrmMSTLOB(
            RecID INTEGER,
            LOBCode TEXT PRIMARY KEY,
            LOBCode1 varchar,
            LOBCode2 varchar,
            LOBDesc1 varchar,
            LOBDesc2 varchar,
            IsActive varchar,
            CreatedBy varchar,
            CreateDTim varchar,
            UpdatedBy varchar,
            UpdatedDTim varchar,
            shortcode varchar,
            CeasedDTim varchar
)''';

  //Drop tbl
  static const dropCreateTbl_CBFrmMSTLOB = '''
  DROP TABLE IF EXISTS CBFrmMSTLOB
''';

  //Create tbl

  static const CreateTbl_CBFrmMSTProduct = '''
  CREATE TABLE IF NOT EXISTS CBFrmMSTProduct(
            RecID INTEGER,
            ProdCode TEXT PRIMARY KEY,
            ProdCode1 varchar,
            ProdCode2 varchar,
            ProdDesc1 varchar,
            ProdDesc2 varchar,
            ClassCode varchar,
            ClassName varchar,
            IsActive varchar,
            CreatedBy varchar,
            CreateDTim varchar,
            UpdatedBy varchar,
            UpdateDTim varchar            
)''';

  //Drop tbl
  static const dropCreateTbl_CBFrmMSTProduct = '''
  DROP TABLE IF EXISTS CBFrmMSTProduct
''';

  static const CreateTbl_CBLMSMSTActivity = '''
CREATE TABLE IF NOT EXISTS CBLMSMSTActivity(
            Recid INTEGER,
            ActivityCode TEXT PRIMARY KEY,
            ActivityCode1 varchar,
            ActivityDesc1 varchar,
            ActivityDesc2 varchar,
            MPosStatusKey varchar,
            SortOrder varchar,
            IsAvailToLead varchar,
            IsAvailToProspect varchar,
            IsActive varchar,
            VID varchar,
            CreatedBy varchar,
            CreateDTim varchar,
            UpdatedBy varchar,
            UpdateDTim varchar)
''';

  static const dropCreateTbl_CBLMSMSTActivity = '''
  DROP TABLE IF EXISTS CBLMSMSTActivity
''';

  static const CreateTBL_CUSTOMER_CNT_DTLS = '''
CREATE TABLE IF NOT EXISTS TBL_CUSTOMER_CNT_DTLS(
 REC_ID integer primary key autoincrement,
        Cust_Name TEXT,
        POLICY_NO TEXT,
        IS_PRIMARY TEXT,
        LEAD_NO TEXT,
        MOBILE_NO TEXT,
        EMAIL_ID TEXT,
        IS_PRIMARY_EMAIL TEXT,
        STATUS TEXT,
        SRC TEXT,
        CREATEDBY TEXT,
        CREATEDDTIME TEXT,
        DateInLong LONG,
        UPDATEDBY TEXT,
        UPDATEDDTIME TEXT,
        UserId TEXT,
        SyncStatus TEXT
)

''';

  static const dropTBL_CUSTOMER_CNT_DTLS = '''
  DROP TABLE IF EXISTS TBL_CUSTOMER_CNT_DTLS
''';

  static const CreateTBL_AGENT_CNT_DTLS = '''
 CREATE TABLE IF NOT EXISTS TBL_AGENT_CNT_DTLS(
    REC_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    POLICY_NO TEXT,
    IMD_CODE TEXT,
    INTERMEDIARY_TYPE TEXT,
    IMD_NAME TEXT,
    MOBILE_NO TEXT,
    EMAIL_ID TEXT,
    IS_PRIMARY_MOBILE TEXT,
    IS_PRIMARY_EMAIL TEXT,
    STATUS TEXT,
    SRC TEXT,
    CREATEDBY TEXT,
    CREATEDDTIME TEXT,
    DateInLong INTEGER,
    UPDATEDBY TEXT,
    UPDATEDDTIME TEXT,
    UserId TEXT,
    SyncStatus TEXT
)
''';

  static const dropTBL_AGENT_CNT_DTLS = '''
    DROP TABLE IF EXISTS TBL_AGENT_CNT_DTLS
    ''';
  // Master Tables Setup

  static const createCBLMSChnlSourceMapping = '''
CREATE TABLE IF NOT EXISTS CBLMSChnlSourceMapping(
  ChnlSrvcMapCode TEXT,
  ReqChannelId TEXT,
  ReqChannelDesc TEXT,
  LeadSourceId TEXT,
  LeadSourceDesc TEXT,
  LeadSubSourceId TEXT,
  LeadSubSourceDesc TEXT,
  isActive TEXT,
  CreateBy TEXT,
  CreateDtim TEXT
);
''';

  static const dropcreateCBLMSChnlSourceMapping = '''
  DROP TABLE IF EXISTS CBLMSChnlSourceMapping
''';

  static const createCBFrmLOBProdMapping = '''
CREATE TABLE IF NOT EXISTS CBFrmLOBProdMapping(
  LOBProdMapCode TEXT,
  LOBCode TEXT,
  ProdCode TEXT,
  BrochureURL TEXT,
  WebQuoteURL TEXT,
  isRequiredPreInsp TEXT,
  CreatedBy TEXT,
  CreateDTim TEXT,
  IsRetail TEXT,
  RenewalRDLC TEXT,
  RDLCURL TEXT,
  RDLCServer TEXT,
  IsActive TEXT,
  ProdCategory TEXT
);
''';

  static const dropcreateCBFrmLOBProdMapping = '''
  DROP TABLE IF EXISTS CBFrmLOBProdMapping
''';

  static const createCBLMSLeadActivityMapping = '''
CREATE TABLE IF NOT EXISTS CBLMSLeadActivityMapping(
  ActMapCode TEXT,
  LeadType TEXT,
  Biztype TEXT,
  Actvitycode TEXT,
  IssActivity TEXT,
  CreatedBy TEXT,
  CreateDTim TEXT,
  LeadSourceId TEXT,
  ReqChannelId TEXT
);
''';

  static const dropcreateCBLMSLeadActivityMapping = '''
  DROP TABLE IF EXISTS CBLMSLeadActivityMapping
''';

  static const createReqChannelLeadSourceMap = '''
CREATE TABLE IF NOT EXISTS CBFRMLmsReqChannelLeadSourceMaping(
  ReqChannelId TEXT,
  LeadSourceId TEXT,
  MstrModuleCode TEXT,
  CreatedBy TEXT,
  CreatedDate TEXT
);
''';

  static const dropcreateReqChannelLeadSourceMap = '''
  DROP TABLE IF EXISTS CBFRMLmsReqChannelLeadSourceMaping
''';

  static const createReqChannelMap = '''
CREATE TABLE IF NOT EXISTS CBFRMLmsReqChannelMaping(
  ReqChannelId TEXT,
  MstrModuleCode TEXT,
  CreatedBy TEXT,
  CreatedDate TEXT
);
''';
  static const dropcreateReqChannelMap = '''
  DROP TABLE IF EXISTS CBFRMLmsReqChannelMaping
''';

  static const createNotificationDetails = '''
CREATE TABLE IF NOT EXISTS NotificationDetails(
    RecId INTEGER PRIMARY KEY AUTOINCREMENT,
    UserId TEXT,
    Notification TEXT,
    DateTime TEXT,
    Module TEXT,
    CreateBy TEXT,
    CreateDTim TEXT,
    Remark1 TEXT,
    Remark2 TEXT
);
''';

  static const dropNotificationDetails = '''
DROP TABLE IF EXISTS NotificationDetails
''';

  //Filter and calender activity tables
  static const createTbl_ZoneRegionBranch = '''
CREATE TABLE IF NOT EXISTS Tbl_ZoneRegionBranch(
    SrNo integer primary key autoincrement,
    RMCode varchar,
    Zone varchar,
    Region varchar,
    BranchCode varchar,
    BranchName varchar,
    UserId varchar,
    Month varchar,
    Year varchar,
    SyncDate varchar
);
''';

  static const dropTbl_ZoneRegionBranch = '''
DROP TABLE IF EXISTS Tbl_ZoneRegionBranch
''';

  static const createTbl_SalesManager = '''
CREATE TABLE IF NOT EXISTS Tbl_SalesManager(
    SrNo integer primary key autoincrement,
    RMCode varchar,
    BranchCode varchar,
    SMCode varchar,
    SMName varchar,
    UserId varchar,
    SyncDate varchar
);
''';

  static const dropTbl_SalesManager = '''
DROP TABLE IF EXISTS Tbl_SalesManager
''';

  static const createTbl_Agent = '''
CREATE TABLE IF NOT EXISTS Tbl_Agent(
    SrNo integer primary key autoincrement,
    SMCode varchar,
    AgentCode varchar,
    AgentName varchar,
    UserId varchar,
    SyncDate varchar
);
''';

  static const dropTbl_Agent = '''
DROP TABLE IF EXISTS Tbl_Agent
''';

  static const createTbl_Reference = '''
CREATE TABLE IF NOT EXISTS Tbl_Reference(
    SrNo integer primary key autoincrement,
    AgentCode varchar,
    ReferenceCode varchar,
    ReferenceName varchar,
    UserId varchar,
    SyncDate varchar
);
''';

  static const dropTbl_Reference = '''
DROP TABLE IF EXISTS Tbl_Reference
''';

  static const createTbl_LookUpSU = '''
CREATE TABLE IF NOT EXISTS LookUpSU(
    LookupCode varchar,
    ParamValue varchar,
    ParamDesc1 varchar,
    ParamDesc2 varchar,
    SortOrder varchar,
    ParamDescShort varchar,
    IsActive varchar,
    RecID integer,
    CreatedBy varchar,
    CreateDtim varchar,
    LookUpCode2 varchar,
    CeaseDate varchar,
    UpdateDTim varchar,
    UpdatedBy varchar,
    PRIMARY KEY (LookupCode, ParamValue)
);
''';

  static const dropTbl_LookUpSU = '''
DROP TABLE IF EXISTS LookUpSU
''';
  static const dropTbl_Make_Master = '''
DROP TABLE IF EXISTS Make_Master
''';

  static const String createTbl_Make_Master = '''
CREATE TABLE IF NOT EXISTS Make_Master(
  Make_ID_PK TEXT PRIMARY KEY NOT NULL,
  Make_Tac_Code TEXT NOT NULL,
  Make_Name TEXT NOT NULL,
  Make_Desc TEXT,
  Created_Date TEXT NOT NULL,
  Created_By TEXT NOT NULL,
  Updated_Date TEXT,
  Updated_By TEXT,
  Deleted_Date TEXT,
  Deleted_By TEXT,
  Field1 TEXT,
  Field2 TEXT,
  Make_ARC TEXT NOT NULL,
  CeaseDate TEXT
);
''';

  static const createDashboardIndexes = '''
CREATE INDEX IF NOT EXISTS idx_dashboard_user_month 
ON DashboardData_Mob(UserId, MothYear);

CREATE INDEX IF NOT EXISTS idx_dashboard_user_month_activity 
ON DashboardData_Mob(UserId, MothYear, Activity, SubActivity);

CREATE INDEX IF NOT EXISTS idx_dashboard_user_month_leadtype 
ON DashboardData_Mob(UserId, MothYear, LeadType);

CREATE INDEX IF NOT EXISTS idx_team_dashboard_rm_month 
ON TeamDashboardData_Mob(RMCode, MonthYear);

CREATE INDEX IF NOT EXISTS idx_lead_details_srvc 
ON LeadDetails(SrvcReqDtlCode);

CREATE INDEX IF NOT EXISTS idx_lead_details_user_month_activity 
ON LeadDetails(UserId, MothYear, Activity, SubActivity);

CREATE INDEX IF NOT EXISTS idx_tracker_srvc 
ON LMSLeadActivityTracker(SrvcReqDtlCode);
''';
}
