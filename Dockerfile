# Оптимальный вариант - multi-stage сборка
# так в продакшн-контейнере не окажется лишних зависимостей и TS-исходников

# Задаем базовый образ для этапа сборки
FROM node:16-alpine as build
# Задаем рабочую директорию
WORKDIR /usr/src/app
# Копируем список зависимостей и лок-файл отдельно от файлов проекта
# напомним, это нужно для кэширования установки зависимостей
COPY package*.json ./
# Устанавливаем зависимости 
RUN npm i
COPY . .
RUN npm run build

FROM node:16-alpine As production
ENV NODE_ENV=production
WORKDIR /usr/src/app
COPY package*.json ./
# Флаг --omit=dev означает "не ставить dev-зависимости"
RUN npm i --omit=dev
COPY . .
# Копируем результат сборки из build-стадии
COPY --from=build /usr/src/app/dist ./dist
EXPOSE 3000
# Команда для запуска
CMD ["node", "dist/main"]