# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Hwayo is a Ruby gem that extracts text from Korean HWP (Hangul Word Processor) files. It provides a simple Ruby interface to the Java-based hwplib library.

## Development Commands

```bash
# Setup development environment
bin/setup

# Open interactive console with gem loaded
bin/console

# Build the gem
rake build

# Install gem locally
rake install

# Release to RubyGems (requires permissions)
rake release
```

## Architecture

The gem uses a simple command-line bridge between Ruby and Java:

1. **Main Interface**: `Hwayo.extract_text(hwp_file, output_file = nil)` in `lib/hwayo.rb`
2. **Java Bridge**: Executes `HWPTextExtractorCLI` class with hwplib JAR via system call
3. **JAR Discovery**: Searches in gem directory, current directory, target/, or `HWPLIB_JAR_PATH` env var

Key files:
- `lib/hwayo.rb`: Main module with extraction logic
- `lib/hwayo/java/`: Contains Java CLI wrapper and hwplib JAR
- `lib/hwayo/version.rb`: Version constant

## Important Notes

- **No test suite**: The gem currently has no tests implemented
- **Java dependency**: Requires Java 8+ installed on the system
- **Unused code**: `extractor.rb` and `simple_extractor.rb` are alternative implementations not currently used
- **Process overhead**: Each extraction spawns a new Java process
- **Text only**: Extracts plain text and control text (tables, image descriptions) but no formatting or images