import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invest_note/collections/invest_name.dart';
import 'package:invest_note/enum/invest_kind.dart';
import 'package:invest_note/extensions/extensions.dart';
import 'package:invest_note/repository/invest_names_repository.dart';
import 'package:invest_note/screens/components/invest_name_input_alert.dart';
import 'package:invest_note/screens/components/parts/invest_dialog.dart';
import 'package:isar/isar.dart';

class InvestNameListAlert extends StatefulWidget {
  const InvestNameListAlert(
      {super.key, required this.isar, required this.investKind});

  final Isar isar;
  final InvestKind investKind;

  ///
  @override
  State<InvestNameListAlert> createState() => _InvestNameListAlertState();
}

class _InvestNameListAlertState extends State<InvestNameListAlert> {
  List<InvestName>? investNameList = [];

  ///
  @override
  Widget build(BuildContext context) {
    _makeStockNameList();

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: double.infinity,
        child: DefaultTextStyle(
          style: GoogleFonts.kiwiMaru(fontSize: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(width: context.screenSize.width),
              Text('${widget.investKind.japanName}名称一覧'),
              Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  TextButton(
                    onPressed: () => InvestDialog(
                      context: context,
                      widget: InvestNameInputAlert(
                          isar: widget.isar, investKind: widget.investKind),
                      clearBarrierColor: true,
                    ),
                    child: Text(
                      getInvestName(),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(child: _displayStockNames()),
            ],
          ),
        ),
      ),
    );
  }

  ///
  String getInvestName() {
    switch (widget.investKind) {
      case InvestKind.stock:
        return '株式名称を追加する';
      case InvestKind.shintaku:
        return '信託名称を追加する';
      case InvestKind.blank:
      case InvestKind.gold:
    }
    return '';
  }

  ///
  Future<void> _makeStockNameList() async => InvestNamesRepository()
      .getInvestNameListByInvestKind(
          isar: widget.isar, investKind: widget.investKind.name)
      .then((value) => setState(() => investNameList = value));

  ///
  Widget _displayStockNames() {
    final list = <Widget>[];

    investNameList?.forEach((element) {
      list.add(Container(
        width: context.screenSize.width,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2), width: 2))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 30,
              child: Text(element.dealNumber.toString()),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(element.frame), Text(element.name)],
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => InvestDialog(
                context: context,
                widget: InvestNameInputAlert(
                    isar: widget.isar,
                    investName: element,
                    investKind: widget.investKind),
                clearBarrierColor: true,
              ),
              child: Icon(Icons.edit,
                  size: 16, color: Colors.greenAccent.withOpacity(0.6)),
            ),
          ],
        ),
      ));
    });

    return SingleChildScrollView(child: Column(children: list));
  }
}
