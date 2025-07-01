# frozen_string_literal: true

require_relative "hwayo/version"
require 'open3'
require 'tempfile'

module Hwayo
  class Error < StandardError; end
  
  # Extract text from HWP file
  def self.extract_text(hwp_file_path, output_path = nil)
    raise Error, "HWP file not found: #{hwp_file_path}" unless File.exist?(hwp_file_path)
    
    # Java 실행 가능 여부 확인
    unless system('java -version > /dev/null 2>&1')
      return { success: false, error: "Java is not installed. Please install Java 8 or later." }
    end
    
    # JAR 파일 경로 찾기
    jar_path = find_jar_path
    unless jar_path
      return { success: false, error: "hwplib JAR not found. Please ensure hwplib-1.1.10.jar is in the gem's lib/hwayo/java directory or in the current directory." }
    end
    
    # CLI 클래스 경로 찾기
    cli_class_path = find_cli_class(jar_path)
    unless cli_class_path
      return { success: false, error: "HWPTextExtractorCLI.class not found" }
    end
    
    # 임시 출력 파일
    temp_output = output_path || Tempfile.new(['hwp_output', '.txt']).path
    
    begin
      # Java 명령 실행
      cmd = [
        'java',
        '-cp', "#{jar_path}:#{cli_class_path}",
        'HWPTextExtractorCLI',
        hwp_file_path,
        temp_output
      ]
      
      stdout, stderr, status = Open3.capture3(*cmd)
      
      if status.success? && stdout.strip == "SUCCESS"
        extracted_text = File.read(temp_output, encoding: 'UTF-8')
        
        result = { success: true, text: extracted_text }
        result[:output_path] = output_path if output_path
        result
      else
        { success: false, error: "Extraction failed: #{stderr}" }
      end
      
    ensure
      # 임시 파일 정리
      File.unlink(temp_output) if !output_path && File.exist?(temp_output)
    end
  end
  
  private
  
  def self.find_jar_path
    possible_paths = [
      # gem 내부
      File.expand_path('../hwayo/java/hwplib-1.1.10.jar', __FILE__),
      # 현재 디렉토리
      'hwplib-1.1.10.jar',
      'target/hwplib-1.1.10.jar',
      # 환경 변수
      ENV['HWPLIB_JAR_PATH']
    ].compact
    
    possible_paths.find { |path| path && File.exist?(path) }
  end
  
  def self.find_cli_class(jar_dir)
    jar_directory = File.dirname(jar_dir)
    possible_paths = [
      jar_directory,
      '.',
      File.expand_path('../hwayo/java', __FILE__)
    ]
    
    possible_paths.find { |path| File.exist?(File.join(path, 'HWPTextExtractorCLI.class')) }
  end
end