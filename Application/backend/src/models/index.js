/**
 * 数据库模型索引文件
 */
const dbConfig = require('../config/db.config');
const Sequelize = require('sequelize');

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
    }
});

const db = {};

db.Sequelize = Sequelize;
db.sequelize = sequelize;

// 导入模型
db.artifacts = require('./artifact.model.js')(sequelize, Sequelize);
db.users = require('./user.model.js')(sequelize, Sequelize);
db.comments = require('./comment.model.js')(sequelize, Sequelize);
db.favorites = require('./favorite.model.js')(sequelize, Sequelize);

// 设置关联关系，但不添加外键约束
db.comments.belongsTo(db.artifacts, {
    foreignKey: 'artifactId',
    constraints: false
});
db.comments.belongsTo(db.users, {
    foreignKey: 'userId',
    constraints: false
});

// 修改关联关系的名称，避免与属性冲突
db.artifacts.hasMany(db.comments, {
    foreignKey: 'artifactId',
    as: 'commentList',
    constraints: false
});
db.users.hasMany(db.comments, {
    foreignKey: 'userId',
    as: 'userComments',
    constraints: false
});

db.favorites.belongsTo(db.artifacts, {
    foreignKey: 'artifactId',
    constraints: false
});
db.favorites.belongsTo(db.users, {
    foreignKey: 'userId',
    constraints: false
});
db.users.hasMany(db.favorites, {
    foreignKey: 'userId',
    as: 'userFavorites',
    constraints: false
});
db.artifacts.hasMany(db.favorites, {
    foreignKey: 'artifactId',
    as: 'artifactFavorites',
    constraints: false
});

module.exports = db; 