# 🏹 ianseo Docker Compose Setup

Quick and easy way to run [ianseo](https://ianseo.net/) locally with Docker Compose.

Perfect for development, testing, or small club deployments.

## 📋 Prerequisites

- Docker and Docker Compose installed
- At least 2GB RAM available
- Ports 8080, 3306, and 8081 available

## 🚀 Quick Start

1. **Clone and navigate:**
   ```bash
   git clone https://github.com/your-repo/ianseo-dockerized
   cd ianseo-dockerized/docker-compose
   ```

2. **Configure environment (optional):**
   ```bash
   cp .env.example .env
   # Edit .env with your preferred passwords
   ```

3. **Start services:**
   ```bash
   docker-compose up -d
   ```

4. **Access ianseo:**
   - **ianseo Application**: http://localhost:8080
   - **phpMyAdmin**: http://localhost:8081

## 🔧 Configuration

### Database Credentials
- **Database Name**: `ianseo`
- **Username**: `ianseo` 
- **Password**: `ianseo_password` (or your custom password from `.env`)

### Default Ports
- **ianseo**: 8080
- **MySQL**: 3306
- **phpMyAdmin**: 8081

### Custom Configuration
Modify files in the `config/` directory:
- `config/apache2/ianseo.conf` - Apache virtual host
- `config/php/ianseo.ini` - PHP settings
- `config/mysql/ianseo.cnf` - MySQL configuration

## 📊 Management Commands

```bash
# View logs
docker-compose logs -f ianseo-app

# Stop services
docker-compose down

# Update to latest ianseo
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Reset database (⚠️ destroys all data!)
docker-compose down -v
docker-compose up -d
```

## 🔒 Security Notes

**For production use:**
1. Change default passwords in `.env`
2. Consider using Docker secrets
3. Restrict network access to necessary ports
4. Regular backups of the MySQL data volume

## 📂 Data Persistence

Your tournament data is stored in Docker volumes:
- `mysql_data` - All database content
- Configuration files are mounted from `config/`

## 🐛 Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs

# Verify ports aren't in use
netstat -tulpn | grep -E '(8080|3306|8081)'
```

### Database connection issues
```bash
# Test database connectivity
docker-compose exec ianseo-app mysql -h ianseo-db -u ianseo -p
```

### Reset everything
```bash
# Complete reset (⚠️ destroys all data!)
docker-compose down -v --rmi all
docker-compose up -d
```

## 🤝 Contributing

Issues and pull requests welcome! Please test your changes with:
```bash
docker-compose down -v
docker-compose up --build
```

## 📄 License

This Docker setup is provided as-is. ianseo itself is subject to its own licensing terms.

---

**Need a cloud-hosted solution?** Check out our [Azure Container Instances setup](../aci-docker/) for scalable SaaS deployment.
