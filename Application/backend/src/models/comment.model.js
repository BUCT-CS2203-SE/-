/**
 * 评论模型
 */
module.exports = (sequelize, Sequelize) => {
    const Comment = sequelize.define("comment", {
        id: {
            type: Sequelize.STRING,
            primaryKey: true
        },
        artifactId: {
            type: Sequelize.INTEGER,
            allowNull: false
        },
        userId: {
            type: Sequelize.STRING,
            allowNull: false
        },
        username: {
            type: Sequelize.STRING
        },
        avatarUrl: {
            type: Sequelize.STRING
        },
        content: {
            type: Sequelize.TEXT,
            allowNull: false
        },
        createTime: {
            type: Sequelize.STRING
        },
        createTimestamp: {
            type: Sequelize.DATE
        }
    }, {
        timestamps: true
    });

    return Comment;
}; 