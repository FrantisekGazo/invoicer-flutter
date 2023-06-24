import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart';
import 'package:invoicer/src/data/model/client.dart';
import 'package:invoicer/src/data/model/language.dart';

void main() {
  group('Client', () {
    group('compare', () {
      test('when all have order', () async {
        const c1 = Client(
          id: '1',
          order: 2,
          name: 'foo',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        const c2 = Client(
          id: '2',
          order: 0,
          name: 'foo',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        const c3 = Client(
          id: '3',
          order: 10,
          name: 'foo',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        const c4 = Client(
          id: '4',
          order: -2,
          name: 'foo',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        final clients = [c1, c2, c3, c4];

        final res = clients.sorted();

        expect(res, [c4, c2, c1, c3]);
      });

      test('when none have order', () async {
        const c1 = Client(
          id: '1',
          name: 'Aaa',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        const c2 = Client(
          id: '2',
          name: 'Cccc',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        const c3 = Client(
          id: '3',
          name: 'Baaa',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        const c4 = Client(
          id: '4',
          name: 'Bbbb',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        final clients = [c1, c2, c3, c4];

        final res = clients.sorted();

        expect(res, [c1, c3, c4, c2]);
      });

      test('when some have order', () async {
        const c1 = Client(
          id: '1',
          order: 10,
          name: 'Aaa',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        const c2 = Client(
          id: '2',
          name: 'Cccc',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        const c3 = Client(
          id: '3',
          order: -1,
          name: 'Baaa',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        const c4 = Client(
          id: '4',
          name: 'Bbbb',
          address: [],
          projects: [],
          lang: Language.sk,
        );
        final clients = [c1, c2, c3, c4];

        final res = clients.sorted();

        expect(res, [c3, c1, c4, c2]);
      });
    });
  });
}
