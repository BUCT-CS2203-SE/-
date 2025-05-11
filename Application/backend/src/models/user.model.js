/**
 * 用户数据模型
 */
module.exports = (sequelize, Sequelize) => {
    const User = sequelize.define("user_info", {
        user_id: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            autoIncrement: true,
            comment: '主键，用户唯一标识'
        },
        nickname: {
            type: Sequelize.STRING,
            allowNull: false,
            defaultValue: '用户',
            comment: '昵称'
        },
        gender: {
            type: Sequelize.INTEGER,
            defaultValue: 0,
            comment: '性别(0:默认 1:男 2:女)'
        },
        phone: {
            type: Sequelize.STRING,
            allowNull: false,
            unique: true,
            comment: '手机号，登录时使用（唯一）'
        },
        password: {
            type: Sequelize.STRING,
            allowNull: false,
            comment: '密码'
        },
        email: {
            type: Sequelize.STRING,
            allowNull: false,
            comment: '邮箱'
        },
        img_url: {
            type: Sequelize.STRING,
            defaultValue: 'https://tse1-mm.cn.bing.net/th/id/OIP-C.3dLZ4NXxxg03pzV30ITasAAAAA?rs=1&pid=ImgDetMain',
            comment: '头像地址'
        },
        spare: {
            type: Sequelize.STRING,
            comment: '备用字段'
        }
    }, {
        timestamps: false,
        tableName: 'user_info'
    });

    return User;
}; 