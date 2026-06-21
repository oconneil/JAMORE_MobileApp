abstract interface class CustomerApiSession {
  void configure({
    required String apiServer,
    required String accessToken,
    required String companyId,
  });

  void clear();
}
