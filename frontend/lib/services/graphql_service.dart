import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static final GraphQLService _instance = GraphQLService._internal();
  static GraphQLService get instance => _instance;
  GraphQLService._internal();

  late GraphQLClient _client;
  
  // Update this URL to match your backend server
  static const String _graphqlEndpoint = 'http://localhost:4000/graphql';

  void initialize({String? customEndpoint}) {
    final httpLink = HttpLink(
      customEndpoint ?? _graphqlEndpoint,
      defaultHeaders: {
        'Content-Type': 'application/json',
      },
    );

    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: HiveStore()),
    );
  }

  GraphQLClient get client => _client;

  Future<QueryResult> query(String query, {Map<String, dynamic>? variables}) async {
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
      errorPolicy: ErrorPolicy.all,
    );

    return await _client.query(options);
  }

  Future<QueryResult> mutate(String mutation, {Map<String, dynamic>? variables}) async {
    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
      errorPolicy: ErrorPolicy.all,
    );

    return await _client.mutate(options);
  }

  void updateAuthToken(String token) {
    final authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );

    final httpLink = HttpLink(_graphqlEndpoint);

    _client = GraphQLClient(
      link: authLink.concat(httpLink),
      cache: GraphQLCache(store: HiveStore()),
    );
  }

  void clearAuthToken() {
    initialize(); // Reinitialize without auth token
  }
}