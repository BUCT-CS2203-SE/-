/**
 * 文物评论模型
 */
module.exports = (sequelize, Sequelize) => {
    const Comment = sequelize.define("user_comment_relic", {
        relic_comment_id: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            autoIncrement: true,
            comment: '主键，文物评论id，唯一标识'
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
        comment: {
            type: Sequelize.TEXT,
            allowNull: false,
            comment: '评论内容，文字/图片'
        },
        comment_time: {
            type: Sequelize.DATE,
            allowNull: false,
            comment: '评论时间'
        }
    }, {
        tableName: 'user_comment_relic',
        timestamps: false, // 不使用 Sequelize 的默认时间戳
        charset: 'utf8mb4',
        collate: 'utf8mb4_general_ci'
    });

    // 定义关联关系
    Comment.associate = (models) => {
        // 与文物信息表的关联
        Comment.belongsTo(models.RelicInfo, {
            foreignKey: 'relic_id',
            as: 'relic'
        });
        
        // 与用户信息表的关联
        Comment.belongsTo(models.UserInfo, {
            foreignKey: 'user_id',
            as: 'user'
        });
    };

    return Comment;
}; 