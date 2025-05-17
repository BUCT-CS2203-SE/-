/**
 * 用户浏览历史模型
 */
module.exports = (sequelize, Sequelize) => {
    const UserBrowse = sequelize.define("user_browse", {
        browse_id: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            autoIncrement: true,
            comment: '主键，浏览历史id，唯一标识'
        },
        relic_id: {
            type: Sequelize.INTEGER,
            allowNull: false,
            comment: '文物id,外键',
            references: {
                model: 'relic_info',
                key: 'relic_id'
            }
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
        browse_time: {
            type: Sequelize.DATE,
            allowNull: false,
            comment: '浏览时间'
        }
    }, {
        tableName: 'user_browse',
        timestamps: false, // 不使用 Sequelize 的默认时间戳
        charset: 'utf8mb4',
        collate: 'utf8mb4_general_ci'
    });

    // 定义关联关系
    UserBrowse.associate = (models) => {
        // 与文物信息表的关联
        UserBrowse.belongsTo(models.Artifact, {
            foreignKey: 'relic_id',
            as: 'relic'
        });
        
        // 与用户信息表的关联
        UserBrowse.belongsTo(models.User, {
            foreignKey: 'user_id',
            as: 'browseUser'
        });

        // 反向关联
        models.Artifact.hasMany(UserBrowse, {
            foreignKey: 'relic_id',
            as: 'relicBrowses'
        });

        models.User.hasMany(UserBrowse, {
            foreignKey: 'user_id',
            as: 'userBrowses'
        });
    };

    return UserBrowse;
}; 