
FROM dart:stable AS build

RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter --version

WORKDIR /app


COPY . .

RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine AS production

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
