<!--
 * @Author: LokiYu 2915399378@qq.com
 * @Date: 2025-05-10 16:07:05
 * @LastEditors: LokiYu 2915399378@qq.com
 * @LastEditTime: 2025-05-10 16:43:35
 * @FilePath: \HandHeld_Museum_newframe\Application\backend\README.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
# 掌上博物馆后端服务

这是掌上博物馆应用的后端服务，使用 Node.js、Express 和 Sequelize 构建。

## 技术栈

- Node.js
- Express
- Sequelize (MySQL ORM)
- MySQL

## 数据库配置

数据库连接信息：

- 主机: 101.43.234.152
- 用户名: SE2025
- 密码: Cs22032025
- 数据库: museum_db

## 安装依赖

```bash
cd Application/backend
npm install
```

## 启动服务

```bash
# 开发模式
npm run dev

# 生产模式
npm start
```

默认情况下，服务器将在 <http://localhost:3000> 上运行。

## API 接口

### 文物相关

- `GET /api/artifacts` - 获取文物列表（支持分页和分类筛选）
- `GET /api/artifacts/:id` - 获取文物详情
- `GET /api/artifacts/search` - 搜索文物
- `GET /api/artifacts/:id/comments` - 获取文物评论
- `POST /api/artifacts` - 创建新文物
- `PUT /api/artifacts/:id` - 更新文物
- `DELETE /api/artifacts/:id` - 删除文物

### 用户相关

- `POST /api/users/register` - 用户注册
- `POST /api/users/login` - 用户登录
- `GET /api/users/:id` - 获取用户信息
- `PUT /api/users/:id` - 更新用户信息
- `POST /api/users/comments` - 添加评论
- `GET /api/users/:id/comments` - 获取用户评论
- `POST /api/users/favorites` - 添加收藏
- `DELETE /api/users/:userId/favorites/:artifactId` - 取消收藏
- `GET /api/users/:id/favorites` - 获取用户收藏

## 项目结构

```
backend/
├── src/
│   ├── config/         # 配置文件
│   ├── controllers/    # 控制器
│   ├── models/         # 数据模型
│   ├── routes/         # 路由
│   ├── services/       # 服务
│   ├── utils/          # 工具函数
│   └── index.js        # 入口文件
├── package.json
└── README.md
```
