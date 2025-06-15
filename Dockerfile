# Use Ubuntu 24.04 LTS as base image for better stability
FROM ubuntu:24.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-client \
    php \
    php-mysqli \
    php-gd \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip \
    php-imagick \
    php-intl \
    libapache2-mod-php \
    imagemagick \
    unzip \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite

# Download and extract ianseo
RUN cd /tmp && \
    wget -O ianseo.zip "https://ianseo.net/Release/Ianseo_20250210.zip" && \
    mkdir -p /opt/ianseo && \
    unzip ianseo.zip -d /opt/ianseo && \
    chmod -R 755 /opt/ianseo && \
    chown -R www-data:www-data /opt/ianseo && \
    rm /tmp/ianseo.zip

# Copy configurations
COPY config/apache2/ianseo.conf /etc/apache2/conf-available/ianseo.conf
COPY config/php/ianseo.ini /etc/php/8.3/apache2/conf.d/99-ianseo.ini

# Enable ianseo Apache configuration
RUN a2enconf ianseo

# Create a simple health check endpoint
RUN echo '<?php echo json_encode(["status" => "healthy", "timestamp" => date("c"), "php_version" => phpversion()]); ?>' > /var/www/html/health.php

# Set working directory
WORKDIR /opt/ianseo

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/health.php || exit 1

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]
