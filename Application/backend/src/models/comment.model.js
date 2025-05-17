/**
 * 帖子评论模型
 */
module.exports = (sequelize, Sequelize) => {
    const Comment = sequelize.define("post_comment", {
        comment_id: {
            type: Sequelize.STRING,
            primaryKey: true,
            comment: '评论ID'
        },
        post_id: {
            type: Sequelize.STRING,
            allowNull: false,
            comment: '帖子ID',
            references: {
                model: 'post_info',
                key: 'post_id'
            }
        },
        user_id: {
            type: Sequelize.INTEGER,
            allowNull: false,
            comment: '评论用户ID'
        },
        nickname: {
            type: Sequelize.STRING,
            allowNull: false,
            comment: '评论用户昵称'
        },
        img_url: {
            type: Sequelize.STRING,
            comment: '评论用户头像'
        },
        content: {
            type: Sequelize.TEXT,
            allowNull: false,
            comment: '评论内容'
        },
        create_time: {
            type: Sequelize.STRING,
            allowNull: false,
            comment: '创建时间'
        },
        create_timestamp: {
            type: Sequelize.BIGINT,
            allowNull: false,
            defaultValue: 0,
            comment: '创建时间戳'
        }
    }, {
        tableName: 'post_comment',
        timestamps: false,
        charset: 'utf8mb4',
        collate: 'utf8mb4_general_ci',
        indexes: [
            {
                name: 'post_id_index',
                fields: ['post_id']
            },
            {
                name: 'user_id_index',
                fields: ['user_id']
            },
            {
                name: 'create_timestamp_index',
                fields: ['create_timestamp']
            }
        ]
    });

    // 添加关联关系
    Comment.associate = (models) => {
        Comment.belongsTo(models.Post, {
            foreignKey: 'post_id',
            as: 'post'
        });
    };

    return Comment;
}; 