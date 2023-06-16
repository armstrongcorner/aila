import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

export 'package:flutter_gen/gen_l10n/l10n.dart';

L10n useL10n({BuildContext? theContext}) {
  final BuildContext context = theContext ?? useContext();
  return L10n.of(context)!;
}
