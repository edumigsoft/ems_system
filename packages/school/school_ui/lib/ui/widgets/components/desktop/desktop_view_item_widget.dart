import 'package:design_system_shared/design_system_shared.dart';
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart';
import 'package:school_shared/school_shared.dart' show SchoolDetails;

class DesktopViewItemWidget extends StatelessWidget {
  final SchoolDetails data;

  const DesktopViewItemWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.35;

    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 8.0),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              _status(context, width),
              _name(context, width),
              _email(context, width),
              _address(context, width),
              _phone(context, width),
              _cie(context, width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _status(BuildContext context, double? width) {
    return DSCard(
      child: Container(
        width: width,
        padding: const EdgeInsets.all(DSPaddings.extraSmall),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).status,
                    textScaler: const TextScaler.linear(1.8),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    data.isDeleted ? Icons.cancel : Icons.check,
                    color: data.isDeleted ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              data.isDeleted
                  ? AppLocalizations.of(context).inactive
                  : AppLocalizations.of(context).active,
              textScaler: const TextScaler.linear(1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _name(BuildContext context, double? width) {
    return _card(
      context,
      data.name,
      AppLocalizations.of(context).name,
      width,
    );
  }

  Widget _email(BuildContext context, double? width) {
    return _card(
      context,
      data.email,
      AppLocalizations.of(context).email,
      width,
    );
  }

  Widget _address(BuildContext context, double? width) {
    return _card(
      context,
      data.address,
      AppLocalizations.of(context).address,
      width,
    );
  }

  Widget _phone(BuildContext context, double? width) {
    return _card(
      context,
      data.phone,
      AppLocalizations.of(context).phone,
      width,
    );
  }

  Widget _cie(BuildContext context, double? width) {
    return _card(
      context,
      data.cie,
      /*AppLocalizations.of(context)!.cie*/ 'CIE',
      width,
    );
  }

  Widget _card(BuildContext context, String data, String title, double? width) {
    return DSCard(
      child: Container(
        width: width,
        padding: const EdgeInsets.all(DSPaddings.extraSmall),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data,
              textScaler: const TextScaler.linear(1.8),
            ),
            const Divider(),
            Text(
              title,
              textScaler: const TextScaler.linear(1.2),
            ),
          ],
        ),
      ),
    );
  }
}
