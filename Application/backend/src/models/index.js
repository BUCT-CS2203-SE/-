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
const artifactModels = require('./artifact.model.js')(sequelize, Sequelize);
db.Artifact = artifactModels.Artifact;
db.ArtifactPhoto = artifactModels.ArtifactPhoto;
db.User = require('./user.model.js')(sequelize, Sequelize);
db.Comment = require('./comment.model.js')(sequelize, Sequelize);
db.Favorite = require('./favorite.model.js')(sequelize, Sequelize);

// 设置关联关系
db.Comment.belongsTo(db.Artifact, {
    foreignKey: 'relic_id',
    as: 'artifact'
});

db.Comment.belongsTo(db.User, {
    foreignKey: 'user_id',
    as: 'user'
});

db.Artifact.hasMany(db.Comment, {
    foreignKey: 'relic_id',
    as: 'comments'
});

db.User.hasMany(db.Comment, {
    foreignKey: 'user_id',
    as: 'comments'
});

db.Favorite.belongsTo(db.Artifact, {
    foreignKey: 'artifactId',
    as: 'artifact'
});

db.Favorite.belongsTo(db.User, {
    foreignKey: 'userId',
    as: 'user'
});

db.User.hasMany(db.Favorite, {
    foreignKey: 'userId',
    as: 'favorites'
});

db.Artifact.hasMany(db.Favorite, {
    foreignKey: 'artifactId',
    as: 'favorites'
});

module.exports = db; 