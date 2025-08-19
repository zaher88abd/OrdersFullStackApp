import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static GraphQLService? _instance;
  late GraphQLClient _client;

  GraphQLService._internal();

  static GraphQLService get instance {
    _instance ??= GraphQLService._internal();
    return _instance!;
  }

  void initialize() {
    final HttpLink httpLink = HttpLink(
      'http://localhost:4000', // GraphQL backend endpoint
    );

    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: HiveStore()),
    );
  }

  GraphQLClient get client => _client;

  // Helper method for queries
  Future<QueryResult> query(String query, {Map<String, dynamic>? variables}) async {
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
    );
    return await _client.query(options);
  }

  // Helper method for mutations
  Future<QueryResult> mutate(String mutation, {Map<String, dynamic>? variables}) async {
    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
    );
    return await _client.mutate(options);
  }

  // Helper method for subscriptions
  Stream<QueryResult> subscribe(String subscription, {Map<String, dynamic>? variables}) {
    final SubscriptionOptions options = SubscriptionOptions(
      document: gql(subscription),
      variables: variables ?? {},
    );
    return _client.subscribe(options);
  }
}