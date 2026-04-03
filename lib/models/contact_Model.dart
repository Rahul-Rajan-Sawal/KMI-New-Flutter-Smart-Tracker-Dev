class ContactModel {

  String? custCode;
  String? type;
  String? contact;

  ContactModel({
    this.custCode,
    this.type,
    this.contact,

  });

  factory ContactModel.fromMap(Map<String,dynamic>map){
    return ContactModel(
      custCode: map['CustomerCode']?.toString(),
      type:map['Type']?.toString(),
      contact: map['MOBILE_NO']?.toString(),
    );
  }

  //clean contact 
  String? get cleanedContact{
    if(contact == null ) 
    return null;
    
    final trimmed = contact!.trim();
    
    if(trimmed.isEmpty || trimmed.toLowerCase()=="null")
    return null;

    return trimmed;
  }



  //Validations
   bool get isValidMobile{
    final value = cleanedContact;
    if(value == null)
    return false;

    final regex = RegExp(r'^[6-9]\d{9}$');

    return regex.hasMatch(value);


   }

}