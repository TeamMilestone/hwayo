require 'open3'
require 'tempfile'

module Hwayo
  module PdfExtractor
    class << self
      def extract_text(pdf_file, output_file = nil)
        validate_inputs(pdf_file)
        validate_java_installation
        
        jar_path = find_pdfbox_jar
        
        result = if output_file
          extract_to_file(pdf_file, output_file, jar_path)
        else
          extract_to_string(pdf_file, jar_path)
        end
        
        format_result(result, output_file)
      end
      
      private
      
      def validate_inputs(pdf_file)
        raise ArgumentError, "PDF file path is required" if pdf_file.nil? || pdf_file.empty?
        raise ArgumentError, "PDF file not found: #{pdf_file}" unless File.exist?(pdf_file)
        raise ArgumentError, "Not a PDF file: #{pdf_file}" unless pdf_file.downcase.end_with?('.pdf')
      end
      
      def validate_java_installation
        stdout, stderr, status = Open3.capture3('java', '-version')
        unless status.success?
          raise RuntimeError, "Java is not installed or not in PATH. Please install Java 8 or higher."
        end
      end
      
      def find_pdfbox_jar
        search_paths = [
          File.join(File.dirname(__FILE__), 'java', 'pdfbox-app-3.0.5.jar'),
          'pdfbox-app-3.0.5.jar',
          'target/pdfbox-app-3.0.5.jar',
          ENV['PDFBOX_JAR_PATH']
        ].compact
        
        jar_path = search_paths.find { |path| path && File.exist?(path) }
        
        unless jar_path
          raise RuntimeError, "PDFBox JAR file not found. Searched in: #{search_paths.join(', ')}"
        end
        
        jar_path
      end
      
      def extract_to_file(pdf_file, output_file, jar_path)
        cmd = ['java', '-jar', jar_path, 'export:text', '-i', pdf_file, '-o', output_file]
        
        stdout, stderr, status = Open3.capture3(*cmd)
        
        {
          success: status.success?,
          stdout: stdout,
          stderr: stderr,
          output_path: output_file
        }
      end
      
      def extract_to_string(pdf_file, jar_path)
        Tempfile.create(['pdfbox_output', '.txt']) do |temp_file|
          result = extract_to_file(pdf_file, temp_file.path, jar_path)
          
          if result[:success]
            result[:text] = File.read(temp_file.path, encoding: 'UTF-8')
          end
          
          result
        end
      end
      
      def format_result(result, output_file)
        if result[:success]
          base_result = {
            success: true,
            message: "Successfully extracted text from PDF"
          }
          
          if output_file
            base_result[:output_path] = result[:output_path]
          else
            base_result[:text] = result[:text]
          end
          
          base_result
        else
          {
            success: false,
            message: "Failed to extract text from PDF",
            error: result[:stderr]
          }
        end
      end
    end
  end
end