# 🏹 ianseo Docker Compose Setup

Quick and easy way to run [ianseo](https://ianseo.net/) with Docker Compose.

Perfect for development, testing, or small club deployments with modern Docker practices.

## 📋 Prerequisites

- Docker and Docker Compose installed (Docker Engine 20.10+ recommended)
- At least 2GB RAM available
- Ports 8080, 3306, and 8081 available (customizable in `.env`)

## 🚀 Quick Start

1. **Clone and navigate:**
   ```bash
   git clone https://github.com/your-repo/ianseo-docker-compose
   cd ianseo-docker-compose
   ```

2. **Configure environment (recommended):**
   ```bash
   # Copy the example file and customize it
   cp .env.example .env
   # Edit .env with your preferred settings
   nano .env
   ```

3. **Start services:**
   ```bash
   docker-compose up -d
   ```

4. **Access ianseo:**
   - **🏹 ianseo Application**: http://localhost:8080/ianseo/
   - **🗄️ phpMyAdmin**: http://localhost:8081
   - **❤️ Health Check**: http://localhost:8080/health.php
   
   **Note**: ianseo is served under the `/ianseo/` path, not at the root.

## 🔧 Configuration

### Environment Variables
Customize the `.env` file with your settings:

| Variable | Default in docker-compose.yml | Description |
|----------|-------------------------------|-------------|
| `MYSQL_DATABASE` | `ianseo` | Database name |
| `MYSQL_USER` | `ianseo` | Database user |
| `MYSQL_PASSWORD` | `ianseo_password` | User password |
| `MYSQL_ROOT_PASSWORD` | `root_password` | Root password |

**Note**: The ports are currently hardcoded in docker-compose.yml:
- ianseo Application: `8080`
- MySQL Database: `3306` 
- phpMyAdmin: `8081`

### Database Connection
- **Host**: `ianseo-db` (from container) or `localhost` (from host)
- **Database**: Value from `MYSQL_DATABASE` env var
- **Username**: Value from `MYSQL_USER` env var  
- **Password**: Value from `MYSQL_PASSWORD` env var

### Custom Configuration Files
Modify files in the `config/` directory:
- `config/apache2/ianseo.conf` - Apache virtual host configuration
- `config/php/ianseo.ini` - PHP runtime settings (memory, upload limits)
- `config/mysql/ianseo.cnf` - MySQL server configuration

## 📊 Management Commands

```bash
# View all service logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f ianseo-app
docker-compose logs -f ianseo-db

# Monitor resource usage
docker stats

# Stop services (keeps data)
docker-compose down

# Stop and remove everything including volumes (⚠️ destroys data!)
docker-compose down -v

# Update to latest ianseo version
docker-compose down
docker-compose build --no-cache ianseo-app
docker-compose up -d

# Backup database
docker-compose exec ianseo-db mysqldump -u root -p${MYSQL_ROOT_PASSWORD} ianseo > backup_$(date +%Y%m%d).sql

# Restore database  
docker-compose exec -i ianseo-db mysql -u root -p${MYSQL_ROOT_PASSWORD} ianseo < backup_file.sql
```

## 🔒 Security Best Practices

### For Development
- Use the provided default passwords from docker-compose.yml
- Ensure `.env` contains your custom passwords (don't commit sensitive passwords to git)

### For Production Deployment
1. **🔐 Change ALL passwords** in your environment file
2. **🔒 Use Docker secrets** instead of environment variables:
   ```bash
   echo "your_secure_password" | docker secret create mysql_root_password -
   ```
3. **🌐 Configure reverse proxy** (nginx/traefik) with SSL
4. **🔥 Set up firewall rules** to restrict access
5. **💾 Implement regular backups** of the MySQL data volume
6. **🔄 Keep containers updated** regularly
7. **📊 Monitor logs** for suspicious activity

### Network Security
```bash
# Create custom network with restricted access
docker network create --driver bridge --subnet=172.20.0.0/16 ianseo-secure
```

## 📂 Data Persistence & Volumes

Your tournament data is safely stored in Docker volumes:

| Volume | Purpose | Backup Recommendation |
|--------|---------|----------------------|
| `mysql_data` | All tournament/user data | Daily automated backup |
| `config/` | Configuration files | Include in git repository |

### Manual Backup Strategy
```bash
# Create backup directory
mkdir -p backups/$(date +%Y-%m-%d)

# Backup database (you'll be prompted for the root password)
docker-compose exec ianseo-db mysqldump -u root -p \
  --all-databases > backups/$(date +%Y-%m-%d)/full_backup.sql

# Alternative: Using environment variable (less secure, but automated)
# docker-compose exec ianseo-db mysqldump -u root -p${MYSQL_ROOT_PASSWORD} \
#   --all-databases > backups/$(date +%Y-%m-%d)/full_backup.sql

# Backup configuration
tar -czf backups/$(date +%Y-%m-%d)/config_backup.tar.gz config/
```

## 🐛 Troubleshooting

### Services won't start
```bash
# Check all container status
docker-compose ps

# View detailed logs
docker-compose logs

# Check if ports are already in use
lsof -i :8080 -i :3306 -i :8081
```

### Database connection issues
```bash
# Test database connectivity from app container
docker-compose exec ianseo-app mysql -h ianseo-db -u ianseo -p${MYSQL_PASSWORD}

# Test from host machine (requires mysql client installed)
mysql -h 127.0.0.1 -P 3306 -u ianseo -p${MYSQL_PASSWORD}

# Check database container health
docker-compose exec ianseo-db mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} ping
```

### Application issues
```bash
# Check Apache error logs
docker-compose exec ianseo-app tail -f /var/log/apache2/error.log

# Check PHP configuration
docker-compose exec ianseo-app php -m | grep -i mysql

# Test application health endpoint
curl http://localhost:8080/health.php
```

### Performance issues
```bash
# Monitor resource usage
docker stats

# Check Apache access logs
docker-compose exec ianseo-app tail -f /var/log/apache2/access.log
```

### Complete reset (⚠️ Nuclear option)
```bash
# Stop everything and remove all data
docker-compose down -v --rmi all

# Clean up orphaned volumes
docker volume prune

# Rebuild and restart
docker-compose up --build -d
```

## 🚀 Advanced Usage

### Production Deployment with Docker Swarm
```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml ianseo

# Scale services
docker service scale ianseo_ianseo-app=3
```

### Integration with Reverse Proxy
Example nginx configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Custom SSL Configuration
```bash
# Generate self-signed certificate for development
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/ianseo.key -out certs/ianseo.crt
```

## 📈 Monitoring & Maintenance

### Health Checks
The setup includes built-in health monitoring:
- **Application**: http://localhost:8080/health.php
- **Database**: Automatic Docker health checks
- **Container status**: `docker-compose ps`

### Log Rotation
Configure log rotation to prevent disk space issues:
```bash
# Add to your system's logrotate
echo '/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size=1M
    missingok
    delaycompress
    copytruncate
}' | sudo tee /etc/logrotate.d/docker-containers
```

## 🤝 Contributing

Issues and pull requests welcome! Please test your changes with:
```bash
# Full test cycle
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
docker-compose logs -f

# Run health checks
curl http://localhost:8080/health.php
```

### Development Guidelines
1. **🧪 Test all changes** in clean environment
2. **📝 Update documentation** for new features
3. **🔒 Follow security best practices**
4. **📊 Include monitoring/logging** for new services

## 📄 License

This Docker setup is provided under MIT License. 
ianseo itself is subject to its own licensing terms - see [ianseo.net](https://ianseo.net/).

---

**🏗️ Need enterprise hosting?** Check out our [Azure Container Instances setup](../aci-docker/) for scalable cloud deployment with automatic scaling and managed database services.
