// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  print('Running all tests...');

  // Run root tests.
  runCommand('flutter', ['test']);

  // Get all package directories.
  final packagesDir = Directory('packages');
  if (packagesDir.existsSync()) {
    final packages = packagesDir.listSync().whereType<Directory>();

    for (var directory in packages) {
      print('Running tests in ${directory.path}...');

      runCommand('flutter', ['test'], workingDirectory: directory.path);
    }
  }

  print('All tests completed!');
}

/// Executes a system command synchronously in an optional [workingDirectory]
/// and prints the command’s output and errors.
void runCommand(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) {
  final result = Process.runSync(
    executable,
    arguments,
    workingDirectory: workingDirectory,
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);
}
