# 掌上博物馆后端部署指南

本文档提供将掌上博物馆后端服务从本地部署到云服务器的详细步骤。完成部署后，您将不再需要每次测试前手动启动后端服务。

## 前提条件

- 一台已配置的云服务器（本例中使用IP: 101.43.234.152）
- 服务器上已安装以下软件：
  - Node.js (v14+)
  - MySQL (与本地开发环境相同版本)
  - PM2（Node.js进程管理工具）
  - Git（可选，用于拉取代码）

## 部署步骤

### 1. 准备服务器环境

```bash
# 连接到服务器
ssh username@101.43.234.152

# 安装Node.js (如未安装)
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装PM2进程管理器
sudo npm install -g pm2

# 安装MySQL (如未安装)
sudo apt-get install mysql-server
```

### 2. 配置MySQL数据库

```bash
# 登录MySQL
sudo mysql -u root -p

# 创建数据库和用户
CREATE DATABASE se2025;
CREATE USER 'SE2025'@'%' IDENTIFIED BY 'Cs22032025';
GRANT ALL PRIVILEGES ON se2025.* TO 'SE2025'@'%';
FLUSH PRIVILEGES;
EXIT;

# 配置MySQL允许远程连接 (编辑MySQL配置文件)
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# 找到bind-address行，改为bind-address = 0.0.0.0
# 保存并退出

# 重启MySQL服务
sudo systemctl restart mysql
```

### 3. 上传后端代码到服务器

**方法1: 使用SCP上传**

```bash
# 在本地执行，将后端代码上传到服务器
cd /path/to/your/local/project
scp -r Application/backend username@101.43.234.152:/home/username/handmuseum-backend
```

**方法2: 使用Git拉取**

```bash
# 在服务器上执行
mkdir -p /home/username/handmuseum-backend
cd /home/username/handmuseum-backend
git clone <您的Git仓库URL> .
# 如果只需要backend目录
git sparse-checkout set Application/backend
```

### 4. 配置后端服务

```bash
# 进入后端目录
cd /home/username/handmuseum-backend/Application/backend

# 安装依赖
npm install

# 修改数据库配置（如果数据库已在服务器上）
nano src/config/db.config.js
# 将HOST改为localhost或127.0.0.1（如果MySQL在同一服务器上）
```

### 5. 使用PM2启动并管理后端服务

```bash
# 启动服务并设置自动重启
pm2 start src/index.js --name "handmuseum-backend"

# 设置开机自启动
pm2 startup
pm2 save

# 查看服务状态
pm2 status

# 查看日志
pm2 logs handmuseum-backend
```

### 6. 配置服务器防火墙

```bash
# 开放3000端口
sudo ufw allow 3000/tcp
sudo ufw status
```

### 7. 修改前端API基础URL

在您的开发环境中，修改前端代码中的API基础URL：

```typescript
// 修改文件：Application/entry/src/main/ets/services/ApiService.ets
// 将
private baseUrl: string = 'http://localhost:3000/api';
// 改为
private baseUrl: string = 'http://101.43.234.152:3000/api';
```

### 8. 测试部署

- 确保服务器上的后端服务正在运行
- 使用修改后的前端应用连接到服务器
- 测试所有功能是否正常工作

### 可选：配置Nginx反向代理（生产环境推荐）

为了提高安全性和性能，建议配置Nginx作为反向代理：

```bash
# 安装Nginx
sudo apt-get install nginx

# 创建站点配置
sudo nano /etc/nginx/sites-available/handmuseum

# 输入以下配置
server {
    listen 80;
    server_name your-domain.com; # 或使用服务器IP

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# 启用站点配置
sudo ln -s /etc/nginx/sites-available/handmuseum /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 如果使用Nginx，修改前端API基础URL为：
# private baseUrl: string = 'http://101.43.234.152/api'; # 不再需要端口号
```

## 故障排除

### 服务无法启动

检查日志以获取详细错误信息：

```bash
pm2 logs handmuseum-backend
```

### 连接数据库失败

- 确保MySQL服务正在运行：`sudo systemctl status mysql`
- 检查数据库连接配置是否正确
- 检查MySQL用户权限是否设置正确

### 前端无法连接到后端API

- 检查API基础URL是否配置正确
- 确保服务器防火墙允许3000端口
- 使用curl测试API端点：`curl http://101.43.234.152:3000/api`

## 维护建议

1. 定期备份数据库：

   ```bash
   mysqldump -u SE2025 -p se2025 > backup_$(date +%Y%m%d).sql
   ```

2. 监控服务状态：

   ```bash
   pm2 monit
   ```

3. 设置服务器安全更新：

   ```bash
   sudo apt-get update
   sudo apt-get upgrade
   ```

4. 检查和轮换日志文件：

   ```bash
   pm2 flush  # 清空PM2日志
   ```

完成以上步骤后，您的掌上博物馆后端服务将持续在云服务器上运行，无需每次测试前手动启动。
