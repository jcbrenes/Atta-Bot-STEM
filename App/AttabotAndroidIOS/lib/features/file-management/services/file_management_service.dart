import 'dart:convert';
import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proyecto_tec/config/app_config.dart';

enum FileManagementErrors {
  invalidFileName,
  fileNotFound,
  fileNotSaved,
  saveDataEmpty,
  fileAlreadyExists,
  noFilesFound,
}

class FileManagementService {
  final Map<String, bool> _fileOverWriteStatus = {};

  final String savePath = AppConfig.historySavePath;

  Future<void> saveNewFile(
      String fileName, List<String> saveData) async {
    if (!_validateFileName(fileName)) {
      throw FileManagementErrors.invalidFileName;
    }
    if (saveData.isEmpty) throw FileManagementErrors.saveDataEmpty;

    // Get the directory to save the file
    final Directory workingDirectory = await getApplicationDocumentsDirectory();
    final Directory saveDirectory =
        Directory('${workingDirectory.path}$savePath');
    if (!await saveDirectory.exists()) {
      await saveDirectory.create(recursive: true);
    }

    final File newFile = File('${saveDirectory.path}/$fileName.dat');

    // Check if file already exists
    if (await newFile.exists()) {
      _fileOverWriteStatus[fileName] = true;
      throw FileManagementErrors.fileAlreadyExists;
    }

    // Save the data
    await newFile.writeAsString(jsonEncode(saveData));

  }

  /// Overwrites the file with the given data
  /// Must be called after [saveNewFile] to overwrite the file
  /// if called without saving a new file first, it will return [FileManagementErrors.fileNotFound]
  Future<void> overwriteFile(
      String fileName, List<String> saveData) async {
    if (!_fileOverWriteStatus[fileName]!) {
      throw FileManagementErrors.fileNotFound;
    }

    final Directory workingDirectory = await getApplicationDocumentsDirectory();
    final Directory saveDirectory =
        Directory('${workingDirectory.path}$savePath');

    final File newFile = File('${saveDirectory.path}/$fileName.dat');
    await newFile.writeAsString(jsonEncode(saveData));

  }

  /// Retrieves a list of strings of all the current saved files
  /// throws [FileManagementErrors.noFilesFound] if no files are found
  /// returns a list of file names if files are found
  Future<List<String>> getSavedFilesList() async {
    final Directory workingDirectory = await getApplicationDocumentsDirectory();
    final Directory loadDir = Directory('${workingDirectory.path}$savePath');

    if (!await loadDir.exists()) throw FileManagementErrors.noFilesFound;

    final List<FileSystemEntity> fileList =
        loadDir.listSync()
        .where((file) => file.path.endsWith('.dat'))
        .toList();

    if (fileList.isEmpty) throw FileManagementErrors.noFilesFound;

    final List<String> fileNames = fileList
        .map((file) => file.path.split('/').last)
        .toList();
      
    return fileNames;
  }

  Future<List<String>> loadFile(String fileName) async {
    final Directory workingDirectory = await getApplicationDocumentsDirectory();
    final Directory loadDir = Directory('${workingDirectory.path}$savePath');

    final File file = File('${loadDir.path}/$fileName');

    if (!await file.exists()) throw FileManagementErrors.fileNotFound;

    final String fileData = await file.readAsString();
    return jsonDecode(fileData).cast<String>();
  }

  bool _validateFileName(String name) {
    RegExp validCharacters = RegExp(r'^[a-z0-9_]+$');

    if (name.length > 20) return false;
    if (!validCharacters.hasMatch(name)) return false;

    return true;
  }

Future<void> exportFile(String fileName, String exportPath) async {
    final Directory workingDirectory = await getApplicationDocumentsDirectory();
    final Directory loadDir = Directory('${workingDirectory.path}$savePath');

    final File file = File('${loadDir.path}/$fileName');

    if (!await file.exists()) throw FileManagementErrors.fileNotFound;

    final String fileData = await file.readAsString();

    final File exportFile = File('$exportPath/$fileName');
    await exportFile.writeAsString(fileData);
  }

Future<void> saveFileToFolder(String fileName) async {
    final Directory workingDirectory = await getApplicationDocumentsDirectory();
    final Directory loadDir = Directory('${workingDirectory.path}$savePath');

    final File file = File('${loadDir.path}/$fileName');

    if (!await file.exists()) throw FileManagementErrors.fileNotFound;


    final fileBytes = await file.readAsBytes();

    String cleanName = fileName;
    if (fileName.toLowerCase().endsWith('.dat')) {
      cleanName = fileName.substring(0, fileName.length - 4);
    }

    // Use FileSaver to save the file to the folder selected by the user
    await FileSaver.instance.saveAs(
      name: cleanName,
      bytes: fileBytes,
      fileExtension: "json", 
      mimeType: MimeType.json, 
    );
  }
    
}
