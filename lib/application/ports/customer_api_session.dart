abstract interface class CustomerApiSession {
  void configure({required String apiServer, required String accessToken});
  void clear();
}
