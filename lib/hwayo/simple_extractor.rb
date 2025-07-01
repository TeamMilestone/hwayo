# frozen_string_literal: true

require 'open3'
require 'tempfile'

module Hwayo
  class SimpleExtractor
    def extract_text(hwp_file_path, output_path = nil)
      raise Error, "HWP file not found: #{hwp_file_path}" unless File.exist?(hwp_file_path)
      
      # Java 실행 가능 여부 확인
      unless system('java -version > /dev/null 2>&1')
        return { success: false, error: "Java is not installed. Please install Java 8 or later." }
      end
      
      # JAR 파일 경로
      jar_path = File.expand_path('../java/hwplib-1.1.10.jar', __dir__)
      
      # JAR 파일이 없으면 대체 경로 시도
      unless File.exist?(jar_path)
        # 개발 환경에서 직접 실행하는 경우
        alt_jar_path = File.expand_path('../../../target/hwplib-1.1.10.jar', __dir__)
        if File.exist?(alt_jar_path)
          jar_path = alt_jar_path
        else
          return { success: false, error: "hwplib JAR not found" }
        end
      end
      
      # 임시 출력 파일
      temp_output = Tempfile.new(['hwp_output', '.txt'])
      
      begin
        # Java 클래스 실행
        cmd = [
          'java',
          '-cp', jar_path,
          'kr.dogfoot.hwplib.sample.Extracting_Text',
          hwp_file_path,
          temp_output.path
        ]
        
        stdout, stderr, status = Open3.capture3(*cmd)
        
        if status.success?
          extracted_text = File.read(temp_output.path, encoding: 'UTF-8')
          
          # 결과 저장
          if output_path
            File.write(output_path, extracted_text, encoding: 'UTF-8')
            { success: true, text: extracted_text, output_path: output_path }
          else
            { success: true, text: extracted_text }
          end
        else
          { success: false, error: "Java execution failed: #{stderr}" }
        end
        
      ensure
        temp_output.close
        temp_output.unlink
      end
    end
  end
end