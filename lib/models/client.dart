class ClientData{
  int? id;
  String? name;
  String? phone;
  String? email;
  String? address;

  ClientData.fromJson(Map<String, dynamic> data ) {
    id = data["id"];
    name = data["name"];
    phone = data["phone"];
    email = data["email"];
    address = data["address"];
  }

  Map<String, dynamic> toJson(){
    return {
      "id":id,
      "name":name,
      "phone":phone,
      "email":email,
      "address": address,
    };
  }
}