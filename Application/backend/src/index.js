/**
 * 掌上博物馆后端服务入口文件
 */
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const db = require("./models");

const app = express();

// 配置跨域请求
app.use(cors());

// 解析 application/json 请求
app.use(express.json());

// 解析 application/x-www-form-urlencoded 请求
app.use(express.urlencoded({ extended: true }));

// 日志中间件
app.use(morgan('dev'));

// 初始化数据库
db.sequelize.sync()
    .then(() => {
        console.log("数据库已同步。");
    })
    .catch((err) => {
        console.log("数据库同步失败: " + err.message);
    });

// 简单路由
app.get("/", (req, res) => {
    res.json({ message: "欢迎访问掌上博物馆API服务。" });
});

// 导入路由
require("./routes/artifact.routes")(app);
require("./routes/user.routes")(app);

// 设置端口
const PORT = process.env.PORT || 3000;

// 启动服务器
app.listen(PORT, () => {
    console.log(`服务器运行在端口 ${PORT}。`);
}); 