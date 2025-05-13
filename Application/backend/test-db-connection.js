/**
 * 数据库连接测试脚本
 */
const dbConfig = require('./src/config/db.config');
const Sequelize = require('sequelize');

console.log('尝试连接到数据库...');
console.log(`主机: ${dbConfig.HOST}`);
console.log(`数据库: ${dbConfig.DB}`);
console.log(`用户: ${dbConfig.USER}`);

// 创建Sequelize实例
const sequelize = new Sequelize(dbConfig.DB, dbConfig.USER, dbConfig.PASSWORD, {
    host: dbConfig.HOST,
    dialect: dbConfig.dialect,
    operatorsAliases: false,
    pool: {
        max: dbConfig.pool.max,
        min: dbConfig.pool.min,
        acquire: dbConfig.pool.acquire,
        idle: dbConfig.pool.idle
    },
    logging: console.log
});

// 测试连接
sequelize.authenticate()
    .then(() => {
        console.log('数据库连接成功！');

        // 测试一个简单查询 - 获取文物总数
        return sequelize.query('SELECT COUNT(*) as total FROM relic_info', { type: Sequelize.QueryTypes.SELECT });
    })
    .then(result => {
        console.log('文物总数:', result[0].total);
        console.log('数据库查询测试成功！');
        process.exit(0);
    })
    .catch(err => {
        console.error('数据库连接失败:', err);
        process.exit(1);
    }); 