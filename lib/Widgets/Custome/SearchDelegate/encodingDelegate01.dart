import 'package:flutter/material.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../../Services/NominatimServices/NominatimServices01.dart';

class EncodingDelegate01 extends SearchDelegate<NominatimResponse?> {
  final _querySubject = BehaviorSubject<String>();
  String _lastQuery = '';

  Stream<List<NominatimResponse>> _resultsStream(BuildContext context) {
    final service = context.read<NominatimServices01>();

    return _querySubject.stream
        .debounceTime(const Duration(milliseconds: 500))
        .distinct()
        .switchMap((query) {
          if (query.isEmpty) return Stream.value([]);
          return Stream.fromFuture(service.searchByString(query));
        });
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_outlined),
        onPressed: () {
          query = '';
          _lastQuery = '';
          _querySubject.add('');
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_lastQuery != query) {
      _lastQuery = query;
      _querySubject.add(query);
    }

    return StreamBuilder<List<NominatimResponse>>(
      stream: _resultsStream(context),
      builder: (context, snapshot) {
        if (query.isEmpty) {
          return const Center(child: Text('Start typing to search'));
        }

        if (!snapshot.hasData && query.length > 2) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return ListView.separated(
          separatorBuilder: (_, __) => const Divider(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final place = data[index];

            return ListTile(
              title: Text(place.name ?? ''),
              subtitle: Text(
                place.displayName ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => close(context, place),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  void close(BuildContext context, NominatimResponse? result) {
    _querySubject.close();
    super.close(context, result);
  }
}
