# Hwayo

[![Gem Version](https://badge.fury.io/rb/hwayo.svg)](https://badge.fury.io/rb/hwayo)

Hwayo는 한글(HWP) 및 PDF 파일에서 텍스트를 추출하는 Ruby gem입니다. Java 기반의 [hwplib](https://github.com/neolord0/hwplib)와 [Apache PDFBox](https://pdfbox.apache.org/) 라이브러리를 Ruby에서 쉽게 사용할 수 있도록 래핑하였습니다.

## 특징

- 한글(HWP) 파일에서 텍스트 추출
- PDF 파일에서 텍스트 추출 (Apache PDFBox 3.0.5 사용)
- 표, 그림 설명 등 컨트롤 텍스트 포함 추출
- 간단한 Ruby 인터페이스
- 파일 저장 또는 문자열 반환 선택 가능

## 요구사항

- Ruby 2.7.0 이상
- Java 8 이상 설치 필요
- hwplib JAR 파일 (자동 포함 또는 별도 다운로드)
- PDFBox JAR 파일 (자동 포함)

## 설치

Gemfile에 추가:

```ruby
gem 'hwayo'
```

그리고 실행:

    $ bundle install

또는 직접 설치:

    $ gem install hwayo

## 사용법

### 기본 사용법

```ruby
require 'hwayo'

# HWP 파일에서 텍스트 추출
result = Hwayo.extract_text('document.hwp')

if result[:success]
  puts result[:text]
else
  puts "Error: #{result[:error]}"
end

# PDF 파일에서 텍스트 추출
result = Hwayo.extract_text('document.pdf')

if result[:success]
  puts result[:text]
else
  puts "Error: #{result[:error]}"
end
```

### 파일로 저장

```ruby
# HWP에서 추출한 텍스트를 파일로 저장
result = Hwayo.extract_text('document.hwp', 'output.txt')

if result[:success]
  puts "텍스트가 저장되었습니다: #{result[:output_path]}"
else
  puts "오류 발생: #{result[:error]}"
end

# PDF에서 추출한 텍스트를 파일로 저장
result = Hwayo.extract_text('document.pdf', 'output.txt')

if result[:success]
  puts "텍스트가 저장되었습니다: #{result[:output_path]}"
else
  puts "오류 발생: #{result[:error]}"
end
```

### 여러 파일 일괄 처리

```ruby
# HWP와 PDF 파일 모두 처리
files = Dir.glob("*.{hwp,pdf}")

files.each do |file|
  output_file = file.gsub(/\.(hwp|pdf)$/i, '.txt')
  result = Hwayo.extract_text(file, output_file)
  
  if result[:success]
    puts "✓ #{file} → #{output_file}"
  else
    puts "✗ #{file}: #{result[:error]}"
  end
end
```

### Rails에서 사용하기

```ruby
class DocumentsController < ApplicationController
  def extract
    uploaded_file = params[:file]
    
    if uploaded_file.present?
      # 임시 파일로 저장
      temp_file = Tempfile.new(['document', '.hwp'])
      temp_file.binmode
      temp_file.write(uploaded_file.read)
      temp_file.rewind
      
      # 텍스트 추출
      result = Hwayo.extract_text(temp_file.path)
      
      # 정리
      temp_file.close
      temp_file.unlink
      
      if result[:success]
        render json: { text: result[:text] }
      else
        render json: { error: result[:error] }, status: :unprocessable_entity
      end
    else
      render json: { error: 'No file provided' }, status: :bad_request
    end
  end
end
```

## 설정

### JAR 파일 위치 지정

hwayo는 다음 순서로 JAR 파일을 찾습니다:

**HWP 처리용 hwplib JAR:**
1. gem 내부의 `lib/hwayo/java/hwplib-1.1.10.jar`
2. 현재 디렉토리의 `hwplib-1.1.10.jar`
3. 현재 디렉토리의 `target/hwplib-1.1.10.jar`
4. 환경 변수 `HWPLIB_JAR_PATH`

**PDF 처리용 PDFBox JAR:**
1. gem 내부의 `lib/hwayo/java/pdfbox-app-3.0.5.jar`
2. 현재 디렉토리의 `pdfbox-app-3.0.5.jar`
3. 현재 디렉토리의 `target/pdfbox-app-3.0.5.jar`
4. 환경 변수 `PDFBOX_JAR_PATH`

커스텀 경로 지정:

```bash
export HWPLIB_JAR_PATH=/path/to/hwplib-1.1.10.jar
export PDFBOX_JAR_PATH=/path/to/pdfbox-app-3.0.5.jar
```

### Docker에서 사용하기

Dockerfile에 Java 설치:

```dockerfile
# Debian/Ubuntu
RUN apt-get update && apt-get install -y openjdk-11-jre-headless

# Alpine Linux
RUN apk add --no-cache openjdk11-jre

# 환경 변수 설정
ENV HWPLIB_JAR_PATH=/app/vendor/hwplib-1.1.10.jar
```

## 문제 해결

### Java가 설치되지 않음

```
Error: Java is not installed. Please install Java 8 or later.
```

해결 방법:

```bash
# macOS
brew install openjdk@11

# Ubuntu/Debian
sudo apt-get install openjdk-11-jre

# CentOS/RHEL
sudo yum install java-11-openjdk
```

### JAR 파일을 찾을 수 없음

```
Error: hwplib JAR not found
```

해결 방법:

1. [hwplib releases](https://github.com/neolord0/hwplib/releases)에서 JAR 파일 다운로드
2. 환경 변수 설정: `export HWPLIB_JAR_PATH=/path/to/hwplib-1.1.10.jar`

### 한글 깨짐

UTF-8 인코딩을 확인하세요:

```ruby
result = Hwayo.extract_text('document.hwp')
puts result[:text].encoding  # UTF-8이어야 함
```

## 제한사항

- 암호화된 HWP/PDF 파일은 지원하지 않습니다
- 이미지, HTML로 변환은 지원하지 않습니다
- Java 프로세스 실행으로 인한 오버헤드가 있습니다

## 기여하기

1. Fork it ( https://github.com/onesup/hwayo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## 라이선스

이 gem은 [MIT License](https://opensource.org/licenses/MIT)로 제공됩니다.

hwplib은 [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)으로 제공됩니다.

## 감사의 말

이 gem은 [hwplib](https://github.com/neolord0/hwplib) 프로젝트를 기반으로 만들어졌습니다. hwplib 개발자분들께 감사드립니다.