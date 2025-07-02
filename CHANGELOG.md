# Changelog

## [0.2.0] - 2025-07-02

### Added
- PDF text extraction support using Apache PDFBox 3.0.5
- Automatic file type detection (HWP vs PDF)
- Support for PDFBOX_JAR_PATH environment variable

### Changed
- Main `extract_text` method now supports both HWP and PDF files
- Updated README with PDF examples and documentation

## [0.1.1] - 2025-07-02

### Fixed
- Minor bug fixes and improvements

## [0.1.0] - 2025-07-02

### Added
- Initial release of hwayo gem
- Extract text from HWP files using hwplib Java library
- Support for output to file or return as string
- Automatic Java detection and error handling
- Support for custom JAR paths via environment variable