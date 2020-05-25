import 'dart:io';

extension FileExtension on File {
  String getFileExtension(){
    var path = this.path;
    var pathPartsSlittedByDot = path.split('.');

    return pathPartsSlittedByDot[pathPartsSlittedByDot.length -1];
  }
}