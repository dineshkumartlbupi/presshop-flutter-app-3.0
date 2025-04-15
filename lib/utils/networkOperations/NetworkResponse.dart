
class NetworkResponse {

  void onResponse({required int requestCode,required String response}){}
  void onError({required int requestCode,required String response}){

  }

}


class NavigationUpdate{
  void update(){}
}

class WishListUpdate{
  void update(){}
  void cartUpdate(){}
}
