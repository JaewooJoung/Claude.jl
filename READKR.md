# 🤖 Claude.jl

> *Julia를 위한 당신의 친근한 AI 어시스턴트!* 

[![Julia](https://img.shields.io/badge/Julia-9558B2?style=for-the-badge&logo=julia&logoColor=white)](https://julialang.org)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JaewooJoung.github.io/Claude.jl/stable)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

```julia
using Claude
client = ClaudeClient()
response = chat(client, "Julia가 왜 멋진가요?")
# 빠르고 동적이며, 이제 Claude까지 있으니까요! 🚀
```

## 📋 목차
- [필수 요구사항](#-필수-요구사항)
- [주요 기능](#-주요-기능)
- [설치 방법](#-설치-방법)
- [빠른 시작](#-빠른-시작)
  - [API 키 설정](#api-키-설정)
  - [기본 사용법](#기본-채팅)
  - [고급 사용법](#고급-사용법)
- [커스터마이징](#-커스터마이징)
- [예제](#-예제)
- [API 레퍼런스](#-api-레퍼런스)
- [오류 처리](#오류-처리)
- [기여하기](#-기여하기)

## 📋 필수 요구사항
- Julia 1.6 이상
- Anthropic API 키 ([여기서 받기](https://www.anthropic.com/))
- HTTP.jl 및 JSON3.jl 패키지

## ✨ 주요 기능
- 🔌 **간단한 통합** - 몇 줄의 코드로 Claude API 연결
- 🛠️ **도구 지원** - Claude의 강력한 도구 시스템 완벽 지원
- 🔐 **보안** - 환경 변수를 통한 API 키 지원
- 🎯 **타입 안전성** - 완벽한 타입 구조체와 메소드
- 🚀 **최신 기술** - Claude 3.5 Sonnet 이상 지원

## 📦 설치 방법

Julia REPL을 열고 시작해보세요:

```julia
using Pkg
Pkg.add(url="https://github.com/JaewooJoung/Claude.jl")
```

## 🚀 빠른 시작

### API 키 설정

시작하기 전에 Anthropic API 키를 설정해야 합니다. 운영체제별 설정 방법은 다음과 같습니다:

#### 🐧 Linux 및 macOS

**방법 1: 터미널 (임시 - 현재 세션만)**
```bash
export ANTHROPIC_API_KEY='your-api-key-here'
```

**방법 2: 쉘 설정 (영구적)**
```bash
# ~/.bashrc, ~/.zshrc, 또는 ~/.profile에 추가
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc  # 설정 새로고침
```

#### 🪟 Windows

**방법 1: 명령 프롬프트 (임시)**
```cmd
set ANTHROPIC_API_KEY=your-api-key-here
```

**방법 2: 파워쉘 (임시)**
```powershell
$env:ANTHROPIC_API_KEY="your-api-key-here"
```

**방법 3: 시스템 환경 변수 (영구적)**
1. '내 PC' 또는 '내 컴퓨터' 우클릭
2. '속성' → '고급 시스템 설정' → '환경 변수' 클릭
3. '사용자 변수'에서 '새로 만들기' 클릭
4. 변수 이름: `ANTHROPIC_API_KEY`
5. 변수 값: `your-api-key-here`

#### 🔒 보안 팁
- API 키를 버전 관리에 포함하지 마세요
- `.gitignore`에 `.env` 파일을 추가하세요
- API 키를 주기적으로 교체하세요
- 개발용과 운영용 API 키를 구분하여 사용하세요

### 기본 채팅

```julia
using Claude

# 클라이언트 생성 (환경변수에서 API 키 가져오기)
client = ClaudeClient()

# 간단한 질문
response = chat(client, "Julia에 대한 하이쿠를 써주세요")
println(response.content[1].text)

# 응답 출력 함수
function print_response(resp)
    println("\n응답 내용:")
    println("----------------")
    println(resp.content[1].text)
    println("\n메타데이터:")
    println("----------------")
    println("모델: ", resp.model)
    println("사용된 토큰: ", resp.usage.output_tokens)
end
```

### 고급 사용법

#### 다중 턴 대화
```julia
messages = [
    Message("user", "가장 좋은 프로그래밍 언어는 무엇인가요?"),
    Message("assistant", "그건 필요에 따라 다릅니다! 어떤 프로젝트를 하시나요?"),
    Message("user", "과학 컴퓨팅을 위해 빠른 언어가 필요해요")
]

response = chat(client, messages)
```

#### 상태 확인 및 오류 처리
```julia
# API 상태 확인 함수
function check_api_health(client)
    resp = chat(client, "안녕하세요!")
    println("✓ API 정상 작동 중")
    println("✓ 모델: ", resp.model)
    println("✓ 메시지 ID: ", resp.id)
end

# 오류 처리 함수
function handle_error(e)
    msg = string(e)
    if occursin("credit balance", msg)
        println("⚠️ 크레딧 잔액 부족")
    elseif occursin("API key", msg)
        println("⚠️ API 키 문제")
    else
        println("⚠️ 오류: ", e)
    end
end

# 함께 사용하기
try
    check_api_health(client)
    response = chat(client, "안녕하세요!")
    print_response(response)
catch e
    handle_error(e)
end
```

## 🎨 커스터마이징

### 클라이언트 옵션
```julia
# 사용자 정의 설정
client = ClaudeClient(
    model="claude-3-5-sonnet-20241022",  # 모델 선택
    max_tokens=1024,                      # 토큰 제한 설정
    base_url="https://api.anthropic.com/v1"  # 사용자 정의 엔드포인트
)

# API 키 업데이트
update_api_key!(client, "new-api-key")
```

## 📚 API 레퍼런스

### ClaudeClient
```julia
ClaudeClient(;
    api_key::Union{String,Nothing}=nothing,
    model::String="claude-3-5-sonnet-20241022",
    max_tokens::Int=1024,
    tools::Vector{Tool}=Tool[],
    base_url::String="https://api.anthropic.com/v1"
)
```

### Message
```julia
Message(role::String, content::String)
```

### 응답 구조
응답 객체는 다음을 포함합니다:
- `content`: 메시지 내용 객체 배열
  - `text`: 실제 응답 텍스트
- `model`: 사용된 모델
- `usage`: 토큰 사용 통계
- `id`: 고유 메시지 식별자

## ⚠️ 오류 유형

1. 크레딧 잔액 오류
   - "잔액 부족"
   
2. API 키 오류
   - 유효하지 않거나 만료된 API 키
   - API 키 누락
   
3. 요청 제한 오류
   - 너무 많은 요청

## 💡 모범 사례

1. **환경 변수**
   - API 키를 안전하게 저장
   - 개발 시 `.env` 파일 사용

2. **오류 처리**
   - try-catch 블록 항상 사용
   - 특정 오류 케이스 처리
   - 명확한 오류 메시지 제공

3. **리소스 관리**
   - 토큰 사용량 모니터링
   - 요청 제한 적절히 처리
   - API 상태 정기적 확인

## 🤝 기여하기

1. 저장소 포크하기
2. 기능 브랜치 생성 (`git checkout -b feature/amazing-feature`)
3. 변경사항 커밋 (`git commit -am '멋진 기능 추가'`)
4. 브랜치에 푸시 (`git push origin feature/amazing-feature`)
5. Pull Request 열기

## 📜 라이선스

MIT 라이선스 - Claude와 마음껏 대화하세요! ❤️

## 🙏 감사의 말

- Claude를 만든 Anthropic에 감사드립니다
- Julia 커뮤니티에서 영감을 받았습니다
- Julia와 ❤️로 만들었습니다

---

<div align="center">
정재우가 [![Julia](https://img.shields.io/badge/Julia-9558B2?style=for-the-badge&logo=julia&logoColor=white)](https://julialang.org)로 만들었습니다<br>
Claude.jl이 마음에 드신다면 ⭐을 눌러주세요!
</div>
