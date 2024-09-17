import 'package:excel/excel.dart';

class CellStyles {

  get cellStyleTitle => CellStyle(
    bold: true,
    fontSize: 18,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    textWrapping: TextWrapping.Clip,
    fontFamily: getFontFamily(FontFamily.Calibri),
    rotation: 0,
  );

  get cellStyleHeader => CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.Clip,
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontColorHex: ExcelColor.fromHexString('#748fcc'),
      rotation: 0,
    );

    get cellStyleBody => CellStyle(
      bold: false,
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Left,
      textWrapping: TextWrapping.Clip,
      fontFamily: getFontFamily(FontFamily.Calibri),
      rotation: 0,
    );

}