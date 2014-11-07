import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_style/src/file_util.dart';

void main(List<String> args) {
  var parser = new ArgParser();
  parser.addFlag("help", abbr: "h", negatable: false,
      help: "Shows usage information.");
  parser.addOption("line-length", abbr: "l",
      help: "Wrap lines longer than this.",
      defaultsTo: "80");
  parser.addFlag("overwrite", abbr: "w", negatable: false,
      help: "Overwrite input files with formatted output.\n"
            "If unset, prints results to standard output.");

  var options = parser.parse(args);

  if (options["help"]) {
    printUsage(parser);
    return;
  }

  var overwrite = options["overwrite"];

  int lineLength;

  try {
    lineLength = int.parse(options["line-length"]);
  } on FormatException catch (_) {
    printUsage(parser, '--line-length must be an integer, was '
                       '"${options['line-length']}".');
    exitCode = 64;
    return;
  }

  if (options.rest.isEmpty) {
    printUsage(parser,
        "Please provide at least one directory or file to format.");
    exitCode = 64;
    return;
  }

  for (var path in options.rest) {
    var directory = new Directory(path);
    if (directory.existsSync()) {
      processDirectory(directory, overwrite: overwrite, lineLength: lineLength);
      continue;
    }

    var file = new File(path);
    if (file.existsSync()) {
      processFile(file, overwrite: overwrite, lineLength: lineLength);
    } else {
      stderr.writeln('No file or directory found at "$path".');
    }
  }
}

void printUsage(ArgParser parser, [String error]) {
  var output = stdout;

  var message = "Reformats whitespace in Dart source files.";
  if (error != null) {
    message = error;
    output = stdout;
  }

  output.write("""$message

Usage: dartfmt [-l <line length>] <files or directories...>

${parser.usage}
""");
}
