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
db.RelicComment = require('./relic_comment.model.js')(sequelize, Sequelize);
db.RelicFavorite = require('./relic_favorite.model.js')(sequelize, Sequelize);
db.UserBrowse = require('./user_browse.model.js')(sequelize, Sequelize);

// 设置模型之间的关联关系
Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

module.exports = db; 