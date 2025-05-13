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
    // 定义文物图片模型
    const ArtifactPhoto = sequelize.define("relic_photo", {
        photo_id: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            autoIncrement: true,
            comment: '主键，文物图片id，唯一标识'
        },
        relic_id: {
            type: Sequelize.INTEGER,
            allowNull: false,
            comment: '关联文物id,外键',
            references: {
                model: 'relic_info',
                key: 'relic_id'
            }
        },
        photo_url: {
            type: Sequelize.STRING(255),
            allowNull: false,
            comment: '图片地址'
        }
    }, {
        tableName: 'relic_photo',
        timestamps: false,
        charset: 'utf8mb4',
        collate: 'utf8mb4_general_ci'
    });

    const Artifact = sequelize.define("relic_info", {
        relic_id: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            autoIncrement: true,
            comment: '主键，文物id，唯一标识'
        },
        name: {
            type: Sequelize.STRING(255),
            allowNull: false,
            field: 'relic_name',
            comment: '文物名称'
        },
        type: {
            type: Sequelize.INTEGER,
            defaultValue: 7,
            field: 'relic_type',
            comment: '文物类型(0-青铜器 1-陶瓷器 2-玉器 3-书画 4-货币 5-石器 6:雕塑 7:其他)'
        },
        era: {
            type: Sequelize.STRING(255),
            allowNull: true,
            field: 'relic_time',
            comment: '文物年代'
        },
        museum: {
            type: Sequelize.STRING(255),
            allowNull: false,
            field: 'relic_loc',
            comment: '文物所在地'
        },
        description: {
            type: Sequelize.TEXT,
            allowNull: false,
            field: 'relic_intro',
            comment: '文物介绍'
        },
        spare_id: {
            type: Sequelize.INTEGER,
            defaultValue: 0,
            field: 'spare_id',
            comment: '备用字段'
        }
    }, {
        tableName: 'relic_info',
        timestamps: false,
        charset: 'utf8mb4',
        collate: 'utf8mb4_general_ci'
    });

    // 建立关联关系
    Artifact.hasMany(ArtifactPhoto, {
        foreignKey: 'relic_id',
        as: 'photos'
    });
    
    ArtifactPhoto.belongsTo(Artifact, {
        foreignKey: 'relic_id',
        as: 'artifact'
    });

    // 将两个模型都导出
    return {
        Artifact,
        ArtifactPhoto
    };
}; 