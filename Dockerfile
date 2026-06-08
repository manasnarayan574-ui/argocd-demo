# Using standard Nginx as requested
FROM nginx:alpine

# Optional: Copy custom HTML if you have it, otherwise standard Nginx runs
# COPY ./index.html /usr/share/nginx/html/index.html

EXPOSE 80

