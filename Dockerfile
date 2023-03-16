FROM httpd:latest
RUN apt-get update -y

COPY . /var/www/html

# Echo message
RUN echo "Files transferred"

# Expose port 80
EXPOSE 80

RUN apt-get update

# Turn on Node.js and run in the background


RUN echo "Background services started"

# Start Apache2
CMD ["apache2", "-D", "FOREGROUND"]

# Echo message
RUN echo "Webserver turned on"


