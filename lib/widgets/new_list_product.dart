import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mr_app/models/ren_item.dart';
import 'package:mr_app/services/webservice.dart';
import 'package:mr_app/views/ver.dart';
import 'package:mr_app/utils/helper.dart';

import '../theme/fintech_theme.dart';

class NewsListState extends State<NewsList> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<RenItem> _newsArticles = <RenItem>[];

  @override
  void initState() {
    super.initState();
    _populateNewsArticles();
  }

  void _populateNewsArticles() {
    Future.delayed(Duration.zero, () async {
      LoadingIndicatorDialog().show(context);
    });
    Webservice().load(RenItem.all).then((newsArticles) {
      setState(() {
        _newsArticles = newsArticles;
        LoadingIndicatorDialog().dismiss();
      });
    }).catchError((error) {
      LoadingIndicatorDialog().dismiss();
    });
  }

  ListTile _buildItemsForListView(BuildContext context, int index) {
    DateTime tempDate = DateFormat("yyyy-MM-dd hh:mm:ss")
        .parse(_newsArticles[index].fechaRenovacion.toString());
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      leading: Container(
        padding: const EdgeInsets.only(right: 2.0),
        decoration: const BoxDecoration(
            border:
                Border(right: BorderSide(width: 1.0, color: Colors.white24))),
        child: IconButton(
          icon: const Icon(
            Icons.my_library_books_outlined,
            color: Colors.blue,
            size: 40.0,
          ),
          onPressed: () {},
        ),
      ),
      title: Text(_newsArticles[index].ramo!,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                  _newsArticles[index].placa!.isNotEmpty
                      ? "${_newsArticles[index].tipoSeguro}\n${_newsArticles[index].placa}"
                      : "${_newsArticles[index].tipoSeguro}",
                  style: const TextStyle(color: Colors.black, fontSize: 12.0)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat("yyyy-MM-dd").format(tempDate),
              style: const TextStyle(color: Colors.black45, fontSize: 12.0),
            ),
          ),
        ],
      ),
      isThreeLine: _newsArticles[index].placa!.isNotEmpty,
      trailing: const Icon(
        Icons.arrow_forward_ios_outlined,
        color: Colors.blueAccent,
        size: 30.0,
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Ver(
                      idRen: _newsArticles[index].idRen!,
                    )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: FinTechTheme.of(context).primaryBackground,
        /*appBar: AppBar(
          title: const Text(
            'Mis Productos',
            style: TextStyle(fontSize: 20.0),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color.fromRGBO(23, 0, 147, 1),
          elevation: 1,
        ),*/
        body: SafeArea(
            child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                    child: SingleChildScrollView(
                        primary: false,
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 10, 0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            //context.replaceNamed('HomeView');
                                            context.pop();
                                          },
                                          child: const Icon(
                                            Icons.arrow_back_sharp,
                                            color: Colors.black,
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(5, 0, 0, 0),
                                          child: Text(
                                            'Productos contratados',
                                            style: FinTechTheme.of(context)
                                                .bodyText1
                                                .override(
                                                  fontFamily: 'Inter',
                                                  fontSize: 16,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 40, 0, 0),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                            color: Colors.white,
                                            height: 1,
                                          ),
                                      itemCount: _newsArticles.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0.0, horizontal: 5.0),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  color: Color.fromRGBO(
                                                      23, 0, 147, 1)),
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            child: _buildItemsForListView(
                                                context, index),
                                          ),
                                        );
                                      }))
                            ]))))));
  }
}

class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  createState() => NewsListState();
}
