// ignore_for_file: use_named_constants, lines_longer_than_80_chars

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:invest_note/collections/invest_name.dart';
import 'package:invest_note/collections/invest_record.dart';
import 'package:invest_note/extensions/extensions.dart';

class InvestRecordListAlert extends ConsumerStatefulWidget {
  const InvestRecordListAlert(
      {super.key, required this.investName, required this.allInvestRecord});

  final InvestName investName;
  final List<InvestRecord> allInvestRecord;

  ///
  @override
  ConsumerState<InvestRecordListAlert> createState() =>
      _InvestRecordListAlertState();
}

class _InvestRecordListAlertState extends ConsumerState<InvestRecordListAlert> {
  LineChartData graphData = LineChartData();

  ///
  @override
  Widget build(BuildContext context) {
    setChartData();

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: SizedBox(
          height: context.screenSize.height,
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(width: context.screenSize.width),
                Text(widget.investName.name),
                Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
                const SizedBox(height: 10),
                SizedBox(height: 150, child: LineChart(graphData)),
                const SizedBox(height: 20),
                Expanded(child: _displayInvestRecordList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _displayInvestRecordList() {
    final list = <Widget>[];

    var lastCost = 0;
    widget.allInvestRecord
        .where((element) => element.investId == widget.investName.id)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date))
      ..forEach((element) {
        final costColor =
            (lastCost != element.cost) ? Colors.yellowAccent : Colors.white;

        list.add(Container(
          padding:
              const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 2, child: Text(element.date)),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Text(
                        element.cost.toString().toCurrency(),
                        style: TextStyle(color: costColor),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                          alignment: Alignment.topRight,
                          child: Text(element.price.toString().toCurrency()))),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Expanded(
                      child: Container(
                          alignment: Alignment.topRight,
                          child: Text((element.price - element.cost)
                              .toString()
                              .toCurrency()))),
                ],
              ),
            ],
          ),
        ));

        lastCost = element.cost;
      });

    list.add(const SizedBox(height: 200));

    return SingleChildScrollView(child: Column(children: list));
  }

  ///
  void setChartData() {
    final flspots = <FlSpot>[];

    final points = <int>[];

    var startPrice = 0.0;
    var endPrice = 0.0;

    var startSpot = const FlSpot(0, 0);
    var endSpot = const FlSpot(0, 0);
    var flspotsTrend = <FlSpot>[];

    for (var i = 0; i < widget.allInvestRecord.length; i++) {
      if (widget.allInvestRecord[i].investId == widget.investName.id) {
        if (startPrice == 0) {
          startPrice =
              (widget.allInvestRecord[i].price - widget.allInvestRecord[i].cost)
                  .toDouble();

          startSpot = FlSpot(
              i.toDouble(),
              (widget.allInvestRecord[i].price - widget.allInvestRecord[i].cost)
                  .toDouble());
        }

        flspots.add(
          FlSpot(
              i.toDouble(),
              (widget.allInvestRecord[i].price - widget.allInvestRecord[i].cost)
                  .toDouble()),
        );

        points.add(
            widget.allInvestRecord[i].price - widget.allInvestRecord[i].cost);

        endPrice =
            (widget.allInvestRecord[i].price - widget.allInvestRecord[i].cost)
                .toDouble();

        endSpot = FlSpot(
            i.toDouble(),
            (widget.allInvestRecord[i].price - widget.allInvestRecord[i].cost)
                .toDouble());
      }
    }

    flspotsTrend = [startSpot, endSpot];

    final maxPoint = (points.isNotEmpty) ? points.reduce(max) : 0;

    final minPoint = (points.isNotEmpty) ? points.reduce(min) : 0;

    var devide = 0;
    switch (maxPoint.toString().length) {
      case 3:
        devide = 100;
        break;
      case 4:
        devide = 1000;
        break;
      case 5:
        devide = 10000;
        break;
      case 6:
        devide = 100000;
        break;
      case 7:
        devide = 1000000;
        break;
    }

    if (devide != 0) {
      final graphYMax = (maxPoint / devide).round() * devide;
      final graphYMin = (minPoint < 0) ? minPoint : 0;

      graphData = LineChartData(
        maxY: graphYMax.toDouble(),
        minY: graphYMin.toDouble(),

        ///
        lineTouchData: const LineTouchData(enabled: false),

        ///
        titlesData: FlTitlesData(
          //-------------------------// 上部の目盛り
          topTitles: const AxisTitles(),
          //-------------------------// 上部の目盛り

          //-------------------------// 下部の目盛り
          bottomTitles: AxisTitles(
            axisNameWidget: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(startPrice.toString().split('.')[0].toCurrency()),
                  RichText(
                    text: TextSpan(
                      text: endPrice.toString().split('.')[0].toCurrency(),
                      style: const TextStyle(
                          fontSize: 10, color: Colors.orangeAccent),
                      children: <TextSpan>[
                        const TextSpan(
                            text: ' / ', style: TextStyle(color: Colors.white)),
                        TextSpan(
                          text:
                              '${(endPrice - startPrice) > 0 ? '+' : '-'} ${(endPrice - startPrice).toString().split('.')[0].toCurrency()}',
                          style: TextStyle(
                              color: ((endPrice - startPrice) > 0)
                                  ? const Color(0xFFFBB6CE)
                                  : Colors.yellowAccent),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          //-------------------------// 下部の目盛り

          //-------------------------// 左側の目盛り
          leftTitles: const AxisTitles(),
          //-------------------------// 左側の目盛り

          //-------------------------// 右側の目盛り
          rightTitles: const AxisTitles(),
          //-------------------------// 右側の目盛り
        ),

        ///
        lineBarsData: [
          LineChartBarData(
            spots: flspots,
            barWidth: 1,
            isStrokeCapRound: true,
            color: Colors.yellowAccent,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: flspotsTrend,
            barWidth: 1,
            isStrokeCapRound: true,
            color: Colors.redAccent,
            dotData: const FlDotData(show: false),
          ),
        ],
      );
    }
  }
}
