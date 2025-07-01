# frozen_string_literal: true

require 'tempfile'

module Hwayo
  class Extractor
    def initialize
      @java_loaded = false
      load_java_dependencies
    end
    
    def extract_text(hwp_file_path, output_path = nil)
      raise Error, "HWP file not found: #{hwp_file_path}" unless File.exist?(hwp_file_path)
      
      ensure_java_loaded
      
      begin
        # HWP 파일 읽기
        hwp_file = @hwp_reader.fromFile(hwp_file_path)
        
        # 텍스트 추출 옵션 설정
        option = @text_extract_option.new
        option.setMethod(@text_extract_method.InsertControlTextBetweenParagraphText)
        option.setWithControlChar(false)
        option.setAppendEndingLF(true)
        
        # 텍스트 추출
        extracted_text = @text_extractor.extract(hwp_file, option)
        
        # 결과 저장 또는 반환
        if output_path
          File.write(output_path, extracted_text, encoding: 'UTF-8')
          { success: true, text: extracted_text, output_path: output_path }
        else
          { success: true, text: extracted_text }
        end
        
      rescue => e
        { success: false, error: "Failed to extract text: #{e.message}" }
      end
    end
    
    private
    
    def load_java_dependencies
      if RUBY_PLATFORM == 'java'
        # JRuby environment
        require 'java'
        load_jruby_dependencies
      else
        # MRI Ruby with RJB
        begin
          require 'rjb'
          load_rjb_dependencies
        rescue LoadError
          raise Error, "RJB gem is required for Java integration. Please install it: gem install rjb"
        end
      end
    end
    
    def load_jruby_dependencies
      jar_path = File.expand_path('../java/hwplib-1.1.10.jar', __dir__)
      raise Error, "hwplib JAR not found at: #{jar_path}" unless File.exist?(jar_path)
      
      require jar_path
      
      @hwp_reader = Java::KrDogfootHwplibReader::HWPReader
      @text_extractor = Java::KrDogfootHwplibToolTextextractor::TextExtractor
      @text_extract_option = Java::KrDogfootHwplibToolTextextractor::TextExtractOption
      @text_extract_method = Java::KrDogfootHwplibToolTextextractor::TextExtractMethod
      
      @java_loaded = true
    end
    
    def load_rjb_dependencies
      return if @java_loaded
      
      jar_path = File.expand_path('../java/hwplib-1.1.10.jar', __dir__)
      raise Error, "hwplib JAR not found at: #{jar_path}" unless File.exist?(jar_path)
      
      # Set JAVA_HOME if not set
      ENV['JAVA_HOME'] ||= detect_java_home
      
      # Load RJB with the JAR file
      Rjb::load(jar_path, ['-Xmx512m'])
      
      # Import Java classes
      @hwp_reader = Rjb::import('kr.dogfoot.hwplib.reader.HWPReader')
      @text_extractor = Rjb::import('kr.dogfoot.hwplib.tool.textextractor.TextExtractor')
      @text_extract_option = Rjb::import('kr.dogfoot.hwplib.tool.textextractor.TextExtractOption')
      @text_extract_method = Rjb::import('kr.dogfoot.hwplib.tool.textextractor.TextExtractMethod')
      
      @java_loaded = true
    end
    
    def ensure_java_loaded
      load_rjb_dependencies unless @java_loaded
    end
    
    def detect_java_home
      # Try common Java installation paths
      possible_java_homes = [
        '/usr/libexec/java_home -V 2>&1 | grep -E "1\.(8|11)" | head -1 | awk \'{print $NF}\'',
        '/usr/lib/jvm/java-11-openjdk-amd64',
        '/usr/lib/jvm/java-8-openjdk-amd64',
        '/Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home',
        '/Library/Java/JavaVirtualMachines/jdk1.8.0_*.jdk/Contents/Home'
      ]
      
      if system('which java > /dev/null 2>&1')
        java_home = `echo $(/usr/libexec/java_home 2>/dev/null)`.strip
        return java_home unless java_home.empty?
      end
      
      possible_java_homes.each do |path|
        expanded_path = File.expand_path(path)
        return expanded_path if File.directory?(expanded_path)
      end
      
      raise Error, "Java not found. Please install Java 8 or later and set JAVA_HOME environment variable."
    end
  end
end