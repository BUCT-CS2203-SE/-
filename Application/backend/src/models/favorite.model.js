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
    const Favorite = sequelize.define("favorite", {
        id: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        userId: {
            type: Sequelize.STRING,
            allowNull: false
        },
        artifactId: {
            type: Sequelize.INTEGER,
            allowNull: false
        }
    }, {
        timestamps: true
    });

    return Favorite;
}; 