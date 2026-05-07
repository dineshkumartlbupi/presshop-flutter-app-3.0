
import sys

file_path = r'd:\presshop-flutter-app-3.0\lib\features\camera\presentation\pages\preview_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

start_index = -1
end_index = -1

for i, line in enumerate(lines):
    if 'int originalIndex =' in line and 'widget.cameraListData.length' in line:
        start_index = i - 2
    if 'UpdateCapturedMediaEvent(' in line and 'widget.cameraListData)));' in line:
        end_index = i + 2
        break

if start_index != -1 and end_index != -1:
    indent = '                                   '
    new_content = [
        indent + 'if (originalIndex >= 0 && originalIndex < widget.cameraListData.length) {\n',
        indent + '  final updatedList = List<CameraData>.from(widget.cameraListData);\n',
        indent + '  updatedList.removeAt(originalIndex);\n',
        indent + '  widget.cameraListData.clear();\n',
        indent + '  widget.cameraListData.addAll(updatedList);\n',
        indent + '  context.read<CameraBloc>().add(UpdateCapturedMediaEvent(updatedList));\n',
        indent + '}\n'
    ]
    lines[start_index+2:end_index] = new_content
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print("Replacement successful")
else:
    print(f"Indices not found: {start_index}, {end_index}")
