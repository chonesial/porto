FROM httpd:latest
RUN apt-get update -y

COPY . /usr/local/apache2

# Echo message
RUN echo "Files transferred"

# Expose port 80
EXPOSE 80

RUN apt-get update


RUN echo "Background services started"

# Start Apache2
CMD ["httpd-foreground"]

# Echo message
RUN echo "Webserver turned on"


