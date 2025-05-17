/*
 * @Author: LokiYu 2915399378@qq.com
 * @Date: 2025-05-10 16:00:36
 * @LastEditors: LokiYu 2915399378@qq.com
 * @LastEditTime: 2025-05-10 22:06:39
 * @FilePath: \HandHeld_Museum_newframe\Application\backend\src\models\favorite.model.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
/**
 * 收藏模型
 */
module.exports = (sequelize, Sequelize) => {
    const RelicFavorite = sequelize.define("user_fav_relic", {
        fav_id: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            autoIncrement: true,
            comment: '主键，用户收藏id，唯一标识'
        },
        user_id: {
            type: Sequelize.INTEGER,
            allowNull: false,
            comment: '用户id,外键',
            references: {
                model: 'user_info',
                key: 'user_id'
            }
        },
        relic_id: {
            type: Sequelize.INTEGER,
            allowNull: false,
            comment: '文物id,外键',
            references: {
                model: 'relic_info',
                key: 'relic_id'
            }
        }
    }, {
        tableName: 'user_fav_relic',
        timestamps: false, // 不使用 Sequelize 的默认时间戳
        charset: 'utf8mb4',
        collate: 'utf8mb4_general_ci'
    });

    // 定义关联关系
    RelicFavorite.associate = (models) => {
        // 与文物信息表的关联
        RelicFavorite.belongsTo(models.Artifact, {
            foreignKey: 'relic_id',
            as: 'relic'
        });

        // 与用户信息表的关联
        RelicFavorite.belongsTo(models.User, {
            foreignKey: 'user_id',
            as: 'favoriteUser'
        });

        // 反向关联
        models.Artifact.hasMany(RelicFavorite, {
            foreignKey: 'relic_id',
            as: 'relicFavorites'
        });

        models.User.hasMany(RelicFavorite, {
            foreignKey: 'user_id',
            as: 'userFavorites'
        });
    };

    return RelicFavorite;
}; 