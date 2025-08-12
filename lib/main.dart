import 'package:alice/alice.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter/character_bloc.dart';
import 'package:rick_and_morty_flutter/model/character_model.dart';
import 'package:rick_and_morty_flutter/repo/rick_and_morty_repo.dart';
import 'package:rick_and_morty_flutter/repo/rick_and_morty_repo_impl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talker_flutter/talker_flutter.dart';

late Talker talker;
void main() {
  talker = TalkerFlutter.init();
  ChuckerFlutter.showOnRelease = true;
  runApp(const MyApp());
}
final Alice alice = Alice(showNotification: true, navigatorKey: navigatorKey);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<RickAndMortyRepo>(
          create: (context) => RickAndMortyRepoImpl(),
        )
      ],
      child: BlocProvider(
        create: (context) =>
            CharacterBloc(rickAndMortyRepo: context.read<RickAndMortyRepo>(),alice:alice)..add(CharacterBlocRefreshEvent()),
        child: MaterialApp(
          title: 'Rick and Morty Flutter',
          navigatorKey: navigatorKey,
          navigatorObservers: [
            ChuckerFlutter.navigatorObserver,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Rick and Morty Characters'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int shimmerCount = 2;
  final int colCount = 2;
  
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(icon:Icon(Icons.history), onPressed: () { 
            Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TalkerScreen(talker: talker),
  )
);
           },),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<CharacterBloc>().add(CharacterBlocRefreshEvent()),
        child: BlocBuilder<CharacterBloc, CharacterBlocState>(
          builder: (context, state) {
            if (state is CharacterBlocLoadingFirstPageState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CharacterBlocSuccessPageState ||
                state is CharacterBlocLoadingNextPageState) {
              final List<Result?> characters = getCharacters(state);

              return NotificationListener(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    final metrics = notification.metrics;

                    if (metrics.pixels >= metrics.maxScrollExtent-500) {
                      // At bottom — load next page
                      context.read<CharacterBloc>().add(CharacterBlocFetchNextPageEvent());
                      return true; // handled
                    }

                    if (metrics.pixels <= metrics.minScrollExtent) {
                      // At top — allow parent (like RefreshIndicator) to handle
                      return false;
                    }
                  }

                  return false; // default: don't block scroll bubbling
                },
                child: GridView.builder(
                  key: const PageStorageKey('characterGrid'),
                  controller: scrollController,
                  padding: const EdgeInsets.all(8),
                  physics: AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: colCount,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: getItemCount(state),
                  itemBuilder: (context, index) {
                    if (index >= characters.length) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Shimmer.fromColors(
                                  baseColor:
                                      Colors.lightGreenAccent.withAlpha(128),
                                  highlightColor: Colors.white,
                                  child: Container(
                                    color: Colors.black,
                                    height: double.maxFinite,
                                    width: double.maxFinite,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Shimmer.fromColors(
                                baseColor: Colors.lightGreenAccent,
                                highlightColor: Colors.white,
                                child: Column(
                                  children: [
                                    Container(
                                      color: Colors.black,
                                      height: 24,
                                      width:
                                          (MediaQuery.of(context).size.width /
                                                  3.5) -
                                              24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final character = characters[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: CachedNetworkImage(
                                imageUrl:character?.image ?? '',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              character?.name ?? '',
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            return SizedBox();
          },
        ),
      ),
    );
  }

  List<Result?> getCharacters(CharacterBlocState state) {
    if (state is CharacterBlocSuccessPageState) {
      return state.results;
    }

    if (state is CharacterBlocLoadingNextPageState) {
      return state.results;
    }
    return [];
  }

  int getItemCount(CharacterBlocState state) {
    if (state is CharacterBlocSuccessPageState) {
      int currentLength = state.results.length;
      int itemCount = state.info?.count ?? 0;
      if (currentLength < itemCount) {
        return currentLength + (shimmerCount * colCount);
      } else {
        return currentLength;
      }
    } else if (state is CharacterBlocLoadingNextPageState) {
      return state.results.length + (shimmerCount * colCount);
    }
    return 0;
  }
}
