/**
 * 帖子数据模型
 */
module.exports = (sequelize, Sequelize) => {
    const Post = sequelize.define("post_info", {
        post_id: {
            type: Sequelize.STRING,
            primaryKey: true,
            comment: '主键，帖子唯一标识'
        },
        content: {
            type: Sequelize.TEXT,
            allowNull: false,
            comment: '帖子内容'
        },
        post_img_url: {
            type: Sequelize.STRING,
            comment: '帖子图片地址'
        },
        likes: {
            type: Sequelize.INTEGER,
            allowNull: false,
            defaultValue: 0,
            comment: '点赞数'
        },
        is_favorited: {
            type: Sequelize.INTEGER,
            allowNull: false,
            defaultValue: 0,
            comment: '是否收藏(0:未收藏 1:已收藏)'
        },
        user_id: {
            type: Sequelize.INTEGER,
            allowNull: false,
            comment: '发帖用户ID'
        },
        nickname: {
            type: Sequelize.STRING,
            allowNull: false,
            comment: '发帖用户昵称'
        },
        img_url: {
            type: Sequelize.STRING,
            comment: '用户头像地址'
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
        tableName: 'post_info',
        timestamps: false,
        charset: 'utf8mb4',
        collate: 'utf8mb4_general_ci',
        indexes: [
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
    Post.associate = (models) => {
        Post.hasMany(models.Comment, {
            foreignKey: 'post_id',
            as: 'comments'
        });
    };

    return Post;
}; 