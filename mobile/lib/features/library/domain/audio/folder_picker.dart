class PickedFolder {
  const PickedFolder({required this.ref, required this.name});

  final String ref;
  final String name;
}

abstract interface class FolderPicker {
  Future<PickedFolder?> pickFolder();
}
