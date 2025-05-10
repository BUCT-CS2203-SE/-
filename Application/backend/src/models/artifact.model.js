/*
 * @Author: LokiYu 2915399378@qq.com
 * @Date: 2025-05-10 15:59:57
 * @LastEditors: LokiYu 2915399378@qq.com
 * @LastEditTime: 2025-05-10 16:57:55
 * @FilePath: \HandHeld_Museum_newframe\Application\backend\src\models\artifact.model.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
/**
 * 文物模型
 */
module.exports = (sequelize, Sequelize) => {
    const Artifact = sequelize.define("relic_info", {
        relic_id: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            autoIncrement: true,
            field: 'relic_id'
        },
        name: {
            type: Sequelize.STRING,
            allowNull: false,
            field: 'relic_name'
        },
        type: {
            type: Sequelize.INTEGER,
            defaultValue: 7,
            field: 'relic_type'
        },
        era: {
            type: Sequelize.STRING,
            field: 'relic_time'
        },
        museum: {
            type: Sequelize.STRING,
            allowNull: false,
            field: 'relic_loc'
        },
        description: {
            type: Sequelize.TEXT,
            allowNull: false,
            field: 'relic_intro'
        },
        spare_id: {
            type: Sequelize.INTEGER,
            defaultValue: 0,
            field: 'spare_id'
        }
    }, {
        tableName: 'relic_info',
        timestamps: false
    });

    return Artifact;
}; 