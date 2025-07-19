FROM cirrusci/flutter:stable AS build

# flutter 유저 생성
RUN useradd -ms /bin/bash flutter

# flutter 유저가 flutter SDK 접근 가능하도록 소유권 변경
RUN chown -R flutter:flutter /sdks/flutter

# flutter 유저로 전환
USER flutter

WORKDIR /app

# 이 설정을 안전하게 적용하기 위해 추가
RUN git config --global --add safe.directory /sdks/flutter

# flutter 세팅
RUN flutter config --no-analytics

COPY pubspec.* ./
RUN flutter pub get

COPY . .

# 웹 앱 빌드
RUN flutter build web

# nginx로 서빙할 스테이지
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
