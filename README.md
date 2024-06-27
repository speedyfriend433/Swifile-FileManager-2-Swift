# Swift File Manager - Swifile 2

A comprehensive file management application built using SwiftUI. This application provides a user-friendly interface for navigating directories, managing files, and viewing file details with additional support for specific file types like text, images, plists, binaries, and application packages (`.ipa` and `.deb`).

Revived From Original Swifile

## Features

### Directory Navigation
- **Browse Directories**: Navigate through directories and view their contents.
- **Folder and File Icons**: Differentiate between folders and files with appropriate icons.
- **File Size Display**: Show file sizes in a human-readable format.

### File Operations
- **Add New Items**: Create new folders and files.
- **Rename and Copy**: Rename files and folders, or create copies.
- **Delete Items**: Delete selected files and folders with confirmation alerts.

### Multi-Select and Bulk Operations
- **Edit Mode**: Enter edit mode to select multiple files and folders.
- **Bulk Delete**: Delete multiple selected items at once.

### Search Functionality
- **Search Bar**: Toggle a search bar to find files and folders.
- **Search Scopes**: Search within the current directory or the entire root directory.

### Sorting Options
- **Sort Menu**: Sort items by name, date, or size using a menu with multiple options.

### File Viewing and Editing
- **Text Files**: View and edit `.txt` files.
- **Image Files**: View image files (`.png`, `.jpg`, `.jpeg`).
- **Plist Files**: View and edit plist files (`.plist`, `.entitlements`).
- **Hex Editor**: View and edit binary files (`.bin`, `.dylib`, `.geode`) in a hex editor.
- **Application Packages**: View details of `.ipa` and `.deb` files, including name, description, size, and a share option.

### File Detail View
- **Dynamic File Information**: Displays file name, description based on the file extension, and file size.
- **Share Functionality**: Share files using the iOS share sheet.

## Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/speedyfriend433/Swifile-FileManager-2-Swift.git
    ```
2. Open the project in Xcode:
    ```sh
    open Swifile-FileManager-2-Swift.xcodeproj
    ```
3. Build and run the project on your simulator or device. (actually you can just build this on FridaCodeManager)

## Usage

### Navigating Directories
- Launch the app and navigate through the directory structure by tapping on folders.
- Use the back button to return to the previous directory.

### Managing Files
- **Add New Items**: Tap the "+" button to add new folders or files.
- **Rename or Copy**: Long press on a file or folder to open the context menu, then select "Rename" or "Copy".
- **Delete**: Long press on a file or folder to open the context menu, then select "Delete". Confirm deletion in the alert.

### Multi-Select and Bulk Operations
- Tap "Edit" to enter edit mode. Select multiple items and perform bulk delete operations.

### Search and Sort
- Toggle the search bar using the magnifying glass button.
- Use the sort menu to sort items by name, date, or size.

### Viewing and Editing Files
- **Text Files**: Tap on a `.txt` file to view and edit its content.
- **Image Files**: Tap on an image file to view it.
- **Plist Files**: Tap on a `.plist` or `.entitlements` file to view and edit its content.
- **Hex Editor**: Tap on a `.bin`, `.dylib`, or `.geode` file to open it in the hex editor.
- **Application Packages**: Tap on an `.ipa` or `.deb` file to view its details.

## Future Improvements

### Additional Features
- **Zip/Unzip Functionality**: Add support for compressing and decompressing files and directories.
- **File Permissions**: Implement file permission management.
- **Metadata Viewing**: Display more detailed metadata for files, such as creation and modification dates.

### User Interface Enhancements
- **Dark Mode**: Improve support and styling for dark mode.
- **Custom Icons**: Add more distinctive icons for different file types.

### Performance Optimizations
- **Asynchronous Loading**: Improve the responsiveness of the UI by optimizing file loading operations.
- **Caching**: Implement caching for frequently accessed directories to speed up navigation.

## Contribution

Contributions are welcome! If you have any ideas or improvements, please feel free to submit a pull request or open an issue.

## Thanks to..
Thanks to AppinstalleriOS for the Shell Script!
Thanks to FridaCodeManager Team for the on-device compiler!
Thanks to le bao nguyen for the idea of sort options and action confirmations!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or suggestions, please contact [speedyfriend433@gmail.com].
